import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/research_progress_model.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_headers.dart';
import '../../domain/enums/research_status.dart';

abstract class LongResearchRemoteDatasource {
  Future<String> startResearch(Map<String, dynamic> body);

  /// WebSocket progress stream mapped to [ResearchProgressModel].
  Stream<ResearchProgressModel> watchProgress(String jobId);

  /// Send `{"type":"stop"}` on the active progress socket (if any).
  Future<void> sendStopCommand();

  /// Close the active progress WebSocket (optionally after [sendStopCommand]).
  Future<void> closeProgressWatch({bool sendStop = false});

  Future<Uint8List> downloadResearch(String jobId);
}

class LongResearchRemoteDatasourceImpl
    implements LongResearchRemoteDatasource {
  final Dio dio;

  static String get _httpBase =>
      '${ApiConfig.normalizedBaseUrl}/api/v1/research';

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _socketSubscription;
  StreamController<ResearchProgressModel>? _controller;

  /// Last full progress snapshot — used to attach live worker updates.
  ResearchProgressModel? _lastProgress;
  final Map<String, SubAgentStatusModel> _subAgents = {};

  LongResearchRemoteDatasourceImpl({required this.dio});

  /// POST /start → يعيد job_id
  @override
  Future<String> startResearch(Map<String, dynamic> body) async {
    final headers = await ApiHeaders.authenticatedAsync();
    final resp = await dio.post(
      '$_httpBase/start',
      data: body,
      options: Options(headers: headers),
    );
    return resp.data['job_id'] as String;
  }

  /// WS /ws/{job_id} → Stream of progress updates (BLoC-compatible).
  @override
  Stream<ResearchProgressModel> watchProgress(String jobId) {
    // Replace any previous socket without requesting stop on the old job.
    unawaited(closeProgressWatch(sendStop: false));
    _lastProgress = null;
    _subAgents.clear();

    final controller = StreamController<ResearchProgressModel>(
      onCancel: () async {
        await closeProgressWatch(sendStop: false);
      },
    );
    _controller = controller;

    final uri = _progressWsUri(jobId);
    final channel = WebSocketChannel.connect(uri);
    _channel = channel;

    () async {
      try {
        await channel.ready;
      } catch (e, st) {
        if (!controller.isClosed) {
          controller.addError(e, st);
          await controller.close();
        }
        await _teardownSocket();
        return;
      }

      if (_channel != channel || controller.isClosed) {
        try {
          await channel.sink.close();
        } catch (_) {}
        return;
      }

      _socketSubscription = channel.stream.listen(
        (raw) {
          final model = _mapSocketMessage(raw, jobId);
          if (model == null || controller.isClosed) return;
          controller.add(model);
          if (model.status.isTerminal) {
            unawaited(_finishTerminal(controller));
          }
        },
        onError: (Object e, StackTrace st) {
          if (!controller.isClosed) {
            controller.addError(e, st);
          }
        },
        onDone: () {
          if (!controller.isClosed) {
            unawaited(controller.close());
          }
          unawaited(_teardownSocket());
        },
        cancelOnError: false,
      );
    }();

    return controller.stream;
  }

  @override
  Future<void> sendStopCommand() async {
    final channel = _channel;
    if (channel == null) return;
    try {
      channel.sink.add(jsonEncode({'type': 'stop'}));
    } catch (_) {}
  }

  @override
  Future<void> closeProgressWatch({bool sendStop = false}) async {
    if (sendStop) {
      await sendStopCommand();
    }
    final controller = _controller;
    await _teardownSocket();
    if (controller != null && !controller.isClosed) {
      await controller.close();
    }
    if (identical(_controller, controller)) {
      _controller = null;
    }
  }

  /// GET /download/{job_id} → Uint8List
  @override
  Future<Uint8List> downloadResearch(String jobId) async {
    final headers = await ApiHeaders.authenticatedAsync();
    final resp = await dio.get(
      '$_httpBase/download/$jobId',
      options: Options(
        responseType: ResponseType.bytes,
        headers: headers,
      ),
    );
    return Uint8List.fromList(resp.data as List<int>);
  }

  // ── Internals ─────────────────────────────────────────────

  static Uri _progressWsUri(String jobId) {
    final httpBase = ApiConfig.normalizedBaseUrl;
    final wsBase = httpBase
        .replaceFirst(RegExp(r'^https://', caseSensitive: false), 'wss://')
        .replaceFirst(RegExp(r'^http://', caseSensitive: false), 'ws://');
    return Uri.parse('$wsBase/api/v1/research/ws/$jobId');
  }

  ResearchProgressModel? _mapSocketMessage(dynamic raw, String jobId) {
    try {
      final decoded = raw is String ? jsonDecode(raw) : raw;
      if (decoded is! Map) return null;
      final envelope = Map<String, dynamic>.from(decoded);
      final type = envelope['type'] as String?;
      final data = envelope['data'];
      if (type == null || data is! Map) return null;
      final payload = Map<String, dynamic>.from(data);

      if (type == 'subagent_status') {
        return _applySubAgentUpdate(jobId, payload);
      }

      switch (type) {
        case 'job_snapshot':
        case 'stage_changed':
        case 'section_progress':
        case 'complete':
        case 'error':
        case 'cancelled':
          payload.putIfAbsent('job_id', () => jobId);
          if (type == 'error') {
            payload.putIfAbsent('status', () => ResearchStatus.failed.name);
            payload.putIfAbsent(
              'current_step',
              () => payload['error_message']?.toString() ?? 'فشل إنشاء البحث',
            );
          }
          if (type == 'cancelled') {
            payload['status'] = ResearchStatus.cancelled.name;
            payload.putIfAbsent(
              'current_step',
              () =>
                  payload['error_message']?.toString() ??
                  'تم إيقاف البحث بواسطة المستخدم',
            );
          }
          if (type == 'complete') {
            payload.putIfAbsent('status', () => ResearchStatus.completed.name);
            payload.putIfAbsent('progress_pct', () => 100);
          }

          final model = ResearchProgressModel.fromJson(payload);
          // Clear workers once we leave the researching stage.
          if (model.status != ResearchStatus.researching) {
            _subAgents.clear();
          }
          final withAgents = model.copyWith(
            subAgents: _orderedSubAgents(),
          );
          _lastProgress = withAgents;
          return withAgents;
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  ResearchProgressModel _applySubAgentUpdate(
    String jobId,
    Map<String, dynamic> payload,
  ) {
    final agent = SubAgentStatusModel.fromWs(payload);
    _subAgents[agent.id] = agent;

    final base = _lastProgress ??
        ResearchProgressModel(
          jobId: jobId,
          status: ResearchStatus.researching,
          progressPct: 22,
          currentStep: agent.message,
          currentSection: agent.section,
          sectionsDone: 0,
          sectionsTotal: 0,
        );

    final updated = base.copyWith(
      status: ResearchStatus.researching,
      currentStep: agent.message.isNotEmpty ? agent.message : base.currentStep,
      currentSection: agent.section,
      subAgents: _orderedSubAgents(),
    );
    _lastProgress = updated;
    return updated;
  }

  List<SubAgentStatusModel> _orderedSubAgents() {
    final list = _subAgents.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  Future<void> _finishTerminal(
    StreamController<ResearchProgressModel> controller,
  ) async {
    await _teardownSocket();
    if (!controller.isClosed) {
      await controller.close();
    }
  }

  Future<void> _teardownSocket() async {
    final sub = _socketSubscription;
    _socketSubscription = null;
    await sub?.cancel();

    final channel = _channel;
    _channel = null;
    if (channel != null) {
      try {
        await channel.sink.close();
      } catch (_) {}
    }
  }
}

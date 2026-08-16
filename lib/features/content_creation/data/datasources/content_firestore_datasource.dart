import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/upload_orchestrator.dart';
import '../models/content_model.dart';

abstract class ContentFirestoreDataSource {
  Future<void> createContent(ContentModel content);
  Stream<List<ContentModel>> getContentsStream();
  Future<String> uploadReferenceFileAndLink(
    String contentId,
    File file, {
    Function(double)? onProgress,
  });
}

class ContentFirestoreDataSourceImpl implements ContentFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final UploadOrchestrator _uploadOrchestrator;

  ContentFirestoreDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required UploadOrchestrator uploadOrchestrator,
  })  : _firestore = firestore,
        _auth = auth,
        _uploadOrchestrator = uploadOrchestrator;

  @override
  Future<void> createContent(ContentModel content) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final contentWithUser = ContentModel(
      id: content.id,
      taskType: content.taskType,
      title: content.title,
      promptDetails: PromptDetailsModel(
        prompt: content.promptDetails.prompt,
        tone: content.promptDetails.tone,
        keywords: content.promptDetails.keywords,
        additionalContext: content.promptDetails.additionalContext,
      ),
      referenceFiles: content.referenceFiles,
      generatedText: content.generatedText,
      createdAt: content.createdAt ?? DateTime.now(),
      userId: currentUser.uid,
    );

    await _firestore
        .collection('contents')
        .doc(contentWithUser.id)
        .set(contentWithUser.toFirestore(), SetOptions(merge: true));
  }

  @override
  Stream<List<ContentModel>> getContentsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('contents')
        .where('user_id', isEqualTo: currentUser.uid)
        .orderBy('created_at', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ContentModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<String> uploadReferenceFileAndLink(
    String contentId,
    File file, {
    Function(double)? onProgress,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    return await _uploadOrchestrator.uploadAndTrack(
      file: file,
      collection: 'contents',
      docId: contentId,
      fieldName: 'reference_files',
      isArrayField: true,
      userId: currentUser.uid,
      onProgress: onProgress,
    );
  }
}

import 'package:equatable/equatable.dart';

class JournalMatch extends Equatable {
  final String journalId;
  final String journalName;
  final String quartile;
  final double apc;
  final double matchScore;

  const JournalMatch({
    required this.journalId,
    required this.journalName,
    required this.quartile,
    required this.apc,
    required this.matchScore,
  });

  @override
  List<Object?> get props => [
        journalId,
        journalName,
        quartile,
        apc,
        matchScore,
      ];
}

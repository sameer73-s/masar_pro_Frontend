// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'research_job_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResearchJobModelAdapter extends TypeAdapter<ResearchJobModel> {
  @override
  final int typeId = 10;

  @override
  ResearchJobModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResearchJobModel(
      jobId: fields[0] as String,
      title: fields[1] as String,
      statusName: fields[2] as String,
      downloadUrl: fields[3] as String,
      totalWords: fields[4] as int,
      sourcesCount: fields[5] as int,
      processingTimeSeconds: fields[6] as int,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ResearchJobModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.jobId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.statusName)
      ..writeByte(3)
      ..write(obj.downloadUrl)
      ..writeByte(4)
      ..write(obj.totalWords)
      ..writeByte(5)
      ..write(obj.sourcesCount)
      ..writeByte(6)
      ..write(obj.processingTimeSeconds)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResearchJobModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

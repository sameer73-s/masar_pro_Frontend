// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archived_order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArchivedOrderModelAdapter extends TypeAdapter<ArchivedOrderModel> {
  @override
  final int typeId = 21;

  @override
  ArchivedOrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArchivedOrderModel(
      id: fields[0] as String,
      studentId: fields[1] as String,
      orderType: fields[2] as String,
      title: fields[3] as String,
      status: fields[4] as String,
      fileUrls: (fields[5] as List).cast<String>(),
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ArchivedOrderModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.orderType)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.fileUrls)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArchivedOrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

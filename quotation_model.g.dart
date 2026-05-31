// lib/data/models/quotation_model.g.dart

part of 'quotation_model.dart';

class QuotationModelAdapter extends TypeAdapter<QuotationModel> {
  @override
  final int typeId = 2;

  @override
  QuotationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuotationModel(
      id:          fields[0] as String,
      missionId:   fields[1] as String,
      title:       fields[2] as String,
      vendor:      fields[3] as String,
      amount:      fields[4] as double,
      description: fields[5] as String?,
      isWinner:    fields[6] as bool,
      createdAt:   fields[7] as DateTime,
      contactInfo: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QuotationModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.missionId)
      ..writeByte(2)..write(obj.title)
      ..writeByte(3)..write(obj.vendor)
      ..writeByte(4)..write(obj.amount)
      ..writeByte(5)..write(obj.description)
      ..writeByte(6)..write(obj.isWinner)
      ..writeByte(7)..write(obj.createdAt)
      ..writeByte(8)..write(obj.contactInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuotationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

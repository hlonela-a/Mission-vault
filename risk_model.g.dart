// lib/data/models/risk_model.g.dart

part of 'risk_model.dart';

class RiskModelAdapter extends TypeAdapter<RiskModel> {
  @override
  final int typeId = 3;

  @override
  RiskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RiskModel(
      id:          fields[0] as String,
      missionId:   fields[1] as String,
      title:       fields[2] as String,
      impact:      fields[3] as String,
      mitigation:  fields[4] as String,
      status:      fields[5] as String,
      createdAt:   fields[6] as DateTime,
      description: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RiskModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.missionId)
      ..writeByte(2)..write(obj.title)
      ..writeByte(3)..write(obj.impact)
      ..writeByte(4)..write(obj.mitigation)
      ..writeByte(5)..write(obj.status)
      ..writeByte(6)..write(obj.createdAt)
      ..writeByte(7)..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// lib/data/models/mission_model.g.dart
// HAND-WRITTEN Hive adapter (no build_runner required)

part of 'mission_model.dart';

class MissionModelAdapter extends TypeAdapter<MissionModel> {
  @override
  final int typeId = 0;

  @override
  MissionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MissionModel(
      id:               fields[0]  as String,
      name:             fields[1]  as String,
      destination:      fields[2]  as String,
      description:      fields[3]  as String?,
      departureDate:    fields[4]  as DateTime?,
      returnDate:       fields[5]  as DateTime?,
      budgetAllocated:  fields[6]  as double,
      currency:         fields[7]  as String,
      travelersCount:   fields[8]  as int,
      status:           fields[9]  as String,
      createdAt:        fields[10] as DateTime,
      coverEmoji:       fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MissionModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.destination)
      ..writeByte(3)..write(obj.description)
      ..writeByte(4)..write(obj.departureDate)
      ..writeByte(5)..write(obj.returnDate)
      ..writeByte(6)..write(obj.budgetAllocated)
      ..writeByte(7)..write(obj.currency)
      ..writeByte(8)..write(obj.travelersCount)
      ..writeByte(9)..write(obj.status)
      ..writeByte(10)..write(obj.createdAt)
      ..writeByte(11)..write(obj.coverEmoji);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

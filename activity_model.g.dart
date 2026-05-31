// lib/data/models/activity_model.g.dart

part of 'activity_model.dart';

class ActivityModelAdapter extends TypeAdapter<ActivityModel> {
  @override
  final int typeId = 5;

  @override
  ActivityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityModel(
      id:             fields[0] as String,
      missionId:      fields[1] as String,
      title:          fields[2] as String,
      scheduledDate:  fields[3] as DateTime?,
      time:           fields[4] as String?,
      cost:           fields[5] as double?,
      location:       fields[6] as String?,
      notes:          fields[7] as String?,
      isCompleted:    fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.missionId)
      ..writeByte(2)..write(obj.title)
      ..writeByte(3)..write(obj.scheduledDate)
      ..writeByte(4)..write(obj.time)
      ..writeByte(5)..write(obj.cost)
      ..writeByte(6)..write(obj.location)
      ..writeByte(7)..write(obj.notes)
      ..writeByte(8)..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

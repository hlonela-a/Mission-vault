// lib/data/models/packing_item_model.g.dart

part of 'packing_item_model.dart';

class PackingItemModelAdapter extends TypeAdapter<PackingItemModel> {
  @override
  final int typeId = 4;

  @override
  PackingItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PackingItemModel(
      id:        fields[0] as String,
      missionId: fields[1] as String,
      name:      fields[2] as String,
      isPacked:  fields[3] as bool,
      category:  fields[4] as String,
      quantity:  fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PackingItemModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.missionId)
      ..writeByte(2)..write(obj.name)
      ..writeByte(3)..write(obj.isPacked)
      ..writeByte(4)..write(obj.category)
      ..writeByte(5)..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PackingItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// lib/data/models/expense_model.g.dart

part of 'expense_model.dart';

class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final int typeId = 1;

  @override
  ExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseModel(
      id:         fields[0] as String,
      missionId:  fields[1] as String,
      title:      fields[2] as String,
      amount:     fields[3] as double,
      category:   fields[4] as String,
      date:       fields[5] as DateTime,
      notes:      fields[6] as String?,
      paidBy:     fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.missionId)
      ..writeByte(2)..write(obj.title)
      ..writeByte(3)..write(obj.amount)
      ..writeByte(4)..write(obj.category)
      ..writeByte(5)..write(obj.date)
      ..writeByte(6)..write(obj.notes)
      ..writeByte(7)..write(obj.paidBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

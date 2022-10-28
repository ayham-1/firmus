// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 1;

  @override
  Item read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Item(
      label: fields[2] as String,
      type: fields[1] as ItemViewType,
      packageName: fields[0] as String,
      contactID: fields[3] as String,
      openCount: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.contactID)
      ..writeByte(4)
      ..write(obj.openCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemViewTypeAdapter extends TypeAdapter<ItemViewType> {
  @override
  final int typeId = 2;

  @override
  ItemViewType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemViewType.app;
      case 1:
        return ItemViewType.contact;
      default:
        return ItemViewType.app;
    }
  }

  @override
  void write(BinaryWriter writer, ItemViewType obj) {
    switch (obj) {
      case ItemViewType.app:
        writer.writeByte(0);
        break;
      case ItemViewType.contact:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemViewTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

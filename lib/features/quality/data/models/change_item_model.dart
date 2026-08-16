import '../../domain/entities/change_item.dart';

class ChangeItemModel extends ChangeItem {
  const ChangeItemModel({
    required super.original,
    required super.replacement,
    required super.category,
  });

  factory ChangeItemModel.fromJson(Map<String, dynamic> json) {
    return ChangeItemModel(
      original: json['original'] as String,
      replacement: json['replacement'] as String,
      category: json['category'] as String,
    );
  }
}

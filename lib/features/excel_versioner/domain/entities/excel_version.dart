import 'package:equatable/equatable.dart';

class ExcelVersion extends Equatable {
  final String name;
  final String url;

  const ExcelVersion({required this.name, required this.url});

  @override
  List<Object?> get props => [name, url];
}

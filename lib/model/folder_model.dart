class FolderModel {
  FolderModel({
    required this.title,
  });

  String title;

  factory FolderModel.fromJson(Map<String, dynamic> json) =>
      FolderModel(title: json['Title'] as String);

  FolderModel copyWith({String? title}) {
    return FolderModel(
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Title'] = title;

    return data;
  }

  @override
  String toString() => 'FolderModel{title: $title}';

  @override
  bool operator ==(Object other) {
    if (other is FolderModel) {
      return title == other.title;
    }
    return false;
  }

  @override
  int get hashCode => title.hashCode;
}

extension FolderModelExt on FolderModel {}

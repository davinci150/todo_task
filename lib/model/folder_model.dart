class FolderModel {
  FolderModel({
    required this.title,
    required this.createdOn,
  });

  String? title;
  DateTime? createdOn;

  FolderModel.fromJson(Map<String, dynamic> json) {
    title = json['Title'] as String;
    createdOn = json['CreatedOn'] is int
        ? DateTime.fromMillisecondsSinceEpoch(json['CreatedOn'] as int)
        : null;
  }

  FolderModel copyWith({String? title, DateTime? createdOn}) {
    return FolderModel(
      title: title ?? this.title,
      createdOn: createdOn ?? this.createdOn,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Title'] = title;
    data['CreatedOn'] = createdOn?.millisecondsSinceEpoch;

    return data;
  }

  @override
  String toString() => 'FolderModel{title: $title, createdOn: $createdOn}';
}

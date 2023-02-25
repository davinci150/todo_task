class BirthdayModel {
  BirthdayModel({
    required this.name,
    required this.birthday,
  });

  String name;
  DateTime birthday;

  factory BirthdayModel.fromJson(Map<String, dynamic> json) => BirthdayModel(
        name: json['Name'] as String,
        birthday: DateTime.parse(json['Birthday'] as String),
      );

  BirthdayModel copyWith({String? name, DateTime? birthday}) {
    return BirthdayModel(
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Name'] = name;
    data['Birthday'] = birthday.toIso8601String();

    return data;
  }

  @override
  String toString() =>
      'BirthdayModel{name: $name, birthday: ${birthday.toIso8601String()}}';

  @override
  bool operator ==(Object other) {
    if (other is BirthdayModel) {
      return name == other.name && birthday == other.birthday;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode ^ birthday.hashCode;
}

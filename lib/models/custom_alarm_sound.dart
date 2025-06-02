class CustomAlarmSound {
  final String name;
  final String filePath;

  CustomAlarmSound({required this.name, required this.filePath});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'filePath': filePath,
    };
  }

  factory CustomAlarmSound.fromJson(Map<String, dynamic> json) {
    return CustomAlarmSound(
      name: json['name'] as String,
      filePath: json['filePath'] as String,
    );
  }
}

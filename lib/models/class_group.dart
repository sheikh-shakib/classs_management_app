class ClassGroup {
  final String id;
  final String name;
  final String? crId; //class representative id

  ClassGroup({
    required this.id,
    required this.name,
    this.crId,
  });

  factory ClassGroup.fromMap(Map<String, dynamic> map) {
    return ClassGroup(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      crId: map['crId'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'crId': crId,
    };
  }
}
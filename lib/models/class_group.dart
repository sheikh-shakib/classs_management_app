class ClassGroup {
  final String id;
  final String name;
  final String creatorId; //teacher who created the group
  final String? crId; //class representative id

  ClassGroup({
    required this.id,
    required this.name,
    required this.creatorId,
    this.crId,
  });

  factory ClassGroup.fromMap(Map<String, dynamic> map) {
    return ClassGroup(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      creatorId: map['creatorId'] ?? '',
      crId: map['crId'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'creatorId': creatorId,
      'crId': crId,
    };
  }
}
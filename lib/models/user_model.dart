// enum for roles of users
enum UserRole { student, cr, teacher }
//usermodel class
 class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? groupId;
  //constructor
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.groupId,
  });

  //factory constructor to load data from firebase map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${map['role']}',
        orElse: () => UserRole.student,
      ),
      groupId: map['groupId'],
    );
  }
  //convert usermodel to map for firebase store
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'groupId': groupId,
    };
  }
} 
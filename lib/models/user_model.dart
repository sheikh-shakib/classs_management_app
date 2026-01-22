//user models defines here using oop classses concept
enum UserRole { student, cr, teacher }
 class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? groupId;
  

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.groupId,
  });
//factory constructor to create UserModel from map from database
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${map['role']}',
        orElse: () => UserRole.student,
      ),
      groupId: map['groupId'] ?? '',
    );
  }
//method to convert UserModel to map for database storage
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
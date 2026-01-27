import '../models/class_group.dart';
import '../models/user_model.dart';

final List<UserModel> mockUsers = [
  UserModel(
    id: 't1',
    name: 'Dr.  Johnson',
    email: 'dr.johnson@example.com',
    role: UserRole.teacher,
  ),
  UserModel(
    id: 't2',
    name: 'Dr. Smith',
    email: 'dr.smith@example.com',
    role: UserRole.teacher,
  ),
  UserModel(
    id: 't3',
    name: 'Alice Johnson',
    email: 'alice.johnson@example.com',
    role: UserRole.teacher,
  ),
  UserModel(
    id: 't4',
    name: 'Bob Brown',
    email: 'bob.brown@example.com',
    role: UserRole.teacher,
  ),
  UserModel(
    id: 't5',
    name: 'Charlie Davis',
    email: 'charlie.davis@example.com',
    role: UserRole.teacher,
  ),
  UserModel(
    id: 's1',
    name: 'Emily Clark',
    email: 'emily.clark@example.com',
    role: UserRole.student,
    groupId: 'g1',
  ),
  UserModel(
    id: 's2',
    name: 'Michael Lee',
    email: 'michael.lee@example.com',
    role: UserRole.student,
    groupId: 'g2',
  ),
  UserModel(
    id: 's3',
    name: 'Sarah Wilson',
    email: 'sarah.wilson@example.com',
    role: UserRole.student,
    groupId: 'g3',
  ),
  UserModel(
    id: 'c1',
    name: 'David Martinez',
    email: 'david.martinez@example.com',
    role: UserRole.cr,
    groupId: 'g1',

  ),
  UserModel(
    id: 'c2',
    name: 'Sophia Garcia',
    email: 'sophia.garcia@example.com',
    role: UserRole.cr,
    groupId: 'g2',
  ),
  UserModel(
    id: 'c3',
    name: 'James Wilson',
    email: 'james.wilson@example.com',
    role: UserRole.cr,
    groupId: 'g3',
  ),
];

final List<ClassGroup> mockClassGroups = [
  ClassGroup(
    id: 'g1',
    name: 'cse_2022 Group',
    creatorId: 't1',
    crId: 'u1',
  ),
  ClassGroup(
    id: 'g2',
    name: 'cse_2023 Group',
    creatorId: 't2',
    crId: 'u2',
  ),
  ClassGroup(
    id: 'g3',
    name: 'cse_2024 Group',
    creatorId: 't3',
    crId: 'u3',
  ),
];
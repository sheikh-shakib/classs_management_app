import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //login user with email and password
  //returns UserModel if successful
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        return null;
      }
      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  //log out current user
  Future<void> logout() async {
    await _auth.signOut();
  }
  //get current user
  Future<UserModel?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    final userDoc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (!userDoc.exists) {
      return null;
    }
    return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
  }
  //register new user with email and password
  Future<UserModel?> register({
  required String name,
  required String id,
  required String email,
  required String password,
  required UserRole role,
  String? groupId,
}) async {
  try {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = cred.user!.uid;
    final user = UserModel(
      id: id,
      name: name,
      email: email,
      role: role,
      groupId: groupId,
    );
    await _firestore.collection('users').doc(uid).set(user.toMap());
    return user;
  } catch (e) {
    return null;
  }
}
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //LOGIN USING EMAIL AND PASSWORD
  //returns UserModel if successful, null otherwise
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      //CHECK with firebase auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //GET FIREBASE USER ID
      String uid = userCredential.user!.uid;
      //FETCH USER DATA FROM FIRESTORE
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        return null;
      }
      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  //log out current user
  Future<void> logout() async {
    await _auth.signOut();
  }
  //get curret user details 
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
}


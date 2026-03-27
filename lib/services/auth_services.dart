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
      //the function here tries to sign in the user with provided email and pass word
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //if successful it gets the uid of the user
      String uid = userCredential.user!.uid;
      //then it fetches the user document from firestore using the uid
      final userDoc = await _firestore.collection('users').doc(uid).get();
      //if no user document exists it returns null

      if (!userDoc.exists) {
        return null;
      }
      //if found , converts the user document data to UserModel and returns it
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
    //if the user is logged in, it auto fetches the user document from firestore
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
  // the group id is optional because teachers may not have it
  String? groupId,
}) async {
  try {
    //first it creates a new user in firebase auth with the provided email and password
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
   //then it gets the uid of the newly created user , ! means it must not be null
    String uid = cred.user!.uid;
    //creates a new user in docs in firestore
    final user = UserModel(
      id: id,
      name: name,
      email: email,
      role: role,
      groupId: groupId,
    );
    //saves the user document in firestore with the uid as the document id
    await _firestore.collection('users').doc(uid).set(user.toMap());
    //returns the created user for auto login after regis
    return user;
  } catch (e) {
    return null;
  }
}
}


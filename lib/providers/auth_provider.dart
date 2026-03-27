import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_services.dart';
//notify listener comes from the changeNotifier
//notifylisteners is used to tell the UI to rebuild when some change is made in the provider
class AuthProvider with ChangeNotifier {
  final AuthServices _authServices = AuthServices();
  UserModel? _user;
  bool _isLoading = false;
  //get is used to access the private variables outside the provider
  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  //login
  Future<bool> login({required String email, required String password}) async {
    //loading true to show a loading indicator in the UI while the login process is happening
    _isLoading = true;
    notifyListeners();
    final user = await _authServices.login(email: email, password: password);
    //if login is successful, the user variable is set to the logged in user and loading is set to false and UI is notified to rebuild
    if (user != null) {
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    }
    //if login fails, loading is set to false and UI is notified to rebuild accordingly
    _isLoading = false;
    notifyListeners();
    return false;
  }

  //logout
  Future<void> logout() async {
    //logs out the user and notifies the UI to rebuild with no user logged in
    await _authServices.logout();
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  //register
  Future<bool> register({
    required String name,
    required String id,
    required String email,
    required String password,
    required UserRole role,
    String? groupId,
  }) async {
    //loading true to show a loading indicator in the UI while the registration process is happening
    _isLoading = true;
    notifyListeners();
    //calls the register function in auth services to create a new user with the provided details from front end
    final result = await _authServices.register(
      name: name,
      id: id,
      email: email,
      password: password,
      role: role,
      groupId: groupId,
    );
    //loading finished
    _isLoading = false;
    //makes decision based on the result of the registration process
    if (result != null) {
      _user = result;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }
}

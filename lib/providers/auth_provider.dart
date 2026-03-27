import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_services.dart';

class AuthProvider with ChangeNotifier {
  final AuthServices _authServices = AuthServices();

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  //login
  Future<bool> login({required String email, required String password}) 
  async {
    _isLoading = true;
    notifyListeners();

    final user = await _authServices.login(email: email, password: password);
    if (user != null) {
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  //logout
  Future<void> logout() async {
    await _authServices.logout();
    _user = null;
    _isLoading = false;
    notifyListeners();
  }
  Future<bool> register({
  required String name,
  required String id,
  required String email,
  required String password,
  required UserRole role,
  String? groupId,
}) async {
  _isLoading = true;
  notifyListeners();

  final result = await _authServices.register(
    name: name,
    id: id,
    email: email,
    password: password,
    role: role,
    groupId: groupId,
  );

  _isLoading = false;

  if (result != null) {
    _user = result;
    notifyListeners();
    return true;
  }

  notifyListeners();
  return false;
}
}
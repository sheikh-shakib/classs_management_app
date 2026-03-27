import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final group = TextEditingController();
  final id = TextEditingController();

  UserRole role = UserRole.student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 30),

              _field("Name", name),
              const SizedBox(height: 12),
              _field("UniqueId", id),
              const SizedBox(height: 12),
              _field("Email", email),
              const SizedBox(height: 12),
              _field("Password", password, obscure: true),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                value: role,
                dropdownColor: const Color(0xFF1C1F2E),
                decoration: _inputDecoration("Role"),
                items: UserRole.values.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(
                      r.toString().split('.').last,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => role = v!),
              ),

              const SizedBox(height: 12),

              //group selection
              if (role != UserRole.teacher)
                _field("Group ID", group),

              const SizedBox(height: 20),

              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              final success = await auth.register(
                                name: name.text.trim(),
                                id: id.text.trim(),
                                email: email.text.trim(),
                                password: password.text.trim(),
                                role: role,
                                groupId: role == UserRole.teacher
                                    ? null
                                    : group.text.trim(),
                              );

                              if (success) {
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Registration failed")),
                                );
                              }
                            },
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Register"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String hint, TextEditingController c,
      {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF1C1F2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
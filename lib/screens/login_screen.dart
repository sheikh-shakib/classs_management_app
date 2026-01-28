import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/login.png"),fit: BoxFit.cover,)
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 150,left: 15),
              child: Text("Welcome to \n Classroom Manager",style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.w600),),
            ),
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*.40),
                padding: EdgeInsets.all(10),
                child: Column(children: [
                  Text("Login",style: TextStyle(fontSize: 25,fontWeight: FontWeight.w600)),
                  SizedBox(height: 40,),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fillColor: Colors.grey.shade100,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 15,),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fillColor: Colors.grey.shade100,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 20,),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return ElevatedButton(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                final email = _emailController.text.trim();
                                final password = _passwordController.text.trim();

                                if (email.isEmpty || password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Email and password are required"),
                                    ),
                                  );
                                  return;
                                }

                                final success = await auth.login(
                                  email: email,
                                  password: password,
                                );

                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Login successful ✅"),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Login failed ❌"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }

                              },
                        child: auth.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      );
                    },
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height*.18,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    TextButton(onPressed: (){Navigator.pushNamed(context, "register");}, child: Text("Sign Up")),
                    TextButton(onPressed: (){}, child: Text("Forgot Password")),
                  ],)
              ]),
              ),
            )
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();      
  }
}
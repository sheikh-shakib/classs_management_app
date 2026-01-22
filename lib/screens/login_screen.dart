import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                  TextField(decoration: InputDecoration(hintText: "Email",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  )
                  ), 
                  SizedBox(height: 15,),
                  TextField(obscureText: true,decoration: InputDecoration(hintText: "Password",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  )
                  ), 
                  SizedBox(height: 20,),
                  ElevatedButton(onPressed: (){}, child: Text("Login",style: TextStyle(fontWeight: FontWeight.w600),),style:ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 88, 191, 231),
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                  ),),
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
}
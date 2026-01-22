import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/register.png"),fit: BoxFit.cover,)
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 100,left: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text("Welcome to",style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.w600),),
                Text("Classroom Manager",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600),),
                Text("A class management assistant",style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w600),),
              ],)
            ),
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*.35),
                padding: EdgeInsets.all(10),
                child: Column(children: [
                  Text("Register",style: TextStyle(fontSize: 25,fontWeight: FontWeight.w600)),
                  SizedBox(height: 20,),
                  TextField(decoration: InputDecoration(hintText: "Email",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  )
                  ), 
                  SizedBox(height: 15,),
                  TextField(decoration: InputDecoration(hintText: "Phone Number",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                  SizedBox(height: 15,),
                  TextField(obscureText: true,decoration: InputDecoration(hintText: "Confirm Password",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  )
                  ), 
                  SizedBox(height: 20,),
                  ElevatedButton(onPressed: (){}, child: Text("Sign Up",style: TextStyle(fontWeight: FontWeight.w600),),style:ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 67, 151, 247),
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                  ),),
                  SizedBox(height: 80,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    TextButton(onPressed: (){Navigator.pushNamed(context, "login");}, child: Text("Login")),
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
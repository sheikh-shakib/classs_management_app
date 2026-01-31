import 'package:class_management_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  signOut()async{
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Routine"),
        backgroundColor: const Color.fromARGB(255, 147, 214, 253),
        actions: [
          Padding(
            padding: EdgeInsets.all(
              10,
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.person
              ),
              color: Colors.black
            ),
          ),
        ],
        ),
        drawer: NavigationDrawer(
          children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 50),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text("Welcome to Classroom Manager")
            ),
          ),
          Divider(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: ListTile(
                  leading: Icon(Icons.home),
                  title: Text("Home Page"),
                  onTap: () {
                    
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: ListTile(
                  leading: Icon(Icons.schedule),
                  title: Text("Class Schedule"),
                  onTap: () {
                    
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Dashboard"),
                  onTap: () {
                    
                  },
                ),
              ),
            ),
            Divider(),
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.center,
                leading: Icon(Icons.logout),
                title: Text("Logout"),
                onTap: () {
                  signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                },
              ),
            ),
          ),
          ],
        )
    );
  }
}
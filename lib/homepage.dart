// homepage.dart
import 'package:bucket_list_with_firebase/activatedList.dart';
import 'package:bucket_list_with_firebase/auth_service.dart';
import 'package:bucket_list_with_firebase/bucket_service.dart';
import 'package:bucket_list_with_firebase/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'todoList.dart';
import 'graph.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController jobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser()!;
    return Consumer<BucketService>(
      builder: (context, bucketService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "투두핑",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                child: const Text(
                  "로그아웃",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  context.read<AuthService>().signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ],
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 187, 236),
                    Color.fromARGB(255, 169, 201, 255),
                  ],
                  begin: Alignment(-0.766, -0.643),
                  end: Alignment(0.766, 0.643),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                TodoList(userId: user.uid),
                ActivatedList(userId: user.uid),
                const Text(
                  "Today's Task Completion",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Graph(userId: user.uid),
                SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

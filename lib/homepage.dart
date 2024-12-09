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
import 'graph.dart'; // 추가된 위젯 import

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
            backgroundColor: const Color.fromARGB(255, 88, 165, 232),
            title: const Text("버킷 리스트"),
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
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                TodoList(userId: user.uid),
                ActivatedList(userId: user.uid),
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

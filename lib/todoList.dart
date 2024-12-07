import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'bucket_service.dart';

class TodoList extends StatefulWidget {
  final String userId;

  TodoList({required this.userId});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    final bucketService = context.watch<BucketService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Today Tasks",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Consumer<BucketService>(
          builder: (context, bucketService, child) {
            return FutureBuilder<QuerySnapshot>(
              future: bucketService.bucketCollection
                  .where('uid', isEqualTo: widget.userId)
                  .where('isActivate', isEqualTo: true)
                  .get(),
              builder: (context, snapshot) {
                final documents = snapshot.data?.docs ?? [];
                if (documents.isEmpty) {
                  return Center(child: Text("오늘의 할 일을 추가해주세요."));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    String job = doc.get('job');
                    bool isDone = doc.get('isDone');

                    return Container(
                      margin: EdgeInsets.only(bottom: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          job,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Checkbox(
                          value: !isDone,
                          onChanged: (value) {
                            bucketService.update(doc.id, isDone: !value!);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

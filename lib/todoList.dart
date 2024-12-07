import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'bucket_service.dart';
import 'dart:core';

class TodoList extends StatefulWidget {
  final String userId;

  TodoList({required this.userId});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> with TickerProviderStateMixin {
  bool _isExpanded = true; // 리스트의 확장 상태를 관리

  @override
  Widget build(BuildContext context) {
    final bucketService = context.watch<BucketService>();
    DateTime now = DateTime.now();
    int today = now.weekday; // 오늘의 요일 (1=월요일, 7=일요일)

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today Tasks",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.5, // 아이콘 회전 애니메이션
                  duration: Duration(milliseconds: 300),
                  child: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 30,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded; // 리스트 확장 상태 전환
                  });
                },
              ),
            ],
          ),
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded // 리스트가 확장된 경우만 표시
                ? Consumer<BucketService>(
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
                              List<int> week = List<int>.from(doc.get('week'));

                              // 오늘 요일과 저장된 요일이 일치하지 않으면 표시하지 않음
                              if (!week.contains(today)) {
                                return Container();
                              }

                              int color = doc.get('color');
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
                                  leading: Container(
                                    width: 8,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color(color),
                                      borderRadius: BorderRadius.circular(
                                          8), // 원하는 반지름 값 설정
                                    ),
                                  ),
                                  title: Text(
                                    job,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isDone ? Colors.grey : Colors.black,
                                      decoration: isDone
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  trailing: Checkbox(
                                    value: isDone,
                                    onChanged: (value) {
                                      bucketService.update(doc.id,
                                          isDone: value!);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'bucket_service.dart';

class TodoList extends StatefulWidget {
  final String userId;
  final TextEditingController jobController;

  TodoList({required this.userId, required this.jobController});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward(); // 펼치기 애니메이션 실행
      } else {
        _controller.reverse(); // 접기 애니메이션 실행
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bucketService = context.watch<BucketService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "To Do",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tomorrow Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _heightAnimation, // 애니메이션 적용
          axis: Axis.vertical, // 세로 방향으로 슬라이드
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Consumer<BucketService>(
              builder: (context, bucketService, child) {
                return FutureBuilder<QuerySnapshot>(
                  future: bucketService.read(widget.userId),
                  builder: (context, snapshot) {
                    final documents = snapshot.data?.docs ?? [];
                    if (documents.isEmpty) {
                      return Center(child: Text("버킷 리스트를 작성해주세요."));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), // 내부 스크롤 방지
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
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 5,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            title: Text(
                              job,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: isDone ? Colors.grey : Colors.black,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(CupertinoIcons.delete),
                              onPressed: () {
                                bucketService.delete(doc.id);
                              },
                            ),
                            onTap: () {
                              bucketService.update(doc.id, isDone: !isDone);
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.center, // 중앙 정렬
          child: ElevatedButton(
            child: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("추가할 todo 리스트"),
                    content: Container(
                      height: 100,
                      child: TextField(
                        controller: widget.jobController,
                        decoration: InputDecoration(
                          hintText: "add list",
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text("add"),
                        onPressed: () {
                          if (widget.jobController.text.isNotEmpty) {
                            // 추가할 정보를 설정
                            String job = widget.jobController.text;
                            String info = ""; // 기본 값으로 설정
                            bool isActivate = false; // 기본 값으로 설정
                            int color = Colors.grey.value; // 기본 색상
                            List<int> week = []; // 빈 주간 정보

                            bucketService.create(
                              job,
                              widget.userId,
                              info: info,
                              isActivate: isActivate,
                              color: color,
                              week: week,
                            );
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

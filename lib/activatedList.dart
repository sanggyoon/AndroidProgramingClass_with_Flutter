import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'bucket_service.dart';

class ActivatedList extends StatefulWidget {
  final String userId;

  const ActivatedList({Key? key, required this.userId}) : super(key: key);

  @override
  _ActivatedListState createState() => _ActivatedListState();
}

class _ActivatedListState extends State<ActivatedList> {
  TextEditingController jobController = TextEditingController();
  TextEditingController infoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bucketService = context.watch<BucketService>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Activate Task",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: bucketService.bucketCollection
                  .where('uid', isEqualTo: widget.userId)
                  .get(),
              builder: (context, snapshot) {
                final documents = snapshot.data?.docs ?? [];
                if (documents.isEmpty) {
                  return Center(child: Text("활성화된 리스트가 없습니다."));
                }
                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    String job = doc.get('job');
                    bool isActivate = doc.get('isActivate');

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
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        trailing: CupertinoSwitch(
                          value: isActivate,
                          onChanged: (value) {
                            bucketService.update(doc.id, isActivate: value);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                _showAddTaskModal(context, bucketService);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 4),
                  Text("Add Task"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskModal(BuildContext context, BucketService bucketService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("새로운 Task 추가"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: jobController,
                      decoration: InputDecoration(hintText: "제목 입력"),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: infoController,
                      decoration: InputDecoration(hintText: "정보 입력"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("취소"),
                ),
                TextButton(
                  onPressed: () {
                    if (jobController.text.isNotEmpty) {
                      bucketService.create(
                        jobController.text,
                        widget.userId,
                        info: infoController.text,
                        isActivate: false,
                        color: 0xFFFFFF, // 기본 색상 값 필요
                        week: [], // 기본 주간 값 필요
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Text("추가"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

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

class _ActivatedListState extends State<ActivatedList>
    with TickerProviderStateMixin {
  TextEditingController jobController = TextEditingController();
  TextEditingController infoController = TextEditingController();

  // 선택된 요일과 색상 상태를 관리
  List<int> selectedDays = [];
  Color? selectedColor;
  bool _isExpanded = true; // 기본적으로 리스트가 펼쳐진 상태

  @override
  Widget build(BuildContext context) {
    final bucketService = context.watch<BucketService>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Activate Task",
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
            child: _isExpanded
                ? FutureBuilder<QuerySnapshot>(
                    future: bucketService.bucketCollection
                        .where('uid', isEqualTo: widget.userId)
                        .get(),
                    builder: (context, snapshot) {
                      final documents = snapshot.data?.docs ?? [];
                      if (documents.isEmpty) {
                        return Center(child: Text("활성화된 리스트가 없습니다."));
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final doc = documents[index];
                          String job = doc.get('job');
                          bool isActivate = doc.get('isActivate');
                          int colorValue = doc.get('color');
                          String? info = doc.get('info');

                          Color taskColor = Color(colorValue);

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
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    width: 8,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: taskColor,
                                      borderRadius: BorderRadius.circular(
                                          8), // 원하는 반지름 값 설정
                                    ),
                                  ),
                                  title: Text(
                                    job,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: info != null && info.isNotEmpty
                                      ? Text(
                                          info,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54),
                                        )
                                      : null, // info가 null이거나 비어 있으면 subtitle을 표시하지 않음
                                  trailing: CupertinoSwitch(
                                    value: isActivate,
                                    onChanged: (value) {
                                      bucketService.update(doc.id,
                                          isActivate: value);
                                    },
                                    activeColor: taskColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  )
                : SizedBox.shrink(),
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
                      decoration: InputDecoration(hintText: "제목 입력(필수)"),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: infoController,
                      decoration: InputDecoration(hintText: "정보 입력(선택)"),
                    ),
                    SizedBox(height: 16),
                    Text("요일 선택"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selectedDays.contains(index + 1)) {
                                selectedDays.remove(index + 1);
                              } else {
                                selectedDays.add(index + 1);
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: selectedDays.contains(index + 1)
                                  ? Colors.blue.withOpacity(0.3)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ["M", "T", "W", "T", "F", "S", "S"][index],
                              style: TextStyle(
                                fontSize: 16,
                                color: selectedDays.contains(index + 1)
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 16),
                    Text("색상 선택"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ColorPickerTile(Colors.red, selectedColor,
                              (color) {
                            setState(() {
                              selectedColor = color;
                            });
                          }),
                        ),
                        SizedBox(width: 8), // 요소 사이 간격
                        Expanded(
                          child: ColorPickerTile(Colors.orange, selectedColor,
                              (color) {
                            setState(() {
                              selectedColor = color;
                            });
                          }),
                        ),
                        SizedBox(width: 8), // 요소 사이 간격
                        Expanded(
                          child: ColorPickerTile(Colors.yellow, selectedColor,
                              (color) {
                            setState(() {
                              selectedColor = color;
                            });
                          }),
                        ),
                        SizedBox(width: 8), // 요소 사이 간격
                        Expanded(
                          child: ColorPickerTile(Colors.green, selectedColor,
                              (color) {
                            setState(() {
                              selectedColor = color;
                            });
                          }),
                        ),
                        SizedBox(width: 8), // 요소 사이 간격
                        Expanded(
                          child: ColorPickerTile(Colors.blue, selectedColor,
                              (color) {
                            setState(() {
                              selectedColor = color;
                            });
                          }),
                        ),
                        SizedBox(width: 8), // 요소 사이 간격
                        Expanded(
                          child: ColorPickerTile(Colors.purple, selectedColor,
                              (color) {
                            setState(() {
                              selectedColor = color;
                            });
                          }),
                        ),
                        SizedBox(width: 8), // 요소 사이 간격
                        Expanded(
                          child: ColorPickerTile(Colors.grey, selectedColor,
                              (color) {
                            setState(() {
                              selectedColor = color;
                            });
                          }),
                        ),
                      ],
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
                    if (jobController.text.isNotEmpty &&
                        selectedDays.isNotEmpty &&
                        selectedColor != null) {
                      bucketService.create(
                        jobController.text,
                        widget.userId,
                        info: infoController.text,
                        isActivate: false,
                        color: selectedColor!.value,
                        week: selectedDays,
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

class ColorPickerTile extends StatelessWidget {
  final Color color;
  final Color? selectedColor;
  final Function(Color) onSelect;

  ColorPickerTile(this.color, this.selectedColor, this.onSelect);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelect(color);
      },
      child: Container(
        width: 40,
        height: 40,
        color: color,
        child: Center(
          child: selectedColor == color
              ? Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                )
              : null,
        ),
      ),
    );
  }
}

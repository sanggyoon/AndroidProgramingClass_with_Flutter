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
  final TextEditingController jobController = TextEditingController();
  final TextEditingController infoController = TextEditingController();
  List<int> selectedDays = [];
  Color? selectedColor;
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final bucketService = context.watch<BucketService>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildTaskList(bucketService),
          _buildAddTaskButton(context, bucketService),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Activate Task",
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: AnimatedRotation(
            turns: _isExpanded ? 0 : 0.5,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 30,
            ),
          ),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTaskList(BucketService bucketService) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _isExpanded
          ? FutureBuilder<QuerySnapshot>(
              future: bucketService.bucketCollection
                  .where('uid', isEqualTo: widget.userId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final documents = snapshot.data?.docs ?? [];
                if (documents.isEmpty) {
                  return const Center(child: Text("활성화된 리스트가 없습니다."));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    return _buildTaskTile(doc, bucketService);
                  },
                );
              },
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildTaskTile(
      QueryDocumentSnapshot doc, BucketService bucketService) {
    String job = doc.get('job');
    String? info = doc.get('info');
    bool isActivate = doc.get('isActivate');
    int colorValue = doc.get('color');
    Color taskColor = Color(colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 8,
          height: 30,
          decoration: BoxDecoration(
            color: taskColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        title: Text(
          job,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: info != null && info.isNotEmpty
            ? Text(
                info,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              )
            : null,
        trailing: CupertinoSwitch(
          value: isActivate,
          onChanged: (value) {
            bucketService.update(doc.id, isActivate: value);
          },
          activeColor: taskColor,
        ),
        onLongPress: () {
          _confirmDeleteTask(context, doc.id, bucketService);
        },
      ),
    );
  }

  Widget _buildAddTaskButton(
      BuildContext context, BucketService bucketService) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          _showAddTaskModal(context, bucketService);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add),
            SizedBox(width: 4),
            Text("Add Task"),
          ],
        ),
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
              title: const Text("새로운 Task 추가"),
              content: _buildAddTaskForm(setState),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소"),
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
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("추가"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAddTaskForm(Function setState) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: jobController,
            decoration: const InputDecoration(hintText: "제목 입력 (필수)"),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: infoController,
            decoration: const InputDecoration(hintText: "정보 입력 (선택)"),
          ),
          const SizedBox(height: 16),
          _buildWeekdaySelector(setState),
          const SizedBox(height: 16),
          _buildColorPicker(setState),
        ],
      ),
    );
  }

  Widget _buildWeekdaySelector(Function setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("요일 선택"),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
      ],
    );
  }

  Widget _buildColorPicker(Function setState) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.grey,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("색상 선택"),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: colors
              .map(
                (color) => GestureDetector(
                  onTap: () {
                    setState(() => selectedColor = color);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selectedColor == color
                            ? Colors.black
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

void _confirmDeleteTask(
    BuildContext context, String taskId, BucketService bucketService) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("정말 삭제하시겠습니까?"),
        content: Text("이 작업은 되돌릴 수 없습니다."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("취소"),
          ),
          TextButton(
            onPressed: () {
              bucketService.delete(taskId);
              Navigator.pop(context);
            },
            child: Text(
              "삭제",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

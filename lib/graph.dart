import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bucket_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Graph extends StatelessWidget {
  final String userId;

  const Graph({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bucketService = context.read<BucketService>();
    DateTime now = DateTime.now();
    int today = now.weekday;

    return FutureBuilder<QuerySnapshot>(
      future: bucketService.bucketCollection
          .where('uid', isEqualTo: userId)
          .where('isActivate', isEqualTo: true)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("오늘 활성화된 작업이 없습니다."));
        }

        final docs = snapshot.data!.docs.where((doc) {
          List<int> week = List<int>.from(doc['week']);
          return week.contains(today);
        }).toList();

        int totalTasks = docs.length;
        int doneTasks = docs.where((doc) => doc['isDone'] == true).length;

        double completionRate = totalTasks > 0 ? doneTasks / totalTasks : 0;

        String message;
        if (completionRate <= 0.25) {
          message = '열심히 하세요!';
        } else if (completionRate <= 0.5) {
          message = '조금 더 노력하세요!';
        } else if (completionRate <= 0.75) {
          message = '잘하고 있습니다!';
        } else {
          message = '완벽합니다!';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(150, 150),
                        painter: CircleGraphPainter(completionRate),
                      ),
                      Text(
                        "${(completionRate * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class CircleGraphPainter extends CustomPainter {
  final double completionRate;

  CircleGraphPainter(this.completionRate);

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 12.0;
    final double radius = (size.width - strokeWidth) / 2;

    final Paint backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint foregroundPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blue, Colors.green],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), radius, backgroundPaint);

    double sweepAngle = 2 * 3.141592653589793 * completionRate;
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), radius: radius),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

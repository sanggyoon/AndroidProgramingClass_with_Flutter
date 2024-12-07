import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BucketService extends ChangeNotifier {
  final bucketCollection = FirebaseFirestore.instance.collection('bucket');

  Future<QuerySnapshot> read(String uid) async {
    // 오늘 날짜 구하기
    DateTime now = DateTime.now();
    String today = "${now.year}-${now.month}-${now.day}";

    // 오늘 날짜에 해당하는 bucketList 가져오기
    return bucketCollection
        .where('uid', isEqualTo: uid)
        .where('createdAt', isEqualTo: today)
        .get();
  }

  void create(
    String job,
    String uid, {
    required String info,
    required bool isActivate,
    required int color,
    required List<int> week,
  }) async {
    // 오늘 날짜 구하기
    DateTime now = DateTime.now();
    String today = "${now.year}-${now.month}-${now.day}";

    // bucket 만들기
    await bucketCollection.add({
      'uid': uid, // 유저 식별자
      'job': job, // 하고싶은 일
      'isDone': false, // 완료 여부
      'createdAt': today, // 생성 날짜
      'isRepeat': false, // 반복 여부
      'color': color, // 리스트 색상
      'week': week, // 주간 정보
      'isActivate': isActivate, // 활성화 여부
      'info': info, // 추가 정보
    });
    notifyListeners(); // 화면 갱신
  }

  void update(
    String docId, {
    bool? isDone,
    bool? isRepeat,
    String? job,
    String? info,
    int? color,
    List<int>? week,
    bool? isActivate,
  }) async {
    Map<String, dynamic> updateData = {};

    if (isDone != null) updateData['isDone'] = isDone;
    if (isRepeat != null) updateData['isRepeat'] = isRepeat;
    if (job != null) updateData['job'] = job;
    if (info != null) updateData['info'] = info;
    if (color != null) updateData['color'] = color;
    if (week != null) updateData['week'] = week;
    if (isActivate != null) updateData['isActivate'] = isActivate;

    // 업데이트할 데이터가 있는 경우만 Firestore에 적용
    if (updateData.isNotEmpty) {
      await bucketCollection.doc(docId).update(updateData);
      notifyListeners(); // 화면 갱신
    }
  }

  void delete(String docId) async {
    // bucket 삭제
    await bucketCollection.doc(docId).delete();
    notifyListeners(); // 화면 갱신
  }
}

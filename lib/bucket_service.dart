import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BucketService extends ChangeNotifier {
  final bucketCollection = FirebaseFirestore.instance.collection('bucket');

  Future<QuerySnapshot> read(String uid) async {
    DateTime now = DateTime.now();
    String today = "${now.year}-${now.month}-${now.day}";

    return bucketCollection
        .where('uid', isEqualTo: uid)
        .where('createdAt', isEqualTo: today)
        .get();
  }

  Future<void> resetIsDone(String uid) async {
    DateTime now = DateTime.now();
    String today = "${now.year}-${now.month}-${now.day}";

    QuerySnapshot snapshot = await bucketCollection
        .where('uid', isEqualTo: uid)
        .where('createdAt', isEqualTo: today)
        .get();

    for (var doc in snapshot.docs) {
      await bucketCollection.doc(doc.id).update({'isDone': false});
    }
  }

  void create(
    String job,
    String uid, {
    required String info,
    required bool isActivate,
    required int color,
    required List<int> week,
  }) async {
    DateTime now = DateTime.now();
    String today = "${now.year}-${now.month}-${now.day}";

    await bucketCollection.add({
      'uid': uid,
      'job': job,
      'isDone': false,
      'createdAt': today,
      'color': color,
      'week': week,
      'isActivate': isActivate,
      'info': info,
    });
    notifyListeners();
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

    if (updateData.isNotEmpty) {
      await bucketCollection.doc(docId).update(updateData);
      notifyListeners();
    }
  }

  void delete(String docId) async {
    await bucketCollection.doc(docId).delete();
    notifyListeners();
  }
}

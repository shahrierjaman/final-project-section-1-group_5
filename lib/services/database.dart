import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addExpDetails(Map<String, dynamic> expanseInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Expanse")
        .doc(id)
        .set(expanseInfoMap);
  }

  Future<Stream<QuerySnapshot>> getEmpDetails() async {
    return await FirebaseFirestore.instance.collection("Expanse").snapshots();
  }

  Future saveUserDetails(String uid, Map<String, dynamic> userInfo) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .set(userInfo);
  }
}

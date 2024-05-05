import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // collaction refrence..
  final CollectionReference userCollaction =
      FirebaseFirestore.instance.collection('user');
  final CollectionReference groupCollaction =
      FirebaseFirestore.instance.collection('groups');

  // add or update user to database

  Future SaveUserData(String username, String email) async {
    return await userCollaction.doc(uid).set({
      "username": username,
      "email": email,
      "groups": [],
      "profile": "",
      "uid": uid,
    });
  }

  Future getUSerData(String email) async {
    QuerySnapshot snapshot =
        await userCollaction.where("email", isEqualTo: email).get();
    return snapshot;
  }

  getUserGroup() async {
    return userCollaction.doc(uid).snapshots();
  }

  getMember(String groupId) async {
    return groupCollaction.doc(groupId).snapshots();
  }

  //cracte grops

  Future createGropus(String userName, String id, String grpName) async {
    DocumentReference groupDocumentReference = await groupCollaction.add({
      "groupName": grpName,
      "groupIcon": '',
      "admin": "${id}_$userName",
      "members": [],
      "groupId": '',
      "recentMesaage": '',
      "recentMessageSender": ''
    });

    //update member and id

    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${id}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    //update user grp

    DocumentReference userDocumentReference = userCollaction.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$grpName"]),
    });
  }

  getChats(String groupId) {
    return groupCollaction
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  Future getAdmin(String groupId) async {
    DocumentReference d = groupCollaction.doc(groupId);
    DocumentSnapshot docsnap = await d.get();
    return docsnap['admin'];
  }

//grp search

  searchByName(String groupName) {
    return groupCollaction.where('groupName', isEqualTo: groupName).get();
  }

//is joined grp or not

  Future<bool> isUserJoined(String groupId, String groupName) async {
    DocumentReference userDocumentReference = userCollaction.doc(uid);
    DocumentSnapshot doc = await userDocumentReference.get();

    List<dynamic> grps = await doc['groups'];
    if (grps.contains("${groupId}_${groupName}")) {
      return true;
    } else {
      return false;
    }
  }

// join or exit from group

  Future toggleGroupJoin(
      String groupId, String groupName, String userName) async {
    DocumentReference userRef = userCollaction.doc(uid);
    DocumentReference grpRef = groupCollaction.doc(groupId);

    DocumentSnapshot docSnap = await userRef.get();
    List<dynamic> grps = await docSnap['groups'];

    if (grps.contains("${groupId}_$groupName")) {
      await userRef.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"]),
      });
      await grpRef.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"]),
      });
    } else {
      await userRef.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"]),
      });
      await grpRef.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      });
    }
  }

  Future exitGroup(String groupId, String groupName, String userName) async {
    DocumentReference userRef = userCollaction.doc(uid);
    DocumentReference grpRef = groupCollaction.doc(groupId);
    await userRef.update({
      "groups": FieldValue.arrayRemove(["${groupId}_$groupName"]),
    });
    await grpRef.update({
      "members": FieldValue.arrayRemove(["${uid}_$userName"]),
    });
  }

//mesaage sending

  sendMessage(String groupId, Map<String, dynamic> messageData) async {
    groupCollaction.doc(groupId).collection('messages').add(messageData);
    groupCollaction.doc(groupId).update({
      "recentMesaage": messageData['message'],
      "recentMessageSender": messageData['sender'],
      "time": messageData['time'].toString()
    });
  }
}

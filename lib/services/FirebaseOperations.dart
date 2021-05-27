import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reddit/screens/landingpage/landingUtils.dart';
import 'package:reddit/services/Authentication.dart';

class FirebaseOperations with ChangeNotifier{

  UploadTask imageUploadTask;
  String initUserName, initUserEmail, initUserImage;

  String get getInitUserName => initUserName;
  String get getInitUserEmail => initUserEmail;
  String get getInitUserImage => initUserImage;

  Future uploadUserAvatar(BuildContext context) async {
    Reference imageReference = FirebaseStorage.instance.ref().child(
      'userProfileAvatar/${Provider.of<LandingUtils>(context, listen: false).getUserAvatar.path}/${TimeOfDay.now()}');
    imageUploadTask = imageReference.putFile(Provider.of<LandingUtils>(context, listen: false).getUserAvatar);
    await imageUploadTask.whenComplete(() {
    });
    imageReference.getDownloadURL().then((url){
      Provider.of<LandingUtils>(context, listen: false).userAvatarUrl = url.toString();
      notifyListeners();
    });
  }

  Future createUserCollection(BuildContext context, dynamic data) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
        .set(data);
  }
  
  Future initUserData(BuildContext context) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
        .get()
        .then((doc) {
          initUserName = doc.data()['username'];
          initUserEmail = doc.data()['useremail'];
          initUserImage = doc.data()['userimage'];
          notifyListeners();
    });
  }

  Future uploadPostData(String postId, dynamic data) async {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .set(data);
  }

  Future deleteUserData(String userUid, dynamic collection) async{
    return FirebaseFirestore.instance.collection(collection).doc(userUid).delete();
  }

  Future addAward(String postId, dynamic data) async{
    return FirebaseFirestore.instance.collection('posts').doc(postId).collection('awards').add(data);
  }

  Future updateCaption(String postId, dynamic data) async{
    return FirebaseFirestore.instance.collection('posts').doc(postId).update(data);
  }

  Future followUser(String followingUid, String followingDocId, dynamic followingData,
      String followerUid, String followerDocId, dynamic followerData) async{
    return FirebaseFirestore.instance.collection('users')
        .doc(followingUid).collection('followers')
        .doc(followingDocId).set(followingData)
        .whenComplete(() async {
          return FirebaseFirestore.instance.collection('users')
              .doc(followerUid).collection('following')
              .doc(followerDocId).set(followerData);
    });
  }
  
  Future submitChatRoomData(String chatRoomName, dynamic chatRoomData) async{
    return FirebaseFirestore.instance.collection('chatrooms')
        .doc(chatRoomName).set(chatRoomData);
  }

}
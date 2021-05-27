import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reddit/screens/stories/stories_widgets.dart';
import 'package:reddit/services/Authentication.dart';
import 'package:reddit/services/FirebaseOperations.dart';
import 'package:timeago/timeago.dart' as timeago;

class StoriesHelpers with ChangeNotifier{
  UploadTask imageUploadTask;
  final picker = ImagePicker();
  File storyImage;
  File get getStoryImage => storyImage;
  final StoriesWidgets storiesWidgets = StoriesWidgets(); 
  String storyImageUrl;
  String get getStoryImageUrl => storyImageUrl;
  String storyTime;
  String get getStoryTime => storyTime;
  String lastSeenTime;
  String get getLastSeenTime => lastSeenTime;
  String storyHighlightIcon;
  String get getStoryHighlightIcon => storyHighlightIcon;

  Future selectStoryImage(BuildContext context, ImageSource source) async{
    final pickStoryImage = await picker.getImage(source: source);
    pickStoryImage == null
        ? print('Error')
        : storyImage = File(pickStoryImage.path);
    storyImage != null
        ? storiesWidgets.previewStoryImage(context, storyImage)
        : print('Error');
    notifyListeners();
  }

  Future uploadStoryImage(BuildContext context) async{
    Reference imageReference = FirebaseStorage.instance.ref()
        .child('stories/${getStoryImage.path}/${Timestamp.now()}');
    imageUploadTask = imageReference.putFile(getStoryImage);
    await imageUploadTask.whenComplete(() {
      print('Upload successful');
    });
    imageReference.getDownloadURL().then((url) {
      storyImageUrl = url;

    });
    notifyListeners();
  }

  Future convertHighlightIcons(String firestoreImageUrl) async{
    storyHighlightIcon = firestoreImageUrl;
    notifyListeners();
  }

  Future addStoryToNewAlbum(BuildContext context, String userUid, String highlightName, String storyImage) async{
    return FirebaseFirestore.instance.collection('users')
        .doc(userUid).collection('highlights')
        .doc(highlightName).set({
          'title': highlightName,
          'cover': storyHighlightIcon
    }).whenComplete(() {
      return FirebaseFirestore.instance.collection('users')
          .doc(userUid).collection('highlights')
          .doc(highlightName).collection('stories')
          .add({
            'image': getStoryImageUrl,
            'username':Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
            'userimage':Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,

      });
    });
  }

  Future addStoryToExistingAlbum(BuildContext context, String userUid, String highlightColId, String storyImage) async{
    return FirebaseFirestore.instance.collection('users')
        .doc(userUid).collection('highlights')
        .doc(highlightColId).collection('stories')
        .add({
          'image': storyImage,
          'username': Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
          'userimage': Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,

    });
  }

  storyTimePosted(dynamic timeData){
    Timestamp timestamp = timeData;
    DateTime dateTime = timestamp.toDate();
    storyTime = timeago.format(dateTime);
    lastSeenTime = timeago.format(dateTime);
  }

  Future addSeenStamp(BuildContext context, String storyId, String personId, DocumentSnapshot documentSnapshot) async{
    if(documentSnapshot['useruid'] != Provider.of<Authentication>(context, listen: false).getUserUid){
      return FirebaseFirestore.instance.collection('stories')
          .doc(storyId).collection('seen')
          .doc(personId).set({
            'time': Timestamp.now(),
            'username': Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
            'userimage': Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,
            'useruid': Provider.of<Authentication>(context, listen: false).getUserUid
      });
    }
  }

}
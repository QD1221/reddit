import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/screens/feed/feed.dart';
import 'package:reddit/screens/homepage/homePage.dart';
import 'package:reddit/services/Authentication.dart';
import 'package:reddit/services/FirebaseOperations.dart';

class UploadPost with ChangeNotifier{

  TextEditingController captionController = TextEditingController();
  ConstantColors constantColors = ConstantColors();
  File uploadPostImage;
  File get getUploadPostImage => uploadPostImage;
  String uploadPostImageUrl;
  String get getUploadPostImageUrl => uploadPostImageUrl;
  final picker = ImagePicker();
  UploadTask imagePostUploadTask;

  Future pickUploadPostImage(BuildContext context, ImageSource source) async {
    final uploadPostImageVal = await picker.getImage(source: source);
    uploadPostImageVal == null ? print('Select image') : uploadPostImage = File(uploadPostImageVal.path);

    uploadPostImage != null
        ? showPostImage(context)
        : print('Image upload error');

    notifyListeners();
  }

  Future uploadPostImageToFirebase() async {
    Reference imageReference = FirebaseStorage.instance.ref().child(
      'posts/${uploadPostImage.path}/${TimeOfDay.now()}'
    );
    imagePostUploadTask = imageReference.putFile(uploadPostImage);
    await imagePostUploadTask.whenComplete(() {
    });
    imageReference.getDownloadURL().then((imageUrl) {
      uploadPostImageUrl = imageUrl;
    });
    notifyListeners();
  }

  selectPostImageType(BuildContext context){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.blueGreyColor,
          borderRadius: BorderRadius.circular(12)
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150),
              child: Divider(
                thickness: 4,
                color: constantColors.whiteColor,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              MaterialButton(
                color: constantColors.blueColor,
                child: Text(
                  'Gallery',
                  style: TextStyle(
                    color: constantColors.whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
                onPressed: (){
                  pickUploadPostImage(context, ImageSource.gallery);
                },
              ),
              MaterialButton(
                color: constantColors.blueColor,
                child: Text(
                  'Camera',
                  style: TextStyle(
                      color: constantColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                  ),
                ),
                onPressed: (){
                  pickUploadPostImage(context, ImageSource.camera);
                },
              ),
            ],)
          ],
        ),
      );
    });
  }
  showPostImage(BuildContext context){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: constantColors.darkColor,
            borderRadius: BorderRadius.circular(12)
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150),
              child: Divider(
                thickness: 4,
                color: constantColors.whiteColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child: Container(
                height: 200,
                width: 400,
                child: Image.file(uploadPostImage, fit: BoxFit.contain,),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                MaterialButton(
                  child: Text(
                    'Reselect', style: TextStyle(
                      color: constantColors.whiteColor, fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: constantColors.whiteColor
                  ),
                  ),
                  onPressed: (){
                    selectPostImageType(context);
                  },
                ),
                MaterialButton(
                  color: constantColors.blueColor,
                  child: Text(
                    'Confirm image', style: TextStyle(
                    color: constantColors.whiteColor,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                  onPressed: (){
                    uploadPostImageToFirebase().whenComplete(() {
                      editPostSheet(context);
                    });
                  },
                )
              ],),
            )
          ],
        ),
      );
    });
  }

  editPostSheet(BuildContext context){
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      builder: (context){
        return Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: Divider(
                  thickness: 4,
                  color: constantColors.whiteColor,
                ),
              ),
              Container(
                child: Row(
                  children: [
                    Container(
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.image_aspect_ratio,
                              color: constantColors.greenColor,),
                            onPressed: (){

                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.fit_screen,
                              color: constantColors.yellowColor,),
                            onPressed: (){

                            },
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 200,
                      width: 300,
                      child: Image.file(uploadPostImage, fit: BoxFit.contain,),
                    )
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.asset('assets/icons/sunflower.png'),
                    ),
                    Container(
                      height: 110,
                      width: 5,
                      color: constantColors.blueColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        height: 120,
                        width: 300,
                        child: TextField(
                          maxLines: 5,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(100)
                          ],
                          maxLengthEnforced: true,
                          maxLength: 100,
                          controller: captionController,
                          style: TextStyle(
                            color: constantColors.whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          ),
                          decoration: InputDecoration(
                            hintText: 'Add a caption...',
                            hintStyle: TextStyle(
                              color: constantColors.whiteColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              MaterialButton(
                child: Text(
                  'Share',
                  style: TextStyle(
                    color: constantColors.whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
                onPressed: () async {
                  Provider.of<FirebaseOperations>(context, listen: false)
                      .uploadPostData(captionController.text, {
                        'postimage': getUploadPostImageUrl,
                        'caption': captionController.text,
                        'username': Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
                        'userimage': Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,
                        'useruid': Provider.of<Authentication>(context, listen: false).getUserUid,
                        'time': Timestamp.now(),
                        'useremail': Provider.of<FirebaseOperations>(context, listen: false).getInitUserEmail,

                  }).whenComplete(() async{
                    //Add data under user profile
                    return FirebaseFirestore.instance.collection('users')
                        .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
                        .collection('posts').add({
                      'postimage': getUploadPostImageUrl,
                      'caption': captionController.text,
                      'username': Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
                      'userimage': Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,
                      'useruid': Provider.of<Authentication>(context, listen: false).getUserUid,
                      'time': Timestamp.now(),
                      'useremail': Provider.of<FirebaseOperations>(context, listen: false).getInitUserEmail,
                    });
                  }).whenComplete(() {
                    Navigator.pop(context);
                  });
                },
                color: constantColors.blueColor,
              )
            ],
          ),
          height: MediaQuery.of(context).size.height * 0.75,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: constantColors.blueGreyColor,
            borderRadius: BorderRadius.circular(12)
          ),
        );
      }
    );
  }

}
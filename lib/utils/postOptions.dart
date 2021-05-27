import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/screens/altprofile/altProfile.dart';
import 'package:reddit/services/Authentication.dart';
import 'package:reddit/services/FirebaseOperations.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostFunctions with ChangeNotifier{
  TextEditingController commentController = TextEditingController();
  ConstantColors constantColors = ConstantColors();
  String imageTimePosted;
  String get getImageTimePosted => imageTimePosted;
  TextEditingController updateCaptionController = TextEditingController();

  showTimeAgo(dynamic timedata){
    Timestamp time = timedata;
    DateTime dateTime = time.toDate();
    imageTimePosted = timeago.format(dateTime);
  }

  showPostOptions(BuildContext context, String postId){
    return showModalBottomSheet(context: context, isScrollControlled: true, builder: (context){
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      color: constantColors.blueColor,
                      child: Text(
                        'Edit caption',
                        style: TextStyle(
                          color: constantColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                      onPressed: (){
                        showModalBottomSheet(context: context, builder: (context){
                          return Container(
                            child: Center(
                              child: Row(
                                children: [
                                  Container(
                                    width: 300,
                                    height: 50,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Add new caption',
                                        hintStyle: TextStyle(
                                          color: constantColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16
                                        )
                                      ),
                                      style: TextStyle(
                                          color: constantColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16
                                      ),
                                      controller: updateCaptionController,
                                    ),
                                  ),
                                  FloatingActionButton(
                                    backgroundColor: constantColors.redColor,
                                    child: Icon(
                                      FontAwesomeIcons.fileUpload,
                                      color: constantColors.whiteColor,
                                    ),
                                    onPressed: (){
                                      // Provider.of<FirebaseOperations>(context, listen: false).updateCaption(postId, {
                                      //   'caption': updateCaptionController.text
                                      // }).whenComplete(() {
                                      //   Navigator.pop(context);
                                      // });
                                    },
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    ),
                    MaterialButton(
                      color: constantColors.redColor,
                      child: Text(
                        'Delete post',
                        style: TextStyle(
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                      onPressed: (){
                        showDialog(
                          context: context,
                          builder: (context){
                            return AlertDialog(
                              backgroundColor: constantColors.darkColor,
                              title: Text(
                                'Delete this post?',
                                style: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              actions: [
                                MaterialButton(
                                  child: Text(
                                    'No',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor: constantColors.whiteColor,
                                      color: constantColors.whiteColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                    ),
                                  ),
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                ),
                                MaterialButton(
                                  color: constantColors.redColor,
                                  child: Text(
                                    'Yes',
                                    style: TextStyle(
                                      color: constantColors.whiteColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                    ),
                                  ),
                                  onPressed: (){
                                    Provider.of<FirebaseOperations>(context, listen: false)
                                        .deleteUserData(postId,'posts')
                                        .whenComplete(() {
                                          Navigator.pop(context);
                                    });
                                  },
                                ),
                              ],
                            );
                          });
                      },
                    )
                  ],
                ),
              )
            ],
          ),
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: constantColors.blueGreyColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12)
            )
          ),
        ),
      );
    });
  }

  Future addLike(BuildContext context, String postId, String subDocId) async{
    return FirebaseFirestore.instance.collection('posts')
        .doc(postId).collection('likes')
        .doc(subDocId).set({
          'likes': FieldValue.increment(1),
          'username': Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
          'useruid': Provider.of<Authentication>(context, listen: false).getUserUid,
          'userimage': Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,
          'useremail': Provider.of<FirebaseOperations>(context, listen: false).getInitUserEmail,
          'time': Timestamp.now()
    });
  }
  
  Future addComment(BuildContext context, String postId, String comment) async{
    await FirebaseFirestore.instance.collection('posts')
        .doc(postId).collection('comments')
        .doc(comment).set({
          'comment': comment,
          'username': Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
          'useruid': Provider.of<Authentication>(context, listen: false).getUserUid,
          'userimage': Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,
          'useremail': Provider.of<FirebaseOperations>(context, listen: false).getInitUserEmail,
          'time': Timestamp.now()
    });
  }

  showAwardsPresenter(BuildContext context, String postId){
    return showModalBottomSheet(context: context, isScrollControlled: true, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
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
              padding: EdgeInsets.only(top: 8),
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                    border: Border.all(color: constantColors.whiteColor),
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Center(
                  child: Text(
                    'Award Socialites',
                    style: TextStyle(
                        color: constantColors.blueColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
            Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts').doc(postId)
                      .collection('awards').orderBy('time').snapshots(),
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    else{
                      return new ListView(
                        children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                          return ListTile(
                            leading: GestureDetector(
                              onTap: (){
                                if(documentSnapshot['useruid'] != Provider.of<Authentication>(context, listen: false).getUserUid){
                                  Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                          child: AltProfile(
                                            userUid: documentSnapshot['useruid'],
                                          ),
                                          type: PageTransitionType.bottomToTop
                                      )
                                  );
                                }
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  documentSnapshot['userimage']
                                ),
                                radius: 15,
                                backgroundColor: constantColors.darkColor,
                              ),
                            ),
                            trailing: Provider.of<Authentication>(context, listen: false).getUserUid
                                == documentSnapshot['useruid']
                                ? Container(width: 0, height: 0,)
                                : MaterialButton(
                              child: Text(
                                'Follow',
                                style: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14
                                ),
                              ),
                              onPressed: (){},
                              color: constantColors.blueColor,
                            ),
                            title: Text(
                              documentSnapshot['username'],
                              style: TextStyle(
                                color: constantColors.blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                )
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: constantColors.blueGreyColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))
        ),
      );
    });
  }

  showCommentsSheet(BuildContext context, DocumentSnapshot snapshot, String docId){
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context){
        return Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
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
                  padding: EdgeInsets.only(top: 8),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: constantColors.whiteColor),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Center(
                      child: Text(
                        'Comments',
                        style: TextStyle(
                          color: constantColors.blueColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('posts').doc(docId)
                        .collection('comments').orderBy('time').snapshots(),
                    builder: (context, snapshot){
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      else{
                        return new ListView(
                          children: snapshot.data.docs
                            .map((DocumentSnapshot documentSnapshot) {
                              return Container(
                                height: MediaQuery.of(context).size.height * 0.15,
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16),
                                          child: GestureDetector(
                                            onTap: (){
                                              if(documentSnapshot['useruid'] != Provider.of<Authentication>(context, listen: false).getUserUid){
                                                Navigator.pushReplacement(
                                                    context,
                                                    PageTransition(
                                                        child: AltProfile(
                                                          userUid: documentSnapshot['useruid'],
                                                        ),
                                                        type: PageTransitionType.bottomToTop
                                                    )
                                                );
                                              }
                                            },
                                            child: CircleAvatar(
                                              backgroundColor: constantColors.darkColor,
                                              radius: 15,
                                              backgroundImage: NetworkImage(
                                                documentSnapshot['userimage']
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: Container(
                                            child:
                                              Text(
                                                documentSnapshot['username'],
                                                style: TextStyle(
                                                color: constantColors.whiteColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18
                                              ),
                                            )
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  FontAwesomeIcons.arrowUp,
                                                  color: constantColors.blueColor,
                                                  size: 12,
                                                ),
                                                onPressed: () {},
                                              ),
                                              Text(
                                                '0',
                                                style: TextStyle(
                                                  color: constantColors.whiteColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  FontAwesomeIcons.reply,
                                                  color: constantColors.yellowColor,
                                                  size: 12,
                                                ),
                                                onPressed: () {},
                                              ),

                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      height: MediaQuery.of(context).size.height * 0.05,
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              color: constantColors.blueColor,
                                              size: 12,
                                            ),
                                            onPressed: () {},
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.6,
                                            child: Text(
                                              documentSnapshot['comment'],
                                              style: TextStyle(
                                                color: constantColors.whiteColor,
                                                fontSize: 14
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              FontAwesomeIcons.trashAlt,
                                              color: constantColors.redColor,
                                              size: 18,
                                            ),
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Container(
                            width: 250,
                            height: 50,
                            child: TextField(
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'Add comment...',
                                hintStyle: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              controller: commentController,
                              style: TextStyle(
                                color: constantColors.whiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: FloatingActionButton(
                            backgroundColor: constantColors.greenColor,
                            child: Icon(
                              FontAwesomeIcons.comment,
                              color: constantColors.whiteColor,
                              size: 16,
                            ),
                            onPressed: () {
                              addComment(
                                context,
                                snapshot['caption'],
                                commentController.text
                              ).whenComplete(() {
                                commentController.clear();
                                notifyListeners();
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            decoration: BoxDecoration(
              color: constantColors.blueGreyColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12)
              )
            ),
          ),
        );
    });
  }

  showLikes(BuildContext context, String postId){
    return showModalBottomSheet(
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
                width: 100,
                decoration: BoxDecoration(
                    border: Border.all(color: constantColors.whiteColor),
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Center(
                  child: Text(
                    'Likes',
                    style: TextStyle(
                        color: constantColors.blueColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('posts')
                      .doc(postId).collection('likes').snapshots(),
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator());
                    }
                    else{
                      return new ListView(
                        children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                          return ListTile(
                            leading: GestureDetector(
                              onTap: (){
                                if(documentSnapshot['useruid'] != Provider.of<Authentication>(context, listen: false).getUserUid){
                                  Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                          child: AltProfile(
                                            userUid: documentSnapshot['useruid'],
                                          ),
                                          type: PageTransitionType.bottomToTop
                                      )
                                  );
                                }
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  documentSnapshot['userimage']
                                ),
                              ),
                            ),
                            title: Text(
                              documentSnapshot['username'],
                              style: TextStyle(
                                color: constantColors.blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              ),
                            ),
                            subtitle: Text(
                              documentSnapshot['useremail'],
                              style: TextStyle(
                                  color: constantColors.whiteColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                              ),
                            ),
                            trailing: Provider.of<Authentication>(context, listen: false).getUserUid
                              == documentSnapshot['useruid']
                              ? Container(width: 0, height: 0,)
                              : MaterialButton(
                              child: Text(
                                'Follow',
                                style: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14
                                ),
                              ),
                              onPressed: (){},
                              color: constantColors.blueColor,
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              )
            ],
          ),
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: constantColors.blueGreyColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12)
            )
          ),
        );
      }
    );
  }

  showRewards(BuildContext context, String postId){
    return showModalBottomSheet(context: context, builder: (context){
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
              width: 100,
              decoration: BoxDecoration(
                  border: Border.all(color: constantColors.whiteColor),
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Center(
                child: Text(
                  'Rewards',
                  style: TextStyle(
                      color: constantColors.blueColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('awards').snapshots(),
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator());
                    }
                    else{
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                          return GestureDetector(
                            onTap: () async{
                              await Provider.of<FirebaseOperations>(context, listen: false).addAward(postId, {
                                'username': Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
                                'userimage': Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,
                                'useruid': Provider.of<Authentication>(context, listen: false).getUserUid,
                                'time': Timestamp.now(),
                                'award': documentSnapshot['image']
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                height: 50,
                                width: 50,
                                child: Image.network(documentSnapshot['image']),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ),
            )
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: constantColors.blueGreyColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12)
            )
        ),
      );
    });
  }
  
}
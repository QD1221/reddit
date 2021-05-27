import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/screens/homepage/homePage.dart';
import 'package:reddit/services/Authentication.dart';
import 'package:reddit/services/FirebaseOperations.dart';
import 'package:reddit/utils/postOptions.dart';

import 'altProfile.dart';

class AltProfileHelper with ChangeNotifier{
  ConstantColors constantColors = ConstantColors();
  Widget appBar(BuildContext context){
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded),
        color: constantColors.whiteColor,
        onPressed: (){
          Navigator.pushReplacement(
            context, PageTransition(
              child: HomePage(),
              type: PageTransitionType.bottomToTop
            )
          );
        },
      ),
      backgroundColor: constantColors.blueGreyColor.withOpacity(0.4),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(EvaIcons.moreVertical, color: constantColors.whiteColor,),
          color: constantColors.whiteColor,
          onPressed: (){
            Navigator.pushReplacement(
                context, PageTransition(
                child: HomePage(),
                type: PageTransitionType.bottomToTop
            )
            );
          },
        ),
      ],
      title: RichText(
        text: TextSpan(
          text: 'The',
          style: TextStyle(
            color: constantColors.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 20
            ),
          children: <TextSpan>[
            TextSpan(
              text: 'Social',
              style: TextStyle(
                color: constantColors.blueColor,
                fontWeight: FontWeight.bold,
                fontSize: 20
               ),
            )
          ]
        )
      ),
    );
  }

  Widget headerProfile(BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot, String userUid){
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.38,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 160,
                  width: 180,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: CircleAvatar(
                          backgroundColor: constantColors.transparent,
                          radius: 40,
                          backgroundImage: snapshot.data['userimage'] == null
                              ? NetworkImage('https://firebasestorage.googleapis.com/v0/b/reddit-f63cd.appspot.com/o/121433066_1051716855298514_5129594433440537632_n.jpg?alt=media&token=c180ac79-2d7b-48f3-b7f4-1d8d2dc24d29')
                              : NetworkImage(
                              snapshot.data['userimage']
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          snapshot.data['username'],
                          style: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(EvaIcons.email, color: constantColors.greenColor, size: 16,),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                snapshot.data['useremail'],
                                style: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: 160,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: (){
                                checkFollowersSheet(context, snapshot);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: constantColors.darkColor,
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                height: 60,
                                width: 70,
                                child: Column(
                                  children: [
                                    StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance.collection('users')
                                            .doc(snapshot.data['useruid'])
                                            .collection('followers').snapshots(),
                                        builder: (context, snapshot){
                                          if(snapshot.connectionState == ConnectionState.waiting){
                                            return Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          }
                                          else{
                                            return new Text(
                                                snapshot.data.docs.length.toString(),
                                                style: TextStyle(
                                                    color: constantColors.whiteColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12
                                                )
                                            );
                                          }
                                        }
                                    ),
                                    Text(
                                      'Followers',
                                      style: TextStyle(
                                          color: constantColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: constantColors.darkColor,
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              height: 60,
                              width: 70,
                              child: Column(
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance.collection('users')
                                      .doc(snapshot.data['useruid'])
                                      .collection('following').snapshots(),
                                    builder: (context, snapshot){
                                      if(snapshot.connectionState == ConnectionState.waiting){
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      else{
                                        return new Text(
                                          snapshot.data.docs.length.toString(),
                                            style: TextStyle(
                                                color: constantColors.whiteColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12
                                            )
                                        );
                                      }
                                    }
                                  ),
                                  Text(
                                    'Following',
                                    style: TextStyle(
                                        color: constantColors.whiteColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          decoration: BoxDecoration(
                              color: constantColors.darkColor,
                              borderRadius: BorderRadius.circular(15)
                          ),
                          height: 60,
                          width: 70,
                          child: Column(
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                ),
                              ),
                              Text(
                                'Posts',
                                style: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    color: constantColors.blueColor,
                    child: Text(
                      'Follow',
                      style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      ),
                    ),
                    onPressed: (){
                      Provider.of<FirebaseOperations>(context, listen: false).followUser(
                          userUid,
                          Provider.of<Authentication>(context, listen: false).getUserUid,
                          {
                            'username': Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
                            'userimage': Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,
                            'useruid': Provider.of<Authentication>(context, listen: false).getUserUid,
                            'useremail': Provider.of<FirebaseOperations>(context, listen: false).getInitUserEmail,
                            'time': Timestamp.now()

                          },
                          Provider.of<Authentication>(context, listen: false).getUserUid,
                          userUid,
                          {
                            'username': snapshot.data['username'],
                            'userimage': snapshot.data['userimage'],
                            'useremail': snapshot.data['useremail'],
                            'useruid': snapshot.data['useruid'],
                            'time': Timestamp.now()

                          }).whenComplete(() {
                            followedNotification(context, snapshot.data['username']);
                      });
                    },
                  ),
                  MaterialButton(
                    color: constantColors.blueColor,
                    child: Text(
                      'Message',
                      style: TextStyle(
                          color: constantColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                    ),
                    onPressed: (){

                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget divider(){
    return Center(
      child: SizedBox(
        height: 20,
        width: 350,
        child: Divider(
          color: constantColors.whiteColor,
        ),
      ),
    );
  }

  Widget middleProfile(BuildContext context, dynamic snapshot){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      FontAwesomeIcons.userAstronaut,
                      color: constantColors.yellowColor,
                      size: 16,
                    ),
                    Text(
                      'Recently Added',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: constantColors.whiteColor
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users')
                          .doc(snapshot.data['useruid'])
                          .collection('following').snapshots(),
                      builder: (context, snapshot){
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        else{
                          return new ListView(
                            scrollDirection: Axis.horizontal,
                            children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                              if(snapshot.connectionState == ConnectionState.waiting){
                                return Center(child: CircularProgressIndicator());
                              }
                              else{
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: new CircleAvatar(
                                    radius: 20,
                                    backgroundColor: constantColors.transparent,
                                    backgroundImage: NetworkImage(documentSnapshot['userimage']),
                                  ),
                                );
                              }
                            }).toList(),
                          );
                        }
                      }
                  ),
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: constantColors.darkColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(15)
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget footerProfile(BuildContext context, dynamic snapshot){
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users')
                .doc(snapshot.data['useruid'])
                .collection('posts').snapshots(),
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              else{
                return new GridView(
                  children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                    return GestureDetector(
                      onTap: (){
                        showPostDetails(context, documentSnapshot);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width,
                          child: FittedBox(
                            child: Image.network(
                                documentSnapshot['postimage']
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2
                  ),
                );
              }
            },
          ),
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: constantColors.darkColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(5)
          )
      ),
    );
  }

  followedNotification(BuildContext context, String name){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: Divider(
                  thickness: 4,
                  color: constantColors.whiteColor,
                ),
              ),
              Text(
                'Followed $name',
                style: TextStyle(
                  color: constantColors.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),
              )
            ],
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.darkColor,
          borderRadius: BorderRadius.circular(12)
        ),
      );
    });
  }

  checkFollowersSheet(BuildContext context, dynamic snapshot){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: constantColors.blueGreyColor,
            borderRadius: BorderRadius.circular(12)
        ),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users')
                .doc(snapshot.data['useruid'])
                .collection('followers').snapshots(),
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              else{
                return new ListView(
                  children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator());
                    }
                    else{
                      return new ListTile(
                        onTap: (){
                          if(documentSnapshot['useruid']
                          != Provider.of<Authentication>(context, listen: false).getUserUid){
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                child: AltProfile(
                                  userUid: documentSnapshot['useruid']
                                ),
                                type: PageTransitionType.leftToRight
                              )
                            );
                          }
                        },
                        trailing: documentSnapshot['useruid']
                            == Provider.of<Authentication>(context, listen: false).getUserUid
                            ? Container(width: 0, height: 0)
                            : MaterialButton(
                              color: constantColors.blueColor,
                              child: Text(
                                'Unfollow',
                                style: TextStyle(
                                    color: constantColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                ),
                              ),
                              onPressed: (){

                              },
                        ),
                        leading: CircleAvatar(
                          backgroundColor: constantColors.darkColor,
                          backgroundImage: NetworkImage(
                              documentSnapshot['userimage']
                          ),
                        ),
                        title: Text(
                          documentSnapshot['username'],
                          style: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                          ),
                        ),
                        subtitle: Text(
                          documentSnapshot['useremail'],
                          style: TextStyle(
                              color: constantColors.yellowColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                          ),
                        ),
                      );
                    }
                  }).toList(),
                );
              }
            }
        ),
      );
    });
  }

  showPostDetails(BuildContext context, DocumentSnapshot documentSnapshot){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        color: constantColors.darkColor,
        height: MediaQuery.of(context).size.height * 0.6,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: Row(
                children: [
                  GestureDetector(
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
                      backgroundColor: constantColors.blueGreyColor,
                      radius: 20,
                      backgroundImage: NetworkImage(documentSnapshot['userimage']),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              documentSnapshot['caption'],
                              style: TextStyle(
                                  color: constantColors.greenColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              ),
                            ),
                          ),
                          Container(
                              child: RichText(
                                text: TextSpan(
                                    text: documentSnapshot['username'],
                                    style: TextStyle(
                                        color: constantColors.blueColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: ' , ${
                                              Provider.of<PostFunctions>(context, listen: false).getImageTimePosted.toString()
                                          }',
                                          style: TextStyle(
                                              color: constantColors.lightColor.withOpacity(0.8)
                                          )
                                      )
                                    ]
                                ),
                              )
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('posts')
                          .doc(documentSnapshot['caption'])
                          .collection('awards').snapshots(),
                      builder: (context, snapshot){
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return Center(child: CircularProgressIndicator());
                        }
                        else{
                          return ListView(
                            scrollDirection: Axis.horizontal,
                            children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                              return Container(
                                height: 30,
                                width: 30,
                                child: Image.network(documentSnapshot['award']),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width,
                child: FittedBox(
                  child: Image.network(documentSnapshot['postimage'], scale: 2,),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onLongPress: (){
                              Provider.of<PostFunctions>(context, listen: false).showLikes(context, documentSnapshot['caption']);
                            },
                            onTap: (){
                              Provider.of<PostFunctions>(context, listen: false)
                                  .addLike(context, documentSnapshot['caption'], Provider.of<Authentication>(context, listen: false).getUserUid);
                            },
                            child: Icon(
                              FontAwesomeIcons.heart,
                              color: constantColors.redColor,
                              size: 22,
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('posts')
                                .doc(documentSnapshot['caption'])
                                .collection('likes').snapshots(),
                            builder: (context, snapshot){
                              if(snapshot.connectionState == ConnectionState.waiting){
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              else{
                                return Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      snapshot.data.docs.length.toString(),
                                      style: TextStyle(
                                          color: constantColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: (){
                              Provider.of<PostFunctions>(context, listen: false)
                                  .showCommentsSheet(context, documentSnapshot, documentSnapshot['caption']);
                            },
                            child: Icon(
                              FontAwesomeIcons.comment,
                              color: constantColors.blueColor,
                              size: 22,
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('posts')
                                .doc(documentSnapshot['caption'])
                                .collection('comments').snapshots(),
                            builder: (context, snapshot){
                              if(snapshot.connectionState == ConnectionState.waiting){
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              else{
                                return Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      snapshot.data.docs.length.toString(),
                                      style: TextStyle(
                                          color: constantColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          )
                        ],
                      ),
                    ),
                    Container(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onLongPress: (){
                                Provider.of<PostFunctions>(context, listen: false)
                                    .showAwardsPresenter(context, documentSnapshot['caption']);
                              },
                              onTap: (){
                                Provider.of<PostFunctions>(context, listen: false)
                                    .showRewards(context, documentSnapshot['caption']);
                              },
                              child: Icon(
                                FontAwesomeIcons.award,
                                color: constantColors.yellowColor,
                                size: 22,
                              ),
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('posts')
                                  .doc(documentSnapshot['caption'])
                                  .collection('awards').snapshots(),
                              builder: (context, snapshot){
                                if(snapshot.connectionState == ConnectionState.waiting){
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                else{
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        snapshot.data.docs.length.toString(),
                                        style: TextStyle(
                                            color: constantColors.whiteColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            )
                          ],
                        )
                    ),
                    Spacer(),
                    Provider.of<Authentication>(context, listen: false).getUserUid
                        == documentSnapshot['useruid']
                        ?  IconButton(
                        icon: Icon(EvaIcons.moreVertical, color: constantColors.whiteColor,),
                        onPressed: (){
                          Provider.of<PostFunctions>(context, listen: false).showPostOptions(context, documentSnapshot['caption']);
                        })
                        : Container(width: 0, height: 0,)
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }


}
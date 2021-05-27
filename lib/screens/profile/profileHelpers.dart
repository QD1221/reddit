
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/screens/altprofile/altProfile.dart';
import 'package:reddit/screens/landingpage/landingPage.dart';
import 'package:reddit/screens/stories/stories_widgets.dart';
import 'package:reddit/services/Authentication.dart';
import 'package:reddit/utils/postOptions.dart';

class ProfileHelpers with ChangeNotifier{
  final StoriesWidgets storiesWidgets = StoriesWidgets();
  ConstantColors constantColors = ConstantColors();
  Widget headerProfile(BuildContext context, dynamic snapshot){
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 220,
              width: 180,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      //Add stories
                      storiesWidgets.addStory(context);
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: constantColors.transparent,
                          radius: 40,
                          backgroundImage: snapshot.data.data()['userimage'] == null
                              ? NetworkImage('https://firebasestorage.googleapis.com/v0/b/reddit-f63cd.appspot.com/o/121433066_1051716855298514_5129594433440537632_n.jpg?alt=media&token=c180ac79-2d7b-48f3-b7f4-1d8d2dc24d29')
                              : NetworkImage(
                              snapshot.data['userimage']
                          ),
                        ),
                        Positioned(
                          top: 60,
                          left: 60,
                          child: Icon(FontAwesomeIcons.plusCircle, color: constantColors.lightBlueColor, size: 18),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      snapshot.data.data()['username'],
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
                            snapshot.data.data()['useremail'],
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
                        GestureDetector(
                          onTap: (){
                            checkFollowingSheet(context, snapshot);
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
      ),
    );
  }

  Widget divider(){
    return Center(
      child: SizedBox(
        height: 25,
        width: 350,
        child: Divider(
          color: constantColors.whiteColor,
        ),
      ),
    );
  }

  Widget middleProfile(BuildContext context, dynamic snapshot){
    return Padding(
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
                  'Highlights',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: constantColors.whiteColor
                  ),
                )
              ],
            ),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users')
                  .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
                  .collection('highlights').snapshots(),
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
                      return GestureDetector(
                        onTap: (){
                          storiesWidgets.previewAllHighlights(
                            context,
                            documentSnapshot['title']
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: constantColors.darkColor,
                                  backgroundImage: NetworkImage(
                                    documentSnapshot['cover']
                                  ),
                                  radius: 20,
                                ),
                                Text(
                                  documentSnapshot['title'],
                                  style: TextStyle(
                                    color: constantColors.greenColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            height: MediaQuery.of(context).size.height * 0.12,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: constantColors.darkColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(15)
            ),
          )
          // Padding(
          //   padding: const EdgeInsets.only(top: 8),
          //   child: Container(
          //     child: StreamBuilder<QuerySnapshot>(
          //         stream: FirebaseFirestore.instance.collection('users')
          //             .doc(snapshot.data['useruid'])
          //             .collection('following').snapshots(),
          //         builder: (context, snapshot){
          //           if(snapshot.connectionState == ConnectionState.waiting){
          //             return Center(
          //               child: CircularProgressIndicator(),
          //             );
          //           }
          //           else{
          //             return new ListView(
          //               scrollDirection: Axis.horizontal,
          //               children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
          //                 if(snapshot.connectionState == ConnectionState.waiting){
          //                   return Center(child: CircularProgressIndicator());
          //                 }
          //                 else{
          //                   return Padding(
          //                     padding: const EdgeInsets.only(left: 8),
          //                     child: new CircleAvatar(
          //                       radius: 20,
          //                       backgroundColor: constantColors.transparent,
          //                       backgroundImage: NetworkImage(documentSnapshot['userimage']),
          //                     ),
          //                   );
          //                 }
          //               }).toList(),
          //             );
          //           }
          //         }
          //     ),
          //     height: MediaQuery.of(context).size.height * 0.08,
          //     width: MediaQuery.of(context).size.width,
          //     decoration: BoxDecoration(
          //       color: constantColors.darkColor.withOpacity(0.4),
          //       borderRadius: BorderRadius.circular(15)
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget footerProfile(BuildContext context, dynamic snapshot){
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users')
              .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
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
                        height: MediaQuery.of(context).size.height,
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

  logOutDialog(BuildContext context){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        backgroundColor: constantColors.darkColor,
        title: Text(
          'Log out',
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
                color: constantColors.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                decoration: TextDecoration.underline,
                decorationColor: constantColors.whiteColor
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
                  fontSize: 18,
              ),
            ),
            onPressed: (){
              Provider.of<Authentication>(context, listen: false)
                  .logOutViaEmail()
                  .whenComplete(() {
                Navigator.pushReplacement(
                    context, PageTransition(
                    child: LandingPage(),
                    type: PageTransitionType.bottomToTop));
              });
            },
          )
        ],
      );
    });
  }

  checkFollowingSheet(BuildContext context, dynamic snapshot){
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
                .collection('following').snapshots(),
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
                          Navigator.pushReplacement(
                            context, PageTransition(
                              child: AltProfile(
                                userUid: documentSnapshot['useruid']
                              ),
                              type: PageTransitionType.topToBottom
                            )
                          );
                        },
                        trailing: MaterialButton(
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
                height: MediaQuery.of(context).size.height * 0.35,
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
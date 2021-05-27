import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/screens/altprofile/altProfile.dart';
import 'package:reddit/screens/stories/stories.dart';
import 'package:reddit/services/Authentication.dart';
import 'package:reddit/utils/postOptions.dart';
import 'package:reddit/utils/uploadPost.dart';

class FeedHelpers with ChangeNotifier{
  ConstantColors constantColors = ConstantColors();
  Widget appBar(BuildContext context){
    return AppBar(
      backgroundColor: constantColors.darkColor.withOpacity(0.6),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.camera_enhance_rounded),
          color: constantColors.greenColor,
          onPressed: (){
            Provider.of<UploadPost>(context, listen: false).selectPostImageType(context);
          },
        )
      ],
      title: RichText(
        text: TextSpan(
            text: 'My',
            style: TextStyle(
                color: constantColors.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 20
            ),
            children: <TextSpan>[
              TextSpan(
                  text: 'Profile',
                  style: TextStyle(
                      color: constantColors.blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  )
              )
            ]
        ),
      ),
    );
  }

  Widget feedBody(BuildContext context){
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('stories').snapshots(),
                builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator());
                  }
                  else{
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                        return GestureDetector(
                          onTap: (){
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                child: Stories(
                                  documentSnapshot: documentSnapshot
                                ),
                                type: PageTransitionType.leftToRight
                              )
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              child: CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(documentSnapshot['userimage']),
                              ),
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: constantColors.blueColor,
                                  width: 2
                                )
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: constantColors.darkColor,
                borderRadius: BorderRadius.circular(12)
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0),
            child: Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('posts').orderBy('time', descending: true).snapshots(),
                builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Lottie.asset('assets/animations/loading2.json'),
                      ),
                    );
                  }
                  else{
                    return loadPosts(context, snapshot);
                  }
                },
              ),
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: constantColors.darkColor.withOpacity(0.6),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18))
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget loadPosts(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
    return ListView(
      children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot){
        Provider.of<PostFunctions>(context, listen: false).showTimeAgo(documentSnapshot['time']);
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
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
                        width: MediaQuery.of(context).size.width * 0.4,
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
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width,
                  child: FittedBox(
                    child: Image.network(documentSnapshot['postimage'], scale: 2),
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
      }).toList(),
    );
  }

}
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/screens/altprofile/altProfile.dart';
import 'package:reddit/screens/homepage/homePage.dart';
import 'package:reddit/screens/profile/profile.dart';
import 'package:reddit/screens/stories/stories_helpers.dart';
import 'package:reddit/services/Authentication.dart';
import 'package:reddit/services/FirebaseOperations.dart';

class StoriesWidgets{
  final ConstantColors constantColors = ConstantColors();
  final TextEditingController storyHighlightTitleController = TextEditingController();

  addStory(BuildContext context){
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  color: constantColors.blueColor,
                  child: Text(
                    'Gallery',
                    style: TextStyle(
                      color: constantColors.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  onPressed: (){
                    Provider.of<StoriesHelpers>(context, listen: false)
                        .selectStoryImage(context, ImageSource.gallery)
                        .whenComplete(() {
                    });
                  },
                ),
                MaterialButton(
                  color: constantColors.blueColor,
                  child: Text(
                    'Camera',
                    style: TextStyle(
                        color: constantColors.whiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  onPressed: (){
                    Provider.of<StoriesHelpers>(context, listen: false)
                        .selectStoryImage(context, ImageSource.camera)
                        .whenComplete(() {
                      Navigator.pop(context);
                    });
                  },
                )
              ],
            )
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.darkColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))
        ),
      );
    });
  }

  previewStoryImage(BuildContext context, File storyImage){
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context){
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: constantColors.darkColor
          ),
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image.file(storyImage),
              ),
              Positioned(
                top: 500,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: 'Reselect image',
                        backgroundColor: constantColors.redColor,
                        child: Icon(FontAwesomeIcons.backspace, color: constantColors.whiteColor),
                        onPressed: (){
                          addStory(context);
                        },
                      ),
                      FloatingActionButton(
                        heroTag: 'Confirm image',
                        backgroundColor: constantColors.blueColor,
                        child: Icon(FontAwesomeIcons.check, color: constantColors.whiteColor),
                        onPressed: (){
                          Provider.of<StoriesHelpers>(context, listen: false)
                              .uploadStoryImage(context)
                              .whenComplete(() async{
                                try{
                                  if(Provider.of<StoriesHelpers>(context, listen: false).getStoryImageUrl != null){
                                    await FirebaseFirestore.instance.collection('stories')
                                        .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
                                        .set({
                                      'image': Provider.of<StoriesHelpers>(context, listen: false).getStoryImageUrl,
                                      'username': Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
                                      'userimage': Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,
                                      'time': Timestamp.now(),
                                      'useruid': Provider.of<Authentication>(context, listen: false).getUserUid,
                                    }).whenComplete(() {
                                      Navigator.pushReplacement(
                                        context,
                                        PageTransition(
                                          child: HomePage(),
                                          type: PageTransitionType.bottomToTop
                                          )
                                      );
                                    });
                                  }
                                  else{
                                    return showModalBottomSheet(
                                      context: context,
                                      builder: (context){
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: constantColors.darkColor
                                          ),
                                          child: Center(
                                            child: MaterialButton(
                                              onPressed: () async{
                                                await FirebaseFirestore.instance.collection('stories')
                                                    .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
                                                    .set({
                                                  'image': Provider.of<StoriesHelpers>(context, listen: false).getStoryImageUrl,
                                                  'username': Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
                                                  'userimage': Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,
                                                  'time': Timestamp.now(),
                                                  'useruid': Provider.of<Authentication>(context, listen: false).getUserUid,
                                                }).whenComplete(() {
                                                  Navigator.pushReplacement(
                                                      context,
                                                      PageTransition(
                                                          child: HomePage(),
                                                          type: PageTransitionType.bottomToTop
                                                      )
                                                  );
                                                });
                                              },
                                              child: Text(
                                                'Upload story!',
                                                style: TextStyle(
                                                  color: constantColors.whiteColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    );
                                  }
                                }
                                catch(e){
                                  print(e.toString());
                                }
                          });
                        },
                      )
                    ],
                  ),
                )
              )
            ],
          ),
        );
    });
  }

  addToHighLights(BuildContext context, String storyImage){
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
              Text(
                'Add to existing album',
                style: TextStyle(
                  color: constantColors.yellowColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold
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
                        child: CircularProgressIndicator()
                      );
                    }
                    else{
                      return new ListView(
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                          return GestureDetector(
                            onTap: (){
                              Provider.of<StoriesHelpers>(context, listen: false)
                                  .addStoryToExistingAlbum(
                                    context,
                                    Provider.of<Authentication>(context, listen: false).getUserUid,
                                    documentSnapshot.id,
                                    storyImage
                              ).whenComplete(() {
                                Navigator.pop(context);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
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
                            )
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width,
              ),
              Text(
                'Create new album',
                style: TextStyle(
                    color: constantColors.greenColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('awards').snapshots(),
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    else{
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                          return GestureDetector(
                            onTap: (){
                              Provider.of<StoriesHelpers>(context, listen: false)
                                  .convertHighlightIcons(documentSnapshot['image']);
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
              Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: storyHighlightTitleController,
                        style: TextStyle(
                          color: constantColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add album title...',
                          hintStyle: TextStyle(
                            color: constantColors.blueColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      child: Icon(
                        FontAwesomeIcons.check,
                        color: constantColors.whiteColor,
                      ),
                      onPressed: (){
                        if(storyHighlightTitleController.text.isNotEmpty){
                          Provider.of<StoriesHelpers>(context, listen: false)
                              .addStoryToNewAlbum(
                                  context, 
                                Provider.of<Authentication>(context, listen: false).getUserUid,
                                storyHighlightTitleController.text,
                                storyImage
                          );
                        }
                        else{
                          return showModalBottomSheet(context: context, builder: (context){
                            return Container(
                              color: constantColors.darkColor,
                              height: 100,
                              width: 400,
                              child: Center(
                                child: Text(
                                  'Add album title'
                                ),
                              ),
                            );
                          });
                        }
                      },
                    )
                  ],
                ),
              )
            ],
          ),
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: constantColors.darkColor,
            borderRadius: BorderRadius.circular(12)
          ),
        );
      }
    );
  }

  showViewer(BuildContext context, String storyId, String personUid){
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('stories')
                    .doc(storyId).collection('seen').snapshots(),
                builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  else{
                    return ListView(
                      children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                        Provider.of<StoriesHelpers>(context, listen: false).storyTimePosted(documentSnapshot['time']);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(documentSnapshot['userimage']),
                            backgroundColor: constantColors.darkColor,
                            radius: 25,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.arrowAltCircleRight,
                              color: constantColors.yellowColor,
                            ),
                            onPressed: (){
                              Navigator.pushReplacement(
                                context,
                                PageTransition(
                                  child: AltProfile(userUid: documentSnapshot['useruid']),
                                  type: PageTransitionType.bottomToTop
                                )
                              );
                            }
                          ),
                          title: Text(
                            documentSnapshot['username'],
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            ),
                          ),
                          subtitle: Text(
                            Provider.of<StoriesHelpers>(context, listen: false)
                                .getLastSeenTime.toString(),
                            style: TextStyle(
                                color: constantColors.greenColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                            ),
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
          color: constantColors.darkColor,
          borderRadius: BorderRadius.circular(12)
        ),
      );
    });
  }
  
  previewAllHighlights(BuildContext context, String highlightTitle){
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users')
            .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
            .collection('highlights').doc(highlightTitle)
            .collection('stories').snapshots(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            else{
              return PageView(
                children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot){
                  return Container(
                    decoration: BoxDecoration(
                      color: constantColors.darkColor
                    ),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(documentSnapshot['image']),
                  );
                }).toList()
              );
            }
          }
        ),
      );
    });
  }

}
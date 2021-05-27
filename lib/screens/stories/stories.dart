import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/screens/homepage/homePage.dart';
import 'package:reddit/screens/stories/stories_helpers.dart';
import 'package:reddit/screens/stories/stories_widgets.dart';
import 'package:reddit/services/Authentication.dart';

class Stories extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  Stories({@required this.documentSnapshot});
  @override
  _StoriesState createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {

  final ConstantColors constantColors = ConstantColors();
  final StoriesWidgets storiesWidgets = StoriesWidgets();

  @override
  void initState() {
    Provider.of<StoriesHelpers>(context, listen: false)
        .storyTimePosted(widget.documentSnapshot['time']);
    Provider.of<StoriesHelpers>(context, listen: false)
        .addSeenStamp(
            context,
            widget.documentSnapshot.id,
            Provider.of<Authentication>(context, listen: false).getUserUid,
            widget.documentSnapshot
    );
    // Timer(
    //   Duration(seconds: 15),
    //     () => Navigator.pushReplacement(
    //         context,
    //         PageTransition(
    //             child: HomePage(),
    //             type: PageTransitionType.bottomToTop
    //         )
    //       )
    //     );
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.darkColor,
      body: GestureDetector(
        onPanUpdate: (update){
          if(update.delta.dx > 0){
            Navigator.pushReplacement(
              context,
              PageTransition(
                child: HomePage(),
                type: PageTransitionType.bottomToTop
              )
            );
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Image.network(
                        widget.documentSnapshot['image'],
                        fit: BoxFit.contain,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: 30,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width
                ),
                child: Row(
                  children: [
                    Container(
                      child: CircleAvatar(
                        backgroundColor: constantColors.darkColor,
                        backgroundImage: NetworkImage(
                          widget.documentSnapshot['userimage']
                        ),
                        radius: 25,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.documentSnapshot['username'],
                              style: TextStyle(
                                color: constantColors.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              ),
                            ),
                            Text(
                              Provider.of<StoriesHelpers>(context, listen: false).getStoryTime,
                              style: TextStyle(
                                  color: constantColors.greenColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Provider.of<Authentication>(context, listen: false).getUserUid
                        == widget.documentSnapshot['useruid']
                        ? GestureDetector(
                          onTap: (){
                            storiesWidgets.showViewer(
                              context,
                              widget.documentSnapshot.id,
                              widget.documentSnapshot['useruid']
                            );
                          },
                          child: Container(
                            height: 30,
                            width: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  FontAwesomeIcons.solidEye,
                                  color: constantColors.yellowColor,
                                  size: 16
                                ),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance.collection('stories')
                                    .doc(widget.documentSnapshot.id).collection('seen').snapshots(),
                                  builder: (context, snapshot){
                                    if(snapshot.connectionState == ConnectionState.waiting){
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    else{
                                      return Text(
                                        snapshot.data.docs.length.toString(),
                                        style: TextStyle(
                                          color: constantColors.whiteColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                        ),
                                      );
                                    }
                                  }
                                )
                              ],
                            ),
                          ),
                        )
                        : Container(width: 0, height: 0),
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularCountDownTimer(
                        isTimerTextShown: false,
                        duration: 15,
                        fillColor: constantColors.blueColor,
                        height: 20,
                        width: 20,
                        ringColor: constantColors.darkColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        EvaIcons.moreVertical,
                        color: constantColors.whiteColor,
                      ),
                      onPressed: (){
                        return showMenu(
                          color: constantColors.darkColor,
                          context: context,
                          position: RelativeRect.fromLTRB(300, 70, 0, 0),
                          items: [
                            PopupMenuItem(
                              child: FlatButton.icon(
                                  color: constantColors.blueColor,
                                  onPressed: (){
                                    storiesWidgets.addToHighLights(context, widget.documentSnapshot['image']);
                                  },
                                icon: Icon(
                                  FontAwesomeIcons.archive,
                                  color: constantColors.whiteColor,
                                ),
                                label: Text(
                                  'Add to highlights',
                                  style: TextStyle(
                                    color: constantColors.whiteColor
                                  ),
                                )
                              )
                            ),
                            PopupMenuItem(
                                child: FlatButton.icon(
                                  color: constantColors.redColor,
                                  onPressed: (){
                                    FirebaseFirestore.instance.collection('stories')
                                        .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
                                        .delete()
                                        .whenComplete(() {
                                      Navigator.pushReplacement(
                                          context,
                                          PageTransition(
                                              child: HomePage(),
                                              type: PageTransitionType.bottomToTop
                                          )
                                      );
                                    });
                                  },
                                  icon: Icon(
                                    FontAwesomeIcons.trashAlt,
                                    color: constantColors.whiteColor,
                                  ),
                                  label: Text(
                                    'Delete',
                                    style: TextStyle(
                                        color: constantColors.whiteColor
                                    ),
                                  )
                                )
                            )
                          ]
                        );
                      }
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

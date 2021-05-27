import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/screens/homepage/homePage.dart';
import 'package:reddit/screens/messaging/groupMessageHelpers.dart';
import 'package:reddit/services/Authentication.dart';

class GroupMessage extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  GroupMessage({@required this.documentSnapshot});

  @override
  _GroupMessageState createState() => _GroupMessageState();
}

class _GroupMessageState extends State<GroupMessage> {
  final ConstantColors constantColors = ConstantColors();
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    Provider.of<GroupMessagingHelpers>(context, listen: false)
        .checkIfJoined(context, widget.documentSnapshot.id, widget.documentSnapshot['useruid'])
        .whenComplete(() async{
          if(Provider.of<GroupMessagingHelpers>(context, listen: false).getHasMemberJoined == false){
            Timer(
              Duration(milliseconds: 10),
              () => Provider.of<GroupMessagingHelpers>(context, listen: false)
                  .askToJoin(context, widget.documentSnapshot.id)
            );
          }
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.darkColor,
      appBar: AppBar(
        actions: [
          Provider.of<Authentication>(context, listen: false).getUserUid
              == widget.documentSnapshot['useruid']
              ? IconButton(
              icon: Icon(EvaIcons.moreVertical,color: constantColors.whiteColor,),
              onPressed: (){

              }
          ): Container(width: 0, height: 0),
          IconButton(
              icon: Icon(EvaIcons.logOutOutline, color: constantColors.redColor),
              onPressed: (){
                Provider.of<GroupMessagingHelpers>(context, listen: false)
                    .leaveGroup(context, widget.documentSnapshot.id);
              },
          ),
        ],
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: constantColors.whiteColor),
            onPressed: (){
              Navigator.pushReplacement(
                  context,
                  PageTransition(
                      child: HomePage(),
                      type: PageTransitionType.leftToRight
                  )
              );
            }
        ),
        backgroundColor: constantColors.darkColor.withOpacity(0.6),
        title: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: constantColors.darkColor,
                backgroundImage: NetworkImage(widget.documentSnapshot['roomavatar']),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.documentSnapshot['roomname'],
                      style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('chatrooms')
                        .doc(widget.documentSnapshot.id)
                        .collection('members').snapshots(),
                      builder: (context, snapshot){
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return Center(child: CircularProgressIndicator());
                        }
                        else{
                          return new Text(
                            '${snapshot.data.docs.length.toString()} members',
                            style: TextStyle(
                              color: constantColors.greenColor.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                              fontSize: 12
                            ),
                          );
                        }
                      }
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              AnimatedContainer(
                child: Provider.of<GroupMessagingHelpers>(context, listen: false)
                    .showMessage(context, widget.documentSnapshot, widget.documentSnapshot['useruid']),
                height: MediaQuery.of(context).size.height * 0.75,
                width: MediaQuery.of(context).size.width,
                duration: Duration(seconds: 1),
                curve: Curves.bounceIn,
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: (){
                          Provider.of<GroupMessagingHelpers>(context, listen: false)
                              .showStickers(context, widget.documentSnapshot.id);
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: constantColors.transparent,
                          backgroundImage: AssetImage('assets/icons/sunflower.png'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: TextField(
                            controller: messageController,
                            style: TextStyle(
                              color: constantColors.whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            ),
                            decoration: InputDecoration(
                              hintText: 'Drop a hi...',
                              hintStyle: TextStyle(
                                  color: constantColors.greenColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                      FloatingActionButton(
                        backgroundColor: constantColors.blueColor,
                        child: Icon(Icons.send_sharp, color: constantColors.whiteColor),
                        onPressed: (){
                          if(messageController.text.isNotEmpty){
                            Provider.of<GroupMessagingHelpers>(context, listen: false)
                                .sendMessage(context, widget.documentSnapshot, messageController);
                          }
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

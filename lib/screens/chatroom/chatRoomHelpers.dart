import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/screens/altprofile/altProfile.dart';
import 'package:reddit/screens/messaging/groupMessage.dart';
import 'package:reddit/services/Authentication.dart';
import 'package:reddit/services/FirebaseOperations.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatRoomHelpers with ChangeNotifier{
  String latestMessageTime;
  String get getLatestMessageTime => latestMessageTime;
  String chatRoomAvatarUrl;
  String chatRoomID;
  String get getChatRoomAvatarUrl => chatRoomAvatarUrl;
  String get getChatRoomID => chatRoomID;
  ConstantColors constantColors = ConstantColors();
  final TextEditingController chatRoomNameController = TextEditingController();

  showChatRoomDetails(BuildContext context, DocumentSnapshot documentSnapshot){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height * 0.32,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.blueGreyColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150),
              child: Divider(
                color: constantColors.whiteColor,
                thickness: 4,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: constantColors.blueColor),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Members',
                  style: TextStyle(
                    color: constantColors.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('chatrooms')
                  .doc(documentSnapshot.id).collection('members').snapshots(),
                builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return new Center(child: CircularProgressIndicator());
                  }
                  else{
                    return new ListView(
                      scrollDirection: Axis.horizontal,
                      children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                        return GestureDetector(
                          onTap: (){
                            if(Provider.of<Authentication>(context, listen: false).getUserUid != documentSnapshot['useruid']){
                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      child: AltProfile(userUid: documentSnapshot['useruid']),
                                      type: PageTransitionType.bottomToTop
                                  )
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: CircleAvatar(
                              backgroundColor: constantColors.darkColor,
                              backgroundImage: NetworkImage(
                                documentSnapshot['userimage']
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: constantColors.yellowColor),
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Admin',
                    style: TextStyle(
                        color: constantColors.whiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: constantColors.transparent,
                    backgroundImage: NetworkImage(documentSnapshot['userimage']),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8, top: 8),
                        child: Text(
                          documentSnapshot['username'],
                          style: TextStyle(
                              color: constantColors.whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Provider.of<Authentication>(context, listen: false).getUserUid
                      == documentSnapshot['useruid']
                      ? Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: MaterialButton(
                          color: constantColors.redColor,
                          child: Text(
                            'Delete Room',
                            style: TextStyle(
                                color: constantColors.whiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          onPressed: (){
                            return showDialog(context: context, builder: (context){
                              return AlertDialog(
                                title: Text(
                                  'Delete Chat Room?',
                                  style: TextStyle(
                                      color: constantColors.whiteColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),
                                ),
                                backgroundColor: constantColors.darkColor,
                                actions: [
                                  MaterialButton(
                                    child: Text(
                                      'No',
                                      style: TextStyle(
                                          color: constantColors.whiteColor,
                                          fontWeight: FontWeight.bold,
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
                                      ),
                                    ),
                                    onPressed: (){
                                      FirebaseFirestore.instance.collection('chatrooms')
                                          .doc(documentSnapshot.id).delete()
                                          .whenComplete(() {
                                        Navigator.pop(context);
                                      });
                                    },
                                  )
                                ],
                              );
                            });
                          },
                        ),
                      )
                      : Container(
                        width: 0,
                        height: 0
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  showCreateChatRoomSheet(BuildContext context){
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context){
        return Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    color: constantColors.whiteColor,
                    thickness: 4,
                  ),
                ),
                Text(
                  'Select Chat Room Avatar',
                  style: TextStyle(
                    color: constantColors.greenColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('awards').snapshots(),
                    builder: (context, snapshot){
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return Center(child: CircularProgressIndicator());
                      }
                      else{
                        return new ListView(
                          scrollDirection: Axis.horizontal,
                          children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                            return GestureDetector(
                              onTap: (){
                                chatRoomAvatarUrl = documentSnapshot['image'];
                                notifyListeners();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: chatRoomAvatarUrl == documentSnapshot['image']
                                        ? constantColors.whiteColor
                                        : constantColors.transparent
                                    )
                                  ),
                                  height: 10,
                                  width: 40,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextField(
                        textCapitalization: TextCapitalization.words,
                        controller: chatRoomNameController,
                        style: TextStyle(
                          color: constantColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter Chatroom ID',
                          hintStyle: TextStyle(
                              color: constantColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      backgroundColor: constantColors.blueGreyColor,
                      child: Icon(
                          FontAwesomeIcons.plus,
                          color: constantColors.yellowColor
                      ),
                      onPressed: () async{
                        Provider.of<FirebaseOperations>(context, listen: false)
                            .submitChatRoomData(
                              chatRoomNameController.text,
                              {
                                'roomavatar': getChatRoomAvatarUrl,
                                'time': Timestamp.now(),
                                'roomname': chatRoomNameController.text,
                                'username': Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
                                'userimage': Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,
                                'useremail': Provider.of<FirebaseOperations>(context, listen: false).getInitUserEmail,
                                'useruid': Provider.of<Authentication>(context, listen: false).getUserUid
                              }
                        ).whenComplete(() {
                          Navigator.pop(context);
                        });
                      },
                    )
                  ],
                )
              ],
            ),
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: constantColors.darkColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12)
              )
            ),
          ),
        );
    }
    );
  }
  
  showChatRooms(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chatrooms').snapshots(),
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
          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot){
            showLastMessageTime(documentSnapshot['time']);
              return ListTile(
                onTap: (){
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      child: GroupMessage(
                          documentSnapshot: documentSnapshot
                      ),
                      type: PageTransitionType.leftToRight
                    )
                  );
                },
                onLongPress: (){
                  showChatRoomDetails(context, documentSnapshot);
                },
                trailing: Container(
                  width: 80,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('chatrooms')
                      .doc(documentSnapshot.id).collection('messages')
                      .orderBy('time', descending: true).snapshots(),
                    builder: (context, snapshot){
                      showLastMessageTime(snapshot.data.docs.first['time']);
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return Center(
                            child: CircularProgressIndicator()
                        );
                      }
                      else{
                        return Text(
                          getLatestMessageTime,
                          style: TextStyle(
                            color: constantColors.whiteColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold
                          ),
                        );
                      }
                    },
                  ),
                ),
                title: Text(
                  documentSnapshot['roomname'],
                  style: TextStyle(
                    color: constantColors.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),

                subtitle: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('chatrooms')
                    .doc(documentSnapshot.id).collection('messages')
                    .orderBy('time', descending: true).snapshots(),
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(
                        child: CircularProgressIndicator()
                      );
                    }
                    else if(snapshot.data.docs.first['username'] != null
                        && snapshot.data.docs.first['message']!= null
                        && !snapshot.data.docs.first['message'].toString().contains('https://firebasestorage.googleapis.com')) {
                      return Text(
                        '${snapshot.data.docs.first['username']} : ${ snapshot.data.docs.first['message']}',
                        style: TextStyle(
                          color: constantColors.greenColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        ),
                      );
                    }
                    else if(snapshot.data.docs.first['username'] != null
                        && snapshot.data.docs.first['message']!= null
                        && snapshot.data.docs.first['message'].toString().contains('https://firebasestorage.googleapis.com')){
                      return Text(
                        '${snapshot.data.docs.first['username']} : Sticker',
                        style: TextStyle(
                            color: constantColors.greenColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        ),
                      );
                    }
                    else if(snapshot.data.docs.first['message']== null){
                      return Text(
                        'Write the first message...',
                        style: TextStyle(
                            color: constantColors.greenColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        ),
                      );
                    }
                    else{
                      return Text('');
                    }
                  },
                ),
                leading: CircleAvatar(
                  backgroundColor: constantColors.transparent,
                  backgroundImage: NetworkImage(
                    documentSnapshot['roomavatar']
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }
  showLastMessageTime(dynamic timeData){
    Timestamp t = timeData;
    DateTime dateTime = t.toDate();
    latestMessageTime = timeago.format(dateTime);

  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/screens/homepage/homePage.dart';
import 'package:reddit/services/Authentication.dart';
import 'package:reddit/services/FirebaseOperations.dart';
import 'package:timeago/timeago.dart' as timeago;

class GroupMessagingHelpers with ChangeNotifier{
  ConstantColors constantColors = ConstantColors();
  String lastMessageTime;
  String get getLastMessageTime => lastMessageTime;
  bool hasMemberJoined = false;
  bool get getHasMemberJoined => hasMemberJoined;

  leaveGroup(BuildContext context, String chatRoomName){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        backgroundColor: constantColors.darkColor,
        title: Text(
          'Leave $chatRoomName?',
          style: TextStyle(
            color: constantColors.whiteColor,
            fontSize: 18,
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
                decoration: TextDecoration.underline,
                decorationColor: constantColors.whiteColor,
                fontSize: 14
              ),
            ),
            onPressed: (){
              Navigator.pop(context);
          }),
          MaterialButton(
            color: constantColors.redColor,
            child: Text(
              'Yes',
              style: TextStyle(
                color: constantColors.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 14
              ),
            ),
            onPressed: (){
              FirebaseFirestore.instance.collection('chatrooms')
                .doc(chatRoomName).collection('members')
                .doc(Provider.of<Authentication>(context, listen: false).getUserUid).delete()
                .whenComplete(() {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      child: HomePage(),
                      type: PageTransitionType.bottomToTop
                    )
                  );
              });
            })
        ],
      );
    });
  }

  sendMessage(BuildContext context, DocumentSnapshot documentSnapshot, TextEditingController messageController){
    return FirebaseFirestore.instance.collection('chatrooms')
        .doc(documentSnapshot.id).collection('messages')
        .add({
      'message': messageController.text,
      'time': Timestamp.now(),
      'useruid': Provider.of<Authentication>(context, listen: false).getUserUid,
      'username': Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
      'userimage': Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,

    });
  }

  showMessage(BuildContext context, DocumentSnapshot documentSnapshot, String adminUserUid){
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chatrooms')
        .doc(documentSnapshot.id).collection('messages').orderBy('time', descending: true).snapshots(),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        }
        else{
          return new ListView(
            reverse: true,
            children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
              showLastMessageTime(documentSnapshot['time']);
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: documentSnapshot['message'].toString().contains('https://firebasestorage.googleapis.com')
                    ? MediaQuery.of(context).size.height * 0.28
                    : MediaQuery.of(context).size.height * 0.18,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 60, top: 20, bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: documentSnapshot['message'].toString().contains('https://firebasestorage.googleapis.com')
                                  ? MediaQuery.of(context).size.height * 0.42
                                  : MediaQuery.of(context).size.height * 0.12,
                                maxWidth: documentSnapshot['message'] != null
                                    ? MediaQuery.of(context).size.width * 0.5
                                    : MediaQuery.of(context).size.width * 0.5,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 18),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 180,
                                      child: Row(
                                        children: [
                                          Text(
                                            documentSnapshot['username'],
                                            style: TextStyle(
                                              color: constantColors.greenColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14
                                            ),
                                          ),
                                          Provider.of<Authentication>(context, listen: false).getUserUid == adminUserUid
                                          ? Padding(
                                            padding: const EdgeInsets.only(left: 8),
                                            child: Icon(FontAwesomeIcons.chessKing, color: constantColors.yellowColor, size: 12),
                                          )
                                          : Container(width: 0, height: 0)
                                        ],
                                      ),
                                    ),
                                    documentSnapshot['message'].toString().contains('https://firebasestorage.googleapis.com')
                                    ? Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Container(
                                        height: 90,
                                        width: 100,
                                        child: Image.network(
                                            documentSnapshot['message']
                                        ),
                                      ),
                                    )
                                    : Text(
                                      documentSnapshot['message'],
                                      style: TextStyle(
                                          color: constantColors.whiteColor,
                                          fontSize: 12
                                      ),
                                    ),
                                    Container(
                                      width: 80,
                                      child: Text(
                                        getLastMessageTime,
                                        style: TextStyle(
                                          color: constantColors.whiteColor,
                                          fontSize: 8
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Provider.of<Authentication>(context, listen: false).getUserUid
                                    == documentSnapshot['useruid']
                                    ? constantColors.blueGreyColor.withOpacity(0.8)
                                    : constantColors.blueGreyColor
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        left: 20,
                        child: Provider.of<Authentication>(context, listen: false).getUserUid
                            == documentSnapshot['useruid']
                            ? Container(
                          child: Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                    Icons.edit,
                                    color: constantColors.blueColor,
                                    size: 12
                                ),
                                onPressed: (){

                                }
                              ),
                              IconButton(
                                  icon: Icon(
                                      FontAwesomeIcons.trashAlt,
                                      color: constantColors.redColor,
                                      size: 12
                                  ),
                                  onPressed: (){

                                  }
                              )
                            ],
                          ),
                        ) : Container(
                          width: 0,
                          height: 0,
                        )
                      ),
                      Positioned(
                          left: 40,
                          child: Provider.of<Authentication>(context, listen: false).getUserUid
                              == documentSnapshot['useruid']
                              ? Container(width: 0, height: 0)
                              : CircleAvatar(
                            backgroundColor: constantColors.darkColor,
                            backgroundImage: NetworkImage(
                              documentSnapshot['userimage']
                            ),
                          )
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }
      }
    );
  }

  Future checkIfJoined(BuildContext context, String chatRoomName, String chatRoomAdminUid) async{
    return FirebaseFirestore.instance.collection('chatrooms')
        .doc(chatRoomName).collection('members')
        .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
        .get().then((value) {
          hasMemberJoined = false;
          if(value['joined'] != null){
            hasMemberJoined = value['joined'];
            notifyListeners();
          }
          if(Provider.of<Authentication>(context, listen: false).getUserUid == chatRoomAdminUid){
            hasMemberJoined = true;
            notifyListeners();
          }
    });
  }
  
  askToJoin(BuildContext context, String roomName){
    return showDialog(
        context: context,
        builder: (context){
          return new AlertDialog(
            backgroundColor: constantColors.darkColor,
            title: Text(
                'Join $roomName?',
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
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: constantColors.whiteColor,
                      fontWeight: FontWeight.bold
                  ),
                ),
                onPressed: (){
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          child: HomePage(),
                          type: PageTransitionType.bottomToTop
                      )
                  );
                },
              ),
              MaterialButton(
                color: constantColors.blueColor,
                child: Text(
                  'Yes',
                  style: TextStyle(
                      color: constantColors.whiteColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                  ),
                ),
                onPressed: () async{
                  FirebaseFirestore.instance.collection('chatrooms')
                      .doc(roomName).collection('members')
                      .doc(Provider.of<Authentication>(context, listen: false).getUserUid)
                      .set({
                        'joined': true,
                        'username': Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
                        'userimage': Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,
                        'useruid': Provider.of<Authentication>(context, listen: false).getUserUid,
                        'time': Timestamp.now()

                  }).whenComplete(() {
                    Navigator.pop(context);
                  });
                },
              )
            ],
          );
        }
    );
  }

  showStickers(BuildContext context, String chatRoomId){
    return showModalBottomSheet(context: context, builder: (context){
      return AnimatedContainer(
        duration: Duration(seconds: 1),
        curve: Curves.easeIn,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 105),
              child: Divider(
                thickness: 4,
                color: constantColors.whiteColor,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: constantColors.blueColor)
                    ),
                    height: 30,
                    width: 30,
                    child: Image.asset('assets/icons/sunflower.png'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('stickers').snapshots(),
                builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return new Center(
                      child: CircularProgressIndicator()
                    );
                  }
                  else{
                    return new GridView(
                      children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
                        return GestureDetector(
                          onTap: (){
                            sendStickers(context, documentSnapshot['image'], chatRoomId);
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            child: Image.network(
                              documentSnapshot['image']
                            ),
                          ),
                        );
                      }).toList(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3
                      ),
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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12)
          )
        ),
      );
    });
  }

  sendStickers(BuildContext context, String stickerImageUrl, String chatRoomId) async{
    await FirebaseFirestore.instance.collection('chatrooms')
        .doc(chatRoomId).collection('messages').add({
      'message': stickerImageUrl,
      'useruid': Provider.of<Authentication>(context, listen: false).getUserUid,
      'username': Provider.of<FirebaseOperations>(context, listen: false).getInitUserName,
      'userimage': Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage,
      'time': Timestamp.now()
    });
  }

  showLastMessageTime(dynamic timeData){
    Timestamp time = timeData;
    DateTime dateTime = time.toDate();
    lastMessageTime = timeago.format(dateTime);
  }

}
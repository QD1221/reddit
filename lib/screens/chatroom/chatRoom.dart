import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/screens/chatroom/chatRoomHelpers.dart';

class ChatRoom extends StatelessWidget {
  final ConstantColors constantColors = ConstantColors();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: constantColors.blueGreyColor,
        child: Icon(FontAwesomeIcons.plus, color: constantColors.greenColor),
        onPressed: (){
          Provider.of<ChatRoomHelpers>(context, listen: false).showCreateChatRoomSheet(context);
        },
      ),
      appBar: AppBar(
        backgroundColor: constantColors.darkColor.withOpacity(0.6),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(EvaIcons.moreVertical, color: constantColors.whiteColor),
            onPressed: (){
              Provider.of<ChatRoomHelpers>(context, listen: false).showCreateChatRoomSheet(context);
            },
          )
        ],
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.plus, color: constantColors.greenColor),
          onPressed: (){

          },
        ),
        title: RichText(
          text: TextSpan(
              text: 'Chat',
              style: TextStyle(
                  color: constantColors.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
              ),
              children: <TextSpan>[
                TextSpan(
                    text: 'Box',
                    style: TextStyle(
                        color: constantColors.blueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    )
                )
              ]
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Provider.of<ChatRoomHelpers>(context, listen: false).showChatRooms(context),
      ),
    );
  }


}

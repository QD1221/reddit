import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/screens/chatroom/chatRoom.dart';
import 'package:reddit/screens/feed/feed.dart';
import 'package:reddit/screens/homepage/homePageHelpers.dart';
import 'package:reddit/screens/profile/profile.dart';
import 'package:reddit/services/FirebaseOperations.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ConstantColors constantColors = ConstantColors();
  final PageController homePageController = PageController();
  int pageIndex = 0;

  @override
  void initState(){
    Provider.of<FirebaseOperations>(context,listen: false)
        .initUserData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constantColors.darkColor,
      body: PageView(
        controller: homePageController,
        children: [
          Feed(),
          ChatRoom(),
          Profile(),
        ],
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (page){
          setState(() {
            pageIndex = page;
          });
        },
      ),
      bottomNavigationBar:
        Provider.of<HomePageHelpers>(context,listen: false)
            .bottomNavBar(context, pageIndex, homePageController),
    );
  }
}


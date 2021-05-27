
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/services/FirebaseOperations.dart';

class HomePageHelpers with ChangeNotifier{
  ConstantColors constantColors = ConstantColors();
  Widget bottomNavBar(
      BuildContext context, int index, PageController pageController){
    return CustomNavigationBar(
      currentIndex: index,
      bubbleCurve: Curves.bounceIn,
      scaleCurve: Curves.decelerate,
      selectedColor: constantColors.blueColor,
      unSelectedColor: constantColors.whiteColor,
      strokeColor: constantColors.blueColor,
      scaleFactor: 0.5,
      iconSize: 30,
      onTap: (val){
        index = val;
        pageController.jumpToPage(val);
        notifyListeners();
      },
      backgroundColor: Color(0xff040307),
      items: [
        CustomNavigationBarItem(icon: Icon(EvaIcons.home)),
        CustomNavigationBarItem(icon: Icon(EvaIcons.messageSquare)),
        CustomNavigationBarItem(
         icon: CircleAvatar(
            radius: 35,
            backgroundColor: constantColors.blueGreyColor,
            backgroundImage:
                (Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage == null)
                ? NetworkImage('https://firebasestorage.googleapis.com/v0/b/reddit-f63cd.appspot.com/o/121433066_1051716855298514_5129594433440537632_n.jpg?alt=media&token=c180ac79-2d7b-48f3-b7f4-1d8d2dc24d29')
                : NetworkImage(Provider.of<FirebaseOperations>(context, listen: false).getInitUserImage),
          )
        ),
      ],
    );
  }
}
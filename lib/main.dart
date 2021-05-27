import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/Constantcolors.dart';
import 'package:reddit/screens/altprofile/altProfileHelper.dart';
import 'package:reddit/screens/chatroom/chatRoomHelpers.dart';
import 'package:reddit/screens/feed/feedHelpers.dart';
import 'package:reddit/screens/homepage/homePageHelpers.dart';
import 'package:reddit/screens/landingpage/landingHelpers.dart';
import 'package:reddit/screens/landingpage/landingServices.dart';
import 'package:reddit/screens/landingpage/landingUtils.dart';
import 'package:reddit/screens/messaging/groupMessageHelpers.dart';
import 'package:reddit/screens/profile/profileHelpers.dart';
import 'package:reddit/screens/splashscreen/splashScreen.dart';
import 'package:reddit/screens/stories/stories_helpers.dart';
import 'package:reddit/services/Authentication.dart';
import 'package:reddit/services/FirebaseOperations.dart';
import 'package:reddit/utils/postOptions.dart';
import 'package:reddit/utils/uploadPost.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ConstantColors constantColors = ConstantColors();
    return MultiProvider(
      child: MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          accentColor: constantColors.blueColor,
          fontFamily: 'Poppins',
          canvasColor: Colors.transparent
          ),
        ),
      providers: [
        ChangeNotifierProvider(create: (_) => StoriesHelpers()),
        ChangeNotifierProvider(create: (_) => GroupMessagingHelpers()),
        ChangeNotifierProvider(create: (_) => ChatRoomHelpers()),
        ChangeNotifierProvider(create: (_) => AltProfileHelper()),
        ChangeNotifierProvider(create: (_) => PostFunctions()),
        ChangeNotifierProvider(create: (_) => FeedHelpers()),
        ChangeNotifierProvider(create: (_) => UploadPost()),
        ChangeNotifierProvider(create: (_) => ProfileHelpers()),
        ChangeNotifierProvider(create: (_) => HomePageHelpers()),
        ChangeNotifierProvider(create: (_) => FirebaseOperations()),
        ChangeNotifierProvider(create: (_) => LandingService()),
        ChangeNotifierProvider(create: (_) => LandingUtils()),
        ChangeNotifierProvider(create: (_) => Authentication()),
        ChangeNotifierProvider(create: (_) => LandingHelpers()),

      ]
    );
  }
}

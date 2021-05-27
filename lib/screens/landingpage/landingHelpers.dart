import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/screens/homepage/homePage.dart';
import 'package:reddit/screens/landingpage/landingServices.dart';
import 'package:reddit/screens/landingpage/landingUtils.dart';
import 'package:reddit/services/Authentication.dart';

class LandingHelpers with ChangeNotifier{
  ConstantColors constantColors = ConstantColors();
  Widget bodyImage(BuildContext context){
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/login.png')
        )
      ),
    );

  }

  Widget taglineText(BuildContext context){
    return Positioned(
      top: 450,
      left: 10,
      child: Container(
          constraints: BoxConstraints(
            maxWidth: 170,
          ),
          child: RichText(
              text: TextSpan(
                  text: 'Are ',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      color: constantColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 40
                  ),

                  children: <TextSpan>[
                    TextSpan(
                        text: 'You ',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 40
                        )
                    ),
                    TextSpan(
                        text: 'Social ',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: constantColors.blueColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 40
                        )
                    ),
                    TextSpan(
                        text: '?',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 40
                        )
                    )
                  ]
              )
          ),
      ),
    );
  }
  Widget mainButton(BuildContext context){
    return Positioned(
      top: 600,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: (){
                emailAuthSheet(context);
              },
              child: Container(
                child: Icon(EvaIcons.emailOutline, color: constantColors.yellowColor,),
                width: 80,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: constantColors.yellowColor
                  ),
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                Provider.of<Authentication>(context, listen: false).signInWithGoogle().whenComplete((){
                  Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.leftToRight));
                });
              },
              child: Container(
                child: Icon(EvaIcons.google, color: constantColors.redColor,),
                width: 80,
                height: 40,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: constantColors.redColor
                    ),
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
            GestureDetector(
              child: Container(
                child: Icon(EvaIcons.facebookOutline, color: constantColors.blueColor,),
                width: 80,
                height: 40,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: constantColors.blueColor
                    ),
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget privacyText(BuildContext context){
    return Positioned(
      top: 740,
      left: 20,
      right: 20,
      child: Container(
        child: Column(
          children: [
            Text(
              "By continuing you agree theSocial's Terms of", style: TextStyle(
              color: Colors.grey.shade600, fontSize: 12
              ),
            ),
            Text(
              "Services & Privacy Policy", style: TextStyle(
                color: Colors.grey.shade600, fontSize: 12
            ),
            )
          ],
        ),
      ),
    );
  }

  emailAuthSheet(BuildContext context){
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
            Provider.of<LandingService>(context, listen: false).passwordLessSignIn(context),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  color: constantColors.blueColor,
                  child: Text(
                    'Login', style: TextStyle(
                      color: constantColors.whiteColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  onPressed: () {
                    Provider.of<LandingService>(context, listen: false).logInSheet(context);
                  },
                ),
                MaterialButton(
                  color: constantColors.redColor,
                  child: Text(
                    'Signup', style: TextStyle(
                      color: constantColors.whiteColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  onPressed: () {
                    // Provider.of<LandingService>(context, listen: false).signUpSheet(context);
                    Provider.of<LandingUtils>(context, listen: false).selectAvatarOptionsSheet(context);
                  },
                ),
              ],
            )
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: constantColors.blueGreyColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          )
        ),
      );
    });
  }
}
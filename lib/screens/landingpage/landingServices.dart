import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:reddit/constants/constantcolors.dart';
import 'package:reddit/screens/homepage/homePage.dart';
import 'package:reddit/screens/landingpage/landingUtils.dart';
import 'package:reddit/services/Authentication.dart';
import 'package:reddit/services/FirebaseOperations.dart';

class LandingService with ChangeNotifier{
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  ConstantColors constantColors = ConstantColors();

  showUserAvatar(BuildContext context){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150),
              child: Divider(
                thickness: 4,
                color: constantColors.whiteColor,
              ),
            ),
            CircleAvatar(
              radius: 80,
              backgroundColor: constantColors.transparent,
              backgroundImage: FileImage(
                Provider.of<LandingUtils>(context, listen: false).userAvatar
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    child: Text(
                      'Reselect', style: TextStyle(
                      color: constantColors.whiteColor, fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: constantColors.whiteColor
                      ),
                    ),
                    onPressed: (){
                      Provider.of<LandingUtils>(context, listen: false)
                          .pickUserAvatar(context, ImageSource.gallery);
                    },
                  ),
                  MaterialButton(
                    color: constantColors.blueColor,
                    child: Text(
                      'Confirm image', style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        ),
                      ),
                    onPressed: (){
                      Provider.of<FirebaseOperations>(context, listen: false)
                          .uploadUserAvatar(context)
                          .whenComplete(() {
                            signUpSheet(context);
                      });
                    },
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }
  Widget passwordLessSignIn(BuildContext context){
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else{
            return new ListView(
              children: snapshot.data.docs.map((DocumentSnapshot documentSnapshot){
                return ListTile(
                  trailing: Container(
                    width: 120,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(FontAwesomeIcons.check, color: constantColors.blueColor),
                          onPressed: () {
                            Provider.of<Authentication>(context, listen: false)
                                .logIntoAccount(documentSnapshot['useremail'], documentSnapshot['userpassword'])
                                .whenComplete(() {
                                  Navigator.pushReplacement(context, PageTransition(
                                      child: HomePage(), type: PageTransitionType.leftToRight
                                    )
                                  );
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.trashAlt, color: constantColors.redColor),
                          onPressed: () {
                            Provider.of<FirebaseOperations>(context, listen: false)
                                .deleteUserData(documentSnapshot['useruid'],'users');

                          },
                        )
                      ],
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: constantColors.darkColor,
                    backgroundImage: NetworkImage(documentSnapshot['userimage']),
                  ),
                  subtitle: Text(documentSnapshot['useremail'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: constantColors.whiteColor,
                      fontSize: 12
                    ),
                  ),
                  title: Text(documentSnapshot['username'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: constantColors.greenColor
                    ),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }

  logInSheet(BuildContext context){
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context){
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    thickness: 4,
                    color: constantColors.whiteColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: userEmailController,
                    decoration: InputDecoration(
                        hintText: 'Enter email...',
                        hintStyle: TextStyle(
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        )
                    ),
                    style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: userPasswordController,
                    decoration: InputDecoration(
                        hintText: 'Enter password...',
                        hintStyle: TextStyle(
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        )
                    ),
                    style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    ),
                  ),
                ),
                FloatingActionButton(
                  backgroundColor: constantColors.blueColor,
                  child: Icon(EvaIcons.checkmark, color: constantColors.whiteColor,),
                  onPressed: (){
                    if(userEmailController.text.isNotEmpty){
                      Provider.of<Authentication>(context, listen: false)
                          .logIntoAccount(userEmailController.text, userPasswordController.text)
                          .whenComplete(() {
                            Navigator.pushReplacement(context, PageTransition(
                              child: HomePage(),
                                type: PageTransitionType.bottomToTop
                            ));
                      });
                    }
                    else{
                      warningText(context, 'Fill all the data ');
                    }
                  },
                )
              ],
            ),
            decoration: BoxDecoration(
                color: constantColors.blueGreyColor,
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

  signUpSheet(BuildContext context){
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context){
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Expanded(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: constantColors.blueGreyColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              )
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    thickness: 4,
                    color: constantColors.whiteColor,
                  ),
                ),
                CircleAvatar(
                  backgroundImage: FileImage(
                    Provider.of<LandingUtils>(context, listen: false).getUserAvatar
                  ),
                  backgroundColor: constantColors.transparent,
                  radius: 60,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: userNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter name...',
                      hintStyle: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      )
                    ),
                    style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: userEmailController,
                    decoration: InputDecoration(
                        hintText: 'Enter email...',
                        hintStyle: TextStyle(
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        )
                    ),
                    style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: userPasswordController,
                    decoration: InputDecoration(
                        hintText: 'Enter password...',
                        hintStyle: TextStyle(
                            color: constantColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        )
                    ),
                    style: TextStyle(
                        color: constantColors.whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: FloatingActionButton(
                    backgroundColor: constantColors.redColor,
                    child: Icon(EvaIcons.checkmark, color: constantColors.whiteColor,),
                    onPressed: (){
                      if(userEmailController.text.isNotEmpty){
                        Provider.of<Authentication>(context, listen: false)
                            .createAccount(userEmailController.text, userPasswordController.text)
                            .whenComplete(() {
                              print('Creating collection...');
                              Provider.of<FirebaseOperations>(context, listen: false).createUserCollection(context, {
                                'userpassword': userPasswordController.text,
                                'useruid':Provider.of<Authentication>(context, listen: false).getUserUid,
                                'useremail': userEmailController.text,
                                'username': userNameController.text,
                                'userimage': Provider.of<LandingUtils>(context, listen: false).getUserAvatarUrl
                              });
                            })
                            .whenComplete(() {
                          Navigator.pushReplacement(context, PageTransition(
                              child: HomePage(),
                              type: PageTransitionType.bottomToTop
                          ));
                        });
                      }
                      else{
                        warningText(context, 'Fill all the data ');
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  warningText(BuildContext context, String warning){
    return showModalBottomSheet(context: context, builder: (context){
      return Container(
        decoration: BoxDecoration(
          color: constantColors.darkColor,
          borderRadius: BorderRadius.circular(15)
        ),
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Text(warning, style: TextStyle(
            color: constantColors.whiteColor, fontSize: 16, fontWeight: FontWeight.bold
            ),
          ),
        ),
      );
    });
  }
}
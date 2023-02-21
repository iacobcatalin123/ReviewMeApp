// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, file_names, non_constant_identifier_names, avoid_print, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:review_me/widgets/Icon_With_Text.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String phone_nuumber = '';
  var password_controller = TextEditingController();
  Future signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    if (googleAuth?.accessToken == null ||
        googleAuth == null ||
        googleAuth.idToken == null) {
      return;
    }
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.pop(context);
    var user_exists = await FirebaseAuth.instance
        .fetchSignInMethodsForEmail(googleUser!.email);
    if (user_exists.isNotEmpty) {
      return;
    }
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      "firstname": "",
      "lastname": "",
      "profile_pic": "",
      "reviews":
          [], //reviews contain: description, firstname (of sender), lastname (of sender), email (of sender), isRecieved (if you got it or you sent it to someone), rating (1-5), title, timestamp (time of review)
      "reports":
          [], // email (of reporter), description (of report), timestamp (time of report)
      "jobs": [],
    });
  }

  Future phone_number_login() async {
    if (phone_nuumber.isEmpty) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Please input the phone number"),
              actions: [
                FlatButton(
                  child: Text("OK"),
                  onPressed: () => {Navigator.pop(context)},
                ),
              ],
            );
          });
    } else {
      var otp_code = "";
      var phone_number = phone_nuumber.trim();

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone_number,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          print("verificationCompleted");
          print(credential);
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (ex) {
          print("verificationFailed");
          print(ex);
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          print("codeSent");
          print(verificationId);
          print(forceResendingToken);
          //show dialog to input the sms code, if all is right signin with credential
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Enter the sms code"),
                  content: TextField(
                    onChanged: (value) {
                      otp_code = value;
                    },
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Done"),
                      onPressed: () {
                        FirebaseAuth.instance
                            .signInWithCredential(PhoneAuthProvider.credential(
                                verificationId: verificationId,
                                smsCode: otp_code))
                            .then((value) => {
                                  //if the uid is not in users/uid then log out and show error
                                  FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(value.user!.uid)
                                      .get()
                                      .then((value) {
                                    if (value.exists) {
                                      //go to home
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    } else {
                                      //go to register
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                  }),
                                });
                      },
                    ),
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("codeAutoRetrievalTimeout");
          print(verificationId);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Future backButton() async {
      Navigator.pop(context);
    }

    return MaterialApp(
      home: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: backButton,
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                // 3040 × 1440
                image: Image.asset('assets/icons/register_login_background.jpg')
                    .image,
                fit: BoxFit.fill,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 55,
                        ),
                        Icon(
                          Icons.account_circle,
                          size: 50,
                          color: Colors.blue,
                        ),
                        const Text(
                          "Login",
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        const Text(
                          "We missed you!",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    IntlPhoneField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        //rounded borders
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      initialCountryCode: 'RO',
                      onChanged: (phone) {
                        phone_nuumber = phone.completeNumber;
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 60,
                      width: 250,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(48, 97, 255, 1),
                            borderRadius: BorderRadius.circular(15)),
                        child: TextButton(
                          onPressed: phone_number_login,
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Fast Sign In with Google"),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: FlatButton(
                        onPressed: () => {signInWithGoogle()},
                        child: Image.asset('assets/icons/google_login.png'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

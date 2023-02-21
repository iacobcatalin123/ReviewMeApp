// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:review_me/screens/Login.dart';
import 'package:review_me/widgets/Icon_With_Text.dart';
import 'package:review_me/widgets/Modern_Text_Box.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String phone_nuumber = '';
  var password_controller = TextEditingController();
  var confirm_password_controller = TextEditingController();

  bool is_invalid_field = false;
  String text_to_show_as_error = "The provided email is invalid";

  Future phone_register() async {
    setState(() {
      is_invalid_field = false;
      text_to_show_as_error = "The provided email is invalid";
    });

    if (confirm_password_controller.text.trim() !=
        password_controller.text.trim()) {
      setState(() {
        is_invalid_field = true;
        text_to_show_as_error = "Passwords do not match";
      });
      return;
    }
    //register using phone
    //1. send the message to user, then send him to a show dialog in which he needs to put his smsCode, then send it to firebase and pop the dialog
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
                          .then((user_credentials) => {
                                //check if the uid is already in users/uid
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(user_credentials.user!.uid)
                                    .get()
                                    .then((value) => {
                                          if (value.exists)
                                            {print("bypassing re-update")}
                                          else
                                            {
                                              print("inserting new data"),
                                              FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(user_credentials
                                                      .user!.uid)
                                                  .set({
                                                "firstname": "",
                                                "lastname": "",
                                                "profile_pic": "",
                                                "reviews":
                                                    [], //reviews contain: description, firstname (of sender), lastname (of sender), email (of sender), isRecieved (if you got it or you sent it to someone), rating (1-5), title, timestamp (time of review)
                                                "reports":
                                                    [], // email (of reporter), description (of report), timestamp (time of report)
                                                "jobs": [],
                                              })
                                            }
                                        }),
                              });

                      Navigator.of(context).pop();
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
    //check if user is already in firebase as users/email
    var user_exists = await FirebaseAuth.instance
        .fetchSignInMethodsForEmail(googleUser!.email);
    if (user_exists.isNotEmpty) {
      //inform the user that the account is already registered
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Account already registered"),
              content: Text("Please log in with your account"),
              actions: <Widget>[
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    //navigate to login screen
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  },
                ),
              ],
            );
          });
      return;
    }
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseAuth.instance.signInWithCredential(credential);
    while (FirebaseAuth.instance.currentUser == null) {
      await Future.delayed(Duration(seconds: 1));
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
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
                    //HEADER
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
                        Text(
                          "Register",
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Text(
                          "Are you ready to be heard?",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),

                    //BODY
                    const SizedBox(height: 20),

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

                    if (is_invalid_field)
                      Text(
                        this.text_to_show_as_error,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already registered?",
                          style: TextStyle(fontSize: 15),
                        ),
                        TextButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login())),
                            child: Text(
                              "Login",
                              style: TextStyle(fontSize: 13),
                            )),
                      ],
                    ),
                    Container(
                      height: 60,
                      width: 300,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(48, 97, 255, 1),
                          borderRadius: BorderRadius.circular(15)),
                      child: TextButton(
                        onPressed: phone_register,
                        child: const Text(
                          "Create account",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Fast Register with Google"),
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

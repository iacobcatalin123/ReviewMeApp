// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, file_names, non_constant_identifier_names, avoid_print, avoid_function_literals_in_foreach_calls

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:review_me/screens/New_Job_Screen.dart';
import 'package:review_me/screens/Reviews_Page.dart';
import 'package:review_me/screens/Template_To_Insert_Data.dart';
import 'package:review_me/widgets/Icon_With_Text.dart';
import 'package:review_me/widgets/Modern_Text_Box.dart';
import 'package:review_me/widgets/Pill_Button.dart';
import 'package:review_me/widgets/Review_Modern.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<dynamic, dynamic> _user_data = {};

  Future get_my_reviews() async {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    String the_user_email = FirebaseAuth.instance.currentUser!.uid;
    _user_data.clear();
    //check if email is in users/hisemail
    var user_ref = await FirebaseFirestore.instance
        .collection("users")
        .doc(the_user_email)
        .get();
    if (!user_ref.exists) {
      for (int i = 0; i < 3; i++) {
        user_ref = await FirebaseFirestore.instance
            .collection("users")
            .doc(the_user_email)
            .get();
        if (user_ref.exists) {
          break;
        }
        print("retrying");
        await Future.delayed(Duration(seconds: 3));
      }
    }
    if (!user_ref.exists) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Session expired, login again"),
              actions: [
                FlatButton(
                  child: Text("OK"),
                  onPressed: () =>
                      {Navigator.pop(context), FirebaseAuth.instance.signOut()},
                ),
              ],
            );
          });
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(the_user_email)
        .get()
        .then((value) => {
              _user_data['lastname'] = value.data()!['lastname'],
              _user_data['firstname'] = value.data()!['firstname'],
              _user_data['profile_pic'] = value.data()!['profile_pic'],
              _user_data['reviews'] = value.data()!['reviews'],
              _user_data['jobs'] = value.data()!['jobs'],
              //email
              _user_data['email'] = value.data()!['email'],
              //age
              _user_data['age'] = value.data()!['age'],
            });
    while (_user_data.isEmpty) {
      Future.delayed(Duration(milliseconds: 100));
    }
    _user_data['total_reviews'] = _user_data['reviews'].length;
    _user_data['overall_rating'] = 0;
    _user_data['reviews'].forEach((review) {
      _user_data['overall_rating'] += review['rating'];
    });
    _user_data['overall_rating'] /= _user_data['total_reviews'];

    if (_user_data['overall_rating'].toString() == "NaN") {
      _user_data['overall_rating'] = "0.00";
    } else {
      _user_data['overall_rating'] =
          _user_data['overall_rating'].toStringAsFixed(2);
    }

    //if there is .00 in overall rating make it be 0 or any other number
    if (_user_data['overall_rating'].toString().contains(".00")) {
      _user_data['overall_rating'] =
          _user_data['overall_rating'].toString().replaceAll(".00", "");
    }

    int r_wait = Random().nextInt(1000) + 500;
    await Future.delayed(Duration(milliseconds: r_wait), () {});

    if (mounted) {
      setState(() {
        _user_data = _user_data;
      });
    }
  }

  Future<void> setup_profile_image() async {
    var image_picker = ImagePicker();
    final XFile? image = await image_picker.pickImage(
        source: ImageSource.gallery, imageQuality: 10);

    if (image == null) {
      return;
    }

    //convert image to base64 string
    var image_bytes = await image.readAsBytes();
    var base64_image = base64Encode(image_bytes);
    var base64_image_string = base64_image.toString();
    setState(() {
      _user_data['profile_pic'] = base64_image_string;
    });
    //upload to firebase
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'profile_pic': base64_image_string});
    force_refresh();
  }

  void view_my_reviews() {
    var reviews_from_back_to_front = _user_data['reviews'].reversed.toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Reviews_Page(reviews: reviews_from_back_to_front),
      ),
    );
  }

  void force_refresh() {
    setState(() {});
  }

  void add_job_title() async {
    //push to new job screen
    String? refresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => New_Job_Screen(),
      ),
    );
    if (refresh == 'refresh') {
      get_my_reviews();
      force_refresh();
    }
  }

  void edit_job_title(String job_title) async {
    for (var job_data in _user_data['jobs']) {
      if (job_data['job_title'] == job_title) {
        String? refresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => New_Job_Screen(
              job_details: job_data,
              actual_job_being_modified: job_title,
            ),
          ),
        );
        if (refresh == 'refresh') {
          get_my_reviews();
          force_refresh();
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user_data.isEmpty) {
      get_my_reviews();
      return Container(
        padding: EdgeInsets.all(115),
        child: Center(
            child: Lottie.asset("assets/animations/profile_loading.json")),
      );
    }
    return MaterialApp(
      title: "Review Me",
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(48, 97, 255, 1),
          title: Text('Profile'),
          actions: [
            IconButton(
              onPressed: () => {FirebaseAuth.instance.signOut()},
              icon: Icon(Icons.logout_outlined),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                GFCard(
                  // showImage: true,
                  // image: _user_data['profile_pic'].toString().length > 5
                  //     ? Image.memory(base64Decode(_user_data['profile_pic']))
                  //     : null,
                  content: Column(
                    children: [
                      if (_user_data['profile_pic'].toString().length > 5)
                        Container(
                          height: 250,
                          width: 250,
                          //rounded corners
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: Image.memory(
                                      base64Decode(_user_data['profile_pic']))
                                  .image,
                            ),
                          ),
                        ),
                      if (_user_data['profile_pic'].toString().length < 5)
                        Column(
                          children: [
                            TextButton(
                              onPressed: setup_profile_image,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.account_circle_outlined,
                                    size: 54,
                                  ),
                                  Text("Add Profile Image"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon_Text_Button(
                              name: 'View Reviews',
                              icontouse: Icons.reviews_outlined,
                              onPressed: view_my_reviews,
                              color: Colors.blue),
                          if (_user_data['profile_pic'].toString().length > 5)
                            Icon_Text_Button(
                                name: 'Change Picture',
                                icontouse: Icons.person_outline,
                                onPressed: setup_profile_image,
                                color: Colors.blue)
                          else
                            Icon_Text_Button(
                                name: 'Change Picture',
                                icontouse: Icons.person_outline,
                                onPressed: () {},
                                color: Colors.grey),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                GFCard(
                  title: GFListTile(
                    titleText: "Public Info",
                  ),
                  content: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Public_Information_Widget(
                                onTap: () {
                                  //copy to clipboard  FirebaseAuth.instance.currentUser!.uid
                                  Clipboard.setData(ClipboardData(
                                      text: FirebaseAuth
                                          .instance.currentUser!.uid));
                                },
                                title: 'Unique ID',
                                text: FirebaseAuth.instance.currentUser!.uid),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Public_Information_Widget(
                                title: 'Reviews Recieved',
                                text: _user_data['total_reviews'] == null
                                    ? "Eroare"
                                    : _user_data['total_reviews'].toString()),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Overall Rating",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      //value is from 0 to 1.0, but overallreviews is from 1-5, make sure 5 is 1.0 and 1 is 0.0
                                      //change overallreviws to float since its string in userdata
                                      backgroundColor: Colors.grey,
                                      value:
                                          _user_data['overall_rating'] == null
                                              ? 0.01
                                              : double.parse(_user_data[
                                                      'overall_rating']) /
                                                  5,
                                      //change color while its getting bigger in number
                                    ),
                                    Text(
                                      _user_data['overall_rating'] ?? "Eroare",
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Wrap(
                        spacing: 10,
                        children: [
                          for (var job_data in _user_data['jobs'] ?? [])
                            Pill_Button(
                              onPressed: () {
                                edit_job_title(job_data['job_title']);
                              },
                              text: job_data['job_title'],
                              color: Colors.blue,
                            ),
                          Pill_Button(
                            onPressed: add_job_title,
                            text: "Add Job",
                            color: Color.fromARGB(255, 237, 65, 53),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GFCard(
                  title: GFListTile(
                    titleText: "Setup Personal Information",
                  ),
                  content: Column(
                    children: [
                      Wrap(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: _user_data['firstname'] != ""
                                ? Public_Information_Widget(
                                    title: "Full Name",
                                    text: _user_data['firstname'] +
                                        " " +
                                        _user_data['lastname'],
                                  )
                                : TextButton(
                                    onPressed: setup_full_name,
                                    child: Text(
                                      "Add full name",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: _user_data['email'] == "" ||
                                    _user_data['email'] == null
                                ? TextButton(
                                    onPressed: setup_email,
                                    child: Text(
                                      "Add email",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                                : Public_Information_Widget(
                                    title: "Email",
                                    text: _user_data['email'],
                                  ),
                          ),
                          //age
                          Expanded(
                            child: _user_data['age'] == "" ||
                                    _user_data['age'] == null
                                ? TextButton(
                                    onPressed: setup_age,
                                    child: Text(
                                      "Add age",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                                : Public_Information_Widget(
                                    title: "Age",
                                    text: _user_data['age'].toString(),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setup_email() async {
    var email_ctrler = TextEditingController();
    //go to template to insert data
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Template_To_Insert_Data(
          title: "Setup Email",
          title_icon: Icon(Icons.mail_outline),
          description: "Insert your email and confirm it",
          onSubmit: () {
            _user_data['email'] = email_ctrler.text.trim();
            setState(() {});
          },
          /* 
            inputs[i] = {type='textfield', label='', controller= }
          */
          inputs: [
            {
              "type": "textfield",
              "label": "Email",
              "controller": email_ctrler,
            },
            {
              "type": "textfield",
              "label": "Confirm Email",
              "controller": null,
            },
          ],
        ),
      ),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'email': email_ctrler.text.trim()});
  }

  void setup_age() async {
    var age_ctrler = TextEditingController();
    //go to template to insert data
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Template_To_Insert_Data(
          title: "Setup Age",
          title_icon: Icon(Icons.calendar_today),
          description: "Insert your age",
          onSubmit: () {
            _user_data['age'] = age_ctrler.text.trim();
            setState(() {});
          },
          inputs: [
            {
              "type": "textfield",
              "label": "Age",
              "controller": age_ctrler,
            },
          ],
        ),
      ),
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'age': age_ctrler.text.trim()});
  }

  void setup_full_name() async {
    var firstname_ctrler = TextEditingController();
    var lastname_ctrler = TextEditingController();
    //go to template to insert data
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Template_To_Insert_Data(
          title: "Setup Full Name",
          title_icon: Icon(Icons.person_outline),
          description: "Insert your full name",
          onSubmit: () {
            _user_data['firstname'] = firstname_ctrler.text.trim();
            _user_data['lastname'] = lastname_ctrler.text.trim();
            setState(() {});
          },
          inputs: [
            {
              "type": "textfield",
              "label": "First Name",
              "controller": firstname_ctrler,
            },
            {
              "type": "textfield",
              "label": "Last Name",
              "controller": lastname_ctrler,
            },
          ],
        ),
      ),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'firstname': firstname_ctrler.text.trim(),
      'lastname': lastname_ctrler.text.trim(),
    });
  }
}

class Public_Information_Widget extends StatefulWidget {
  final String title;
  final String text;
  final Function? onTap;
  const Public_Information_Widget({
    Key? key,
    required this.title,
    required this.text,
    this.onTap,
  }) : super(key: key);

  @override
  State<Public_Information_Widget> createState() =>
      _Public_Information_WidgetState();
}

class _Public_Information_WidgetState extends State<Public_Information_Widget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          this.widget.title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blueAccent),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
          ),
          child: Text(
            this.widget.text,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

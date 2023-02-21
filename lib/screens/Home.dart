// ignore_for_file: file_names, prefer_const_constructors, non_constant_identifier_names, avoid_print, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:review_me/widgets/Employee_Profile.dart';
import 'package:review_me/widgets/Icon_With_Text.dart';
import 'package:review_me/widgets/Modern_Text_Box.dart';
import 'package:review_me/widgets/Pill_Button.dart';
import 'package:review_me/widgets/Search_Bar.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800),
    );

    controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
        controller.reset();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final _nr_ecuson_controller = TextEditingController();
  bool nr_ecuson_changed = false;
  final _comment_controller = TextEditingController();

  var stars_filled = 0;
  var allow_commenting = false;
  String last_bar_code_scanned = "";

  String titlu_la_job = "";
  Future submit_review() async {
    print("NR Ecuson: ${_nr_ecuson_controller.text}");
    print("Comment: ${_comment_controller.text}");

    //get firstname, lastname from users / my email / firstname, lastname
    var temp_data = {};
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then(
          (value) => {
            temp_data['firstname'] = value.data()!['firstname'],
            temp_data['lastname'] = value.data()!['lastname'],
          },
        );

    Map<dynamic, dynamic> to_insert = {};
    to_insert['description'] = _comment_controller.text;
    to_insert['email'] = FirebaseAuth.instance.currentUser!.uid;
    to_insert['firstname'] = temp_data['firstname'];
    to_insert['lastname'] = temp_data['lastname'];
    to_insert['profile_pic'] = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) => value.data()!['profile_pic']);
    to_insert['isRecieved'] = false;
    to_insert['rating'] = stars_filled;
    to_insert['title'] = titlu_la_job;
    to_insert['timestamp'] = DateTime.now().toString();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_nr_ecuson_controller.text.trim())
        .update({
      'reviews': FieldValue.arrayUnion([to_insert])
    });

    void showDoneDialog() => showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Lottie.asset(
                  'assets/animations/person_star.json',
                  repeat: false,
                  controller: controller,
                  onLoaded: (composition) {
                    controller.forward();
                  },
                ),
                Text(
                  "Thank you for your review!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
              ]),
            ));

    showDoneDialog();

    _nr_ecuson_controller.clear();
    _comment_controller.clear();
    scanned_user_data.clear();
    setState(() {
      stars_filled = 0;
      allow_commenting = false;
    });
  }

  String base64_profile_image = "";
  String full_name = "";
  Future scan_barcode() async {
    last_bar_code_scanned = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.BARCODE);
    if (last_bar_code_scanned == "-1") {
      return;
    }
    _nr_ecuson_controller.text =
        last_bar_code_scanned == "-1" ? "" : last_bar_code_scanned;
    get_scanned_user_from_database();
    setState(() {});
  }

  Map<String, dynamic> scanned_user_data = {};
  Future get_scanned_user_from_database() async {
    var uniq_id = last_bar_code_scanned;
    if (uniq_id == "") {
      // showSnackBar(context, "No user found", Colors.red);

      return;
    }
    var user_data =
        await FirebaseFirestore.instance.collection('users').doc(uniq_id).get();
    if (!user_data.exists) {
      //look if the uniq_id is the firstname, lastname, or email
      //if the uniq_id contains spaces match first word with firstname, lastname, or email
      var temp_data = {};
      //get all docs
      await FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((value) => {
                value.docs.forEach((element) {
                  temp_data[element.id] = element.data();
                }),
              });
      bool last_effort_worked = false;
      var last_bar_code_scanned_words = [];
      //get all the words, they are splitted by space
      last_bar_code_scanned.split(" ").forEach((element) {
        last_bar_code_scanned_words.add(element);
      });
      temp_data.forEach((key, value) {
        String firstname = value['firstname'] ?? "";
        String lastname = value['lastname'] ?? "";
        String email = value['email'] ?? "";
        //if firstname or lastname or email in last_bar_code_scanned_words
        if (last_bar_code_scanned_words.contains(firstname) ||
            last_bar_code_scanned_words.contains(lastname) ||
            last_bar_code_scanned_words.contains(email)) {
          last_effort_worked = true;
          scanned_user_data = value;
          uniq_id = key;
        }
      });
      if (!last_effort_worked) {
        // showSnackBar(context, "No user found", Colors.red);

        return;
      }
      user_data = await FirebaseFirestore.instance
          .collection('users')
          .doc(uniq_id)
          .get();
      _nr_ecuson_controller.text = uniq_id;
      last_bar_code_scanned = uniq_id;
    }
    scanned_user_data = user_data.data()!;
    scanned_user_data['overall_rating'] = 0;
    for (var review in scanned_user_data['reviews']) {
      scanned_user_data['overall_rating'] += review['rating'];
    }
    scanned_user_data['overall_rating'] /= scanned_user_data['reviews'].length;
    scanned_user_data['overall_rating'] =
        scanned_user_data['overall_rating'].toStringAsFixed(2);
    setState(() {});
  }

  void clean_up_fields() {
    _nr_ecuson_controller.clear();
    _comment_controller.clear();
    scanned_user_data.clear();
    setState(() {
      stars_filled = 0;
      allow_commenting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Review Me",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: Text("Home"),
            backgroundColor: Color.fromRGBO(48, 97, 255, 1),
          ),
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (scanned_user_data.isNotEmpty)
                        Employee_Profile(
                          full_name: scanned_user_data['firstname'] +
                              " " +
                              scanned_user_data['lastname'],
                          email: last_bar_code_scanned,
                          profile_image_Base64:
                              scanned_user_data['profile_pic'],
                          stars_out_of_5:
                              scanned_user_data['overall_rating'].toString(),
                        ),
                      Column(
                        children: [
                          Column(
                            children: [
                              if (scanned_user_data.isEmpty)
                                FlatButton(
                                  onPressed: scan_barcode,
                                  child: SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: Image.asset(
                                          'assets/icons/qrcode_icon.png')),
                                ),
                              SizedBox(height: 10),
                              if (scanned_user_data.isEmpty)
                                Search_Bar(
                                  onSubmitted: (value) {
                                    last_bar_code_scanned = value;
                                    get_scanned_user_from_database();
                                    setState(() {});
                                  },
                                  controller: _nr_ecuson_controller,
                                  hintText: "Search employee",
                                ),
                            ],
                          ),

                          //RATING

                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (scanned_user_data.isNotEmpty)
                                  // for (int i = 0; i < 5; i++)
                                  //   IconButton(
                                  //     onPressed: () => {
                                  //       setState(() {
                                  //         stars_filled = i + 1;
                                  //         allow_commenting = true;
                                  //       })
                                  //     },
                                  //     icon: Icon(
                                  //       stars_filled > i
                                  //           ? Icons.star_outlined
                                  //           : Icons.star_border,
                                  //       color:
                                  //           Color.fromARGB(255, 225, 191, 22),
                                  //     ),
                                  //     iconSize: 50,
                                  //   ),
                                  RatingBar.builder(
                                    initialRating: 3,
                                    itemCount: 5,
                                    itemBuilder: (context, index) {
                                      switch (index) {
                                        case 0:
                                          return Icon(
                                            Icons.sentiment_very_dissatisfied,
                                            color: Colors.red,
                                          );
                                        case 1:
                                          return Icon(
                                            Icons.sentiment_dissatisfied,
                                            color: Colors.redAccent,
                                          );
                                        case 2:
                                          return Icon(
                                            Icons.sentiment_neutral,
                                            color: Colors.amber,
                                          );
                                        case 3:
                                          return Icon(
                                            Icons.sentiment_satisfied,
                                            color: Colors.lightGreen,
                                          );
                                        case 4:
                                          return Icon(
                                            Icons.sentiment_very_satisfied,
                                            color: Colors.green,
                                          );
                                        default:
                                          return Icon(
                                            Icons.sentiment_neutral,
                                            color: Colors.amber,
                                          );
                                      }
                                    },
                                    onRatingUpdate: (double value) {
                                      setState(() {
                                        stars_filled = value.toInt();
                                        allow_commenting = true;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),

                          if (allow_commenting)
                            Column(
                              children: [
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Select from available Jobs",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Wrap(
                                  spacing: 10,
                                  children: [
                                    for (var job_data
                                        in scanned_user_data['jobs'])
                                      Pill_Button(
                                        onPressed: () {
                                          setState(() {
                                            titlu_la_job =
                                                job_data['job_title'];
                                          });
                                        },
                                        text: job_data['job_title'],
                                        color: titlu_la_job ==
                                                job_data['job_title']
                                            ? Colors.green
                                            : Colors.blue,
                                      )
                                  ],
                                ),
                                Modern_Text_Box(
                                  controller: _comment_controller,
                                  label: 'Comentariu* (optional)',
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: TextButton(
                                    onPressed: submit_review,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          "Trimite",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.send,
                                          size: 30,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: file_names, prefer_const_constructors, non_constant_identifier_names, avoid_print, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:getwidget/getwidget.dart';
import 'package:lottie/lottie.dart';
import 'package:review_me/widgets/Employee_Profile.dart';
import 'package:review_me/widgets/Icon_With_Text.dart';
import 'package:review_me/widgets/Modern_Text_Box.dart';

class Report_Screen extends StatefulWidget {
  final String identifier_to_report;
  const Report_Screen({
    Key? key,
    required this.identifier_to_report,
  }) : super(key: key);

  @override
  State<Report_Screen> createState() => _Report_ScreenState();
}

class _Report_ScreenState extends State<Report_Screen>
    with SingleTickerProviderStateMixin {
  var report_details_controller = TextEditingController();
  Map<String, dynamic> details = {
    'timestamp': '',
    'email': '',
    'description': '',
  };
  late AnimationController controller;
  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2300),
    );

    controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        Phoenix.rebirth(context);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future submit_report() async {
    details['timestamp'] = DateTime.now().toString();
    details['email'] = widget.identifier_to_report;
    details['description'] = report_details_controller.text.trim();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.identifier_to_report)
        .update(
      {
        'reports': FieldValue.arrayUnion([details]),
      },
    );
    void showDoneDialog() => showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Lottie.asset(
                  'assets/animations/report_animation.json',
                  repeat: false,
                  controller: controller,
                  onLoaded: (composition) {
                    controller.forward();
                  },
                ),
                Text(
                  "Report submited!",
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(0, 100, 186, 1.0),
        title: Text(
          "Report",
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: Colors.red,
                    size: 60,
                  ),
                  Text(
                    "Report Employee",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "Quick responses",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          report_details_controller.text = "Employee was rude";
                        },
                        child: Column(
                          children: [
                            Text("🤬", style: TextStyle(fontSize: 35)),
                            Text("Employee was rude",
                                style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          report_details_controller.text =
                              "My products were mistreated";
                        },
                        child: Column(
                          children: [
                            Text("🍳", style: TextStyle(fontSize: 35)),
                            Text("My products were mistreated",
                                style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          report_details_controller.text =
                              "Acted unprofessional";
                        },
                        child: Column(
                          children: [
                            Text("🤪", style: TextStyle(fontSize: 35)),
                            Text("Acted unprofessional",
                                style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Modern_Text_Box(
                      controller: this.report_details_controller,
                      label: "Details",
                      hint_on_invalid: "",
                      enable_validator: false,
                      obscure_text: false,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  GFButtonBadge(
                    text: "Submit Report",
                    onPressed: submit_report,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

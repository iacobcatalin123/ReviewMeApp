// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:review_me/screens/Report.dart';
import 'package:review_me/screens/Reviews_Page.dart';
import 'package:review_me/widgets/Icon_With_Text.dart';

class Employee_Profile extends StatefulWidget {
  final String full_name;
  final String email;
  final String profile_image_Base64;
  final String stars_out_of_5;

  const Employee_Profile({
    Key? key,
    required this.full_name,
    required this.email,
    required this.profile_image_Base64,
    required this.stars_out_of_5,
  }) : super(key: key);

  @override
  State<Employee_Profile> createState() => _Employee_ProfileState();
}

class _Employee_ProfileState extends State<Employee_Profile> {
  void report() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Report_Screen(
                  identifier_to_report: this.widget.email,
                )));
  }

  void tip() {
    return print('TIP');
  }

  Future last_reviews() async {
    var temp_data = {};
    //go to Reviews_Page supplying the reviews list
    await FirebaseFirestore.instance
        .collection('users')
        .doc(this.widget.email)
        .get()
        .then(
          (value) => {
            temp_data['lastname'] = value.data()!['lastname'],
            temp_data['firstname'] = value.data()!['firstname'],
            temp_data['profile_pic'] = value.data()!['profile_pic'],
            temp_data['reviews'] = value.data()!['reviews'],
          },
        );
    temp_data['reviews'] = temp_data['reviews'].reversed.toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Reviews_Page(
          reviews: temp_data['reviews'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GFCard(
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(this.widget.full_name),
              Text(
                this.widget.email,
                style: TextStyle(fontSize: 8),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          if (this.widget.profile_image_Base64 == "")
            Icon(
              Icons.account_circle_outlined,
              size: 100,
            )
          else
            Image.memory(
              base64Decode(this.widget.profile_image_Base64),
              height: 250,
              width: 250,
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(this.widget.stars_out_of_5 == "NaN"
                  ? "No reviews"
                  : this.widget.stars_out_of_5 + "/5"),
              Icon(
                Icons.star,
                color: Colors.yellow[900],
                size: 30,
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon_Text_Button(
                name: "Tip",
                icontouse: Icons.payment,
                onPressed: tip,
                color: Colors.green,
              ),
              Icon_Text_Button(
                  name: "Last Reviews",
                  icontouse: Icons.reviews_outlined,
                  onPressed: last_reviews,
                  color: Colors.blue),
              Icon_Text_Button(
                  name: "Report",
                  icontouse: Icons.flag_outlined,
                  onPressed: report,
                  color: Colors.red)
            ],
          )
        ],
      ),
    );
  }
}

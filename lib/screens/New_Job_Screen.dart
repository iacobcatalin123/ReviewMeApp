// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';
import 'dart:core';
import 'dart:core';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:getwidget/getwidget.dart';
import 'package:lottie/lottie.dart';
import 'package:review_me/screens/Profile.dart';
import 'package:review_me/widgets/Icon_With_Text.dart';
import 'package:review_me/widgets/Pill_Button.dart';

class New_Job_Screen extends StatefulWidget {
  final Map<String, dynamic>? job_details;
  final String? actual_job_being_modified;
  const New_Job_Screen(
      {Key? key, this.job_details, this.actual_job_being_modified})
      : super(key: key);

  @override
  State<New_Job_Screen> createState() => _New_Job_ScreenState();
}

class _New_Job_ScreenState extends State<New_Job_Screen>
    with SingleTickerProviderStateMixin {
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
        Navigator.pop(context);
        Navigator.pop(context, 'refresh');
        controller.reset();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String error_message = "";
  var job_title_controller = TextEditingController();
  var job_description_controller = TextEditingController();
  var job_company_name_controller = TextEditingController();

  DateTime? start_date;
  DateTime? end_date;

  void add_job() {
    if (job_title_controller.text.trim().isEmpty) {
      setState(() {
        error_message = "Job title is required";
      });
      return;
    }
    if (job_description_controller.text.trim().isEmpty) {
      setState(() {
        error_message = "Job description is required";
      });
      return;
    }
    if (job_company_name_controller.text.trim().isEmpty) {
      setState(() {
        error_message = "Company name is required";
      });
      return;
    }

    if (start_date == null) {
      setState(() {
        error_message = "Start date is required";
      });
      return;
    }

    if (end_date == null) {
      setState(() {
        error_message = "End date is required";
      });
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'jobs': FieldValue.arrayUnion([
        {
          'job_title': job_title_controller.text,
          'job_description': job_description_controller.text,
          'job_company_name': job_company_name_controller.text,
          'start_date': start_date.toString(),
          'end_date': end_date.toString(),
        },
      ]),
    });

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Lottie.asset(
                  'assets/animations/job_added.json',
                  repeat: false,
                  controller: controller,
                  onLoaded: (composition) {
                    controller.forward();
                  },
                ),
                Text(
                  "Job succesfully added!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
              ]),
            ));

    //animation and pop
  }

  void edit_job() {
    //get all jobs, store them, remove the one in the db, and update with all the new jobs
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((doc) {
      var jobs = doc.data()!['jobs'] as List<dynamic>;
      var new_jobs = [];
      for (var job in jobs) {
        print(job['job_title']);
        print(widget.actual_job_being_modified);
        if (job['job_title'] == widget.actual_job_being_modified) {
          print(start_date.toString() + " <DATES> " + end_date.toString());
          new_jobs.add({
            'job_title': job_title_controller.text,
            'job_description': job_description_controller.text,
            'job_company_name': job_company_name_controller.text,
            'start_date': start_date.toString(),
            'end_date': end_date.toString(),
          });
        } else {
          new_jobs.add(job);
        }
      }
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'jobs': new_jobs,
      });
    });

    //animation and pop
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Lottie.asset(
                  'assets/animations/job_edited.json',
                  repeat: false,
                  controller: controller,
                  onLoaded: (composition) {
                    controller.forward();
                  },
                ),
                Text(
                  "Success!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
              ]),
            ));
  }

  void delete_job() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'jobs': FieldValue.arrayRemove([
        {
          'job_title': job_title_controller.text,
          'job_description': job_description_controller.text,
          'job_company_name': job_company_name_controller.text,
          'start_date': start_date.toString(),
          'end_date': end_date.toString(),
        },
      ]),
    });

    //animation and pop
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Lottie.asset(
                  'assets/animations/job_deleted.json',
                  repeat: false,
                  controller: controller,
                  onLoaded: (composition) {
                    controller.forward();
                  },
                ),
                Text(
                  "Success!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
              ]),
            ));
  }

  var initialized_if_edit = false;
  @override
  Widget build(BuildContext context) {
    if (widget.job_details != null && !initialized_if_edit) {
      job_title_controller.text = widget.job_details!['job_title'];
      job_description_controller.text = widget.job_details!['job_description'];
      job_company_name_controller.text =
          widget.job_details!['job_company_name'];
      start_date = DateTime.parse(widget.job_details!['start_date']);
      end_date = DateTime.parse(widget.job_details!['end_date']);
      initialized_if_edit = true;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(48, 97, 255, 1),
        title: Text('Job Details'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: GFCard(
            content: Column(
              children: [
                Text(
                  "Job Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Icon(Icons.work),
                SizedBox(
                  height: 20,
                ),
                error_message == ""
                    ? Container()
                    : Text(
                        error_message,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                TextField(
                  controller: job_title_controller,
                  decoration: InputDecoration(
                    labelText: 'Title*',
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: job_description_controller,
                  decoration: InputDecoration(
                    labelText: 'Responsabilities*',
                    border: UnderlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: job_company_name_controller,
                  decoration: InputDecoration(
                    labelText: 'Company Name*',
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                end_date == null
                    ? Icon_Text_Button(
                        name: "Date",
                        icontouse: Icons.calendar_month,
                        onPressed: () async {
                          DateTime? res = await showDatePicker(
                              helpText: "Start Date",
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(DateTime.now().year - 100),
                              lastDate: DateTime.now());
                          if (res != null) {
                            setState(() {
                              start_date = res;
                            });

                            res = await showDatePicker(
                                helpText: "End Date",
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(DateTime.now().year - 100),
                                lastDate: DateTime.now());
                          }
                          if (res != null) {
                            setState(() {
                              end_date = res;
                            });
                          }
                        },
                        color: Colors.blue,
                        size: 50,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${start_date?.day}/${start_date?.month}/${start_date?.year}",
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("-"),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${end_date?.day}/${end_date?.month}/${end_date?.year}",
                            style: TextStyle(fontSize: 15),
                          ),
                          Spacer(),
                          // change date
                          Icon_Text_Button(
                              name: "Change Date",
                              icontouse: Icons.calendar_month_outlined,
                              onPressed: () async {
                                DateTime? res = await showDatePicker(
                                    helpText: "Start Date",
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate:
                                        DateTime(DateTime.now().year - 100),
                                    lastDate: DateTime.now());
                                if (res != null) {
                                  setState(() {
                                    start_date = res;
                                  });

                                  res = await showDatePicker(
                                      helpText: "End Date",
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate:
                                          DateTime(DateTime.now().year - 100),
                                      lastDate: DateTime.now());
                                }
                                if (res != null) {
                                  setState(() {
                                    end_date = res;
                                  });
                                }
                              },
                              color: Colors.blue)
                        ],
                      ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //if there is a job details then "edit" or "delete" else "add"
                    this.widget.job_details == null
                        ? Expanded(
                            child: Pill_Button(
                              onPressed: add_job,
                              text: "Add Job",
                              color: Colors.blue,
                            ),
                          )
                        : Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Pill_Button(
                                  onPressed: edit_job,
                                  text: "Save Edit",
                                  color: Colors.blue,
                                ),
                                Pill_Button(
                                  onPressed: delete_job,
                                  text: "Delete",
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:review_me/widgets/Review_Modern.dart';

class Reviews_Page extends StatefulWidget {
  final List<dynamic> reviews;
  const Reviews_Page({
    Key? key,
    required this.reviews,
  }) : super(key: key);

  @override
  State<Reviews_Page> createState() => _Reviews_PageState();
}

class _Reviews_PageState extends State<Reviews_Page> {
  String convert_datetime_to_string(String date_time_as_string) {
    DateTime date_time = DateTime.parse(date_time_as_string);
    String year = date_time.year.toString();
    String month = date_time.month.toString();
    String day = date_time.day.toString();
    //if hour is less than 10, add a 0 before it
    String hour = date_time.hour.toString();
    if (hour.length < 2) {
      hour = "0" + hour;
    }
    //if minute is less than 10, add a 0 before it
    String minute = date_time.minute.toString();
    if (minute.length < 2) {
      minute = "0" + minute;
    }
    String formated =
        "$day/$month/$year - $hour:$minute"; //returns formatted date time
    return formated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reviews"),
        backgroundColor: Color.fromRGBO(0, 100, 186, 1.0),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < widget.reviews.length; i++)
              Review_Modern(
                title: widget.reviews[i]['title'],
                description: widget.reviews[i]['description'],
                rating: widget.reviews[i]['rating'],
                reviwer_image_base64: widget.reviews[i]['profile_pic'] ?? "",
                reviewer_name: widget.reviews[i]['firstname'] +
                    " " +
                    widget.reviews[i]['lastname'],
                date_time: convert_datetime_to_string(
                    widget.reviews[i]['timestamp'].toString()),
              ),
          ],
        ),
      ),
    );
  }
}

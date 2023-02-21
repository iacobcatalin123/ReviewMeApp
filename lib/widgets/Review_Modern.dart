// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, file_names, camel_case_types, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:getwidget/components/card/gf_card.dart';

class Review_Modern extends StatefulWidget {
  final String title;
  final String description;
  final int rating;
  final String reviwer_image_base64;
  final String reviewer_name;
  final String date_time;

  const Review_Modern({
    Key? key,
    required this.title,
    required this.description,
    required this.rating,
    required this.reviwer_image_base64,
    required this.reviewer_name,
    required this.date_time,
  }) : super(key: key);

  @override
  State<Review_Modern> createState() => _Review_ModernState();
}

class _Review_ModernState extends State<Review_Modern> {
  @override
  Widget build(BuildContext context) {
    return GFCard(
      elevation: 2,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          // review type icon
          Icon(
            Icons.star_border,
            color: Colors.blueAccent,
            size: 30,
          ),
          SizedBox(height: 20),
          // review title
          Text(widget.title,
              style: TextStyle(fontSize: 20, color: Colors.black)),
          SizedBox(height: 10),
          Text(widget.description,
              style: TextStyle(fontSize: 14, color: Colors.black)),
          // horinzontal separator inside card
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${widget.rating}/5"),
              Icon(Icons.star, color: Colors.yellow[700]),
            ],
          ),
          SizedBox(height: 10),
          // row that has the review stars a separator line and  ability to report it
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  widget.reviwer_image_base64 != ""
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: MemoryImage(
                                base64Decode(widget.reviwer_image_base64),
                              ),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                          width: 30,
                          height: 30,
                        )
                      : Icon(Icons.account_circle_outlined),
                  SizedBox(width: 5),
                  Text(widget.reviewer_name),
                ],
              ),
              Text(this.widget.date_time),
              IconButton(
                tooltip: "Report",
                onPressed: () {},
                icon: Icon(Icons.flag_outlined, color: Colors.red[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

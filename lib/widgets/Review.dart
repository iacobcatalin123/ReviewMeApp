// ignore_for_file: prefer_const_constructors, file_names, must_be_immutable, non_constant_identifier_names

import 'package:flutter/material.dart';

class Review extends StatelessWidget {
  Review({
    Key? key,
    required bool isRecieved,
    required String title,
    required String description,
    required int rating,
  })  : _isRecieved = isRecieved,
        _title = title,
        _description = description,
        _rating = rating,
        super(key: key);

  final bool _isRecieved;
  final String _title;
  final String _description;
  final int _rating;

  String temp_description = "";
  corrected_string() {
    for (int i = 0; i < _description.length; i++) {
      if (i % 30 == 0 && i != 0) {
        temp_description += "\n";
      }
      temp_description += _description[i];
    }
    return temp_description;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isRecieved
              ? Icon(
                  Icons.reviews_outlined,
                  color: Colors.deepPurple,
                  size: 30,
                )
              : Icon(
                  Icons.reviews_outlined,
                  color: Colors.green,
                  size: 30,
                ),
          SizedBox(
            width: 10,
          ),
          Column(
            children: [
              Text(_title),
              _description.length > 50
                  ? Text(corrected_string())
                  : Text(_description),
              Row(
                children: [
                  for (int i = 0; i < 5; i++)
                    i < _rating
                        ? Icon(
                            Icons.star,
                            color: Colors.yellow[900],
                            size: 20,
                          )
                        : Icon(
                            Icons.star_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

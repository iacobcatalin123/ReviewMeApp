// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Search_Bar extends StatefulWidget {
  final Function? onChanged;
  final Function? onSubmitted;
  final String? hintText;
  final TextEditingController? controller;

  const Search_Bar({
    Key? key,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
    this.controller,
  }) : super(key: key);

  @override
  State<Search_Bar> createState() => _Search_BarState();
}

class _Search_BarState extends State<Search_Bar> {
  var possible_Emopyees = [
    "Emily",
    "John",
    "Daria",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
      //all around border with cirlce shape
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(80),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: TextField(
              onChanged: (value) => widget.onChanged?.call(value),
              onSubmitted: (value) => widget.onSubmitted?.call(value),
              controller: widget.controller,
              //remove all borders
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
              ),
              //dont underline etext
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

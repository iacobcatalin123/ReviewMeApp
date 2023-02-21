// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:review_me/widgets/Modern_Text_Box.dart';
import 'package:review_me/widgets/Pill_Button.dart';

class Template_To_Insert_Data extends StatefulWidget {
  final String title;
  final Icon? title_icon;
  final String? description;
  List<Map<String, dynamic>>? inputs;
  final Function?
      onSubmit; //result should be returned to the caller where the navigator was called from
  final Function? onChange;
  /* 
    inputs[i] = {type='textfield', label='', controller= }
  */
  Template_To_Insert_Data({
    Key? key,
    this.description,
    required this.title,
    this.title_icon,
    this.inputs,
    this.onSubmit,
    this.onChange,
  }) : super(key: key);

  @override
  State<Template_To_Insert_Data> createState() =>
      _Template_To_Insert_DataState();
}

class _Template_To_Insert_DataState extends State<Template_To_Insert_Data> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Information"),
        backgroundColor: Color.fromRGBO(48, 97, 255, 1),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: GFCard(
            content: Column(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  widget.description ?? "",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                widget.title_icon ?? Container(),
                SizedBox(
                  height: 10,
                ),
                for (var i = 0; i < widget.inputs!.length; i++)
                  Column(
                    children: [
                      Modern_Text_Box(
                        label: widget.inputs![i]['label'],
                        controller: widget.inputs![i]['controller'],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                SizedBox(
                  height: 20,
                ),
                Pill_Button(
                    onPressed: () {
                      //pop navigator
                      Navigator.pop(context);
                      this.widget.onSubmit?.call();
                    },
                    text: 'Submit',
                    color: Colors.blue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

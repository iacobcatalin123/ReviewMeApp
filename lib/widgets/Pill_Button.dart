import 'package:flutter/material.dart';

class Pill_Button extends StatefulWidget {
  final String text;
  final Color color;
  final Color? textColor;
  final Function? onPressed;
  const Pill_Button({
    Key? key,
    required this.text,
    required this.color,
    this.textColor,
    this.onPressed,
  }) : super(key: key);

  @override
  State<Pill_Button> createState() => _Pill_ButtonState();
}

class _Pill_ButtonState extends State<Pill_Button> {
  @override
  Widget build(BuildContext context) {
    //pill button
    return RaisedButton(
      child: Text(this.widget.text),
      color: this.widget.color,
      textColor: this.widget.textColor ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: () {
        this.widget.onPressed?.call();
      },
    );
  }
}

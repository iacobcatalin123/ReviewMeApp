// ignore_for_file: file_names, camel_case_types

import 'package:flutter/material.dart';

class Icon_Text_Button extends StatelessWidget {
  const Icon_Text_Button({
    Key? key,
    required String name,
    required IconData icontouse,
    required Function onPressed,
    required Color color,
    double? size,
  })  : _name = name,
        _icontouse = icontouse,
        _onPressed = onPressed,
        _color = color,
        _size = size,
        super(key: key);

  final String _name;
  final IconData _icontouse;
  final Function _onPressed;
  final Color _color;
  final double? _size;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => {_onPressed()},
      child: Column(
        children: [
          Icon(
            _icontouse,
            color: _color,
            size: _size ?? 32,
          ),
          Text(
            _name,
            style: TextStyle(color: _color),
          ),
        ],
      ),
    );
  }
}

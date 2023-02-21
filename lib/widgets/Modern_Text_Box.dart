// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names, prefer_const_constructors

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class Modern_Text_Box extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint_on_invalid;
  final bool? enable_validator;
  final bool? obscure_text;
  final bool? is_enabled;
  final Function? on_Finish;
  final Function? on_Changed;
  final Function? on_FieldSubmitted;

  const Modern_Text_Box({
    Key? key,
    this.controller,
    required this.label,
    this.hint_on_invalid,
    this.enable_validator,
    this.obscure_text,
    this.is_enabled,
    this.on_Finish,
    this.on_Changed,
    this.on_FieldSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: const Color.fromARGB(118, 3, 168, 244)),
        borderRadius: BorderRadius.circular(
          15,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: TextFormField(
          // onChanged: (text) => {this.on_Changed!(text)},
          // add on change only if this.on_Changed is not null
          onChanged: this.on_Changed == null
              ? null
              : (text) => {this.on_Changed!(text)},
          // onFieldSubmitted: (text) => {this.on_FieldSubmitted},
          onFieldSubmitted: this.on_FieldSubmitted == null
              ? null
              : (text) => {this.on_FieldSubmitted!(text)},
          // onEditingComplete: () => {this.on_Finish},
          onEditingComplete:
              this.on_Finish == null ? null : () => {this.on_Finish!()},

          enabled: this.is_enabled ?? true,
          obscureText: obscure_text ?? false,
          controller: controller ?? TextEditingController(),
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => (enable_validator ?? false) &&
                  value != null &&
                  !EmailValidator.validate(value)
              ? hint_on_invalid ?? ""
              : null,
        ),
      ),
    );
  }
}

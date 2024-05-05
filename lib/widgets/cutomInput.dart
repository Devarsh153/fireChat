import 'package:flutter/material.dart';

const customInputStyle = InputDecoration(
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xffee7b64), width: 1.7)),
  errorBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: Color.fromARGB(255, 139, 0, 0), width: 1.7)),
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xffee7b64), width: 1.7)),
  labelStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.black45),
  focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xffee7b64), width: 1.7)),
  focusColor: Colors.red,
);

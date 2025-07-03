// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hinttext;
  final bool isobsecuretext;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? ontap;
  final TextEditingController? controller;
  const CustomTextField(
      {super.key,
      required this.hinttext,
      this.ontap,
      required this.controller,
      this.readOnly = false,
      this.isobsecuretext = false,
      required this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      onTap: ontap,
      keyboardType: keyboardType,
      obscureText: isobsecuretext,
      validator: (value) {
        if (value!.trim().isEmpty) {
          return '$hinttext is missing!';
        }
        return null;
      },
      controller: controller,
      decoration: InputDecoration(hintText: hinttext),
    );
  }
}

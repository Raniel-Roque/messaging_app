import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool isMultiLine; // New parameter to indicate multi-line support
  final bool
      isUnderlined; // New parameter to indicate underline type (default is false)

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.isMultiLine = false,
    this.isUnderlined = false, // Default is false, meaning outlined by default
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: isMultiLine ? null : 1, // Allow multi-line if specified
      keyboardType: isMultiLine
          ? TextInputType.multiline
          : TextInputType.text, // Set keyboard type
      textInputAction: isMultiLine
          ? TextInputAction.newline
          : TextInputAction.done, // Set action
      decoration: InputDecoration(
        // Border configuration based on whether it's underlined or not
        enabledBorder: isUnderlined
            ? UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.secondary),
              )
            : OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.secondary),
              ),
        focusedBorder: isUnderlined
            ? UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              )
            : OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
        // Dynamically set fill color based on whether it's underlined
        fillColor: isUnderlined
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.secondary,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

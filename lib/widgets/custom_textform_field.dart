import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final String? helpText;
  final String label;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final bool readOnly;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final int? maxLines;
  final FocusNode? focusNode;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    required this.keyboardType,
    this.readOnly = false,
    this.controller,
    this.onTap,
    this.maxLines = 1,
    this.helpText,
    required this.label,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      validator: (value) {
        if (value!.isEmpty) {
          return hintText;
        }
        return null;
      },
      controller: controller,
      onTap: onTap,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      obscureText: keyboardType == TextInputType.visiblePassword ? true : false,
      decoration: InputDecoration(
          label: Text(label),
          helperText: helpText,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          hintText: hintText,
          border: const OutlineInputBorder()),
    );
  }
}

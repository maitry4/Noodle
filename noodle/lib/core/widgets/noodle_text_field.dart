import 'package:flutter/material.dart';
import 'package:noodle/core/theme/app_colors.dart';

class NoodleTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;

  const NoodleTextField({
    super.key,
    required this.hintText,
    this.controller,
  });

  @override
  State<NoodleTextField> createState() => _NoodleTextFieldState();
}

class _NoodleTextFieldState extends State<NoodleTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        hintText: widget.hintText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.borderBrown)
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
                color: AppColors.borderBrown,
          ),
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
        ),
      ),
    );
  }
}
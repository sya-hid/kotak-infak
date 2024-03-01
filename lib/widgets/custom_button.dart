import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.iconData,
    required this.onTap,
    required this.text,
  });

  final IconData? iconData;
  final VoidCallback onTap;
  final String text;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: const ButtonStyle(
            padding:
                MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 15))),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconData != null
                ? Icon(
                    iconData!,
                  )
                : const SizedBox.shrink(),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(),
            ),
          ],
        ));
  }
}

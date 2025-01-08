import 'package:flutter/material.dart';

class newButton extends StatelessWidget {
  final String text;
  final void Function() ontap;
  const newButton({super.key, required this.text, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: ontap,
      child:Container(
        decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Center(
          child: Text(text),
        )
      )
      );
  }
}
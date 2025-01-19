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
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AssetIcon('assets/img.png', size: 40),
            const SizedBox(width: 70),
            Text(text)
          ],
        )
      )
      );
  }
}

class AssetIcon extends StatelessWidget {
  final String assetPath;
  final double? size;
  final Color? color;

  const AssetIcon(
      this.assetPath, {
        this.size = 24.0,
        this.color,
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        color: color,
        width: size,
        height: size,
      ),
    );
  }
}
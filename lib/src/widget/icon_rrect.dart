import 'package:flutter/cupertino.dart';

class IconRRect extends StatelessWidget {
  const IconRRect({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 16,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF72B0FF), Color(0xFF3E78FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

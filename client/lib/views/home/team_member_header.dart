import 'package:flutter/material.dart';

class TeamMemberHeader extends StatelessWidget {
  const TeamMemberHeader({super.key});

  @override
  Widget build(BuildContext context) {
    Color? evenDarkBackground = const Color(0xFF1B6A92);
    Color? oddDarkBackground = const Color(0xFF27A07A);

    Color? evenLightBackground = const Color(0xFF9CDEFF);
    Color? oddLightBackground = const Color(0xFF81FFD7);

    Color? evenBackground = Theme.of(context).brightness == Brightness.light
        ? evenLightBackground
        : evenDarkBackground;
    Color? oddBackground = Theme.of(context).brightness == Brightness.light
        ? oddLightBackground
        : oddDarkBackground;
    return Container(
      color: evenBackground,
      child: Row(
        children: [
          Expanded(
            child: Container(
              color: oddBackground,
              child: const Center(
                child: Text(
                  'Team Member',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: evenBackground,
              child: const Center(
                child: Text(
                  'Type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: oddBackground,
              child: const Center(
                child: Text(
                  'Location',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: evenBackground,
              child: const Center(
                child: Text(
                  'Time In',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

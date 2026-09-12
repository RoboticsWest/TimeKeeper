import 'package:flutter/material.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';

class TeamMemberHeader extends StatelessWidget {
  const TeamMemberHeader({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: tableHeaderDecoration(context),
      child: const Row(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Text(
                  'Team Member',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Text(
                  'Type',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Text(
                  'Location',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Text(
                  'Time In',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

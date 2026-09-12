import 'package:flutter/material.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';

class TeamMemberHeader extends StatelessWidget {
  const TeamMemberHeader({super.key});

  static const _columns = ['Team Member', 'Type', 'Location', 'Time In'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: tableHeaderDecoration(context),
      child: Row(
        children: [
          for (final column in _columns)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: TableHeaderText(column),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CheckInOutButton extends StatelessWidget {
  final bool checkedIn;
  final VoidCallback onPressed;

  const CheckInOutButton({
    super.key,
    required this.checkedIn,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: Icon(
        checkedIn ? Icons.logout : Icons.login,
        color: Colors.white,
        size: 18,
      ),
      label: Text(
        checkedIn ? 'Check Out' : 'Check In',
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: checkedIn
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: const Size(0, 32),
      ),
      onPressed: onPressed,
    );
  }
}

import 'package:flutter/material.dart';

class RiskFlagsList extends StatelessWidget {
  final List<String> flags;

  const RiskFlagsList({super.key, required this.flags});

  @override
  Widget build(BuildContext context) {
    if (flags.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "No risk flags detected.",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Detected Risk Flags:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: flags.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
              title: Text(flags[index]),
            );
          },
        ),
      ],
    );
  }
}
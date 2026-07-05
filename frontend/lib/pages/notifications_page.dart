import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Widget notification({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(time),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        backgroundColor: const Color(0xff6E8B5E),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 12),
        children: [

          notification(
            icon: Icons.favorite,
            color: Colors.red,
            title: "Ali liked your photo",
            time: "2 min ago",
          ),

          notification(
            icon: Icons.comment,
            color: Colors.blue,
            title: "Sara commented: Amazing photo!",
            time: "15 min ago",
          ),

          notification(
            icon: Icons.workspace_premium,
            color: Colors.amber,
            title: "🎉 Congratulations!\n\nNEWBIE ➜ PHOTOGRAPHER",
            time: "1 day ago",
          ),

        ],
      ),
    );
  }
}
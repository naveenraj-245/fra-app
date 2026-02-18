import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // We moved the mock data into the State so it can be updated interactively!
  List<Map<String, dynamic>> notifications = [
    {
      "title": "Application Approved! 🎉",
      "message": "Your Individual Forest Right (IFR) claim has been approved by the Divisional Officer. You can now download your certificate from the dashboard.",
      "time": "2 hours ago",
      "type": "success",
      "isRead": false,
    },
    {
      "title": "Field Visit Scheduled",
      "message": "An officer will visit your marked land coordinates for verification on Thursday. Please ensure you are present with your original documents.",
      "time": "1 day ago",
      "type": "info",
      "isRead": false,
    },
    {
      "title": "Document Update Required",
      "message": "Please re-upload your Ration Card. The previous image was too blurry for the system to verify.",
      "time": "3 days ago",
      "type": "warning",
      "isRead": true,
    },
    {
      "title": "Welcome to Satya-Setu",
      "message": "Your account has been created successfully. Tap here to read about your rights under the Forest Rights Act.",
      "time": "1 week ago",
      "type": "welcome",
      "isRead": true,
    },
  ];

  // --- BUTTON ACTION: MARK ALL AS READ ---
  void _markAllAsRead() {
    setState(() {
      for (var notif in notifications) {
        notif['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All notifications marked as read."), backgroundColor: Colors.green),
    );
  }

  // --- BUTTON ACTION: OPEN NOTIFICATION ---
  void _openNotification(int index) {
    // 1. Mark as read
    setState(() {
      notifications[index]['isRead'] = true;
    });

    // 2. Show Dialog with details
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(notifications[index]['title']),
        content: Text(notifications[index]['message'], style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(color: Color(0xFF1B5E20))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Light green background
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF1B5E20), // Forest Green
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // ✅ The top-right button is now functional
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: "Mark all as read",
            onPressed: notifications.any((n) => n['isRead'] == false) ? _markAllAsRead : null,
          )
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(index);
              },
            ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text("No new notifications", style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- NOTIFICATION CARD ---
  Widget _buildNotificationCard(int index) {
    final notif = notifications[index];
    
    Color iconColor;
    IconData iconData;
    
    switch (notif['type']) {
      case 'success': iconColor = Colors.green; iconData = Icons.check_circle; break;
      case 'warning': iconColor = Colors.orange; iconData = Icons.warning_amber_rounded; break;
      case 'welcome': iconColor = Colors.blue; iconData = Icons.waving_hand; break;
      default: iconColor = const Color(0xFF1B5E20); iconData = Icons.info;
    }

    bool isRead = notif['isRead'];

    // ✅ Added "Dismissible" so users can swipe to delete notifications!
    return Dismissible(
      key: Key(notif['title'] + index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notification deleted"), duration: Duration(seconds: 1)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.green[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isRead ? Colors.transparent : Colors.green.shade200, width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            radius: 24,
            child: Icon(iconData, color: iconColor, size: 28),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  notif['title'], 
                  style: TextStyle(fontWeight: isRead ? FontWeight.w600 : FontWeight.bold, fontSize: 15),
                ),
              ),
              if (!isRead)
                Container(
                  width: 10, height: 10,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                notif['message'], 
                maxLines: 2, 
                overflow: TextOverflow.ellipsis, // Truncates long text for the preview
                style: TextStyle(color: Colors.grey[700], height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(notif['time'], style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
          // ✅ Tapping the card opens the full message
          onTap: () => _openNotification(index),
        ),
      ),
    );
  }
}
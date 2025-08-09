import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touria/widget/screens/event_screen/eventDetailScreen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class Notificationsdeals extends StatefulWidget {
  const Notificationsdeals({super.key});

  @override
  State<Notificationsdeals> createState() => _NotificationsdealsState();
}

class _NotificationsdealsState extends State<Notificationsdeals> {
  List<PendingNotificationRequest> _pending = [];

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    final p =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    setState(() => _pending = p);
  }

  Future<void> _onTapNotification(
    BuildContext context,
    PendingNotificationRequest notif,
  ) async {
    await flutterLocalNotificationsPlugin.cancel(notif.id);
    setState(() {
      _pending.removeWhere((n) => n.id == notif.id);
    });

    final eventId = notif.payload;

    if (eventId != null && eventId.isNotEmpty) {
      try {
        final doc =
            await FirebaseFirestore.instance
                .collection('events')
                .doc(eventId)
                .get();
        if (doc.exists) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EventDetailScreen(event: doc)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event no longer exists')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching event: $e')));
      }
    } else {
      // CHANGED: If no payload or not event, just show info
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification tapped with no event payload')),
      );
    }
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Scheduled Notifications'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 300,
                child:
                    _pending.isEmpty
                        ? const Center(child: Text('No pending notifications'))
                        : ListView.builder(
                          itemCount: _pending.length,
                          itemBuilder: (ctx, i) {
                            final notif = _pending[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 3,
                              child: ListTile(
                                leading: const Icon(
                                  Icons.notifications_active,
                                  color: Colors.blue,
                                ),
                                title: Text(
                                  notif.title ?? 'No Title',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(notif.body ?? ''),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    await flutterLocalNotificationsPlugin
                                        .cancel(notif.id);
                                    setState(() {
                                      _pending.removeAt(i);
                                    });
                                  },
                                ),
                                onTap: () => _onTapNotification(context, notif),
                              ),
                            );
                          },
                        ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  // CHANGED: Clear all notifications on demand
                  await flutterLocalNotificationsPlugin.cancelAll();
                  setState(() => _pending.clear());
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            _loadPending(); // refresh before showing
            _showDialog(context);
          },
          icon: const Icon(Icons.notifications),
        ),
        if (_pending.isNotEmpty)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  '${_pending.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

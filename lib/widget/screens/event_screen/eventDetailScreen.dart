import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:add_2_calendar/add_2_calendar.dart';

class EventDetailScreen extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotification();
  }

  Future<void> _initializeNotification() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);
    tz.initializeTimeZones();
  }

  void _shareEvent() {
    final String title = widget.event['title'];
    final String location = widget.event['location'];
    final String date = widget.event['date'];
    final String imageUrl = widget.event['imageUrl'] ?? '';

    final String text =
        '📍 $title\n📅 $date\n📌 Location: $location\n$imageUrl';
    Share.share(text);
  }

  // setReminder to include eventId and payload in notification
  Future<void> _setReminder(
    DateTime eventDateTime,
    String title,
    String eventId,
  ) async {
    final now = DateTime.now();
    final scheduleTime = eventDateTime.subtract(const Duration(minutes: 30));

    if (scheduleTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⏰ Cannot set reminder for past events.")),
      );
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      "Upcoming Event",
      "$title starts in 30 minutes",
      tz.TZDateTime.from(scheduleTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Notification for upcoming event reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: eventId, //  Pass eventId as payload here
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Reminder set for 30 mins before!")),
    );
  }

  Future<void> _addToCalendar(
    String title,
    String description,
    DateTime startTime,
  ) async {
    final Event event = Event(
      title: title,
      description: description,
      location: widget.event['location'],
      startDate: startTime,
      endDate: startTime.add(const Duration(hours: 2)),
    );

    await Add2Calendar.addEvent2Cal(event);
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final String title = event['title'];
    final String description = event['description'];
    final String location = event['location'];
    final DateTime date = DateTime.parse(event['date']);
    final double latitude = event['latitude']?.toDouble() ?? 7.8731;
    final double longitude = event['longitude']?.toDouble() ?? 80.7718;
    final String? imageUrl = event['imageUrl'];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareEvent,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.alarm),
            onPressed: () => _setReminder(date, title, widget.event.id),
            tooltip: 'Remind Me',
          ),
          IconButton(
            icon: const Icon(Icons.event),
            onPressed: () => _addToCalendar(title, description, date),
            tooltip: 'Add to Calendar',
          ),
        ],
      ),
      // floating button to contact organizer
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Contact Organizer action tapped.")),
          );
        },
        icon: const Icon(Icons.contact_page),
        label: const Text("Contact Organizer"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (imageUrl != null)
            Hero(
              // Hero animation for image
              tag: widget.event.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(imageUrl, height: 200, fit: BoxFit.cover),
              ),
            ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '📅 ${date.toLocal()}'.split(' ')[0],
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text('📍 $location', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Text(description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          const Text(
            'Event Location on Map:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 12,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('eventLocation'),
                  position: LatLng(latitude, longitude),
                  infoWindow: InfoWindow(title: title),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

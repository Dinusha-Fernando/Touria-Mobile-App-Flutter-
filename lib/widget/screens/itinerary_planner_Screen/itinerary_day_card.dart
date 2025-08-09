import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:touria/data/model/itinerary_model.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class ItineraryDayCard extends StatelessWidget {
  final int dayIndex;
  final List<ItineraryItem> items;
  final Function(int, ItineraryItem) onAddActivity;
  final Function(int, int, ItineraryItem) onEditActivity;

  ItineraryDayCard({
    super.key,
    required this.dayIndex,
    required this.items,
    required this.onAddActivity,
    required this.onEditActivity,
  }) {
    tzdata.initializeTimeZones();
  }

  Future<void> _scheduleNotification(
    int dayIndex,
    int activityIndex,
    ItineraryItem item,
  ) async {
    try {
      final now = DateTime.now();

      final timeParts = item.time.split(':');
      if (timeParts.length < 2) throw FormatException("Invalid time format");

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      ).add(Duration(days: dayIndex));

      if (scheduledDate.isBefore(now)) {
        print("Skipping notification for past time.");
        return;
      }

      final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
      final notifId = dayIndex * 100 + activityIndex;

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notifId,
        'Itinerary Reminder',
        '${item.title} at ${item.time} (Day ${dayIndex + 1})',
        scheduledTZ,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'itinerary_channel',
            'Itinerary Notifications',
            channelDescription: 'Reminders for itinerary activities',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode:
            AndroidScheduleMode.exactAllowWhileIdle, // ✅ updated
        payload: 'day_${dayIndex}_activity_$activityIndex',
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  void _showActivityDialog({
    required BuildContext context,
    required String title,
    String initialtitle = '',
    String initialtime = '',
    String initialNote = '',
    required void Function(String time, String title, String note) onSave,
  }) {
    final activityController = TextEditingController(text: initialtitle);
    final timeController = TextEditingController(text: initialtime);
    final noteController = TextEditingController(text: initialNote);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: activityController,
                    decoration: const InputDecoration(
                      hintText: "Enter Activity name",
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: timeController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Time (HH:mm)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(hintText: 'Enter Note'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = activityController.text.trim();
                  final time = timeController.text.trim();
                  final note = noteController.text.trim();
                  if (title.isNotEmpty && time.isNotEmpty) {
                    onSave(time, title, note);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ExpansionTile(
        title: Text("Day ${dayIndex + 1}"),
        children: [
          ...items.asMap().entries.map((entry) {
            int index = entry.key;
            ItineraryItem item = entry.value;
            return ListTile(
              leading: const Icon(Icons.access_time),
              title: Text("${item.time} - ${item.title}"),
              subtitle: Text(item.note),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showActivityDialog(
                    context: context,
                    title: 'Edit Activity',
                    initialtitle: item.title,
                    initialtime: item.time,
                    initialNote: item.note,
                    onSave: (time, title, note) {
                      final updatedItem = ItineraryItem(
                        time: time,
                        title: title,
                        note: note,
                      );
                      onEditActivity(dayIndex, index, updatedItem);
                      _scheduleNotification(dayIndex, index, updatedItem);
                    },
                  );
                },
              ),
            );
          }).toList(),
          TextButton.icon(
            onPressed: () {
              _showActivityDialog(
                context: context,
                title: 'Add Activity',
                onSave: (time, title, note) {
                  final newItem = ItineraryItem(
                    time: time,
                    title: title,
                    note: note,
                  );
                  onAddActivity(dayIndex, newItem);
                  _scheduleNotification(dayIndex, items.length, newItem);
                },
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Activity'),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:touria/widget/screens/event_screen/eventDetailScreen.dart';
import 'package:touria/widget/screens/home_Screen/NotificationsDeals.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  DateTimeRange? _dateRange;
  Set<String> _bookmarkedEventsIds = {};
  bool _showBookmarksOnly = false;

  final List<String> _categories = [
    'All',
    'Music',
    'Cultural',
    'Environment',
    'Sports',
    'Food',
    'Education',
    'Health',
  ];

  @override
  void initState() {
    super.initState();
    initializeTimeZones();
    _initializeNotifications();
    _loadBookmarks();
  }

  Future<void> _initializeNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('bookMarks') ?? [];
    setState(() {
      _bookmarkedEventsIds = ids.toSet();
    });
  }

  Future<void> scheduleNotification(
    String title,
    DateTime dateTime,
    String eventId,
  ) async {
    if (dateTime.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        dateTime.hashCode,
        'Upcoming Event',
        title,
        tz.TZDateTime.from(
          dateTime.subtract(const Duration(hours: 1)),
          tz.local,
        ),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_reminder_channel',
            'Event Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        payload: eventId, //  store eventId payload
      );
    }
  }

  Future<void> _toggleBookmark(
    String eventId,
    String title,
    DateTime dateTime,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (_bookmarkedEventsIds.contains(eventId)) {
      _bookmarkedEventsIds.remove(eventId);
      await flutterLocalNotificationsPlugin.cancel(dateTime.hashCode);
    } else {
      _bookmarkedEventsIds.add(eventId);
      await scheduleNotification(title, dateTime, eventId);
    }
    await prefs.setStringList('bookMarks', _bookmarkedEventsIds.toList());
    setState(() {});
  }

  bool _matchesFilters(QueryDocumentSnapshot event) {
    final title = event['title'].toString().toLowerCase();
    final location = event['location'].toString().toLowerCase();
    final category = event['category'];
    final date = DateTime.parse(event['date']);

    if (_showBookmarksOnly && !_bookmarkedEventsIds.contains(event.id))
      return false;
    if (_selectedCategory != 'All' && category != _selectedCategory)
      return false;
    if (_dateRange != null &&
        (date.isBefore(_dateRange!.start) || date.isAfter(_dateRange!.end)))
      return false;
    if (_searchQuery.isNotEmpty &&
        !(title.contains(_searchQuery.toLowerCase()) ||
            location.contains(_searchQuery.toLowerCase())))
      return false;

    return true;
  }

  //  Add category colors
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Music':
        return Colors.purple.shade100;
      case 'Sports':
        return Colors.green.shade100;
      case 'Food':
        return Colors.orange.shade100;
      case 'Education':
        return Colors.blue.shade100;
      case 'Cultural':
        return Colors.teal.shade100;
      case 'Environment':
        return Colors.lightGreen.shade100;
      case 'Health':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {}); // Refresh stream
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              floating: true,
              pinned: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed:
                    () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/main',
                      (route) => false,
                    ),
              ),
              actions: [Notificationsdeals()],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Events'),
                // background: Lottie.asset(),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by title or location...',
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onChanged:
                          (val) => setState(() {
                            _searchQuery = val;
                          }),
                    ),
                    const SizedBox(height: 10),

                    //  Category chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            _categories.map((cat) {
                              final selected = _selectedCategory == cat;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(cat),
                                  selected: selected,
                                  onSelected:
                                      (_) => setState(
                                        () => _selectedCategory = cat,
                                      ),
                                  selectedColor: Colors.blue.shade300,
                                  backgroundColor: Colors.grey.shade300,
                                  labelStyle: TextStyle(
                                    color:
                                        selected ? Colors.white : Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2025),
                              );
                              if (picked != null) {
                                setState(() => _dateRange = picked);
                              }
                            },
                            icon: const Icon(Icons.date_range),
                            label: const Text('Date Range'),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Bookmark filter toggle switch
                        Row(
                          children: [
                            const Text("Bookmarked Only"),
                            Switch(
                              value: _showBookmarksOnly,
                              onChanged:
                                  (val) =>
                                      setState(() => _showBookmarksOnly = val),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('events')
                      .orderBy('date')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final events =
                    snapshot.data!.docs.where(_matchesFilters).toList();

                if (events.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text("No Events found matching filters."),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final event = events[index];
                    final title = event['title'];
                    final date = DateTime.parse(event['date']);
                    final description = event['description'];
                    final location = event['location'];
                    final eventId = event.id;
                    final imageUrl = event['imageUrl'];

                    //  Calculate countdown string
                    final remaining = date.difference(DateTime.now());
                    final countdown =
                        remaining.inDays > 0
                            ? "${remaining.inDays} days left"
                            : remaining.inHours > 0
                            ? "${remaining.inHours} hours left"
                            : "Starting soon!";

                    return Card(
                      color: _getCategoryColor(
                        event['category'],
                      ), //  color-coded cards
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: Hero(
                          //  Hero animation for image
                          tag: eventId,
                          child:
                              imageUrl != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      imageUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : SizedBox(width: 70, height: 70),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("📅 ${date.toLocal()}".split(' ')[0]),
                            const SizedBox(height: 4),
                            Text("📍 $location"),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              countdown, // Show countdown
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed:
                              () => _toggleBookmark(eventId, title, date),
                          icon: Icon(
                            _bookmarkedEventsIds.contains(eventId)
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: Colors.blue,
                          ),
                        ),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => EventDetailScreen(
                                      event:
                                          event
                                              as DocumentSnapshot<
                                                Map<String, dynamic>
                                              >,
                                    ),
                              ),
                            ),
                      ),
                    );
                  }, childCount: events.length),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

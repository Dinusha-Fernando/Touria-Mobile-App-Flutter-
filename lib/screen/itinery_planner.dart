import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:touria/data/model/itinerary_model.dart';

import 'package:touria/services/provider/theme_provider.dart';
import 'package:touria/widget/screens/home_Screen/aiTravelAssistant.dart';
import 'package:touria/widget/screens/itinerary_planner_Screen/itinerary_day_card.dart';
import 'package:touria/widget/screens/itinerary_planner_Screen/trip_form.dart';

class ItineraryPlanner extends StatefulWidget {
  const ItineraryPlanner({super.key});

  @override
  State<ItineraryPlanner> createState() => _ItineraryPlannerState();
}

class _ItineraryPlannerState extends State<ItineraryPlanner> {
  final TextEditingController _tripTitleController = TextEditingController();
  String tripTitle = '';
  DateTime? startDate;
  DateTime? endDate;

  List<Map<String, dynamic>> allTrips = []; // List to hold multiple trips
  int? selectedTripIndex;
  String userId = 'user_Id';

  @override
  void initState() {
    super.initState();
    loadTripsFromFirestore();
  }

  Future<void> loadTripsFromFirestore() async {
    final tripsSnapshot =
        await FirebaseFirestore.instance
            .collection('itineraries')
            .doc(userId)
            .collection('trips')
            .get();
    List<Map<String, dynamic>> loadedTrips = [];

    for (var doc in tripsSnapshot.docs) {
      final tripData = doc.data();
      final start = (tripData['startDate'] as Timestamp).toDate();
      final end = (tripData['endDate'] as Timestamp).toDate();
      final dayCount = end.difference(start).inDays + 1;

      loadedTrips.add({
        'trip_Id': doc.id,
        'title': tripData['title'],
        'startDate': start,
        'endDate': end,
        'dayCount': dayCount,
        'itinerary': List.generate(
          dayCount,
          (_) => <ItineraryItem>[],
        ), // placeholder
      });
    }
    setState(() {
      allTrips = loadedTrips;
    });
  }

  void createTrip() async {
    if (_tripTitleController.text.isEmpty ||
        startDate == null ||
        endDate == null)
      return;
    if (startDate!.isAfter(endDate!)) return;

    final title = _tripTitleController.text.trim();
    final dayCount = endDate!.difference(startDate!).inDays + 1;
    final tripRef = await FirebaseFirestore.instance
        .collection('itineraries')
        .doc(userId)
        .collection('trips')
        .add({
          'title': title,
          'startDate': Timestamp.fromDate(startDate!),
          'endDate': Timestamp.fromDate(endDate!),
        });

    for (int i = 0; i < dayCount; i++) {
      await tripRef.collection('itinerary').doc('day_$i').set({
        'activities': [],
      });
    }

    setState(() {
      allTrips.add({
        'trip_Id': tripRef.id,
        'title': title,
        'startDate': startDate,
        'endDate': endDate,
        'dayCount': dayCount,
        'itinerary': List.generate(dayCount, (_) => <ItineraryItem>[]),
      });
      selectedTripIndex = allTrips.length - 1;
      _tripTitleController.clear();
      startDate = null;
      endDate = null;
    });
  }

  void onAddActivity(int dayIndex, ItineraryItem activity) async {
    final tripId = allTrips[selectedTripIndex!]['trip_Id'];

    final docRef = FirebaseFirestore.instance
        .collection('itineraries')
        .doc(userId)
        .collection('trips')
        .doc(tripId)
        .collection('itinerary')
        .doc('day_$dayIndex');

    await docRef.update({
      'activities': FieldValue.arrayUnion([
        {'time': activity.time, 'title': activity.title, 'note': activity.note},
      ]),
    });

    setState(() {
      allTrips[selectedTripIndex!]['itinerary'][dayIndex].add(activity);
    });
  }

  void onEditActivity(
    int dayIndex,
    int activityIndex,
    ItineraryItem updatedItem,
  ) async {
    final tripId = allTrips[selectedTripIndex!]['trip_Id'];

    final docRef = FirebaseFirestore.instance
        .collection('itineraries')
        .doc(userId)
        .collection('trips')
        .doc(tripId)
        .collection('itinerary')
        .doc('day_$dayIndex');

    final snapshot = await docRef.get();
    final currentActivities = List<Map<String, dynamic>>.from(
      snapshot.data()?['activities'] ?? [],
    );

    if (activityIndex >= currentActivities.length) return;

    currentActivities[activityIndex] = {
      'time': updatedItem.time,
      'title': updatedItem.title,
      'note': updatedItem.note,
    };

    await docRef.update({'activities': currentActivities});

    setState(() {
      allTrips[selectedTripIndex!]['itinerary'][dayIndex][activityIndex] =
          updatedItem;
    });
  }

  Future<void> deleteTripFromFirestore(String tripId) async {
    final tripRef = FirebaseFirestore.instance
        .collection('itineraries')
        .doc(userId)
        .collection('trips')
        .doc(tripId);

    final itinerarySnapshot = await tripRef.collection('itinerary').get();
    for (var doc in itinerarySnapshot.docs) {
      await doc.reference.delete();
    }
    await tripRef.delete();
  }

  Future<List<List<ItineraryItem>>> _buildItineraryData(
    Map<String, dynamic> trip,
  ) async {
    final dayCount =
        (trip['endDate'] as DateTime)
            .difference(trip['startDate'] as DateTime)
            .inDays +
        1;
    final itinerary = List.generate(dayCount, (_) => <ItineraryItem>[]);

    final snapshot =
        await FirebaseFirestore.instance
            .collection('itineraries')
            .doc(userId)
            .collection('trips')
            .doc(trip['trip_Id'])
            .collection('itinerary')
            .get();

    for (var doc in snapshot.docs) {
      final index = int.tryParse(doc.id.replaceFirst('day_', '')) ?? 0;
      final data = doc.data();
      final activities = (data['activities'] ?? []) as List<dynamic>;
      itinerary[index] =
          activities
              .map(
                (a) => ItineraryItem(
                  time: a['time'] ?? '',
                  title: a['title'] ?? '',
                  note: a['note'] ?? '',
                ),
              )
              .toList();
    }

    return itinerary;
  }

  @override
  void dispose() {
    _tripTitleController.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main',
              (route) => false,
            );
          },
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        title: Row(
          children: [
            Text(
              'Itinerary Planner',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
      floatingActionButton: Tooltip(
        message: 'Chat With AI Assistant',
        child: Aitravelassistant(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body:
          selectedTripIndex != null
              ? FutureBuilder<List<List<ItineraryItem>>>(
                future: _buildItineraryData(allTrips[selectedTripIndex!]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  //  assign loaded itinerary to selected trip
                  allTrips[selectedTripIndex!]['itinerary'] = snapshot.data!;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Trip: ${allTrips[selectedTripIndex!]['title']}',
                            ),
                            TextButton(
                              onPressed:
                                  () =>
                                      setState(() => selectedTripIndex = null),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.arrow_back_ios, size: 16),
                                  Text('Back to Trips'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              allTrips[selectedTripIndex!]['itinerary'].length,
                          itemBuilder:
                              (context, index) => ItineraryDayCard(
                                dayIndex: index,
                                items:
                                    allTrips[selectedTripIndex!]['itinerary'][index],
                                onAddActivity: onAddActivity,
                                onEditActivity: onEditActivity,
                              ),
                        ),
                      ),
                    ],
                  );
                },
              )
              : Column(
                children: [
                  TripForm(
                    tripTitleController: _tripTitleController,
                    startDate: startDate,
                    endDate: endDate,
                    onCreateTrip: createTrip,
                    onStartDatePicked:
                        (date) => setState(() => startDate = date),
                    onEndDatePicked: (date) => setState(() => endDate = date),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'All Trips',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allTrips.length,
                      itemBuilder:
                          (context, index) => Dismissible(
                            key: Key(allTrips[index]['trip_Id']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) async {
                              await deleteTripFromFirestore(
                                allTrips[index]['trip_Id'],
                              );
                              setState(() {
                                allTrips.removeAt(index);
                                if (selectedTripIndex == index)
                                  selectedTripIndex = null;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Trip Deleted')),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(allTrips[index]['title']),
                                subtitle: Text(
                                  DateFormat.yMMMd().format(
                                    allTrips[index]['startDate'],
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap:
                                    () => setState(
                                      () => selectedTripIndex = index,
                                    ),
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

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:touria/constant/colors.dart';
import 'package:touria/widget/screens/services_screen/weatherCard.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String label;
  final IconData icon;
  const ServiceDetailScreen({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool isLoading = true;
  late Future<List<Map<String, dynamic>>> serviceData;

  //NEW STATE VARIABLES FOR WEATHER
  String? weatherDescription;
  double? temperature;
  String? cityName;
  String? weatherIconUrl;

  //Real 5-day forecast data list---
  List<Map<String, dynamic>> fiveDayForecast = [];

  @override
  void initState() {
    super.initState();
    serviceData = _fetchServiceData(widget.label.toLowerCase());
    _determinePositionAndFetchWeather();
  }

  Future<List<Map<String, dynamic>>> _fetchServiceData(String label) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection(label).get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Error fetching $label data: $e');
    }
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    const apiKey = '311f052e68f22451b3424b07acfcf04a';

    final currentWeatherUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );

    final forecastUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
    );

    try {
      final response = await http.get(currentWeatherUrl);
      final forecastUrlResponse = await http.get(forecastUrl);

      if (response.statusCode == 200 && forecastUrlResponse.statusCode == 200) {
        final currentData = json.decode(response.body);
        final forecastData = json.decode(forecastUrlResponse.body);

        setState(() {
          temperature =
              currentData['main']['temp']?.toDouble(); //  ensure double
          weatherDescription = currentData['weather'][0]['description'];
          cityName = currentData['name'];
          final iconCode = currentData['weather'][0]['icon'];
          weatherIconUrl = 'https://openweathermap.org/img/wn/$iconCode@2x.png';

          fiveDayForecast
              .clear(); //  clear previous forecast data before adding

          final list = forecastData['list'] as List;
          final now = DateTime.now();

          // Get forecast for next 5 days, roughly at 12:00 each day
          for (int i = 0; i < list.length; i++) {
            DateTime dt = DateTime.fromMillisecondsSinceEpoch(
              list[i]['dt'] * 1000,
            );
            if (dt.hour == 12 && dt.isAfter(now)) {
              if (fiveDayForecast.length < 5) {
                final temp = list[i]['main']['temp'].round();
                final day = _weekdayShortName(dt.weekday);
                final icon = list[i]['weather'][0]['icon'];
                fiveDayForecast.add({
                  'day': day,
                  'temp': '$temp°',
                  'icon': 'https://openweathermap.org/img/wn/$icon@2x.png',
                });
              }
            }
          }
        });
      } else {
        setState(() {
          weatherDescription = "Failed to fetch weather data";
        });
      }
    } catch (e) {
      setState(() {
        weatherDescription = "Error fetching weather : $e";
      });
    }
  }

  String _weekdayShortName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  //FUNCTION TO DETERMINE LOCATION AND FETCH WEATHER

  Future<void> _determinePositionAndFetchWeather() async {
    bool serviceEnabled;
    LocationPermission permission;

    //Test if Location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        weatherDescription = "Location Services are disabled";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          weatherDescription = "Location Permission Denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        weatherDescription = "Location Permission Permanently Denied";
      });
      return;
    }

    //when permission granted, get position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    //Fetch weather with position
    await _fetchWeather(position.latitude, position.longitude);
  }

  // Generalized list builder for all service types
  Widget _buildServiceList(List<Map<String, dynamic>> dataList) {
    if (dataList.isEmpty) {
      return Center(child: Text('No ${widget.label.toLowerCase()} available.'));
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        final item = dataList[index];

        //data rendering cards
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                item['image'] != null && item['image'].toString().isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['image'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 50),
                      ),
                    )
                    : const Icon(Icons.image, size: 80),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? 'No name',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      if (item['description'] != null)
                        Text(
                          item['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      if (item['rating'] != null)
                        Text(
                          'Rating: ${item['rating']}',
                          style: TextStyle(fontSize: 14),
                        ),
                      if (item['location'] != null)
                        Text(
                          'Location: ${item['location']}',
                          style: TextStyle(fontSize: 14),
                        ),
                      if (item['contact'] != null)
                        Text(
                          'Contact: ${item['contact']}',
                          style: TextStyle(fontSize: 14),
                        ),
                      if (item['amenities'] != null)
                        Text(
                          'Amenities: ${item['amenities']}',
                          style: TextStyle(fontSize: 14),
                        ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (item['contact'] != null)
                            ElevatedButton.icon(
                              onPressed: () {
                                final phone = item['contact'].toString();
                                _launchPhone(phone);
                              },
                              icon: Icon(Icons.phone),
                              label: Text("Contact Now"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $phone')),
      ); //  Show error  instead of throwing exception
    }
  }

  // Simplified content rendering
  Widget _getServiceContent() {
    if (widget.label.toLowerCase() == 'weather') {
      return _buildWeatherContent(); // Show weather card
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: serviceData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        }
        return _buildServiceList(snapshot.data!);
      },
    );
  }

  Color _getMessageColor() {
    //  Show warnings in orange instead of red
    if (weatherDescription != null) {
      if (weatherDescription!.contains("Permission") ||
          weatherDescription!.contains("Location")) {
        return Colors.orange;
      }
    }
    return Colors.red;
  }

  Widget _buildWeatherContent() {
    if (weatherDescription == null) {
      return Center(child: CircularProgressIndicator());
    }
    if (temperature != null) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Weathercard(
              city: cityName ?? '',
              temp: temperature!.round().toString(),
              condition: weatherDescription ?? '',
              icon: weatherIconUrl ?? '',
            ),
            const SizedBox(height: 20),
            const Text(
              '5-Day Forecast',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            //5-Day Forecast Row
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: fiveDayForecast.length,
                itemBuilder: (context, index) {
                  final forecast = fiveDayForecast[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          forecast['day'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Image.network(
                          forecast['icon'],
                          width: 50,
                          height: 50,
                          errorBuilder:
                              (context, error, StackTrace) =>
                                  Icon(Icons.wb_sunny, size: 50),
                        ),
                        SizedBox(height: 8),
                        Text(
                          forecast['temp'] ?? '',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
    // if (fiveDayForecast.isNotEmpty)
    //   SizedBox(
    //     height: 120,
    //     child: ListView.builder(
    //       scrollDirection: Axis.horizontal,
    //       itemCount: fiveDayForecast.length,
    //       itemBuilder: (context, index) {
    //         final forecast = fiveDayForecast[index];
    //         return Card(
    //           margin: const EdgeInsets.symmetric(horizontal: 8),
    //           child: Container(
    //             width: 80,
    //             padding: const EdgeInsets.all(12),
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Text(
    //                   forecast['day'],
    //                   style: const TextStyle(
    //                     fontWeight: FontWeight.bold,
    //                     fontSize: 16,
    //                   ),
    //                 ),
    //                 const SizedBox(height: 8),
    //                 Text(forecast['temp']),
    //               ],
    //             ),
    //           ),
    //         );
    //       },
    //     ),
    //   )
    //else
    //const Text('No forecast data available'),
    else {
      // show error or message if no temp
      return Center(
        child: Text(
          weatherDescription!,
          style: TextStyle(color: _getMessageColor(), fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.label,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 44, 149, 205),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          splashRadius: 24,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: _getServiceContent(),
        ),
      ),
    );
  }
}

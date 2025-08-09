import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:touria/services/provider/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final String placeId;
  final String apiKey;

  const PlaceDetailsScreen({
    super.key,
    required this.placeId,
    required this.apiKey,
  });

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  Map<String, dynamic>? placeDetails;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPlaceDetails();
  }

  Future<void> fetchPlaceDetails() async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.placeId}&key=${widget.apiKey}&fields=name,rating,formatted_address,geometry,photos,formatted_phone_number,website,opening_hours',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'OK') {
        setState(() {
          placeDetails = data['result'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = data['error_message'] ?? 'Failed to load place details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _openMaps() async {
    if (placeDetails == null) return;
    final location = placeDetails!['geometry']?['location'];
    if (location == null) return;

    final lat = location['lat'];
    final lng = location['lng'];

    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Could not launch URL
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  String? getPhotoUrl() {
    if (placeDetails == null) return null;
    if (placeDetails!['photos'] == null) return null;
    final photoReference = placeDetails!['photos'][0]['photo_reference'];
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=${widget.apiKey}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(placeDetails?['name'] ?? 'Loading...'),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text(error!))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (getPhotoUrl() != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          getPhotoUrl()!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey[700],
                        ),
                      ),
                    const SizedBox(height: 16),

                    Text(
                      placeDetails!['name'] ?? '',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      placeDetails!['formatted_address'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),

                    if (placeDetails!['rating'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[600]),
                          SizedBox(width: 6),
                          Text(
                            placeDetails!['rating'].toString(),
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),

                    if (placeDetails!['formatted_phone_number'] != null) ...[
                      Row(
                        children: [
                          Icon(Icons.phone, color: Color(0xff0091d5)),
                          SizedBox(width: 6),
                          Text(placeDetails!['formatted_phone_number']),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (placeDetails!['website'] != null) ...[
                      GestureDetector(
                        onTap: () async {
                          final url = placeDetails!['website'];
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.language, color: Color(0xff0091d5)),
                            SizedBox(width: 6),
                            Text(
                              placeDetails!['website'],
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openMaps,
                            icon: const Icon(Icons.map),
                            label: const Text('Open in Google Maps'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: const Color(0xff0091d5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            Icons.bookmark_add,
                            color: Color(0xff0091d5),
                          ),
                          onPressed: () async {
                            final name =
                                placeDetails?['name'] ?? 'unknown place';
                            final placeId = widget.placeId;

                            try {
                              await FirebaseFirestore.instance
                                  .collection('placeBookmark')
                                  .doc(placeId)
                                  .set({'placeName': name, 'placeId': placeId});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('bookmarked')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error:$e')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}

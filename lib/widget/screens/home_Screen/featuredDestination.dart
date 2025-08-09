import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Featureddestination extends StatefulWidget {
  const Featureddestination({super.key});

  @override
  State<Featureddestination> createState() => _FeatureddestinationState();
}

class _FeatureddestinationState extends State<Featureddestination> {
  List<Map<String, dynamic>> places = [];
  final String apiKey = 'AIzaSyAielZQKKUv-leUMV1lzoImSgCAViBAQyE';

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  Future<void> fetchPlaces() async {
    final String query = 'tourist+attractions+in+Sri+Lanka';
    final String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;

      setState(() {
        places =
            results.map<Map<String, dynamic>>((place) {
              String photoReference = '';
              if (place['photos'] != null && place['photos'].isNotEmpty) {
                photoReference = place['photos'][0]['photo_reference'];
              }

              return {
                'name': place['name'],
                'photo': photoReference,
                'address': place['formatted_address'] ?? '',
                'rating': place['rating']?.toString() ?? 'N/A',
                'lat': place['geometry']['location']['lat'],
                'lng': place['geometry']['location']['lng'],
              };
            }).toList();
      });
    } else {
      print('Failed to load places');
    }
  }

  void openInGoogleMaps(double lat, double lng) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      print('Could not launch Google Maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          final imageUrl =
              place['photo'].isNotEmpty
                  ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place['photo']}&key=$apiKey'
                  : null;

          return GestureDetector(
            onTap: () => openInGoogleMaps(place['lat'], place['lng']),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 200,
              decoration: BoxDecoration(
                color: Color(0xff0091d5).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        imageUrl,
                        width: 200,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 200,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: const Icon(Icons.image_not_supported),
                    ),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        place['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      place['address'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          place['rating'],
                          style: const TextStyle(fontSize: 12),
                        ),

                        // Text(places[index]['image']!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

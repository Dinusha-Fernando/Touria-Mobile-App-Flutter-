import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:touria/services/provider/theme_provider.dart';
import 'package:touria/widget/screens/home_Screen/aiTravelAssistant.dart';
import 'package:touria/widget/screens/search_Screen/PlaceDetailsScreen.dart';
import 'package:touria/widget/screens/search_Screen/bookmarks_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _predictions = [];

  //Firestore-based set of IDs
  Set<String> bookmarkedIds = {};

  final String apiKey = "AIzaSyAielZQKKUv-leUMV1lzoImSgCAViBAQyE";

  final List<Map<String, String>> suggestions = [
    {
      "title": "Sigiriya Rock Fortress",
      "subtitle": "Historic site in Central Province",
    },
    {
      "title": "Unawatuna Beach",
      "subtitle": "Southern paradise for surfers & swimmers",
    },
    {"title": "Kandy", "subtitle": "Sacred city with cultural richness"},
    {"title": "Yala Safari", "subtitle": "Best place to see leopards 🐆"},
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  //Firestore based method to load bookmarks
  Future<void> _loadBookmarks() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('placeBookmark').get();
    setState(() {
      bookmarkedIds = snapshot.docs.map((doc) => doc.id).toSet();
    });
  }

  Future<void> fetchPredictions(String input) async {
    if (input.isEmpty) {
      setState(() => _predictions = []);
      return;
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:lk',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'OK') {
        setState(() => _predictions = data['predictions']);
        await _loadBookmarks();
      } else {
        debugPrint(
          "Google API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}",
        );
        setState(() => _predictions = []);
      }
    } catch (e) {
      debugPrint("Exception: $e");
      setState(() => _predictions = []);
    }
  }

  void _onTagSelected(String tag) {
    final query = "$tag in Sri Lanka";
    setState(() {
      _controller.text = query;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: query.length),
      );
    });
    fetchPredictions(query);
  }

  Widget _buildTag(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        backgroundColor: Color(0xff0091d5).withOpacity(0.1),
        label: Text(label, style: TextStyle(color: Color(0xff0091d5))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed:
              () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/main',
                (route) => false,
              ),
        ),
        title: Text(
          'Search',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        actions: [
          // Updated bookmarks button to pass the map instead of set
          IconButton(
            icon: Icon(
              Icons.bookmarks,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookmarksScreen(apiKey: apiKey),
                ),
              );
              await _loadBookmarks();
            },
          ),
        ],
      ),

      floatingActionButton: Tooltip(
        message: 'Chat With AI Assistant',
        child: Aitravelassistant(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(30),
                  child: TextField(
                    controller: _controller,
                    onChanged: fetchPredictions,
                    decoration: InputDecoration(
                      hintText: 'Search destinations, hotels, places...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: Icon(Icons.mic),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              // Prediction results
              if (_predictions.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _predictions.length,
                  itemBuilder: (context, index) {
                    final p = _predictions[index];
                    final placeId = p['place_id'];
                    final placeName = p['description'] ?? 'Unknown Place';

                    return ListTile(
                      title: Text(placeName),
                      leading: Icon(
                        Icons.location_on,
                        color: Color(0xff0091d5),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          bookmarkedIds.contains(placeId)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: Color(0xff0091d5),
                        ),
                        onPressed: () async {
                          if (bookmarkedIds.contains(placeId)) {
                            await FirebaseFirestore.instance
                                .collection('placeBookmark')
                                .doc(placeId)
                                .delete();
                            setState(() => bookmarkedIds.remove(placeId));
                          } else {
                            await FirebaseFirestore.instance
                                .collection('placeBookmark')
                                .doc(placeId)
                                .set({
                                  'placeId': placeId,
                                  'placeName': placeName,
                                });
                            setState(() => bookmarkedIds.add(placeId));
                          }
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PlaceDetailsScreen(
                                  placeId: placeId,
                                  apiKey: apiKey,
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),

              // No results found
              if (_predictions.isEmpty && _controller.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("No results found."),
                ),

              SizedBox(height: 20),

              // Popular Tags
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Popular Tags',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildTag('Beaches', () => _onTagSelected('Beaches')),
                    _buildTag(
                      'Cultural Sites',
                      () => _onTagSelected('Cultural Sites'),
                    ),
                    _buildTag('Wildlife', () => _onTagSelected('Wildlife')),
                    _buildTag('Hiking', () => _onTagSelected('Hiking')),
                    _buildTag(
                      'Luxury Hotels',
                      () => _onTagSelected('Luxury Hotels'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Suggestions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Suggestions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return _SearchSuggestion(
                    title: suggestions[index]['title']!,
                    subtitle: suggestions[index]['subtitle']!,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSuggestion extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SearchSuggestion({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.place, color: Color(0xff0091d5)),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () {
          // Optional: implement navigation or other action
        },
      ),
    );
  }
}

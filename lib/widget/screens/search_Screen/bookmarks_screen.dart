import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:touria/widget/screens/search_Screen/PlaceDetailsScreen.dart';

class BookmarksScreen extends StatelessWidget {
  // Change Set<String> to Map<String, String>
  // final Map<String, String> bookmarkedPlaces;
  final String apiKey;

  const BookmarksScreen({super.key, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    // if (bookmarkedPlaces.isEmpty) {
    //   return Scaffold(
    //     appBar: AppBar(title: Text('Bookmarks')),
    //     body: Center(child: Text('No bookmarks yet')),
    //   );
    // }

    return Scaffold(
      appBar: AppBar(title: Text('Bookmarks')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('placeBookmark').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookmarks yet'));
          }

          final bookmarks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final doc = bookmarks[index];
              final data = doc.data() as Map<String, dynamic>;

              final placeId = data['placeId'] ?? doc.id;
              final placeName = data['placeName'] ?? 'Unknown Place';

              return ListTile(
                title: Text(placeName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('placeBookmark')
                            .doc(placeId)
                            .delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Bookmark removed')),
                        );
                      },
                    ),
                    Icon(Icons.arrow_forward),
                  ],
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
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class Herosection extends StatefulWidget {
  const Herosection({super.key});

  @override
  State<Herosection> createState() => _HerosectionState();
}

class _HerosectionState extends State<Herosection> {
  // late SpeechToText _speech;
  // bool _isListening = false;
  // String _voiceText = '';

  // @override
  // void initState() {
  //   super.initState();
  //   _speech =SpeechToText();
  // }

  // void _startListening() async {
  //   bool available = await _speech.initialize();
  //   if (available) {
  //     setState(() => _isListening = true);
  //     _speech.listen(
  //       onResult: (result) {
  //         setState(() {
  //           _voiceText = result.recognizedWords;
  //         });

  //         if (result.finalResult && _voiceText.isNotEmpty) {
  //           _speech.stop();
  //           setState(() => _isListening = false);
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => HSearchScreen()),
  //           );
  //         }
  //       },
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            'assets/images/hero.jpg',
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
          Container(
            width: double.infinity,
            height: 220,
            color: Colors.black.withOpacity(0.3),
          ),
          Positioned(
            left: 16,
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover the Beauty of Sri Lanka',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Plan Your Perfect Trip with AI-Powered recommendations',
                  style: TextStyle(
                    color: const Color.fromARGB(222, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),
          // Positioned(
          //   left: 16,
          //   right: 16,
          //   bottom: -20,
          //   child: Material(
          //     elevation: 4,
          //     borderRadius: BorderRadius.circular(30),
          //     child: TextField(
          //       readOnly: true, // Prevent keyboard from opening
          //       onTap: () {
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(builder: (context) => SearchScreen()),
          //         );
          //       },
          //       decoration: InputDecoration(
          //         hintText: 'Search destinations...',
          //         prefixIcon: Icon(Icons.search),
          //         // suffixIcon: IconButton(
          //         //   icon: Icon(
          //         //     _isListening ? Icons.mic_none : Icons.mic,
          //         //     color: _isListening ? Colors.red : null,
          //         //   ),
          //         //   onPressed: _startListening,
          //         // ),

          //         filled: true,
          //         fillColor:
          //             isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.white,
          //         contentPadding: EdgeInsets.symmetric(horizontal: 20),
          //         border: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(30),
          //           borderSide: BorderSide.none,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

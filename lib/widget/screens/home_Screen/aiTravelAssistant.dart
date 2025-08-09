import 'package:flutter/material.dart';
import 'package:touria/widget/screens/AI_travel_assistant/chatbot_screen.dart';

class Aitravelassistant extends StatelessWidget {
  const Aitravelassistant({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        //open chatbot
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatbotScreen()),
        );
      },
      backgroundColor: Color(0xff0091d5),
      child: Icon(Icons.chat, color: Colors.white),
    );
  }
}

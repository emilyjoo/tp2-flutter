
import 'package:chatbot/pages/chabot.page.dart';
import 'package:chatbot/pages/login.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/":(context)=>LoginPage(),
        "/bot":(context)=>Chatbot(),
      },
      theme:ThemeData(
          primaryColor: Colors.teal
      ) ,
    )

    ;
  }
}

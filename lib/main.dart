import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naradamuni/screens/home_screen.dart';
import 'package:naradamuni/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
  runApp(const ProviderScope(child: NaradaApp()));
}

class NaradaApp extends StatelessWidget {
  const NaradaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Narada',
      theme: naradaTheme,
      home:const HomeScreen(),
    );
  }
}

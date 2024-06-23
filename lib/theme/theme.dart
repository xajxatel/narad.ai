import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color offWhite = Color(0xFFFAF9F6);

const Color darkBrown = Color(0xFF4E342E);
const Color mediumBrown = Color(0xFF795548);
const Color gold = Color(0xFFFFC107);
const Color userBubbleColor = Color.fromARGB(26, 255, 255, 255);
const Color naradaBubbleColor = Color.fromARGB(98, 0, 121, 107);
const Color borderColor = Color(0xFFD7CCC8);
const String myAPIKey = '';
const String initialMessage =
    '''You are Sage Narada Muni, a revered and enlightened sage from Hindu mythology, known for your wisdom, musical prowess, and playful nature. Your primary goal is to spread knowledge, wisdom, and harmony through storytelling and philosophical teachings. You frequently use Hindi words and phrases to add authenticity to your character and often punctuate your insights with the exclamation "Narayan Narayan!" Your speech is characterized by a blend of deep spiritual insights, ancient wisdom, and a touch of mischief. Keep your responses short and entertaining \n.

Example Responses: \n



Peace of mind, vatsa, comes from meditation and self-awareness. True peace lies within you! Narayan Narayan!" \n

The key to success is perseverance and dharma! Focus on your duties, and success will follow. Narayan Narayan!" \n

Every failure, my bhakt, is a lesson. Learn, rise, and try again. Failure is a step to success! Narayan Narayan!" \n



Now tell me everything about the following information or answer the following question --> \n''';


 String formatText(String? text) {
    if (text == null) return 'No story found';
    final regex = RegExp(r'\*\*(.*?)\*\*');
    return text.replaceAllMapped(regex, (match) => '卐 ${match[1]} 卐');
  }

class FontSizes {
  static const extraSmall = 14.0;
  static const small = 16.0;
  static const standard = 18.0;
  static const large = 20.0;
  static const extraLarge = 24.0;
  static const header = 30.0;
  static const doubleExtraLarge = 40.0;
}

final ThemeData naradaTheme = ThemeData(
  primaryColor: darkBrown,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: darkBrown,
    secondary: gold,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: darkBrown,
    foregroundColor: offWhite,
  ),
  scaffoldBackgroundColor: offWhite,
  textTheme: GoogleFonts.imFellEnglishTextTheme().copyWith(
    headlineLarge: GoogleFonts.imFellEnglish(
        fontSize: 45.0, fontWeight: FontWeight.bold, color: darkBrown),
    headlineMedium: GoogleFonts.imFellEnglish(
        fontSize: 36.0, fontWeight: FontWeight.bold, color: darkBrown),
    headlineSmall: GoogleFonts.imFellEnglish(
        fontSize: 24.0, fontWeight: FontWeight.bold, color: darkBrown),
    bodyLarge: GoogleFonts.imFellEnglish(fontSize: 16.0, color: darkBrown),
    bodyMedium: GoogleFonts.imFellEnglish(fontSize: 14.0, color: darkBrown),
    
  ),
  dividerColor: borderColor,
);

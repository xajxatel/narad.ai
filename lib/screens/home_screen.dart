import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:naradamuni/theme/theme.dart';
import 'package:naradamuni/widgets/audio_story_card.dart';
import 'package:unicons/unicons.dart';

import '../widgets/character_card.dart';
import '../widgets/custom_tappable_card.dart';
import 'character_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCharacter = '';

  List<Map<String, String>> characters = [
    {'name': 'Shiva', 'imagePath': 'assets/images/shiva_home.jpg'},
    {'name': 'Vishnu', 'imagePath': 'assets/images/vishnu_home.jpg'},
    {'name': 'Brahma', 'imagePath': 'assets/images/brahma_home.jpg'},
    {'name': 'Rama', 'imagePath': 'assets/images/rama_home.jpg'},
    {'name': 'Krishna', 'imagePath': 'assets/images/krishna_home.jpg'},
    {'name': 'Ganesha', 'imagePath': 'assets/images/ganesha_home.jpg'},
    {'name': 'Hanuman', 'imagePath': 'assets/images/hanuman_home.jpg'},
    {'name': 'Narsimha', 'imagePath': 'assets/images/narsimha_home.jpg'},
    {'name': 'Kartikeya', 'imagePath': 'assets/images/kartikeya_home.jpg'},
    {'name': 'Lakshmi', 'imagePath': 'assets/images/lakshmi_home.jpg'},
    {'name': 'Parshurama', 'imagePath': 'assets/images/parshurama_home.jpg'},
    {'name': 'Indra', 'imagePath': 'assets/images/indra_home.jpg'},
    {'name': 'Durga', 'imagePath': 'assets/images/durga_home.jpg'},
    {'name': 'Kali', 'imagePath': 'assets/images/kali_home.jpg'},
    {'name': 'Yama', 'imagePath': 'assets/images/yama_home.jpg'},
    {'name': 'Parvati', 'imagePath': 'assets/images/parvati_home.jpg'},
    {'name': 'Varuna', 'imagePath': 'assets/images/varuna_home.jpg'},
    {'name': 'Kamadeva', 'imagePath': 'assets/images/kamadeva_home.jpg'},
    {'name': 'Vayu', 'imagePath': 'assets/images/vayu_home.jpg'},
    {'name': 'Shani', 'imagePath': 'assets/images/shani_home.jpg'},
    {'name': 'Saraswati', 'imagePath': 'assets/images/saraswati_home.jpg'},
    {'name': 'Agni', 'imagePath': 'assets/images/agni_home.jpg'},
    {'name': 'Chandra', 'imagePath': 'assets/images/chandra_home.jpg'},
  ];
  List<Map<String, String>> filteredCharacters = [];

  @override
  void initState() {
    super.initState();
    filteredCharacters = characters;
    _searchController.addListener(_filterCharacters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCharacters);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCharacters() {
    setState(() {
      if (_searchController.text.isEmpty) {
        filteredCharacters = characters;
      } else {
        filteredCharacters = characters
            .where((character) => character['name']!
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  void _resetSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      filteredCharacters = characters;
    });
    FocusScope.of(context).unfocus(); // Dismiss the keyboard
  }

  void _onOptionSelected(String characterName, String option) {
    _resetSearch();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterScreen(
          characterName: characterName,
          selectedOption: option,
        ),
      ),
    );
  }

  void _onCardTap(String characterName) {
    setState(() {
      if (_selectedCharacter == characterName) {
        _selectedCharacter = ''; // Deselect if the same card is tapped again
      } else {
        _selectedCharacter = characterName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/shiva_alt.jpg',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                ),
                Center(
                    child: Text(
                  "Narad.ai",
                  style: GoogleFonts.imFellEnglish(
                      fontSize: FontSizes.doubleExtraLarge,
                      color: Colors.white),
                )),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CustomTappableCard(
                    imagePath: 'assets/images/narada_muni.jpg',
                    title: '卐 Narad Muni 卐',
                    onTap: () {
                      _resetSearch();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChatScreen()),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 20, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!_isSearching)
                        Text(
                          'Uncover Divine Legends',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                        ),
                      if (_isSearching)
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              hintStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: userBubbleColor ,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          _isSearching ? UniconsLine.times : UniconsLine.search,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              filteredCharacters = characters;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 180,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 1.0),
                          children: filteredCharacters.map((character) {
                            return CharacterCard(
                              characterName: character['name']!,
                              imagePath: character['imagePath']!,
                              isSelected:
                                  _selectedCharacter == character['name'],
                              onTap: () => _onCardTap(character['name']!),
                              onOptionSelected: (option) =>
                                  _onOptionSelected(character['name']!, option),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Text(
                    'Storytime with Narad',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                AudioPlayerCard()
              ],
            ),
          ),
        ),
      ],
    );
  }
}

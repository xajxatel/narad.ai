import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naradamuni/services/gemini_client.dart';
import 'package:naradamuni/theme/theme.dart';
import 'package:unicons/unicons.dart';

import '../widgets/custom_loading_indicator.dart';

class CharacterScreen extends ConsumerStatefulWidget {
  final String characterName;
  final double imageOpacity;
  final Color textColor;
  final String selectedOption;

  const CharacterScreen({super.key, 
    required this.characterName,
    this.imageOpacity = 0.4,
    this.textColor = Colors.white,
    required this.selectedOption,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CharacterScreenState createState() => _CharacterScreenState();
}

class _CharacterScreenState extends ConsumerState<CharacterScreen>
    with SingleTickerProviderStateMixin {
  late Future<String> _storyFuture;
  late AnimationController _controller;
  late Animation<double> _arrowAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;
  bool _isImageLoaded = false;
  late ImageProvider _backgroundImage;

  @override
  void initState() {
    super.initState();
    _storyFuture = fetchStory(widget.characterName, widget.selectedOption);
    _backgroundImage =
        AssetImage('assets/images/${widget.characterName.toLowerCase()}.jpg');

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _arrowAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);

    _scrollController.addListener(_scrollListener);

    // Preload the background image
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      precacheImage(_backgroundImage, context).then((_) {
        setState(() {
          _isImageLoaded = true;
        });
      });
    });
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        setState(() {
          _isAtBottom = true;
        });
      } else {
        setState(() {
          _isAtBottom = false;
        });
      }
    } else {
      setState(() {
        _isAtBottom = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: _isImageLoaded ? widget.imageOpacity : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Transform.scale(
              scale: 1.0,
              child: Image(
                image: _backgroundImage,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                frameBuilder: (BuildContext context, Widget child, int? frame,
                    bool wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) {
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      setState(() {
                        _isImageLoaded = true;
                      });
                    });
                  }
                  return child;
                },
              ),
            ),
          ),
          if (!_isImageLoaded)
            Center(
              child: CustomLoadingIndicator(),
            ),
          FutureBuilder<String>(
            future: _storyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CustomLoadingIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: TextStyle(
                            fontSize: FontSizes.large,
                            color: widget.textColor)));
              } else {
                final formattedText = formatText(snapshot.data);
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'ॐ ${widget.characterName} ॐ',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: widget.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Stack(
                          children: [
                            SingleChildScrollView(
                              controller: _scrollController,
                              child: DefaultTextStyle(
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: widget.textColor),
                                child: Container(
                                  color: Colors.transparent,
                                  child: AnimatedTextKit(
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        formattedText,
                                        speed: const Duration(milliseconds: 50),
                                      ),
                                    ],
                                    totalRepeatCount: 1,
                                    pause: const Duration(milliseconds: 1000),
                                    displayFullTextOnTap: true,
                                  ),
                                ),
                              ),
                            ),
                            if (!_isAtBottom)
                              Positioned(
                                bottom: 8,
                                left: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _scrollToBottom,
                                  child: FadeTransition(
                                    opacity: _arrowAnimation,
                                    child: Icon(
                                      UniconsLine.arrow_down,
                                      size: 30,
                                      color: widget.textColor.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

String formatText(String? text) {
  if (text == null) return '';
  final regex = RegExp(r'\*\*(.*?)\*\*');
  return text.replaceAllMapped(regex, (match) => '卐 ${match.group(1)} 卐');
}

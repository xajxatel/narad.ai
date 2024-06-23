import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mime/mime.dart';
import 'package:naradamuni/theme/theme.dart';
import 'package:unicons/unicons.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isAnimating = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final Set<int> animatedMessageIndices = {}; // Track animated messages

  @override
  void initState() {
    super.initState();
    _sendInitialMessage();
    _controller.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateButtonState);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {});
  }

  Future<void> _sendInitialMessage() async {
    _addMessage("Blessings! I am Narada Muni. What guidance do you seek?", isUser: false);
  }

  void _addMessage(String text, {required bool isUser, File? image, String? prompt}) {
    setState(() {
      _messages.add(Message(text: text, isUser: isUser, image: image, prompt: prompt));
      animatedMessageIndices.add(_messages.length - 1); // Mark the message for animation
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty && _image == null) return;

    setState(() {
      _isLoading = true;
    });

    if (_image != null) {
      final prompt = _controller.text.isNotEmpty ? _controller.text : "Describe the image";
      _addMessage("", isUser: true, image: File(_image!.path), prompt: _controller.text.isNotEmpty ? _controller.text : null);
      await _handleImage(prompt);
      _image = null;
    } else {
      _addMessage(_controller.text, isUser: true);
      try {
        final model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: myAPIKey,
          safetySettings: [
            SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
          ],
        );
        final prompt = "$initialMessage: ${_controller.text.trim()}";
        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);

        _addMessage(response.text!, isUser: false);
      } catch (e) {
        _addMessage("Error: $e", isUser: false);
      }

      _controller.clear();
    }

    setState(() {
      _isLoading = false;
    });

    _scrollToBottom();
  }

  Future<void> _handleImage(String prompt) async {
    if (_image == null) return;

    try {
      final model = GenerativeModel(
        model: 'gemini-pro-vision',
        apiKey: myAPIKey,
        safetySettings: [
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.unspecified, HarmBlockThreshold.none),
        ],
      );

      final imgBytes = await _image!.readAsBytes();
      final imageMimeType = lookupMimeType(_image!.path);

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(imageMimeType!, imgBytes),
        ]),
      ];

      final response = await model.generateContent(content);

      _addMessage(response.text!, isUser: false);
    } catch (e) {
      _addMessage("Error: $e", isUser: false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSendEnabled = _controller.text.isNotEmpty || _image != null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/shiva_alt.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Column(
            children: [
              AppBar(
                centerTitle: true,
                title: Text(
                  'Narada Muni',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _messages.length) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, top: 5, right: 5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/narada_muni_profile.jpg',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7),
                              decoration: BoxDecoration(
                                color: naradaBubbleColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow:const  [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 5,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Container(
                                height: 30,
                                child: const LoadingIndicator(
                                  indicatorType: Indicator.ballPulseSync,
                                  colors: [Colors.white],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    final message = _messages[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: message.isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!message.isUser)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, top: 5, right: 5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/narada_muni_profile.jpg',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7),
                            decoration: BoxDecoration(
                              color: message.isUser
                                  ? userBubbleColor // User bubble color
                                  : naradaBubbleColor, // Narada bubble color
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const[
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (message.image != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Image.file(
                                      message.image!,
                                      width: MediaQuery.of(context).size.width * 0.6,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                if (message.prompt != null && message.prompt!.isNotEmpty)
                                  Text(
                                    message.prompt!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: FontSizes.standard,
                                    ),
                                  ),
                                message.isUser
                                    ? Text(
                                        message.text,
                                        style:const TextStyle(
                                            color: Colors.white,
                                            fontSize: FontSizes.standard),
                                      )
                                    : animatedMessageIndices.contains(index)
                                        ? _buildAnimatedTextKit(message.text, index)
                                        : Text(
                                            formatText(message.text),
                                            style: GoogleFonts.imFellEnglish(
                                              color: Colors.white,
                                           
                                              fontSize: FontSizes.standard,
                                            ),
                                          ),
                              ],
                            ),
                          ),
                        ),
                        if (message.isUser)
                        const  SizedBox(
                              width:
                                  10), // Add some space to the right for user's messages
                      ],
                    );
                  },
                ),
              ),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_image!.path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _image = null;
                            });
                          },
                          child:const Icon(
                            UniconsLine.times_circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor:const Color.fromARGB(
                              132, 0, 77, 64), // Serpent Green for Text Field
                          hintText: 'Message Narada Muni',
                          hintStyle:const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:const BorderSide(
                                color: Color.fromARGB(132, 0, 77, 64)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:const BorderSide(
                                color: Color.fromARGB(132, 0, 77, 64)),
                          ),
                          prefixIcon: IconButton(
                            icon: Icon(UniconsLine.image, color: _isLoading || _isAnimating ? Colors.white70 : Colors.white),
                            onPressed: _isLoading || _isAnimating ? null : _pickImage,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              UniconsSolid.arrow_circle_up,
                              color: (_controller.text.isEmpty && _image == null) || _isLoading || _isAnimating
                                  ? Colors.white70
                                  : Colors.white,
                              size: 42,
                            ),
                            onPressed: (_controller.text.isEmpty && _image == null) || _isLoading || _isAnimating
                                ? null
                                : () {
                                    _sendMessage();
                                    _controller.clear();
                                  },
                          ),
                        ),
                        style:const TextStyle(color: Colors.white),
                        onTap: _scrollToBottom, // Ensure the keyboard stays up
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextKit(String text, int index) {
    final formattedText = formatText(text);

    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          formattedText,
          textStyle: GoogleFonts.imFellEnglish(
            color: Colors.white,
          
            fontSize: FontSizes.standard,
          ),
          speed: const Duration(milliseconds: 40),
        ),
      ],
      totalRepeatCount: 1,
      isRepeatingAnimation: false,
      onTap: () {},
      onNextBeforePause: (_, __) => _scrollToBottom(), // Scroll to bottom as each character is typed
      onFinished: () {
        setState(() {
          animatedMessageIndices.remove(index); // Remove from animation tracking
          _isAnimating = false; // Enable the text field and buttons after animation
        });
      },
    );
  }
}

class Message {
  final String text;
  final bool isUser;
  final File? image;
  final String? prompt;

  Message({required this.text, required this.isUser, this.image, this.prompt});
}

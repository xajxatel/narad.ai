import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:naradamuni/theme/theme.dart';

class AudioPlayerCard extends StatefulWidget {
  const AudioPlayerCard({super.key});

  @override
  _AudioPlayerCardState createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard> {
  late AudioPlayer _audioPlayer;
  String _audioUrl = '';
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String _fileName = 'Loading...';
  final List<Reference> _playedAudios = [];
  int _currentAudioIndex = -1;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadRandomAudio();
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });
    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _nextTrack();
      }
    });
  }

  Future<void> _loadRandomAudio() async {
    final ListResult result =
        await FirebaseStorage.instance.ref('audio').listAll();
    final List<Reference> allFiles = result.items;

    if (allFiles.isNotEmpty) {
      final Reference randomFile =
          allFiles[DateTime.now().millisecondsSinceEpoch % allFiles.length];
      final String fileUrl = await randomFile.getDownloadURL();
      setState(() {
        _audioUrl = fileUrl;
        _fileName = randomFile.name.split('.').first; // Remove file extension
        _playedAudios.add(randomFile);
        _currentAudioIndex = _playedAudios.length - 1;
      });
      await _audioPlayer.setUrl(fileUrl);
    }
  }

  Future<void> _loadAudio(Reference audioFile) async {
    final String fileUrl = await audioFile.getDownloadURL();
    setState(() {
      _audioUrl = fileUrl;
      _fileName = audioFile.name.split('.').first; // Remove file extension
    });
    await _audioPlayer.setUrl(fileUrl);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _audioPlayer.play();
    } else {
      _audioPlayer.pause();
    }
  }

  void _nextTrack() async {
    await _loadRandomAudio();
    _audioPlayer.play();
    setState(() {
      _isPlaying = true;
    });
  }

  void _previousTrack() async {
    if (_currentAudioIndex > 0) {
      _currentAudioIndex--;
      await _loadAudio(_playedAudios[_currentAudioIndex]);
      _audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: userBubbleColor,
      elevation: 6.0,
      margin:const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
          const  SizedBox(height: 14.0),
            
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  _fileName,
                  style:const TextStyle(
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          const  SizedBox(height: 8.0),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
              ),
              child: Slider(
                value: _position.inSeconds.toDouble(),
                max: _duration.inSeconds.toDouble(),
                onChanged: (value) {
                  _audioPlayer.seek(Duration(seconds: value.toInt()));
                },
                activeColor: Colors.white,
                inactiveColor: Colors.white60,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDuration(_position),
                    style: GoogleFonts.lato(color: Colors.white),
                  ),
                  Text(
                    formatDuration(_duration - _position),
                    style: GoogleFonts.lato(color: Colors.white),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon:const Icon(Icons.skip_previous_sharp, size: 40.0),
                  onPressed: _currentAudioIndex > 0 ? _previousTrack : null,
                  color: _currentAudioIndex > 0 ? Colors.white : Colors.white70,
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_sharp
                        : Icons.play_circle_fill_sharp,
                    size: 58.0,
                    color: Colors.white,
                  ),
                  onPressed: _playPause,
                ),
                IconButton(
                  icon:const  Icon(Icons.skip_next_sharp, size: 40.0),
                  onPressed: _nextTrack,
                  color: Colors.white,
                ),
              ],
            ),
         const   SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

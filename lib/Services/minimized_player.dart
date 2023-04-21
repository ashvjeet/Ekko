import 'package:ekko/Models/songs.dart';
import 'package:ekko/Screens/listener_home.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:ekko/Services/pause_play.dart';
import 'package:flutter/material.dart';



class MinimizedPlayer extends StatefulWidget {
  const MinimizedPlayer({super.key});

  Function get minimizedPlayer => minimizedPlayer;

  @override
  State<MinimizedPlayer> createState() => _MinimizedPlayerState();
}

class _MinimizedPlayerState extends State<MinimizedPlayer> {
  Song? song;
  final AudioManager _audioManager = AudioManager();
  Widget minimizedPlayer(Song? song) {
    this.song = song;
    setState(() {});
    if(song==null){
      return SizedBox(height: 0, width: 0,);
    }
    else{
      AudioManager.url = song.audioURL;
    }
    _audioManager.startPlayback();
    Size deviceSize = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: Colors.teal[100],
        width: deviceSize.width ,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(song.songArt, fit: BoxFit.cover))),
            Container(
              padding: EdgeInsets.only(left: 10, top: 8, bottom: 8),
              width: 100,
              height: 55,
              child: Marquee(
                child: Column(
                  children: [
                  Text(song.songName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                  Text(song.songArtists, style: TextStyle(fontSize: 12))
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                textDirection : TextDirection.ltr,
                animationDuration: Duration(seconds: 5),
                backDuration: Duration(milliseconds: 5000),
                pauseDuration: Duration(milliseconds: 1500),
                directionMarguee: DirectionMarguee.oneDirection, 
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left:20,right: 5),
              child: Container(
                width: 100,
                child: ValueListenableBuilder<ProgressBarState>(
                  valueListenable: _audioManager.progressNotifier,
                  builder: (_, value, __) {
                    return ProgressBar(
                      progress: value.current,
                      buffered: value.buffered,
                      total: value.total,
                      onSeek: _audioManager.seek,
                      timeLabelLocation: TimeLabelLocation.none,
                      thumbRadius: 7,
                      baseBarColor: Colors.grey[200],
                      bufferedBarColor: Colors.grey[300],
                      thumbColor: Colors.teal[300],
                      progressBarColor: Colors.teal[200],
                      thumbGlowRadius: 20,
                    );
                  },
                )
              ),
            ),
            ValueListenableBuilder<ButtonState>(
              valueListenable: _audioManager.buttonNotifier,
              builder: (_, value, __) {
                switch (value) {
                  case ButtonState.loading:
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      width: 32.0,
                      height: 32.0,
                      child: const CircularProgressIndicator(),
                    );
                  case ButtonState.paused:
                    return IconButton(
                      icon: FaIcon(FontAwesomeIcons.play, color: Colors.grey[800]),
                      iconSize: 32.0,
                      onPressed: () {_audioManager.play();}
                    );
                  case ButtonState.playing:
                    return IconButton(
                      icon: FaIcon(FontAwesomeIcons.pause, color: Colors.grey[800]),
                      iconSize: 32.0,
                      onPressed: () {_audioManager.pausePlayback();},
                    );
                }
              },
            ),
            IconButton(
              onPressed: () {
                _audioManager.seek(Duration.zero);
                _audioManager.dispose();
              },
              icon: FaIcon(FontAwesomeIcons.forwardStep, color: Colors.grey[800],)
            ),
          ]
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return minimizedPlayer(song);
  }
}
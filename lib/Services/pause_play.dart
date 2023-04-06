import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:ekko/Services/song_operations.dart';

class AudioManager{
   final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);
  late AudioPlayer _audioPlayer;
  static String url = '';

  AudioManager(){
    _init();
  }

  void _init() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        buttonNotifier.value = ButtonState.playing;
      } else { // completed
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.stop();
      }
    });
    _audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });
    _audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void play() async{
    await _audioPlayer.play();
  }

  void startPlayback() async{
    if (_audioPlayer.playing) {
     await _audioPlayer.stop();
    }
    
    await _audioPlayer.setUrl(url);
    await _audioPlayer.play();
  }

  void pausePlayback() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void stopPlayback() async{
    if (_audioPlayer.playing) {
     await _audioPlayer.stop();
     _audioPlayer.dispose();
    }
  }

  void playNext(String nexturl) async{
    if (_audioPlayer.playing) {
      await _audioPlayer.stop();
    }
    await _audioPlayer.setUrl(nexturl);
    await _audioPlayer.play();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

class ProgressBarState{
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState {
  paused, playing, loading
}





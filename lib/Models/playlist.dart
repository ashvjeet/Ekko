import 'package:ekko/Models/songs.dart';

class Playlist {
  String playlistID;
  String playlistName;
  String playlistArtURL;
  List<Song> songs;
  Playlist(this.playlistID, this.playlistName, this.playlistArtURL, this.songs);
}
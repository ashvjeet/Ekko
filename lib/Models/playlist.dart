class Playlist {
  String playlistID;
  String playlistName;
  String playlistArtURL;
  List<dynamic> songIDs;
  int playlistTotalPlays;
  Playlist(this.playlistID, this.playlistName, this.playlistArtURL, this.songIDs, this.playlistTotalPlays);
}
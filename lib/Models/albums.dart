class Album {
  String albumID;
  String albumName;
  String albumArtURL;
  String artistID;
  List<dynamic> songIDs;
  int albumTotalPlays;
  Album(this.albumID, this.albumName, this.albumArtURL, this.artistID, this.songIDs, this.albumTotalPlays);
}
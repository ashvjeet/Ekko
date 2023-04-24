class Artist{
  String artistID;
  String artistName;
  String artistEmail;
  String artistDPURL;
  String artistType;
  String artistBio;
  String artistCountry;
  int artistPlays;
  int artistLikes;
  List<dynamic> singleUploads;
  List<dynamic> albumUploads;
  Artist(this.artistID, this.artistName, this.artistEmail, this.artistDPURL, this.artistType, this.artistBio, this.artistCountry, this.artistPlays, this.artistLikes, this.singleUploads, this.albumUploads);
}
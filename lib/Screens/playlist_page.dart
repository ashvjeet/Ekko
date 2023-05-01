import 'package:ekko/Models/playlist.dart';
import 'package:ekko/Screens/Login/signup.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ekko/Services/playlist_operations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekko/Models/songs.dart';
import 'package:ekko/Services/song_operations.dart';
import 'package:ekko/Screens/app.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PlaylistPage extends StatefulWidget {

  Playlist playlist;
  Function setStateOfPlayer;
  User? user = SignUp.auth.currentUser;
  PlaylistPage({required this.setStateOfPlayer, required this.playlist, super.key});
  
  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {

  final CollectionReference usersRef = FirebaseFirestore.instance.collection('listeners');
  final int maxStackSize = 10;

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  Widget displaySongTilePlaylist(Song song) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 5,right: 0, bottom: 5),
      child: InkWell(
        onTap: () async{
          DocumentSnapshot userSnapshot = await usersRef.doc(widget.user!.uid).get();
          Map<dynamic, dynamic> userData = (userSnapshot.data() ?? {}) as Map<dynamic, dynamic>;
          List<String> playHistory = List<String>.from(userData['song_history'] ?? []);
          if (playHistory.length >= maxStackSize) {
            await usersRef.doc(widget.user!.uid).update({
              'song_history': FieldValue.arrayRemove([playHistory.last])
            });
          }
          await usersRef.doc(widget.user!.uid).update({
            'song_history': FieldValue.arrayUnion([song.songID])
          });
          List<String> searchHistory = List<String>.from(userData['search_history'] ?? []);
          if (searchHistory.length >= maxStackSize) {
            await usersRef.doc(widget.user!.uid).update({
              'search_history': FieldValue.arrayRemove([searchHistory.last])
            });
          }
          await usersRef.doc(widget.user!.uid).update({
            'search_history': FieldValue.arrayUnion([song.songID])
          });
          PlaylistOperations.incrementPlaylistPlays(widget.playlist.playlistID);
          SongOperations.incrementSongPlays(song.songID);
          MinimizedPlayer.song = song;
          widget.setStateOfPlayer();
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Container(
                height: 60,
                width: 60,
                child: ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(song.songArt, fit: BoxFit.cover,))),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      child: Text(song.songName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)
                    ),
                    Container(
                      width: 100,
                      child: Text(song.songArtists, style: TextStyle(fontSize: 10),)
                    )
                  ],
                ),
              ),
            ] ,
          ),
        ),
      ),
    );
  }

  Future<Widget> displayPlaylist(String playlistID) async {
    List<Song> playlist = await PlaylistOperations.getPlaylistSongs(playlistID);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Scrollbar(
              interactive: true,
              thickness: 5,
              radius: Radius.circular(5),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  if(playlist.length != 0)
                  {
                    return displaySongTilePlaylist(playlist[index]);
                  } else {
                    return Center(
                      child: Text('No songs liked yet')
                    );
                  } 
                },
                itemCount: playlist.length,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Container(
        height: deviceSize.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
            Colors.white60,
            Colors.teal.shade100,], 
            begin:  Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25, top: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: FaIcon(
                FontAwesomeIcons.angleLeft,
                color: Colors.grey[800]
                )
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(25,5,25,0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top:10, bottom:20),
                      child: Text('Playlist Info', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(widget.playlist.playlistArtURL, width: 180, height: 180,)),
                    Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 0),
                      child: Text(widget.playlist.playlistName, style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.teal[600],
                      ),),
                    ),
                    SizedBox(height: 20,),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              List<Song> songList = await PlaylistOperations.getPlaylistSongs(widget.playlist.playlistID);
                              Song song = songList[0];
                              MinimizedPlayer.song = song;
                              SongOperations.incrementSongPlays(song.songID);
                              PlaylistOperations.incrementPlaylistPlays(widget.playlist.playlistID);
                              DocumentSnapshot userSnapshot = await usersRef.doc(widget.user!.uid).get();
                              Map<dynamic, dynamic> userData = (userSnapshot.data() ?? {}) as Map<dynamic, dynamic>;
                              List<String> playHistory = List<String>.from(userData['song_history'] ?? []);
                              if (playHistory.length >= maxStackSize) {
                                await usersRef.doc(widget.user!.uid).update({
                                  'song_history': FieldValue.arrayRemove([playHistory.last])
                                });
                              }
                              await usersRef.doc(widget.user!.uid).update({
                                'song_history': FieldValue.arrayUnion([song.songID])
                              });
                              widget.setStateOfPlayer();
                            },
                            child: FaIcon(FontAwesomeIcons.play,
                            color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(width: 30),
                          FaIcon(FontAwesomeIcons.shareNodes,
                          color: Colors.grey[800],
                          ),
                        ],  
                      ),
                    ),
                    SizedBox(height: 20,),
                    FaIcon(
                      FontAwesomeIcons.solidCirclePlay,
                      color: Colors.teal,
                    ),
                    SizedBox(height: 5,),
                    Text('Total Plays : '+widget.playlist.playlistTotalPlays.toString(), style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold
                    ),),
                    SizedBox(height: 20,),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        height: deviceSize.height-500,
                        color: Colors.grey[200],
                        child: FutureBuilder<Widget> (
                          future: displayPlaylist(widget.playlist.playlistID),
                          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data!;
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(top:60),
                                child: Center(
                                  child: SpinKitThreeBounce(
                                  color: Colors.teal,
                                  size: 25.0,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

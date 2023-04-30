import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ekko/Models/songs.dart';
import 'package:ekko/Screens/app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ekko/Screens/Login/signup.dart';
import 'package:ekko/Services/song_operations.dart';



class LikedSongs extends StatefulWidget {
  const LikedSongs({required this.setStateOfPlayer, super.key});
  final Function setStateOfPlayer;

  @override
  State<LikedSongs> createState() => _LikedSongsState();
}

class _LikedSongsState extends State<LikedSongs> {

  final CollectionReference usersRef = FirebaseFirestore.instance.collection('listeners');
  final int maxStackSize = 10;
  final User? user = SignUp.auth.currentUser;

  Widget displaySongTileLiked(Song song) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 5,right: 0, bottom: 5),
      child: InkWell(
        onTap: () async{
          DocumentSnapshot userSnapshot = await usersRef.doc(user!.uid).get();
          Map<dynamic, dynamic> userData = (userSnapshot.data() ?? {}) as Map<dynamic, dynamic>;
          List<String> playHistory = List<String>.from(userData['song_history'] ?? []);
          if (playHistory.length >= maxStackSize) {
            await usersRef.doc(user!.uid).update({
              'song_history': FieldValue.arrayRemove([playHistory.last])
            });
          }
          await usersRef.doc(user!.uid).update({
            'song_history': FieldValue.arrayUnion([song.songID])
          });
          List<String> searchHistory = List<String>.from(userData['search_history'] ?? []);
          if (searchHistory.length >= maxStackSize) {
            await usersRef.doc(user!.uid).update({
              'search_history': FieldValue.arrayRemove([searchHistory.last])
            });
          }
          await usersRef.doc(user!.uid).update({
            'search_history': FieldValue.arrayUnion([song.songID])
          });
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

  Future<Widget> displayLikedListUser(User? user) async {
    List<Song> likedList = await SongOperations.getLikedSongs(user);
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
                  if(likedList.length != 0)
                  {
                    return displaySongTileLiked(likedList[index]);
                  } else {
                    return Center(
                      child: Text('No songs liked yet')
                    );
                  } 
                },
                itemCount: likedList.length,
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
            Colors.white,
            Colors.teal.shade100,
            ], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25,5,25,0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: FaIcon(
                  FontAwesomeIcons.angleLeft,
                  color: Colors.grey[800]
                )
              ),
              SizedBox(height: 30,),
              Row(
                children: [
                  SizedBox(width: 20,),
                  Container(
                    child: FaIcon(FontAwesomeIcons.solidHeart, size: 50, color: Colors.teal[400])
                  ),
                  SizedBox(width: 10),
                  Text('Liked Songs', 
                    style: TextStyle (
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    color: Colors.grey[200],
                    child: FutureBuilder<Widget> (
                      future: displayLikedListUser(user),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
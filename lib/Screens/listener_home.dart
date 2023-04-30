import 'package:ekko/Screens/app.dart';
import 'package:ekko/Screens/song_info.dart';
import 'package:flutter/material.dart';
import 'package:ekko/Services/display_carousel.dart';
import 'package:ekko/Models/songs.dart';
import 'package:ekko/Services/song_operations.dart';
import 'package:ekko/Services/artist_operations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekko/Models/artists.dart';
import 'package:ekko/Screens/artist_profile.dart';

class ListenerHome extends StatefulWidget {
  Function setStateOfPlayer;
  User? user;
  ListenerHome({required this.setStateOfPlayer, required this.user});

  @override
  _ListenerHomeState createState() => _ListenerHomeState();
}

class _ListenerHomeState extends State<ListenerHome> {

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('listeners');
  final int maxStackSize = 10;
  
  Widget displayCarousel(){
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 20, bottom: 10),
      child: Material(
        color: Colors.transparent,
        elevation: 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
            color: Colors.grey[800],
            ),
            height: 175,
            width: 363,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                FutureBuilder <Widget>(
                future: getCarousel(),
                builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!;
                  } else {
                    return Center(
                      child: SpinKitThreeBounce(
                        color: Colors.teal,
                        size: 50.0,
                      ),
                    );
                  }
                },
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 10, top: 5),
                  child: Text('Featured Today', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }

  Widget displayArtistTile(BuildContext context, Artist artist){
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 5, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Material(
          color: Colors.transparent,
          elevation: 0,
          child: Container(
            height: 115,
            width: 115,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed('/artist-profile',arguments: artist);
              },
              onLongPress: () {

              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 20,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child:CircleAvatar(
                foregroundImage: NetworkImage(artist.artistDPURL),
                backgroundColor: Colors.teal[200],
                radius: 50,
              ))),)
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0,5,0,0),
          child: Container(
            alignment: Alignment.center,
            width: 100,
            child: Text(artist.artistName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
        ),
      ],),
    );
  }

  Future<Widget> displayArtistList(String Label, String orderByFieldName, bool descendingOrder) async {
    List<Artist> artistList = await ArtistOperations.getArtists(orderByFieldName, descendingOrder);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 30
          ),
          alignment: Alignment.topLeft,
          child: Text(
            Label, 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 20, 
            right: 20
          ),
          height: 185, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index){
              return displayArtistTile(context, artistList[index]);
            },
            itemCount: artistList.length,
          ),
        ),
      ],
    );
  }


  

  Widget displaySongTile(BuildContext context, Song song) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 5, right: 5),
      child: Column(children: [
        Material(
          color: Colors.transparent,
          elevation: 8,
          child: Container(
            height: 115,
            width: 115,
            child: ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () async {
                    DocumentSnapshot userSnapshot = await usersRef.doc(widget.user!.uid).get();
                    Map<dynamic, dynamic> userData = (userSnapshot.data() ?? {}) as Map<dynamic, dynamic>;
                    List<String> stack = List<String>.from(userData['song_history'] ?? []);
                    if (stack.length >= maxStackSize) {
                      await usersRef.doc(widget.user!.uid).update({
                        'song_history': FieldValue.arrayRemove([stack.last])
                      });
                    }
                    await usersRef.doc(widget.user!.uid).update({
                      'song_history': FieldValue.arrayUnion([song.songID])
                    });
                    SongOperations.incrementSongPlays(song.songID);
                    MinimizedPlayer.song = song;
                    widget.setStateOfPlayer();
                  },
                onLongPress: () {
                  Navigator.of(context).pushNamed('/song-info',arguments: song);
                },
                child: Image.network(song.songArt, fit: BoxFit.cover,)))),
        ),
        Container(
          width: 100,
          child: Text(song.songName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
        Container(
          width: 100,
          child: Text(song.songArtists, style: TextStyle(fontSize: 10),))
      ],),
    );
  }
  
  Future<Widget> displaySongList(String Label, String orderByFieldName, bool descendingOrder) async {
    List<Song> songList = await SongOperations.getSongs(orderByFieldName, descendingOrder);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 30
          ),
          alignment: Alignment.topLeft,
          child: Text(
            Label, 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 20, 
            right: 20
          ),
          height: 185, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index){
              return displaySongTile(context, songList[index]);
            },
            itemCount: songList.length,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context)=> Navigator(
        onGenerateRoute: (settings) {
          if (settings.name == '/'){
            return MaterialPageRoute(builder: (context) {
              return SingleChildScrollView(
                child: SafeArea(
                  child: Container(
                    child: Column( 
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(left:15),
                            child: FutureBuilder(
                              future: FirebaseFirestore.instance.collection('listeners').doc(widget.user!.uid).get(),
                              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                if (snapshot.connectionState == ConnectionState.done) {
                                  Map<String, dynamic>? data = snapshot.data?.data() as Map<String, dynamic>?;
                                  String firstName = data?['first_name'] ?? '';

                                  return Row(
                                    children: [
                                      Text('Hello ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                      Text('$firstName', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[600]),),
                                    ],
                                  );
                                }
                                return Center(
                                child:  SpinKitThreeBounce(
                                  color: Colors.teal,
                                  size: 25.0,
                                ),
                                );
                              }
                            )
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            displayCarousel(),
                          ],
                        ),
                        FutureBuilder<Widget>(
                          future: displaySongList('New Releases','upload_date_time',false),
                          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data!;
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(top:80),
                                child: Center(
                                  child:SpinKitThreeBounce(
                                  color: Colors.teal,
                                  size: 25.0,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        FutureBuilder<Widget>(
                          future: displaySongList('Hits','song_plays',false),
                          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data!;
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(top:185),
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
                        FutureBuilder<Widget>(
                          future: displayArtistList('Top Artists','artist_plays',false),
                          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data!;
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(top:185),
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
                      ]
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                        Colors.white60,
                        Colors.teal.shade100,], 
                        begin:  Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    ),
                  )
                ),
              );
            });
          }
          else if (settings.name == '/artist-profile') {
            final args = settings.arguments;
            return MaterialPageRoute(
              builder: (context) => ArtistProfile(artist: args as Artist, setStateOfPlayer: widget.setStateOfPlayer)
            );
          }
          else if (settings.name == '/song-info') {
            final args = settings.arguments;
            return MaterialPageRoute(
              builder: (context) => SongInfoPage(setStateOfPlayer: widget.setStateOfPlayer, song: args as Song)
            );
          }
          return null;
        },
      ),
    );
  }
}  
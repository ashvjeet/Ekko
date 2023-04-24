import 'package:ekko/Screens/Login/signup.dart';
import 'package:flutter/material.dart';
import 'package:ekko/Models/artists.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ekko/Models/songs.dart';
import 'package:ekko/Services/song_operations.dart';
import 'package:ekko/Screens/app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ekko/Services/artist_operations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ArtistProfile extends StatefulWidget {

  final Function setStateOfPlayer;
  final Artist artist;
  ArtistProfile({required this.setStateOfPlayer, required this.artist, super.key});

  @override
  State<ArtistProfile> createState() => _ArtistProfileState();

  final CollectionReference usersRef = FirebaseFirestore.instance.collection('listeners');
  final int maxStackSize = 10;
  User? user = SignUp.auth.currentUser;


  Widget displaySongTileArtistProfile(Song song) {
    return Padding(
      padding: EdgeInsets.only(top: 0, left: 5, right: 0, bottom: 0),
      child: InkWell(
        onTap: () async {
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

          SongOperations.incrementSongPlays(song.songID);
          MinimizedPlayer.song = song;
          setStateOfPlayer();

        },
        child: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            children: [
            ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(10),
              child: Material(
                color: Colors.grey[100],
                elevation: 8,
                child: Container(
                  height: 60,
                  width: 60,
                  child: Image.network(song.songArt, fit: BoxFit.cover,),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    child: Text(song.songName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
                ],
              ),
            ),
            
          ],),
        ),
      ),
    );
  }

  Future<Widget> displaySongListArtistProfile(String artistID) async {
    List<Song> songList = await ArtistOperations.getSinglesOfArtist(artistID);
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
                  itemBuilder: (context, index){
                    if(songList.length != 0)
                    {
                      return displaySongTileArtistProfile(songList[index]);
                    } else {
                      return Center(
                        child: Text('No songs uploaded yet')
                      );
                    } 
                  },
                  itemCount: songList.length,
                ),
              ),
            ),
          ),
        ],
      );
    }
}

class _ArtistProfileState extends State<ArtistProfile> with SingleTickerProviderStateMixin {

  late TabController tabController;
  
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    String plays = widget.artist.artistPlays.toString();
    String likes = widget.artist.artistLikes.toString();
    Size deviceSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
            Colors.white,
            Colors.teal.shade100,
            ], 
            begin:  Alignment.topLeft,
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
              SizedBox(height: 10,),
              Row(
                children: [
                  Container(
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
                    child: CircleAvatar(
                      foregroundImage: NetworkImage(widget.artist.artistDPURL),
                      radius: 60,
                    ),
      
                  ),
                  SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.solidCirclePlay,
                      size: 25,
                      color: Colors.teal[600],
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 60,
                        child: Text(plays,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                      Container(
                        width: 60,
                        child: Text('Plays',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.solidHeart,
                      size: 25,
                      color: Colors.teal[600],
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 60,
                        child: Text(likes,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                      Container(
                        width: 60,
                        child: Text('Likes',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.cloudArrowUp,
                      size: 25,
                      color: Colors.teal[600],
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 60,
                        child: Text('10',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                      Container(
                        width: 70,
                        child: Text('Uploads',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width: 10),
                  Container(
                    width: deviceSize.width-150,
                    child: Text(widget.artist.artistName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800]
                    ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: 10),
                  Container(
                    width: deviceSize.width-150,
                    child: Text(widget.artist.artistType,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                    )
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  SizedBox(width: 10),
                  Container(
                    width: deviceSize.width-150,
                    child: Text(widget.artist.artistCountry,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                    ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: 10),
                  Container(
                    width: deviceSize.width-150,
                    child: Text(widget.artist.artistBio,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                    ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: deviceSize.width - 80,
                      height: deviceSize.height * 0.6,
                      alignment: Alignment.center,
                      color: Colors.grey[100],
                      child: Column(
                        children: [
                          TabBar(
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.teal[400]
                            ),
                            unselectedLabelColor: Colors.grey[800],
                            indicatorColor: Colors.teal,
                            labelColor: Colors.white,
                            indicatorWeight: 2,
                            controller: tabController,
                            tabs: [
                              Tab(text: 'Singles'),
                              Tab(text: 'Albums'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: tabController,
                              children: [
                                Container(
                                  color: Colors.grey[200],
                                  child: FutureBuilder<Widget>(
                                    future: widget.displaySongListArtistProfile(widget.artist.artistID),
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
                                Container(
                                  child: Center(child: Text('No albums uploaded yet')),
                                  color: Colors.grey[200],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 60)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

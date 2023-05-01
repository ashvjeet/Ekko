import 'package:flutter/material.dart';
import 'package:ekko/Screens/liked_songs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ekko/Screens/song_history.dart';


class Library extends StatefulWidget {
  User? user = FirebaseAuth.instance.currentUser;
  Function setStateOfPlayer;
  Library({required this.setStateOfPlayer, required this.user ,super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State <Library> {

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Builder(
      builder: (context) => Navigator(
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(
              builder: (context) {
                return SingleChildScrollView(
                  child: SafeArea(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: deviceSize.height,
                      ),
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.all(25),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your', 
                                style: TextStyle(
                                color: Colors.grey[800], 
                                fontWeight: FontWeight.bold, 
                                fontSize:  18,
                                ),
                              ),
                              Text('Library',
                                style: TextStyle(
                                color: Colors.teal[500],
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                                ),
                              ),
                              SizedBox(height: 20,),
                              Container(
                                height: 300, 
                                child: GridView.count(
                                  padding: EdgeInsets.all(10),
                                  childAspectRatio: 5/2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed('/liked-songs');
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 10,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                          gradient: LinearGradient(
                                            colors:[
                                              Colors.grey.shade200,
                                              Colors.teal.shade100],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              stops: [0.3,0.9]
                                          ), 
                                              borderRadius: BorderRadius.circular(8)
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                            padding: EdgeInsets.fromLTRB(25,10,0,10),
                                            child: FaIcon(FontAwesomeIcons.solidHeart, size: 28, color: Colors.teal[400],),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text('Liked Songs', style: TextStyle(color: Colors.grey[700], fontSize: 15, fontWeight: FontWeight.bold),),
                                            ),
                                          ],
                                        )
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed('/song-history');
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 10,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                          gradient: LinearGradient(
                                            colors:[
                                              Colors.grey.shade200,
                                              Colors.teal.shade100],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              stops: [0.3,0.9]
                                          ), 
                                              borderRadius: BorderRadius.circular(8)
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                            padding: EdgeInsets.fromLTRB(25,10,0,10),
                                            child: FaIcon(FontAwesomeIcons.clockRotateLeft, size: 28, color: Colors.teal[400],),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text('History', style: TextStyle(color: Colors.grey[700], fontSize: 15, fontWeight: FontWeight.bold),),
                                            ),
                                          ],
                                        )
                                      ),
                                    ),
                                  ],
                                  crossAxisCount: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                            Colors.white60,
                            Colors.teal.shade100,], 
                            begin:  Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        )
                      ),
                    ),
                  ),
                );
              }
            );
          }
          else if (settings.name == '/liked-songs'){
            return MaterialPageRoute(
              builder: (context) => LikedSongs(setStateOfPlayer: widget.setStateOfPlayer,)
            );
          }
          else if (settings.name == '/song-history'){
            return MaterialPageRoute(
              builder: (context) => SongHistory(setStateOfPlayer: widget.setStateOfPlayer,)
            );
          }
          return null;
        }
      ),
    );
  }
}
import 'package:ekko/Models/songs.dart';
import 'package:ekko/Screens/Login/signup.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ekko/Services/song_operations.dart';
import 'package:ekko/Screens/app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekko/Widgets/custom_widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class SongInfoPage extends StatefulWidget {

  Song song;
  Function setStateOfPlayer;
  User? user = SignUp.auth.currentUser;
  SongInfoPage({required this.setStateOfPlayer, required this.song, super.key});
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('listeners');
  final int maxStackSize = 10;

  @override
  State<SongInfoPage> createState() => _SongInfoPageState();

  Future<Widget> getLikedStatus() async {
    if(await SongOperations.IfSongInUserLikes(user!, song)) {
      return FaIcon(FontAwesomeIcons.solidHeart, color: Colors.teal[600],);
    } 
    else {
      return FaIcon(FontAwesomeIcons.heart, color: Colors.grey[800]);
    }
  }
}

class _SongInfoPageState extends State<SongInfoPage> {
 
  String? linkMessage;

  Future<void> shareLink() async {
    if (linkMessage != null) {
      await Share.share(linkMessage!);
    }
  }

  Future<void> createDynamicLink(String songID) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://ekko.page.link/',
      link: Uri.parse('https://ekko.page.link/song-info/${songID}'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.ekko', 
        minimumVersion: 1, 
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Ekko',
        description: 'Check out this cool song on Ekko',
      ),
    );

    final Uri dynamicUrl = await FirebaseDynamicLinks.instance.buildLink(parameters);
    setState(() {
      linkMessage = dynamicUrl.toString();
    });
  }


  @override
  void initState(){
    super.initState();
    createDynamicLink(widget.song.songID);
  }

  @override
  void dispose(){
    super.dispose();
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
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
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top:10, bottom:20),
                      child: Text('Song Info', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(widget.song.songArt, width: 180, height: 180,)),
                    Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 0),
                      child: Text(widget.song.songName, style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.teal[600],
                      ),),
                    ),
                    Text(widget.song.songArtists, style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
                    SizedBox(height: 20,),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                                DocumentSnapshot userSnapshot = await widget.usersRef.doc(widget.user!.uid).get();
                                Map<dynamic, dynamic> userData = (userSnapshot.data() ?? {}) as Map<dynamic, dynamic>;
                                List<String> playHistory = List<String>.from(userData['song_history'] ?? []);
                                if (playHistory.length >= widget.maxStackSize) {
                                  await widget.usersRef.doc(widget.user!.uid).update({
                                    'song_history': FieldValue.arrayRemove([playHistory.last])
                                  });
                                }
                                await widget.usersRef.doc(widget.user!.uid).update({
                                  'song_history': FieldValue.arrayUnion([widget.song.songID])
                                });
                                SongOperations.incrementSongPlays(widget.song.songID);
                                MinimizedPlayer.song = widget.song;
                                widget.setStateOfPlayer();
                            },
                            child: FaIcon(FontAwesomeIcons.play,
                            color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(width: 30,),
                          GestureDetector(
                            onTap: () async {
                              if(await SongOperations.IfSongInUserLikes(widget.user!, widget.song)){
                                await widget.usersRef.doc(widget.user!.uid).update({
                                    'liked_songs': FieldValue.arrayRemove([widget.song.songID])});
                                    SongOperations.decrementSongLikes(widget.song.songID);
                                    ScaffoldMessenger.of(context).showSnackBar(showCustomSnackBar('Removed from Liked Songs',1));
                              }
                              else{
                                widget.usersRef.doc(widget.user!.uid).update({
                                  'liked_songs': FieldValue.arrayUnion([widget.song.songID])});
                                  SongOperations.incrementSongLikes(widget.song.songID);
                                  ScaffoldMessenger.of(context).showSnackBar(showCustomSnackBar('Added to Liked Songs',1));
                              }
                              setState(() {});
                            },
                            child: FutureBuilder<Widget>(
                              future: widget.getLikedStatus(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                } else {
                                  return CircularProgressIndicator(
                                    color: Colors.teal[400],
                                  );
                                } 
                              },
                            ) 
                          ),
                          SizedBox(width: 30,),
                          GestureDetector(
                            onTap: () async {
                              shareLink();
                            },
                            child: FaIcon(FontAwesomeIcons.shareNodes,
                            color: Colors.grey[800],
                            ),
                          ),
                        ],  
                      ),
                    ),
                    SizedBox(height: 20,),
                    FaIcon(FontAwesomeIcons.solidCirclePlay,
                    color: Colors.teal,
                    ),
                    SizedBox(height: 5,),
                    Text('Total Plays : '+widget.song.plays.toString(), style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold
                    ),),
                    SizedBox(height: 5,),
                    FaIcon(FontAwesomeIcons.solidHeart,
                    color: Colors.teal,
                    ),
                    SizedBox(height: 5,),
                    Text('Total Likes : '+widget.song.likes.toString(), style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold
                    ),),
                    SizedBox(height: 5,),
                    Text('Uploaded By : ', style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold
                    ),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 
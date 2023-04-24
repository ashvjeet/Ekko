import 'package:ekko/Models/songs.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SongInfoPage extends StatefulWidget {
  Song song;
  SongInfoPage({required this.song, super.key});

  @override
  State<SongInfoPage> createState() => _SongInfoPageState();
}

class _SongInfoPageState extends State<SongInfoPage> {
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
                          FaIcon(FontAwesomeIcons.play,
                          color: Colors.grey[800],
                          ),
                          SizedBox(width: 30,),
                          FaIcon(FontAwesomeIcons.heart,
                          color: Colors.grey[800],
                          ),
                          SizedBox(width: 30,),
                          FaIcon(FontAwesomeIcons.shareNodes,
                          color: Colors.grey[800],
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
 
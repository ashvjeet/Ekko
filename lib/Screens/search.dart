import 'package:ekko/Services/artist_operations.dart';
import 'package:flutter/material.dart';
import 'package:ekko/Models/songs.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ekko/Services/song_operations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ekko/Screens/app.dart';
import 'package:ekko/Models/artists.dart';

class Search extends StatefulWidget {

  final CollectionReference usersRef = FirebaseFirestore.instance.collection('listeners');
  final int maxStackSize = 10;
  User? user = FirebaseAuth.instance.currentUser;
  Function setStateOfPlayer;
  Search({required this.setStateOfPlayer, required this.user ,super.key});

  Widget displaySongTileSearch(Song song) {
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
          setStateOfPlayer();

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
                    child: Text(song.songName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
                  Container(
                    width: 100,
                    child: Text(song.songArtists, style: TextStyle(fontSize: 10),))
                ],
              ),
            ),
            
          ],),
        ),
      ),
    );
  }

  Future<Widget> displaySongSearchList(String value) async {
    List<Song> songList = await SongOperations.getSongSearch(value);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 10,
              top: 20
            ),
            alignment: Alignment.topLeft,
            child: Text(
              'Results in Songs', 
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 240,
              maxWidth: 300,
            ),
            child: Container(
              padding: EdgeInsets.only(
                left: 0, 
                right: 20
              ),
              child: Scrollbar(
                interactive: true,
                thickness: 5,
                radius: Radius.circular(5),
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index){
                    return displaySongTileSearch(songList[index]);
                  },
                  itemCount: songList.length,
                ),
              ),
            ),
          ),
        ],
      );
    }

  Widget displayArtistTileSearch(Artist artist) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 5,right: 0, bottom: 5),
      child: InkWell(
        onTap: () async{
        },
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            children: [
            CircleAvatar(
              maxRadius: 30,
              minRadius: 30,
              foregroundImage: NetworkImage(artist.artistDPURL)),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    child: Text(artist.artistName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Widget> displayArtistSearchList(String value) async {
    List<Artist> artistList = await ArtistOperations.getArtistSearch(value);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 10,
              top: 20,
              bottom: 5,
            ),
            alignment: Alignment.topLeft,
            child: Text(
              'Results in Artists', 
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 210,
              maxWidth: 300,
            ),
            child: Container(
              padding: EdgeInsets.only(
                left: 8, 
                right: 20
              ),
              child: Scrollbar(
                interactive: true,
                thickness: 5,
                radius: Radius.circular(5),
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index){
                    return displayArtistTileSearch(artistList[index]);
                  },
                  itemCount: artistList.length,
                ),
              ),
            ),
          ),
        ],
      );
    }



  Widget displaySongTileSearchHistory(Song song) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 5,right: 0, bottom: 5),
      child: InkWell(
        onTap: () async{
          SongOperations.incrementSongPlays(song.songID);
          MinimizedPlayer.song = song;
          setStateOfPlayer();
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
                    child: Text(song.songName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
                  Container(
                    width: 100,
                    child: Text(song.songArtists, style: TextStyle(fontSize: 10),))
                ],
              ),
            ),
            
          ],),
        ),
      ),
    );
  }

  Future<Widget> displaySongSearchHistoryList() async {
    List<Song> songList = await SongOperations.getSearchHistory(user);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 10,
              top: 20
            ),
            alignment: Alignment.topLeft,
            child: Text(
              'Recent Searches', 
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 0, 
              right: 20
            ),
            height: 240, 
            width: 300,
            child: Scrollbar(
              interactive: true,
              thickness: 5,
              radius: Radius.circular(5),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index){
                  return displaySongTileSearchHistory(songList[index]);
                },
                itemCount: songList.length,
              ),
            ),
          ),
        ],
      );
    }

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin<Search> {
  String value = '';
  bool _isTextFieldFocused = false;

  void _handleTextFieldFocus(bool isFocused) {
    setState(() {
      _isTextFieldFocused = isFocused;
    });
  }



  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size deviceSize = MediaQuery.of(context).size;
    return SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: deviceSize.height,
          ),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text('Search from thousands of', 
                style: TextStyle(
                  color: Colors.grey[800], 
                  fontWeight: FontWeight.bold, 
                  fontSize:  18),),
                Text('Songs, Artists or Playlists',
                style: TextStyle(
                  color: Colors.teal[500],
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 45,
                  child: GestureDetector(
                    onTap: (){
                      if (_isTextFieldFocused) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    child: TextField(
                      onChanged: (value) => setState(() {
                        this.value = value;
                        widget.displaySongSearchList(value);
                      }),
                      onTap: () {
                        _handleTextFieldFocus(true);
                      },
                      onEditingComplete: () {
                        _handleTextFieldFocus(false);
                      },
                      textAlignVertical: TextAlignVertical.top,
                      cursorHeight: 24,
                      cursorColor: Colors.teal,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: FaIcon(FontAwesomeIcons.magnifyingGlass),
                        ),
                        prefixIconColor: Colors.teal[600],
                      ),
                    ),
                  ),
                ),
                FutureBuilder<Widget>(
                future: widget.displaySongSearchList(value),
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
                future: widget.displayArtistSearchList(value),
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
                future: widget.displaySongSearchHistoryList(),
                builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!;
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top:185),
                      child: Center(
                        child: Text('No History Yet')
                      ),
                    );
                  }
                },
              ),
              ]
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
        ) 
      ),
    );
  }

  @override
  get wantKeepAlive => true;

}
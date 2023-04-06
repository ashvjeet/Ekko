import 'package:flutter/material.dart';
import 'package:ekko/Services/display_carousel.dart';
import 'package:ekko/Models/songs.dart';
import 'package:ekko/Services/song_operations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Home extends StatelessWidget {
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('listeners');
  final int maxStackSize = 10;
  final Function _minimizedPlayer;
  final User? user;
  Home(this._minimizedPlayer,{required this.user}); //Dart Constructor Shorthand
  /*Widget displayCategory(Category category){
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:[
            Colors.grey.shade200,
            Colors.teal.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.3,0.9]
        ), 
            borderRadius: BorderRadius.circular(15)
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, top: 10, bottom: 5),
            child: Text(category.name, style: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.bold),),
          ),
          Expanded(
            child: Padding(
            padding: EdgeInsets.only(left: 20, top:5, bottom:20, right: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(category.imageURL, fit:BoxFit.cover)
              ),
            )
          )
        ],
      )
    );
  }

  Widget displayGrid(){
    return Container(
      height: 200, 
      child: GridView.count(
        padding: EdgeInsets.all(20),
        childAspectRatio: 5/2,
        mainAxisSpacing: 10,
        children: displayListOfCategories(),
        crossAxisCount: 1,
      ),
    );
  }

  List<Widget> displayListOfCategories(){
    List<Category> categoryList = CategoryOperations.getCategories();//Receive Data
    // Convert Data to Widget using Map function
    List<Widget> categories = categoryList.map((Category category)=>displayCategory(category)).toList();
    return categories;
  }*/

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

  Widget displaySongTile(Song song) {
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
                  DocumentSnapshot userSnapshot = await usersRef.doc(user!.uid).get();
                  Map<dynamic, dynamic> userData = (userSnapshot.data() ?? {}) as Map<dynamic, dynamic>;
                  List<String> stack = List<String>.from(userData['song_history'] ?? []);
                  if (stack.length >= maxStackSize) {
                    await usersRef.doc(user!.uid).update({
                      'song_history': FieldValue.arrayRemove([stack.last])
                    });
                  }
                  await usersRef.doc(user!.uid).update({
                    'song_history': FieldValue.arrayUnion([song.songID])
                  });
                  SongOperations.incrementSongPlays(song.songID);
                  _minimizedPlayer(song);
                },
                onLongPress: () {
                  
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
          )
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
              return displaySongTile(songList[index]);
            },
            itemCount: songList.length,
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
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
                    future: FirebaseFirestore.instance.collection('listeners').doc(user!.uid).get(),
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
                      child: CircularProgressIndicator(),
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
                      child: Center(child: CircularProgressIndicator(color: Colors.teal,)),
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
                      child: Center(child: CircularProgressIndicator(color: Colors.teal,)),
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
  }
}  
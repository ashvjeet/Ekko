import 'package:ekko/Models/songs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firestore = FirebaseFirestore.instance;
final CollectionReference songsCollection = FirebaseFirestore.instance.collection('songs');
DocumentReference newSongDocRef = songsCollection.doc();

class SongOperations {
  SongOperations._() {}
  static Future<List<Song>> getSongs(String orderByFieldName, bool descendingOrder) async{
    List<Song> songlist = [];
    await firestore.collection('songs').orderBy(orderByFieldName, descending: descendingOrder).get().then((QuerySnapshot snapshot){
      snapshot.docs.forEach((DocumentSnapshot document) {
        songlist.insert(0,Song(document.get('song_id'),
                               document.get('song_name'),
                               document.get('song_art_url'),
                               document.get('contributing_artist_name'),
                               document.get('song_url'),
                               document.get('song_plays'),
                               document.get('song_likes'),
                               ));
       });
    });
    return songlist;
  }

  static Future<List<Song>> getSongSearch(String searchParameter) async{
    List<Song> songlist = [];
    await firestore.collection('songs').where('song_name',
     isGreaterThanOrEqualTo: searchParameter).where('song_name', 
     isLessThan: searchParameter+'z').get().then((QuerySnapshot snapshot){
      snapshot.docs.forEach((DocumentSnapshot document) {
        songlist.insert(0,Song(document.get('song_id'),
                               document.get('song_name'),
                               document.get('song_art_url'),
                               document.get('contributing_artist_name'),
                               document.get('song_url'),
                               document.get('song_plays'),
                               document.get('song_likes'),
                               ));
       });
    });
    return songlist;
  }

  static Future<List<Song>> getSearchHistory(User? user) async {
    List<Song> songlist = [];
    List<String> mySearchHistoryList = [];
    CollectionReference usersRef = FirebaseFirestore.instance.collection('listeners');
    DocumentSnapshot documentSnapshot = await usersRef.doc(user!.uid).get();
    if (documentSnapshot.exists) {
      Map<dynamic, dynamic> userData = (documentSnapshot.data() ?? {}) as Map<dynamic, dynamic>;
      mySearchHistoryList = List<String>.from(userData['search_history'] ?? []);
    }
    if(mySearchHistoryList.length != 0){
       await FirebaseFirestore.instance.collection('songs').where('song_id', whereIn: mySearchHistoryList).get().then((QuerySnapshot querySnapshot){
      querySnapshot.docs.forEach((QueryDocumentSnapshot document) {
        songlist.insert(0,Song(document.get('song_id'),
                               document.get('song_name'),
                               document.get('song_art_url'),
                               document.get('contributing_artist_name'),
                               document.get('song_url'),
                               document.get('song_plays'),
                               document.get('song_likes'),
                               ));
      });
    }); 
    }
    return songlist;
  }



  static void incrementSongPlays(String songID) {
    DocumentReference SongDocRef = songsCollection.doc(songID);
    SongDocRef.update({'song_plays':FieldValue.increment(1)});
  }

  static void recordSongHistory(String userID){
    
  }
}
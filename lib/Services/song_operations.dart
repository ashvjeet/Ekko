import 'package:ekko/Models/songs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                               document.get('song_plays')));
       });
    });
    return songlist;
  }

  static void incrementSongPlays(String songID) {
    DocumentReference SongDocRef = songsCollection.doc(songID);
    SongDocRef.update({'song_plays':FieldValue.increment(1)});
  }

  static void recordSongHistory(String userID){
    
  }
}
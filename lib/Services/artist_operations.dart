import 'package:ekko/Models/artists.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekko/Models/songs.dart';

final firestore = FirebaseFirestore.instance;
final CollectionReference songsCollection = FirebaseFirestore.instance.collection('artists');
DocumentReference newSongDocRef = songsCollection.doc();

class ArtistOperations {
  ArtistOperations._() {}
  static Future<List<Artist>> getArtists(String orderByFieldName, bool descendingOrder) async {
    List<Artist> artistlist = [];
    await firestore.collection('artists').orderBy(orderByFieldName, descending: descendingOrder).get().then((QuerySnapshot snapshot){
      snapshot.docs.forEach((DocumentSnapshot document) {
        artistlist.insert(0,Artist(document.get('artist_id'),
                               document.get('artist_name'),
                               document.get('artist_email'),
                               document.get('artist_DP_url'),
                               document.get('artist_type'),
                               document.get('artist_bio'),
                               document.get('artist_country'),
                               document.get('artist_plays'),
                               document.get('artist_likes'),
                               document.get('single_uploads'),
                               document.get('album_uploads')
                               ));
       });
    });
    return artistlist;
  }

  static Future<List<Song>> getSinglesOfArtist(String artistID) async {
    CollectionReference artists = FirebaseFirestore.instance.collection('artists');
    List<Song> artistSingles = [];
    List<String> artistSinglesList = [];
    DocumentSnapshot documentSnapshot = await artists.doc(artistID).get();
    if (documentSnapshot.exists) {
      Map<dynamic, dynamic> userData = (documentSnapshot.data() ?? {}) as Map<dynamic, dynamic>;
      artistSinglesList = List<String>.from(userData['single_uploads'] ?? []);
    }
    if(artistSinglesList.length != 0){
       await FirebaseFirestore.instance.collection('songs').where('song_id', whereIn: artistSinglesList).get().then((QuerySnapshot querySnapshot){
      querySnapshot.docs.forEach((QueryDocumentSnapshot document) {
        artistSingles.insert(0,Song(document.get('song_id'),
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
    return artistSingles;
  }
}
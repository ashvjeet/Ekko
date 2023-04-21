import 'package:ekko/Models/artists.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;
final CollectionReference songsCollection = FirebaseFirestore.instance.collection('artists');
DocumentReference newSongDocRef = songsCollection.doc();

class ArtistOperations {
  ArtistOperations._() {}
  static Future<List<Artist>> getArtists(String orderByFieldName, bool descendingOrder) async{
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
                               ));
       });
    });
    return artistlist;
  }
}
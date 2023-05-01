import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekko/Models/playlist.dart';
import 'package:ekko/Models/songs.dart';

final firestore = FirebaseFirestore.instance;
final CollectionReference playlistCollection = FirebaseFirestore.instance.collection('playlists');
DocumentReference newPlaylistDocRef = playlistCollection.doc();

class PlaylistOperations {
  PlaylistOperations._() {}
  static Future<List<Playlist>> getPlaylists(String orderByFieldName, bool descendingOrder) async {
    List<Playlist> playlists = [];
    await firestore.collection('playlists').orderBy(orderByFieldName, descending: descendingOrder).get().then((QuerySnapshot snapshot){
      snapshot.docs.forEach((DocumentSnapshot document) {
        playlists.insert(0,Playlist(document.get('playlist_id'),
                               document.get('playlist_name'),
                               document.get('playlist_art_url'),
                               document.get('song_ids'),
                               document.get('playlist_total_plays'),
                               ));
       });
    });
    return playlists;
  }

  static Future<List<Song>> getPlaylistSongs(String playlistID) async {
    CollectionReference artists = FirebaseFirestore.instance.collection('playlists');
    List<Song> playlistSongs = [];
    List<String> playlistSongIDs = [];
    DocumentSnapshot documentSnapshot = await artists.doc(playlistID).get();
    if (documentSnapshot.exists) {
      Map<dynamic, dynamic> userData = (documentSnapshot.data() ?? {}) as Map<dynamic, dynamic>;
      playlistSongIDs = List<String>.from(userData['song_ids'] ?? []);
    }
    if(playlistSongIDs.length != 0){
       await FirebaseFirestore.instance.collection('songs').where('song_id', whereIn: playlistSongIDs).get().then((QuerySnapshot querySnapshot){
      querySnapshot.docs.forEach((QueryDocumentSnapshot document) {
        playlistSongs.insert(0,Song(document.get('song_id'),
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
    return playlistSongs;
  }

  static void incrementPlaylistPlays(String playlistID) {
    DocumentReference playlistDocRef = playlistCollection.doc(playlistID);
    playlistDocRef.update({'playlist_total_plays':FieldValue.increment(1)});
  }
}
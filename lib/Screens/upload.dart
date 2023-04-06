import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekko/Services/song_operations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
//import 'package:fluttertoast/fluttertoast.dart';


class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController songName = TextEditingController();
  TextEditingController contributingArtistName = TextEditingController();

  String? imageDownURL = null;
  String? audioDownURL = null;
  final firestoreInstance = FirebaseFirestore.instance;
  String audioFileName = '';
  String uploadErrorMessage = '';
  String selectedImagePath = '';
  String imageToDisplay = 'https://firebasestorage.googleapis.com/v0/b/ekko-d8ad2.appspot.com/o/EkkoLogos%2Fimage_upload.png?alt=media&token=b8947947-026a-40c4-99d8-75553e5515cb'; 

  Future<File?> selectImage()async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
    if (result != null){
      selectedImagePath = result.files.single.path!;
      File selectedImage = File(selectedImagePath);
      //_imageToDisplay = selectedImage;
      CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: selectedImage.path, 
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop Your Image',
              toolbarColor: Colors.teal[200],
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          IOSUiSettings(
            title: 'Crop you Image',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
                const CroppieViewPort(width: 480, height: 480, type: 'square'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ]
      );
      if (croppedImage != null){
      return File(croppedImage.path);
      }
      else{
        return null;
      }
    }
    else{
      return null;
    }
  }

  Future<String?> uploadImageFile(File image) async
  {
    String filename = DateTime.now().millisecondsSinceEpoch.toString()+'.jpg';
    Reference ref = FirebaseStorage.instance.ref().child('SongArt/$filename');
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    if(snapshot.state == TaskState.success){
      final imageDownURL = await snapshot.ref.getDownloadURL();
      return imageDownURL;
    }
    else{
      return null;
    }  
  }

  Future<File?> selectAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.audio);
    if (result != null){
      File audioFile = File(result.files.single.path!);
      audioFileName = audioFile.path.split('/').last;
      return(audioFile);
    }
    else{
      return null;
    }
  }

  Future<String?> uploadAudioFile(File audio) async
  {
    String filename = DateTime.now().millisecondsSinceEpoch.toString()+'.mp3';
    Reference ref = FirebaseStorage.instance.ref().child('Songs/$filename');
    UploadTask uploadTask = ref.putFile(audio);
    TaskSnapshot snapshot = await uploadTask;
    if(snapshot.state == TaskState.success){
      final audioDownURL = await snapshot.ref.getDownloadURL();
      return audioDownURL;
    }
    else{
      return null;
    }  
  }

  void _updateImage(){
    if(imageDownURL!=null){
      imageToDisplay = imageDownURL!;
    }
  }

  finalUpload(){
    var data = {
      'song_id':'',
      'song_name':songName.text, 
      'contributing_artist_name':contributingArtistName.text, 
      'song_url':audioDownURL, 
      'song_art_url':imageDownURL,
      'upload_date_time':DateTime.now(),
      'song_plays':0,
    };
    newSongDocRef.set(data);
    final String songID = newSongDocRef.id;
    newSongDocRef.update({'song_id':songID});
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
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
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top:10, bottom:20),
                  child: Text('Upload Song Art', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap:() async {
                     File? image = await selectImage();
                     if(image != null){
                        imageDownURL = await uploadImageFile(image);
                      }
                      _updateImage();
                      setState(() {});
                    },
                    child: Ink.image(
                      image: NetworkImage(imageToDisplay),
                      height: 180,
                      width: 180,
                      )
                      ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[100], elevation: 10, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    onPressed: () async {
                      File? audio = await selectAudio();
                      setState(() {});
                      if(audio != null){
                        audioDownURL = await uploadAudioFile(audio);
                      }
                    },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: FaIcon(FontAwesomeIcons.plus, color: Colors.black),
                      ),
                      Text('Upload Track', style: TextStyle(color: Colors.black)),
                    ],
                  )),
                ),
                Text(audioFileName),
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 30, top:20),
                  child: TextFormField(
                    controller: songName,
                    decoration: InputDecoration(
                      label: Text('Song Name'), 
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
                    ),
                  ),
                 Padding(
                  padding: EdgeInsets.only(left: 30, right: 30, top:20),
                  child: TextFormField(
                    controller: contributingArtistName,
                    decoration: InputDecoration(
                      label: Text('Contributing Artists (optional)'
                      ), 
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[100], elevation: 10, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    onPressed: (){
                      
                      if (songName!='' && audioDownURL!=null && imageDownURL !=null)
                      {
                        uploadErrorMessage = '';
                        finalUpload();
                        /*Fluttertoast.showToast(
                          msg: "Upload Successful",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 2,
                          backgroundColor: Colors.grey[600],
                          textColor: Colors.white,
                          fontSize: 14.0
                        );*/
                        const snackdemo = SnackBar(
                          content: Text('Upload Successful'),
                          backgroundColor: Colors.green,
                          elevation: 20,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(5),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackdemo);
      
                        songName.clear();
                        contributingArtistName.clear();
                        audioFileName = '';
                        audioDownURL = null;
                        imageDownURL = null;
                        imageToDisplay = 'https://firebasestorage.googleapis.com/v0/b/ekko-d8ad2.appspot.com/o/EkkoLogos%2Fimage_upload.png?alt=media&token=b8947947-026a-40c4-99d8-75553e5515cb';
                        setState(() {});
                      } 
                      else 
                      {
                        uploadErrorMessage = 'Song name, Audio File and Song Art are compulsory';
                        setState(() {});
                        
                      } 
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.cloud_upload_outlined, color: Colors.black,),
                        ),
                        Text('UPLOAD', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                      ],
                    )
                  ),
                ),
                Text(
                  uploadErrorMessage, 
                  style: TextStyle(
                    color: Colors.red[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

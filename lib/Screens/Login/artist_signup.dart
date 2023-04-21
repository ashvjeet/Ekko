import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ekko/Widgets/custom_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ekko/Screens/Login/signup.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:ekko/Screens/artist_app.dart';


class ArtistSignUp extends StatefulWidget {
  const ArtistSignUp({super.key});

  @override
  State<ArtistSignUp> createState() => _ArtistSignUpState();
}

class _ArtistSignUpState extends State<ArtistSignUp> with WidgetsBindingObserver {
  
  TextEditingController artistNameController = new TextEditingController();
  TextEditingController artistEmailController = new TextEditingController();
  TextEditingController artistTypeController = new TextEditingController();
  TextEditingController artistBioController = new TextEditingController();
  String artistCountry = 'Unknown';


  final List<String> artistTypeNames = [
    'Singer',
    'Producer/DJ',
    'Instrumentalist',
    'Mix/Mastering Engineer',
  ];

  List<DropdownMenuEntry<String>>artistTypes = <DropdownMenuEntry<String>>[];

  String selectedType = 'Singer';
  String? DPDownURL = null;
  String selectedImagePath = '';
  String imageToDisplay = 'https://firebasestorage.googleapis.com/v0/b/ekko-d8ad2.appspot.com/o/EkkoLogos%2FDP_upload.png?alt=media&token=cc86fd87-2c04-4dee-8c05-3c7563af3555';
  String link = '';
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();


  Future<File?> selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
    if (result != null){
      selectedImagePath = result.files.single.path!;
      File selectedImage = File(selectedImagePath);
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
    Reference ref = FirebaseStorage.instance.ref().child('ArtistDP/$filename');
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    if(snapshot.state == TaskState.success){
      final DPDownURL = await snapshot.ref.getDownloadURL();
      return DPDownURL;
    }
    else{
      return null;
    }  
  }

  void _updateDP(){
    if(DPDownURL!=null){
      imageToDisplay = DPDownURL!;
    }
  }

   Future<bool> validateAndSave() async {
    final FormState form = formKey.currentState!;
    if (form.validate()) {
      form.save();
      bool sent = await sendSignUpLink();
      return sent;
    }
    return false;
  }

   Future<bool> sendSignUpLink() async {
    try {
      var acs = ActionCodeSettings(
        url: 'https://ekko.page.link/getstarted',                             
        handleCodeInApp: true,
        androidPackageName: 'com.example.ekko',
        androidInstallApp: true,
        androidMinimumVersion: '1');
        SignUp.auth.sendSignInLinkToEmail(
        email: artistEmailController.text,
        actionCodeSettings: acs);
    } 
    catch (e) {
      _showDialog(e.toString());
      return false;
    }
    print(artistEmailController.text + "<< sent");
    return true;
  }

  void _showDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Please Try Again.Error code: " + error),
          actions: <Widget>[
            ElevatedButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> retrieveDynamicLink() async {

    Uri? deepLink;
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();

    if(data != null) {
      deepLink = data.link;
      link = deepLink.toString();
    }

    FirebaseDynamicLinks.instance.onLink.listen(
      (pendingDynamicLinkData) async {
        deepLink = pendingDynamicLinkData.link;
        link = deepLink.toString();
      },
    );

    await signInWithEmailAndLink();
    return deepLink.toString();
  }

  Future<void> signInWithEmailAndLink() async {
    bool validLink = await SignUp.auth.isSignInWithEmailLink(link);
    if (validLink) {
      try {
        await SignUp.auth.signInWithEmailLink(email: artistEmailController.text ,emailLink: link);
        SignUp.auth.authStateChanges().listen((User? user) async {
          if(user != null){
            var data = {
              'artist_id':user.uid,
              'artist_DP_url':DPDownURL,
              'artist_name':artistNameController.text,
              'artist_email':artistEmailController.text,
              'artist_type':artistTypeController.text,
              'artist_bio':artistBioController.text,
              'artist_country':artistCountry,
              'artist_plays':0,
              'artist_likes':0,
            };
            final firestore = FirebaseFirestore.instance.collection('artists').doc(user.uid);
            await firestore.set(data);
            await Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistApp()));
          }
        });
      } catch (e) {
        print(e);
        _showDialog(e.toString());
      }
    }
  }

   @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      retrieveDynamicLink();
    }
  }

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    retrieveDynamicLink();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snackBarEmailSent = SnackBar(
      content: Text('Email Sent!')
      );
    final snackBarEmailNotSent = SnackBar(
      content: Text('Email Not Sent. Error.'),
    );
    Size deviceSize = MediaQuery.of(context).size;
      artistTypes  = artistTypeNames.map((String value) {
      return DropdownMenuEntry<String>(
        value: value,
        label: value,
      );
    }).toList();
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        height: deviceSize.height,
        width: deviceSize.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ 
              Colors.white60,
              Colors.teal.shade100,
              ], 
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ), 
        ),
         child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 70, left: 20, right:20, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text(
                    'Get your Music out there', 
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.grey[500]
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text(
                    'Hassle Free', 
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.grey[500]
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 25, 
                    bottom: 25,
                  ),
                  child: Text(
                    'Sign up now to Upload', 
                    style: TextStyle(
                      fontSize: 25, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.teal[300],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],  
                      borderRadius: BorderRadius.circular(40)
                    ),
                    child: Center(
                      child: Form(
                        key: formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget> [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0,10,0,10),
                              child: Text('Upload Profile Picture',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap:() async {
                              File? image = await selectImage();
                              if(image != null){
                                  DPDownURL = await uploadImageFile(image);
                                }
                                _updateDP();
                                setState(() {});
                              },
                              child: CircleAvatar(
                                foregroundImage: NetworkImage(imageToDisplay),
                                backgroundColor: Colors.white,
                                radius: 90,
                                )
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 20, 
                                left: 25, 
                                right: 25
                              ),
                              child: customTextField(
                                'Artist Name', 
                                FontAwesomeIcons.solidUser, 
                                true, 
                                artistNameController
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 20, 
                                left: 25, 
                                right: 25
                              ),
                              child: customTextField(
                                'Artist Email', 
                                FontAwesomeIcons.solidEnvelope, 
                                false , 
                                artistEmailController
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(50,10,50,10),
                              child: Text('You will receive a link on this email to Sign in. This Email will also be used for further communications',
                                style: TextStyle(
                                    fontSize: 14, 
                                    fontWeight: FontWeight.bold, 
                                    color: Colors.grey[600],
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            DropdownMenu<String>(
                              enableSearch: false,
                              initialSelection: artistTypeNames[0],
                              controller: artistTypeController,
                              label: const Text('Select artist Type', style: TextStyle(fontSize: 17),),
                              dropdownMenuEntries: artistTypes,
                              onSelected: (String? type) {
                                setState(() {
                                  selectedType = type!;
                                });
                              },
                            ),
                            SizedBox(height: 10,),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 20, 
                                left: 25, 
                                right: 25
                              ),
                              child: TextFormField(
                                maxLines: null,
                                controller: artistBioController,
                                autocorrect: true,
                                validator: (value) {
                                  if (value!.isEmpty) return "Artist Bio cannot be empty";
                                  return null;
                                },
                                cursorColor: Colors.grey[800],
                                style: TextStyle(
                                  color: Colors.grey.shade800.withOpacity(0.9)),
                                  decoration: InputDecoration(
                                  prefixIcon: Icon(
                                      FontAwesomeIcons.pen,
                                      color:Colors.grey[800],
                                      size: 17,
                                    ),
                                  labelText: 'Enter your Bio',
                                  labelStyle: TextStyle(color: Colors.grey.shade800.withOpacity(0.9)),
                                  filled: true,
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  fillColor: Colors.white.withOpacity(0.3),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      width: 0, 
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.multiline,
                              ),
                            ),
                            SizedBox(height: 20,),
                            Text('Select your Country', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),),
                            SizedBox(height: 5,),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 10,
                                backgroundColor: Colors.teal[300],
                                minimumSize: Size(100, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)
                                )
                              ),
                              onPressed: (){
                              showCountryPicker(
                              context: context,
                              showPhoneCode: false,
                              onSelect: (Country country) {
                                artistCountry = country.flagEmoji+" "+country.displayNameNoCountryCode;
                              },
                              onClosed: () {
                                setState(() {});
                              },
                            );
                            }, 
                            child: artistCountry=='Unknown'?Text('Select Nationality'):Text(artistCountry)
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 20, 
                                left: 25, 
                                right: 25, 
                                bottom: 25
                              ),
                              child: customButton('SIGN UP',
                                () async {
                                  await validateAndSave()
                                    ? ScaffoldMessenger.of(context).showSnackBar(snackBarEmailSent)
                                    : ScaffoldMessenger.of(context).showSnackBar(snackBarEmailNotSent);
                                }
                              ),
                            ),
                          ]
                        )
                      )
                    )
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
}
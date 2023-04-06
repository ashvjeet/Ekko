import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekko/Screens/app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ekko/Widgets/custom_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ekko/Screens/Login/login.dart';
import 'package:google_sign_in/google_sign_in.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
    final OAuthCredential googleAuthCredential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken, 
      idToken: googleSignInAuthentication.idToken);

    return await auth.signInWithCredential(googleAuthCredential);
  }
  

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
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
                    'Sign Up now,', 
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
                    bottom: deviceSize.height*0.1
                  ),
                  child: Text(
                    'Listen free Forever', 
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
                      color: Colors.grey[100], 
                      backgroundBlendMode: BlendMode.multiply, 
                      borderRadius: BorderRadius.circular(40)
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget> [
                          Padding(
                            padding: EdgeInsets.only(
                              top: 20, 
                              left: 25, 
                              right: 25
                            ),
                            child: customTextField(
                              'First Name', 
                              FontAwesomeIcons.solidUser, 
                              false, 
                              _nameController
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 20, 
                              left: 25, 
                              right: 25
                            ),
                            child: customTextField(
                              'Email Address', 
                              FontAwesomeIcons.solidEnvelope, 
                              false , 
                              _emailController
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 30, 
                              left: 25, 
                              right: 25, 
                              bottom: 5
                            ),
                            child: customButton('SIGN UP',() async{
                              var acs = ActionCodeSettings(
                                url: 'https://ekko.page.link/qL6j',
                                handleCodeInApp: true,
                                iOSBundleId: 'com.example.ekko',
                                androidPackageName: 'com.example.ekko',
                                androidInstallApp: true,
                                androidMinimumVersion: '12');

                              await FirebaseAuth.instance.sendSignInLinkToEmail(
                                email: _emailController.text, 
                                actionCodeSettings: acs).catchError((onError) => Text('Error sending email verification $onError')).then((value) => {
                                  Text('Successfully sent SignUp link to email'),
                                  FirebaseAuth.instance.authStateChanges().listen((User? user) {
                                    if(user != null){
                                      var data = {
                                        'listener_id':user.uid,
                                        'first_name':_nameController.text,
                                        'listener_email':_emailController.text,
                                      };
                                      final firestore = FirebaseFirestore.instance.collection('listeners').doc(user.uid);
                                      firestore.set(data);
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
                                    }
                                   }
                                  ),
                                }
                              );
                            }),
                          ),
                          Text('OR', style: TextStyle(fontWeight: FontWeight.bold),),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                              left: 40, 
                              right: 40, 
                              bottom: 30
                            ),
                            child: ElevatedButton(
                              onPressed: () async{
                                try{
                                  final UserCredential userCredential = await signInWithGoogle();
                                  FirebaseAuth.instance.authStateChanges().listen((User? user) {
                                    if(user != null){
                                      var data = {
                                        'listener_id':userCredential.user!.uid,
                                        'first_name':userCredential.user!.displayName!.split(' ')[0],
                                        'listener_email': userCredential.user!.email,
                                      };
                                      final firestore = FirebaseFirestore.instance.collection('listeners').doc(userCredential.user!.uid);
                                      firestore.set(data);
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
                                    }
                                  });
                                }
                                catch(e){
                                  Text('Google Sign in failed: $e');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[800],
                                minimumSize: Size(260, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)
                                ),
                                elevation: 10
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  child: Image.asset('lib/Assets/Logos/google_sign_in.png', fit: BoxFit.cover,)),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text('SIGN UP WITH GOOGLE', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                  )
                          
                              ],)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                            bottom: 5
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already Have an account ?', 
                                  style: TextStyle(
                                    fontSize: 12
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()))
                                  },
                                  child: Text(' Log in', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold ),),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                            bottom: 20
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Are you an Artist? Sign Up for', 
                                  style: TextStyle(
                                    fontSize: 12
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => Login()))
                                      },
                                  child: Text(' Ekko Artist', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold ),),
                                )
                              ],
                            ),
                          ),
                        ],
                      ) 
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  } 
}
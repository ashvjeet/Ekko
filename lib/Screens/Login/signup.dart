import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekko/Screens/app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ekko/Widgets/custom_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ekko/Screens/Login/login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class SignUp extends StatefulWidget {
  SignUp({super.key});
  static final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with WidgetsBindingObserver {
  TextEditingController nameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  String link = '';
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSignInMethodEmail = false;


  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
    final OAuthCredential googleAuthCredential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken, 
      idToken: googleSignInAuthentication.idToken);
    return await SignUp.auth.signInWithCredential(googleAuthCredential);
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
        email: emailController.text,
        actionCodeSettings: acs);
    } 
    catch (e) {
      _showDialog(e.toString());
      return false;
    }
    print(emailController.text + "<< sent");
    return true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
     if (state == AppLifecycleState.resumed) {
      retrieveDynamicLink();
    }
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
        await SignUp.auth.signInWithEmailLink(email: emailController.text ,emailLink: link);
        SignUp.auth.authStateChanges().listen((User? user) async {
          if(user != null){
            var data = {
              'listener_id':user.uid,
              'first_name':nameController.text,
              'listener_email':emailController.text,
            };
            final firestore = FirebaseFirestore.instance.collection('listeners').doc(user.uid);
            await firestore.set(data);
            await Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
          }
        });
      } catch (e) {
        print(e);
        _showDialog(e.toString());
      }
    }
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
                      child: Form(
                        key: formKey,
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
                                true, 
                                nameController
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
                                emailController
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 30, 
                                left: 25, 
                                right: 25, 
                                bottom: 5
                              ),
                              child: customButton('SIGN UP',() async {
                                isSignInMethodEmail = true;
                                await validateAndSave()
                                  ? ScaffoldMessenger.of(context).showSnackBar(snackBarEmailSent)
                                  : ScaffoldMessenger.of(context).showSnackBar(snackBarEmailNotSent);
                                }
                              ),
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
                                    isSignInMethodEmail = false;
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
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()))
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
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()))
                                        },
                                    child: Text(' Ekko Artist', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold ),),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
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
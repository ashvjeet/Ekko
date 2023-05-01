import 'package:flutter/material.dart';
import 'package:ekko/Widgets/custom_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ekko/Screens/Login/signup.dart';
import 'package:ekko/Screens/app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekko/Screens/artist_app.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<User?>(
        stream: SignUp.auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              return LoginPage();
            }
            return ListenerApp();
          } else {
            return Text('Unable to Login');
          }
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {

  final formKey = GlobalKey<FormState>();
  String link = '';
  TextEditingController emailController = TextEditingController();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
    final OAuthCredential googleAuthCredential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken, 
      idToken: googleSignInAuthentication.idToken);
    return await SignUp.auth.signInWithCredential(googleAuthCredential);
  }

  Future<bool> isUserInListeners(String? uid) async {
  DocumentReference documentReference = FirebaseFirestore.instance.doc("listeners/$uid");
  DocumentSnapshot documentSnapshot = await documentReference.get();
  return documentSnapshot.exists;
  }

  Future<bool> isUserInArtists(String? uid) async {
  DocumentReference documentReference = FirebaseFirestore.instance.doc("artists/$uid");
  DocumentSnapshot documentSnapshot = await documentReference.get();
  return documentSnapshot.exists;
  }

  Future<bool> checkEmailExistsInListeners(String email) async {
  final QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore.instance
    .collection('listeners')
    .where('listener_email', isEqualTo: email)
    .get();
    return result.docs.isNotEmpty;
  }

  Future<bool> checkEmailExistsInArtists(String email) async {
  final QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore.instance
    .collection('artists')
    .where('artist_email', isEqualTo: email)
    .get();
    return result.docs.isNotEmpty;
  }

  Future<bool> checkEmailExistsValidateAndSave() async { 
    final FormState form = formKey.currentState!;
    if (form.validate()) {
      if(await checkEmailExistsInListeners(emailController.text) || await checkEmailExistsInArtists(emailController.text))
      {
        form.save();
        bool sent = await sendSignUpLink();
        return sent;
      }
      else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Login Failed", 
              style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text("Account does not exist, Please Sign Up first",
              style: TextStyle(color: Colors.red[800]),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.teal[300]
                  ),
                  child: Text("Close",
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.teal[300]
                  ),
                  child: Text("Sign Up", 
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                  ),
                  onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                  },
                ),
              ],
            );
          },
        );
      } 
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
    // final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    
    // if(data != null) {
    //   deepLink = data.link;
    //   link = deepLink.toString();
    // }

    FirebaseDynamicLinks.instance.onLink.listen(
      (pendingDynamicLinkData) async {
        deepLink = pendingDynamicLinkData.link;
        link = deepLink.toString();
      },
    );

    await logInWithEmailAndLink();
    return deepLink.toString();
  }

  Future<void> logInWithEmailAndLink() async {
    bool validLink = await SignUp.auth.isSignInWithEmailLink(link);
    if (validLink) {
      try {
        await SignUp.auth.signInWithEmailLink(email: emailController.text ,emailLink: link);
        SignUp.auth.authStateChanges().listen((User? user) async {
          if(user != null && await checkEmailExistsInListeners(emailController.text))
          {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => ListenerApp()));
          }
          else if(user != null && await checkEmailExistsInArtists(emailController.text))
          {
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
  }

  @override
  void dispose(){
    super.dispose();
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
                    'Listen to music,', 
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
                  ),
                  child: Text(
                    'The way it\'s meant to be', 
                    style: TextStyle(
                      fontSize: 25, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.teal[300],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Opacity(
                    opacity: 0.9,
                    child: Image.asset(
                    'lib/Assets/Logos/ekko_logo.png',
                    height: 120,
                    width: 120,
                    color: Colors.grey[800],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(40,25,10,0),
                          child: Text('Enter your Email,',
                            style: TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.teal[300],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(40,0,10,0),
                          child: Text('You will receive a link to login',
                          style: TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget> [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 20, 
                                  left: 25, 
                                  right: 25
                                ),
                                child: Form(
                                  key: formKey,
                                  child: customTextField(
                                    'Email', 
                                    FontAwesomeIcons.solidEnvelope, 
                                    false, 
                                    emailController
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 30, 
                                  left: 25, 
                                  right: 25, 
                                  bottom: 5,
                                ),
                                child: customButton('LOG IN', () async { 
                                  await checkEmailExistsValidateAndSave()
                                  ? ScaffoldMessenger.of(context).showSnackBar(showCustomSnackBar('Email sent Successfully', 2))
                                  : ScaffoldMessenger.of(context).showSnackBar(showCustomSnackBar('Error sending Email', 2));
                                }
                                ),
                              ),
                              Text('OR', style: TextStyle(fontWeight: FontWeight.bold),),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 5,
                                  left: 40, 
                                  right: 40, 
                                  bottom: 5,
                                ),
                                child: ElevatedButton(
                                  onPressed: () async{
                                    try{
                                      final UserCredential userCredential = await signInWithGoogle();
                                      SignUp.auth.authStateChanges().listen((User? user) async {
                                        if(await isUserInListeners(userCredential.user?.uid)){
                                          final snackBarLoginSuccess = SnackBar(
                                          elevation: 10,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                          clipBehavior: Clip.antiAlias,
                                          backgroundColor: Colors.teal[200],
                                          content: Text('Login Successful, Welcome back', 
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Kanit',
                                          ),),
                                          );
                                          await ScaffoldMessenger.of(context).showSnackBar(snackBarLoginSuccess);
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => ListenerApp()));
                                        }
                                        else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Login Failed", 
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                content: Text("Account does not exist, Please Sign Up first",
                                                style: TextStyle(color: Colors.red[800]),
                                                ),
                                                actions: <Widget>[
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      elevation: 5,
                                                      backgroundColor: Colors.teal[300]
                                                    ),
                                                    child: Text("Close",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      elevation: 5,
                                                      backgroundColor: Colors.teal[300]
                                                    ),
                                                    child: Text("Sign Up", 
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                    ),
                                                    onPressed: () {
                                                       Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
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
                                    maximumSize: Size(260, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)
                                    ),
                                    elevation: 10
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
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
                                          child: Text('LOG IN WITH GOOGLE', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                        )
                                                            
                                    ],),
                                  )),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(50,5,40,30),
                                child: Text('Note: Google login method is currently supported only for listener accounts',
                                style: TextStyle(
                                  fontSize: 12, 
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.grey[600],
                                ),
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
                                    'New to Ekko?', 
                                    style: TextStyle(
                                      fontSize: 12
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()))
                                    },
                                    child: Text(' Sign Up', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold ),),
                                  )
                                ],
                               ),
                              )
                            ],
                          ) 
                        ),
                      ],
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
import 'package:flutter/material.dart';
import 'package:ekko/Widgets/custom_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ekko/Screens/Login/signup.dart';
import 'package:ekko/Screens/app.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
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
                              'Email', 
                              FontAwesomeIcons.solidUser, 
                              false, 
                              _emailController
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 20, 
                              left: 25, 
                              right: 25
                            ),
                            child: customTextField(
                              'Password', 
                              FontAwesomeIcons.key, 
                              true, 
                              _passwordController
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 30, 
                              left: 25, 
                              right: 25, 
                              bottom: 30
                            ),
                            child: customButton('LOG IN', (){ 
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>MyApp()));}),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                            bottom: 20
                            ),
                            child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'New to Ekko ?', 
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
                           ],),
                         )
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
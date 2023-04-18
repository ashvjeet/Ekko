import 'package:ekko/Screens/Login/login.dart';
import 'package:ekko/Screens/Login/signup.dart';
import 'package:ekko/Services/pause_play.dart';
import 'package:ekko/Assets/Themes/style.dart';
import 'package:ekko/Models/songs.dart';
import 'package:ekko/Screens/home.dart';
import 'package:ekko/Screens/library.dart';
import 'package:ekko/Screens/search.dart';
import 'package:ekko/Screens/upload.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Tab extends StatefulWidget {
  Tab({required this.playerKey, super.key});
  GlobalKey<_MinimizedPlayerState> playerKey;

  static int currentTabIndex = 0;

  @override
  State<Tab> createState() => _TabState();
}

class _TabState extends State<Tab> {
  User? user = FirebaseAuth.instance.currentUser;
  var navigationTabs = [];
  

  @override
  void initState(){
    super.initState();
    navigationTabs = [Home(setStateOfPlayer:()=>widget.playerKey.currentState?.setState(() {}), user: user), 
    Search(setStateOfPlayer:()=>widget.playerKey.currentState?.setState(() {}), user: user), 
    Library(), 
    Upload()
    ];
  }
  @override
  Widget build(BuildContext context) {
    return navigationTabs[Tab.currentTabIndex];
  }
}


class MinimizedPlayer extends StatefulWidget {
  static Song? song = null;
  static bool setState = false;
  const MinimizedPlayer({Key? key}):super(key: key);
 
  @override
  State<MinimizedPlayer> createState() => _MinimizedPlayerState();
 
}

class _MinimizedPlayerState extends State<MinimizedPlayer> {
  final AudioManager _audioManager = AudioManager();

  void initState(){
    super.initState();
  }

  void dispose(){
    _audioManager.dispose();
    super.dispose();
  }

  Widget minimizedPlayer(Song? song) {
    if(MinimizedPlayer.setState == true){
      setState(() {});
    }
    if(song==null){
      return SizedBox(height: 0, width: 0);
    }
    else{
      AudioManager.url = song.audioURL;
      _audioManager.startPlayback();
      Size deviceSize = MediaQuery.of(context).size;
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: Colors.teal[100],
          width: deviceSize.width ,
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(top: 5, bottom: 5, left: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(song.songArt, fit: BoxFit.cover))),
              Container(
                padding: EdgeInsets.only(left: 10, top: 8, bottom: 8),
                width: 100,
                height: 55,
                child: Marquee(
                  child: Column(
                    children: [
                    Text(song.songName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                    Text(song.songArtists, style: TextStyle(fontSize: 12))
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  textDirection : TextDirection.ltr,
                  animationDuration: Duration(seconds: 5),
                  backDuration: Duration(milliseconds: 5000),
                  pauseDuration: Duration(milliseconds: 1500),
                  directionMarguee: DirectionMarguee.oneDirection, 
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:20,right: 5),
                child: Container(
                  width: 100,
                  child: ValueListenableBuilder<ProgressBarState>(
                    valueListenable: _audioManager.progressNotifier,
                    builder: (_, value, __) {
                      return ProgressBar(
                        progress: value.current,
                        buffered: value.buffered,
                        total: value.total,
                        onSeek: _audioManager.seek,
                        timeLabelLocation: TimeLabelLocation.none,
                        thumbRadius: 7,
                        baseBarColor: Colors.grey[200],
                        bufferedBarColor: Colors.grey[300],
                        thumbColor: Colors.teal[300],
                        progressBarColor: Colors.teal[200],
                        thumbGlowRadius: 20,
                      );
                    },
                  )
                ),
              ),
              ValueListenableBuilder<ButtonState>(
                valueListenable: _audioManager.buttonNotifier,
                builder: (_, value, __) {
                  switch (value) {
                    case ButtonState.loading:
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        width: 32.0,
                        height: 32.0,
                        child: const CircularProgressIndicator(),
                      );
                    case ButtonState.paused:
                      return IconButton(
                        icon: FaIcon(FontAwesomeIcons.play, color: Colors.grey[800]),
                        iconSize: 32.0,
                        onPressed: () {_audioManager.play();}
                      );
                    case ButtonState.playing:
                      return IconButton(
                        icon: FaIcon(FontAwesomeIcons.pause, color: Colors.grey[800]),
                        iconSize: 32.0,
                        onPressed: () {_audioManager.pausePlayback();},
                      );
                  }
                },
              ),
              IconButton(
                onPressed: () {
                  _audioManager.seek(Duration.zero);
                  _audioManager.dispose();
                },
                icon: FaIcon(FontAwesomeIcons.forwardStep, color: Colors.grey[800],)
              ),
            ]
          ),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return minimizedPlayer(MinimizedPlayer.song);
  }
}

class MyBottomNavigationBar extends StatefulWidget {
  MyBottomNavigationBar({required this.navTabKey, super.key});
  GlobalKey navTabKey = GlobalKey();

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: Tab.currentTabIndex,
      onTap: (currentIndex){
        Tab.currentTabIndex = currentIndex;
        widget.navTabKey.currentState?.setState(() {}); 
        setState(() {});//Re-render on each press
      },
      backgroundColor: Colors.grey[100],
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedLabelStyle: null,
      selectedItemColor: Colors.teal[500],
      unselectedItemColor: Colors.grey[800],
      type: BottomNavigationBarType.fixed,
      items: [
      BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.house),label: 'HOME',),
      BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.magnifyingGlass),label: 'SEARCH'),
      BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.recordVinyl),label: 'LIBRARY'),
      BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.cloudArrowUp),label: 'UPLOAD')
    ]);
  }
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key:key);
  
  @override
  State <MyApp> createState() => _MyAppState();

  
}

class _MyAppState extends State <MyApp> {
  GlobalKey<_TabState> navTabKey = GlobalKey<_TabState>();
  GlobalKey<_MinimizedPlayerState> playerKey = GlobalKey<_MinimizedPlayerState>();

  void _showMenu(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final menu = PopupMenuButton(
      elevation: 10,
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Row(
            children: [
              FaIcon(FontAwesomeIcons.user, size: 15,),
              SizedBox(width: 10),
              Text("Profile"),
            ],
          ),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              FaIcon(FontAwesomeIcons.doorOpen, size: 15,),
              SizedBox(width: 10),
              Text("Logout"),
            ],
          ),
          onTap: () {
            SignUp.auth.signOut().then((value) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Login()),
              ModalRoute.withName('/'));
          });
          }
        ),
      ],
    );

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(screenWidth - 120, 80, 0, 0),
      items: menu.itemBuilder(context),
    );
}

  @override
  void initState(){
    super.initState();
  }

  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Tab(key: navTabKey, playerKey: playerKey),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: -20,
          leading: Icon(Icons.menu, color: Colors.grey[800]),
          title: appLogo,
          centerTitle: false,
          actions: [
            FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: FaIcon(FontAwesomeIcons.solidUser, color: Colors.black, size: 22,),
              onPressed: () {
                _showMenu(context);
              },
            ), 
          ], 
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: MinimizedPlayer(key: playerKey)),
            MyBottomNavigationBar(navTabKey: navTabKey),
          ],
        ),
      ),
    );
  }
}




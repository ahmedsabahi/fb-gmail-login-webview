import 'package:easacc_task/screens/webview_screen.dart';
import 'package:easacc_task/widgets/bluetooth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easacc_task/screens/sign_in_screen.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class UserInfoScreenFb extends StatefulWidget {
  const UserInfoScreenFb({Key key, @required this.userData}) : super(key: key);

  final dynamic userData;

  @override
  _UserInfoScreenFbState createState() => _UserInfoScreenFbState();
}

class _UserInfoScreenFbState extends State<UserInfoScreenFb> {
  bool _isSigningOut = false;

  TextEditingController textController = new TextEditingController();

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.slowMiddle;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Future<void> _logOut() async {
    await FacebookAuth.instance.logOut();
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C384A),
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(),
                  ClipOval(
                    child: Image.network(
                      widget.userData["picture"]["data"]["url"],
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Hello',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 26,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    widget.userData["name"],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                  SizedBox(height: 30.0),
                  _isSigningOut
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        )
                      : ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.redAccent,
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              _isSigningOut = true;
                            });
                            await _logOut();
                            setState(() {
                              _isSigningOut = false;
                            });
                            Navigator.of(context)
                                .pushReplacement(_routeToSignInScreen());
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                  SizedBox(height: 30.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      TextField(
                        controller: textController,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w300),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.link),
                          hintStyle: TextStyle(
                              fontWeight: FontWeight.w300, color: Colors.grey),
                          hintText: 'Enter URL',
                          helperText: "google.com",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          child: Text("web view"),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    WebViewScreen(url: textController.text),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 60.0),
                  // ElevatedButton(
                  //   child: Text("Devices on your Local Network"),
                  //   onPressed: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (context) => BluetoothScreen(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

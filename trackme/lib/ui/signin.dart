import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackme/bloc/track_data.dart';
import 'package:trackme/bloc/tracker_bloc.dart';
import 'package:trackme/ui/snack.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> implements SnackBarListener {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text('Sign In'),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: Container(),
          ),
        ),
        backgroundColor: Colors.brown[100],
        body: Padding(
          padding: const EdgeInsets.only(top: 40.0, left: 8, right: 8),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 40,
                        ),
                        Text(
                          'Tracker Sign In',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.black),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        isBusy
                            ? Container(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.pink,
                            strokeWidth: 16,
                          ),
                        )
                            : Container(),
                        SizedBox(
                          height: 40,
                        ),
                        TextField(
                          onChanged: _onEmailChanged,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter email address',
                            labelText: 'Email Address',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                          onChanged: _onPasswordChanged,
                          keyboardType: TextInputType.text,
                          controller: _pwdController,
                          decoration: InputDecoration(
                            hintText: 'Enter password',
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(
                          height: 60,
                        ),
                        Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              width: 32,
                            ),
                            RaisedButton(
                              onPressed: _startSignIn,
                              elevation: 8,
                              color: Colors.pink,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
//                          SizedBox(width: 40,),
                            RaisedButton(
                              onPressed: _startRegister,
                              elevation: 8,
                              color: Colors.indigo,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'Register',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),

                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }

  TextEditingController _emailController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  String email, password;
  void _onEmailChanged(String value) {
    email = value;
    debugPrint(_emailController.text);
  }

  void _onPasswordChanged(String value) {
    password = value;
    debugPrint(_pwdController.text);
  }

  void _startSignIn() async {
    if (isBusy) return;
    email = _emailController.text;
    password = _pwdController.text;
    if (email == null || password == null || email.isEmpty || password.isEmpty) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _key,
          message: 'Please enter stuff ...duh!',
          listener: this,
          actionLabel: 'OK');
      return;
    }
    debugPrint('🔑🔑🔑🔑🔑 $email 🔑 $password');
    try {
      setState(() {
        isBusy = true;
      });
      var res = await trackerBloc.signIn(email: email, password: password);
      await trackerBloc.initialize();
      await trackerBloc.getTracks();
      await _addOriginalTrack();
      print(res);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isBusy = false;
      });
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _key,
          message: e.message,
          listener: this,
          actionLabel: 'OK');
    }
  }

  Future _addOriginalTrack() async {
    var loc = await trackerBloc.getCurrentLocation();
    var track =  TrackData(
      latitude: loc.coords.latitude,
      longitude: loc.coords.longitude,
      comment: 'Original Sin',
      event: loc.activity.type,
      created: DateTime.now().toIso8601String(),
    );
    await trackerBloc.addTrack(track);
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
    return null;
  }

  bool isBusy = false;
  void _startRegister() async {
    if (isBusy) return;
    if (email == null ||  password == null || email.isEmpty || password.isEmpty) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _key,
          message: 'Please enter stuff ...duh!',
          listener: this,
          actionLabel: 'OK');
      return;
    }
    email = _emailController.text;
    password = _pwdController.text;
    debugPrint('🔑🔑🔑🔑🔑 $email 🔑 $password');
    try {
      setState(() {
        isBusy = true;
      });
      var res = await trackerBloc.register(email: email, password: password);
      await trackerBloc.initialize();
      await _addOriginalTrack();
      print(res);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isBusy = false;
      });
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _key,
          message: e.message,
          listener: this,
          actionLabel: 'OK');
    }
  }
}

void saveUser(String url) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("url", url);
  debugPrint('SharedPreferences url saved to shared prefs');
}

Future<String> getUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String path = prefs.getString("url");
  debugPrint(
      "SharedPreferences: =================== SharedPrefs url index: $path");
  return path;
}

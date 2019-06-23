import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackme/bloc/track_data.dart';
import 'package:trackme/bloc/tracker_bloc.dart';
import 'package:intl/intl.dart';
import 'package:trackme/ui/comment.dart';
import 'package:trackme/ui/signin.dart';
import 'package:trackme/ui/slide.dart';
import 'package:trackme/ui/track_list.dart';
import 'package:url_launcher/url_launcher.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter for Tiger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        accentColor: Colors.orangeAccent,
        fontFamily: 'Raleway'
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CameraPosition _initialPosition = CameraPosition(target: LatLng(-25.0, 27.0));
  Completer<GoogleMapController> _completer = Completer();
  GoogleMapController _mapController;
  List<TrackData> _tracks = List();
  var _markers = Set<Marker>();
  MapType mapType;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  TrackData lastTrack;
  void _checkAuth() async {
    bool isOK = await trackerBloc.checkAuthorization();
    if (!isOK) {
      Navigator.push(context, SlideRightRoute(
        widget: SignIn(),
      ));
    } else {
      await trackerBloc.initialize();
      _getTracks();
    }
  }
  void _getTracks() async {
    _tracks = await trackerBloc.getTracks();
    _tracks.sort((a,b) => b.created.compareTo(a.created));
    if (_tracks.isEmpty) return;
    lastTrack = _tracks.last;
    setState(() {});
    _moveCamera(lastTrack.latitude, lastTrack.longitude);
  }

  _moveCamera(double lat, double lng) {
    try {
      var latLng = LatLng(lat, lng);
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14.5));
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TrackData>>(
        stream: trackerBloc.trackStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _tracks = snapshot.data;
            _setMarkers();
          }
          return Scaffold(
            appBar: AppBar(
              title: Text('Tiger Tracker',style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              backgroundColor: Colors.orange[600],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(40),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left:20.0),
                      child: Row(
                        children: <Widget>[
                          Text(trackerBloc.email == null?'Tiger Tracks': trackerBloc.email,
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal)),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,)
                  ],
                ),
              ),
            ),
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  mapType: mapType == null ? MapType.hybrid : mapType,
                  initialCameraPosition: _initialPosition,
                  compassEnabled: true,
                  zoomGesturesEnabled: true,
                  markers: _markers,
                  myLocationEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    debugPrint(
                        '🔆 🔆 🔆 🔆 🔆 🔆 onMapCreated ... markersMap ...  🔆 🔆 🔆 🔆 ');
                    _completer.complete(_mapController);
                    _setMarkers();
                  },
//                  onTap: (latLng) {
//                    Navigator.push(context, SlideRightRoute(
//                      widget: Commenter(latLng),
//                    ));
//                  },
                  onLongPress: (latLng) {
                    Navigator.push(context, SlideRightRoute(
                      widget: Commenter(latLng),
                    ));
                  },
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: GestureDetector(
                    onTap:_navigateToList,
                    child: Card(
                      elevation: 16,
                      color: Colors.blue[300],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              '${_tracks.length}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              'Tracks Done',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(getFormattedDateHourMinSec(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _setMarkers() async {
    debugPrint(
        '\n\n🔆🔆🔆 📍 📍 📍 📍 setMarkers: points on map: 🌀🌀 ${_tracks.length} points  🌀🌀\n\n');
    if (_tracks.isEmpty) return;
    _tracks.sort((a,b) => b.created.compareTo(a.created));
    var cnt = 0;
    _tracks.forEach((m) {
      var title = '#${_tracks.length - cnt} 🖍️ ${getFormattedDate(m.created)},  ${getFormattedDateHourMin(m.created)}';
      var snip = '${m.event}';
      if (m.comment != null) {
        snip = m.comment;
      }
      cnt++;
      var marker = Marker(
          onTap: () {
              debugPrint('🌀🌀 🌀🌀 marker tapped ${m.latitude} ${m.longitude}');
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          markerId: MarkerId(m.created),
          position: LatLng(m.latitude, m.longitude),
          infoWindow: InfoWindow(
              title: title,
              snippet: snip,
              onTap: () {
                debugPrint(
                    ' 🧩 🧩 🧩 POINT infoWindow tapped  🧩 🧩 🧩 ${m.created}');
                launchMapsUrl(m.latitude, m.longitude);
              }));
      _markers.add(marker);
    });

    lastTrack = _tracks.first;
    _moveCamera(lastTrack.latitude, lastTrack.longitude);
  }

  void _navigateToList() {
    debugPrint('.............. navigate, Boss!');
    _tracks.sort((a,b) => b.created.compareTo(a.created));
    Navigator.push(context, SlideRightRoute(
      widget: TrackList(tracks: _tracks,),
    ));
  }
}

String getFormattedDateHourMinSec() {
  try {
    DateTime d = DateTime.now();
    var format = new DateFormat.Hms();
    return format.format(d.toUtc());
  } catch (e) {
    DateTime d = DateTime.now();
    var format = new DateFormat.Hm();
    return format.format(d);
  }
}

String getFormattedDateHourMin(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = new DateFormat.Hms();
    return format.format(d.toUtc());
  } catch (e) {
    DateTime d = DateTime.now();
    var format = new DateFormat.Hm();
    return format.format(d);
  }
}

String getFormattedDate(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = new DateFormat.MMMMEEEEd();
    return format.format(d.toUtc());
  } catch (e) {
    DateTime d = DateTime.now();
    var format = new DateFormat.Hm();
    return format.format(d);
  }
}
//Sg55CHHMCsBzSxi
//2676 873 485
//7957 315 307

void launchMapsUrl(double lat, double lon) async {
  debugPrint('\n\n🏀 🏀 launchMapsUrl 🏀 🏀   🌀🌀 $lat   🌀🌀 $lon');
  final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
  debugPrint('\n\n🏀 🏀 launchMapsUrl 🏀 🏀   🌀🌀  $url   🌀🌀 ');
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

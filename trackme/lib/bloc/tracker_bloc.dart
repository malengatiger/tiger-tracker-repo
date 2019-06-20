import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:google_maps_webservice/geocoding.dart' as webService;
import 'package:trackme/bloc/local_db_api.dart';
import 'package:trackme/bloc/track_data.dart';
import "package:google_maps_webservice/geocoding.dart";
import "package:google_maps_webservice/places.dart";

TrackerBloc trackerBloc = TrackerBloc();

class TrackerBloc {
  static const INTERVAL = 60 * 15,
      RADIUS = 2000,
      DISTANCE_FILTER = 50.0,
      url = 'http://tracker.transistorsoft.com/locations/tigertracks';

  static const kGoogleApiKey = "AIzaSyAZyHg_Z_CGZ-mCgTRuQpouY6jVwM3Mf-A";
  final geocoding = new GoogleMapsGeocoding(apiKey: kGoogleApiKey);
  final places = new GoogleMapsPlaces(apiKey: kGoogleApiKey);
  final Firestore fs = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final StreamController<List<TrackData>> _trackController =
      StreamController.broadcast();
  List<TrackData> _trackData = List();
  FirebaseUser user;

  Stream get trackStream => _trackController.stream;
  close() {
    _trackController.close();
  }

  Future _authorize() async {
    debugPrint('🔑 check auth user status ..... ');
    user = await _auth.currentUser();
    if (user == null) {
      debugPrint(
          '🔑 🔑 🔑 🔑 🔑 _authorize: signInAnonymously: 🔑 🔑 🔑 🔑 🔑 ');
      await _auth.signInAnonymously();
      user = await _auth.currentUser();
    }
    debugPrint(
        '🔑 🔑 🔑 🔑 🔑 _authorized: user uid: 🌺 ${user.uid}: 🌺  🔑 🔑 🔑 🔑 🔑 ');
    return user;
  }

  initialize() async {
    debugPrint(
        '\n\n 🔆 🔆 🔆 🔆 🔆 🔆 🔆 TrackerBloc: 💜 initialize and auth ...');
    await _authorize();
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      _onLocation(location);
    });

    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      _onMotionChange(location);
    });

    bg.BackgroundGeolocation.onHeartbeat((event) {
      _onHeartbeat(event);
    });
    bg.BackgroundGeolocation.onSchedule((state) {
      _onSchedule(state);
    });

    debugPrint('💜 💜  setting up BackgroundGeolocation ready config');
    bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        heartbeatInterval: INTERVAL,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: false,
        logLevel: bg.Config.LOG_LEVEL_ERROR,
        distanceFilter: DISTANCE_FILTER,
        enableHeadless: true,
        url: url,
        reset: true,
        schedule: [
          '1-7 1:00-23:59', // Sun-Sat: 1:00am to 12:00am all day
        ])).then((bg.State state) {
      if (!state.enabled) {
        debugPrint(
            '🔶 🔶 BackgroundGeolocation then: state.enabled:  🔶 ${state.enabled},  🔶 calling BackgroundGeolocation start');
        bg.BackgroundGeolocation.start();
      } else {
        debugPrint(
            '💚 💚 BackgroundGeolocation state.enabled: 💚 💚 ${state.enabled}');
      }
    });
  }

  Future<List<TrackData>> getTracks() async {
    if (user == null) {
      await _authorize();
    }
    debugPrint('\n🧩🧩 getting all tracks ....');

    _trackData = await LocalDBAPI.getTracks(userID: user.uid);
//    var qs = await fs
//        .collection('tracks')
//        .document(user.uid)
//        .collection('points')
//        .getDocuments();
//    _trackData.clear();
//    qs.documents.forEach((doc) {
//      _trackData.add(TrackData.fromJson(doc.data));
//    });
    _trackData.sort((a, b) => b.created.compareTo(a.created));
    _trackController.sink.add(_trackData);
    debugPrint(
        '\n🧩🧩🧩🧩🧩🧩 getTracks:  🧩🧩  found: 🍎 ${_trackData.length} 🍎  🧩🧩🧩🧩 ');
    return _trackData;
  }

  Future<TrackData> addTrack(TrackData track) async {
    debugPrint('\n🧩🧩 addTrack:  🧩🧩 🧩🧩 🧩🧩 ... get geocoding ...');
    try {
      var bLoc = await bg.BackgroundGeolocation.getCurrentPosition();
      track.location = bLoc.toString();
      track.userID = user.uid;
      await LocalDBAPI.addTrack(track: track);
//      var res = await LocalDBAPI.getTracks(userID: user.uid);
//      debugPrint('🐙 🐙 ${res.length} 🐙 🐙  tracks in local Mongo : 🌀🌀 ${DateTime.now().toIso8601String()}');
    } catch (e) {
      debugPrint(
          '🐙 🐙 🐙 🐙 🐙 🐙 🐙 we fucked, Hank! 🐙 🐙 🐙 🐙 🐙  mongo mobile fell down? ... fuck!!');
      print(e);
    }

    try {
      var ref = await fs
          .collection('tracks')
          .document(user.uid)
          .collection('points')
          .add(track.toJson());

      _trackData.add(track);
      _trackController.sink.add(_trackData);
      debugPrint(
          '\n\n💚 💚 💚 💚 track data added to firestore, 🧩🧩 ${ref.path} 🧩🧩\n\n');
      return track;
    } catch (e) {
      debugPrint(
          '🐙 🐙 🐙 🐙 🐙 🐙 🐙 we fucked, Hank! 🐙 🐙 🐙 🐙 🐙  no Google api calls working ... fuck!!');
      print(e);
      return null;
    }
  }

  _getStuff() {
    //      var loc = webService.Location(data.latitude, data.longitude);
//      GeocodingResponse response = await geocoding.searchByLocation(loc);
//      if (response.isOkay) {
//        data.address = response.results.elementAt(0);
//      } else {
//        debugPrint('\n\nGeocoder fell down 👽👽👽👽👽👽 response.isOkay: ${response.isOkay} 👽👽 response.isDenied: 🍎  ${response.isDenied} 🍎 🍎 isOverQueryLimit: ${response.isOverQueryLimit} 🍎 🍎 ');
//      }
//      PlacesSearchResponse placesReponse = await places.searchNearbyWithRadius(
//          webService.Location(data.latitude, data.longitude), RADIUS);
//      var pList = [];
//      if (placesReponse.isOkay) {
//        placesReponse.results.forEach((r) {
//          pList.add(r.formattedAddress);
//        });
//        data.places = pList;
//      } else {
//        debugPrint('PlacesSearch fell down 👽👽👽👽👽👽 response.isOkay: ${placesReponse.isOkay} 👽👽 response.isDenied: ${placesReponse.isDenied}');
//      }
  }

  TrackData prevLocation;
  void _onLocation(bg.Location location) {
    debugPrint('\n\n🏀 🏀 🏀 _onLocation fired: $location');

    if (location.activity.type == 'still' || location.activity.type == 'walking') {
      debugPrint(
          '\n\n🏀 🏀 🏀 _onLocation fired: activity type is still. ignore.');
      return;
    }

    var track = TrackData(
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
        created: DateTime.now().toIso8601String(),
        event: 'onLocation: ' + location.activity.type);

    if (prevLocation != null) {
      var date = DateTime.parse(prevLocation.created);
      var date2 = DateTime.parse(track.created);
      var diffInSeconds = date2.difference(date).inSeconds;
      if (diffInSeconds < (60 * 3)) {
        return;
      }
    }
    addTrack(track);
    prevLocation = track;
  }

  void _onMotionChange(bg.Location location) {
    debugPrint('_onMotionChange $location');
  }

  void _onHeartbeat(HeartbeatEvent event) async {
    debugPrint(
        '\n\n ❤️ 🧡 💛 💚 💙 💜 _onHeartbeat \n$event \n ❤️ 🧡 💛 💚 💙 💜\n\n');

    var track = TrackData(
      latitude: event.location.coords.latitude,
      longitude: event.location.coords.longitude,
      created: DateTime.now().toIso8601String(),
      event: 'onHeartbeat: ' + event.location.activity.type,
    );
    addTrack(track);
  }

  void _onSchedule(bg.State state) {
    debugPrint('${state.enabled}');
  }

  TrackerBloc() {
    initialize();
  }
}

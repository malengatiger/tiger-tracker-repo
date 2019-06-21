import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mongodb_mobile/carrier.dart';
import 'package:mongodb_mobile/mongodb_mobile.dart';
import 'package:trackme/bloc/track_data.dart';
/*
const list: any = await landmarkModel
      .find({
        position: {
          $near: {
            $geometry: {
              coordinates: [longitude, latitude],
              type: "Point",
            },
            $maxDistance: RADIUS,
          },
        },
      })
      .catch((err) => {
        console.error(err);
      });
 */

class LocalDBAPI {
  static const DATABASE = 'tigerLocalDBx2', APP_ID = 'tigerAppID';
  static bool dbConnected = false;
  static int cnt = 0;
  static Future _connectToLocalDB() async {
    if (dbConnected) {
      return null;
    }
    debugPrint(
        '\n\n🔵 🔵 🔵 🔵 🔵 🔵 🔵 Connecting to MongoDB Mobile .. . 🔵 🔵 ');
    try {
      var res = await MongodbMobile.setAppID({
        'appID': APP_ID,
        'type': MongodbMobile.LOCAL_DATABASE,
      });
      dbConnected = true;
      debugPrint(
          '👌 Connected to MongoDB Mobile. 🥬 DATABASE: $DATABASE  🥬 APP_ID: $APP_ID  👌 👌 👌');
      print(res);
    } on PlatformException catch (e) {
      debugPrint('👿👿👿👿👿👿👿👿👿👿 ${e.message}  👿👿👿👿');
      throw Exception(e);
    }
  }

  static Future addTrack(
      {@required TrackData track, LocalDBListener listener}) async {
    await _connectToLocalDB();
    debugPrint('\n\n🔵 🔵 🔵 🔵 🔵 🔵 🔵 addTrack ... 🔵 🔵 ');
    var start = DateTime.now();
    Carrier ca =
        Carrier(db: DATABASE, collection: 'tracks', data: track.toJson());

    var res = await MongodbMobile.insert(ca);

    debugPrint(
        '🍏🍏🍏🍏🍏🍏 track added to local db: ${track.toJson()} \n\n 🐥 🐥 🐥 🐥 🐥 $res  🍏🍏🍏🍏🍏🍏 \n\n');
    if (listener != null) {
      listener.onDataAdded(res);
    }
    var end = DateTime.now();
    var elapsedSecs = end.difference(start).inSeconds;
    debugPrint(
        '\n\n🍎 🍎 🍎 🍎 🍎 addTrack: 🌼 added... 🔵 🔵 elapsed: $elapsedSecs seconds 🔵 🔵 ');
    return res;
  }

  static Future<List<TrackData>> getTracks(String userID) async {
    await _connectToLocalDB();
    Carrier carrier = Carrier(db: DATABASE, collection: 'tracks', query: {
      'eq': {
        'userID': userID,
      },
    });
    var res = await MongodbMobile.query(carrier);
    List<TrackData> list = List();
    res.forEach((r) {
      list.add(TrackData.fromJson(r=json.decode(r)));
    });
    list.sort((a,b) => b.created.compareTo(a.created));
    debugPrint('🧩🧩 ${list.length}  🧩🧩 tracks found on local database  🧩🧩');
    return list;
  }
  static Future<List<TrackData>> getAllTracks() async {
    await _connectToLocalDB();
    Carrier carrier = Carrier(db: DATABASE, collection: 'tracks');
    var res = await MongodbMobile.getAll(carrier);
    List<TrackData> list = List();
    res.forEach((r) {
      list.add(TrackData.fromJson(r=json.decode(r)));
    });
    list.sort((a,b) => b.created.compareTo(a.created));
    debugPrint('🧩🧩 ${list.length}  🧩🧩 tracks found on local database  🧩🧩');
    return list;
  }
}

abstract class LocalDBListener {
  onDataAdded(dynamic data);
}

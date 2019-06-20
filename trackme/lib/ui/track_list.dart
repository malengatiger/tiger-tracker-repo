library date_symbol_data_local;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trackme/bloc/track_data.dart';
import 'package:trackme/bloc/tracker_bloc.dart';
import 'package:trackme/ui/slide.dart';

import 'map.dart';

class TrackList extends StatefulWidget {
  final List<TrackData> tracks;

  TrackList({this.tracks});

  @override
  _TrackListState createState() => _TrackListState();
}

class _TrackListState extends State<TrackList> {
  List<TrackData> _tracks = List();
  @override
  void initState() {
    debugPrint(
        '\n\n\n🍎 🍎 🍎 TrackList: 🍎 🍎 🍎 🍎  initState -  getTracks\n\n');
    super.initState();
    _getData();
  }

  void _getData() async {
    if (widget.tracks == null || widget.tracks.isEmpty) {
      debugPrint(' 🧩🧩 widget tracks isEmpty or  Null');
      _tracks = await trackerBloc.getTracks();
    } else {
      _tracks = widget.tracks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TrackData>>(
        stream: trackerBloc.trackStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _tracks = snapshot.data;
          }
          return Scaffold(
            appBar: AppBar(
              title: Text('Tiger Tracks'),
              elevation: 16,
              backgroundColor: Colors.indigo[300],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(80),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Tap to go to a place you have been before.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(
                      height: 40,
                    )
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.brown[100],
            body: ListView.builder(
              itemCount: _tracks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                  child: GestureDetector(
                    onTap: () {
                      _navToPlace(_tracks.elementAt(index));
                    },
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                                width: 40,
                                child: Text(
                                  '${_tracks.length - index}',
                                  style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900),
                                )),
                            SizedBox(
                              width: 8,
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                  '${getFormattedDateShortWithTime(_tracks.elementAt(index).created)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900, fontSize: 20),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                    '${getFormattedDouble(_tracks.elementAt(index).latitude)} ${getFormattedDouble(_tracks.elementAt(index).longitude)}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  String getFormattedDouble(double number) {
    Locale myLocale = Localizations.localeOf(context);
    var val = myLocale.languageCode + '_' + myLocale.countryCode;
    final oCcy = new NumberFormat("###,###,###,###,##0.00000000", val);

    return oCcy.format(number);
  }

  String getFormattedNumber(int number) {
    Locale myLocale = Localizations.localeOf(context);
    var val = myLocale.languageCode + '_' + myLocale.countryCode;
    final oCcy = new NumberFormat("###,###,###,###,###", val);

    return oCcy.format(number);
  }

  String getFormattedDateShortWithTime(String date) {
    Locale myLocale = Localizations.localeOf(context);

    var format = new DateFormat('dd MMMM yyyy HH:mm', myLocale.toString());
    try {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    } catch (e) {
      print(e);
      return 'NoDate';
    }
  }

  void _navToPlace(TrackData data) {
    Navigator.push(
        context,
        SlideRightRoute(
          widget: PlaceMap(data),
        ));
  }
}

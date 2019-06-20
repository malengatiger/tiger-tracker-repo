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
    debugPrint('🍎 🍎 🍎 🍎 🍎 🍎 🍎  initState -  geTracks');
    super.initState();
    if (widget.tracks == null || widget.tracks.isEmpty) {
      trackerBloc.getTracks();
    } else {
      _tracks = widget.tracks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tiger Tracks'),
        backgroundColor: Colors.indigo[400],
      ),
      backgroundColor: Colors.brown[100],
      body: StreamBuilder<List<TrackData>>(
          stream: trackerBloc.trackStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _tracks = snapshot.data;
              _tracks.sort((a, b) => b.created.compareTo(a.created));
            }
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                if (_tracks.isEmpty) {
                  return Container();
                }
                var lat = _tracks.elementAt(index).latitude;
                var lng = _tracks.elementAt(index).longitude;
                return Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: GestureDetector(
                    onTap: () {
                      _navToPlace(_tracks.elementAt(index));
                    },
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 60,
                              child: Text(
                                '${_tracks.length - index}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.indigo[300]),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${getFormattedDateShortWithTime(_tracks.elementAt(index).created)}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black),
                                ),
                                Row(
                                  children: <Widget>[
                                    Text('${getFormattedDouble(lat)}'),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text('${getFormattedDouble(lng)}'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
    );
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

    Navigator.push(context, SlideRightRoute(
      widget: PlaceMap(data),
    ));
  }
}

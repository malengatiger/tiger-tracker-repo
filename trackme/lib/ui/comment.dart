import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:trackme/bloc/track_data.dart';
import 'package:trackme/bloc/tracker_bloc.dart';
import 'package:trackme/ui/snack.dart';

class Commenter extends StatefulWidget {
  final LatLng latLng;

  Commenter(this.latLng);

  @override
  _CommenterState createState() => _CommenterState();
}

class _CommenterState extends State<Commenter> implements SnackBarListener {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Tiger Track Notes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),),
        backgroundColor: Colors.pink[300],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Column(
            children: <Widget>[
              Text(
                'Enter comment about this spot',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                '${widget.latLng.latitude}  ${widget.latLng.longitude}',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(
                height: 28,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.brown[100],
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Notes',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.black),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    TextField(
                      onChanged: _onNotesChanged,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText:
                            'Enter notes here, Bud! If this works, it should wrap around and give you multiple lines to write shit!',
//                        icon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    RaisedButton(
                      onPressed: _addCommentedPoint,
                      elevation: 8,
                      color: Colors.pink[600],
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 40, right: 40, top: 24, bottom: 24),
                        child: Text('Save Note',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.white)),
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String comment;

  void _onNotesChanged(String value) {
    debugPrint('$value');
    comment = value;
  }

  void _addCommentedPoint() async {
    debugPrint('_addCommentedPoint:  $comment');
    if (comment.isEmpty) {
      _showSnackWithAction(message: 'Please enter stuff first, Bud');
      return;
    }
    var track = TrackData(
      latitude: widget.latLng.latitude,
      longitude: widget.latLng.longitude,
      event: 'Tiger: Marked the spot',
      created: DateTime.now().toIso8601String(),
      comment: comment,
    );
    try {
      _showSnackWithProgress(message: 'Adding stuff to  database ... Hang on, Bud!');
      debugPrint('🐻 🐻 🐻 🐻 🐻 adding a Tiger comment ...');
      TrackData result = await trackerBloc.addTrack(track);
      debugPrint('Commentor: 🧡 💛 note added to database ${result.toJson()}');
      _showSnackWithAction(
          message: '🧡 💛  Note added', backgroundColor: Colors.teal[800]);
    } catch (e) {
      _showSnackWithAction(
          message: ' 😡  😡 We have a problem,  😡 Malenga!',
          backgroundColor: Colors.red[900]);
    }
  }

  _showSnackWithAction(
      {@required String message,
      Color textColor,
      String label,
      Color backgroundColor}) async {
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _key,
        message: message,
        actionLabel: 'Done',
        listener: this,
        textColor: textColor == null ? Colors.white : textColor,
        backgroundColor:
            backgroundColor == null ? Colors.black : backgroundColor);
  }
  _showSnackWithProgress(
      {@required String message,
        Color textColor,
        String label,
        Color backgroundColor}) async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _key,
        message: message,
        textColor: textColor == null ? Colors.white : textColor,
        backgroundColor:
        backgroundColor == null ? Colors.black : backgroundColor);
  }

  @override
  onActionPressed(int action) {
    Navigator.pop(context);
  }
}

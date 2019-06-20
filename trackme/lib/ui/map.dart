import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackme/bloc/track_data.dart';
import 'package:trackme/bloc/tracker_bloc.dart';
import 'package:trackme/ui/slide.dart';

import '../main.dart';
import 'comment.dart';

class PlaceMap extends StatefulWidget {
  final TrackData trackData;

  PlaceMap(this.trackData);

  @override
  _PlaceMapState createState() => _PlaceMapState();
}

class _PlaceMapState extends State<PlaceMap> {
  Completer<GoogleMapController> _completer = Completer();
  CameraPosition initialPosition = CameraPosition(target: LatLng(-25.0, 27.0));
  GoogleMapController _mapController;
  var markers = Set<Marker>();

  List<TrackData> _tracks = List();

  MapType mapType;
  @override
  void initState() {
    super.initState();
    _getTracks();
  }

  _getTracks() async {
    _tracks = await trackerBloc.getTracks();
    var icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    _tracks.forEach((t) {
      markers.add(Marker(
          markerId: MarkerId(DateTime.now().toIso8601String()),
          position:
              LatLng(widget.trackData.latitude, widget.trackData.longitude),
          icon: icon,
          infoWindow: InfoWindow(
              title:
                  '${getFormattedDate(widget.trackData.created)} ${getFormattedDateHourMin(widget.trackData.created)}',
              snippet:
                  '${widget.trackData.latitude} ${widget.trackData.longitude}')));
    });
    setState(() {});
  }

  _setMarkers() {
    var icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    markers.add(Marker(
        markerId: MarkerId(DateTime.now().toIso8601String()),
        position: LatLng(widget.trackData.latitude, widget.trackData.longitude),
        icon: icon,
        infoWindow: InfoWindow(
            title:
                '${getFormattedDate(widget.trackData.created)} ${getFormattedDateHourMin(widget.trackData.created)}',
            snippet:
                '${widget.trackData.latitude} ${widget.trackData.longitude}')));

    _mapController.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(widget.trackData.latitude, widget.trackData.longitude), 14.5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tiger Track'),
        backgroundColor: Colors.teal[300],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: Column(
            children: <Widget>[
              Text(
                '${getFormattedDate(widget.trackData.created)} ${getFormattedDateHourMin(widget.trackData.created)}',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 18),
              ),
              SizedBox(
                height: 8,
              ),
              Text('${widget.trackData.latitude} ${widget.trackData.longitude}',
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      fontSize: 12)),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: initialPosition,
            markers: markers,
            compassEnabled: true,
            zoomGesturesEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            myLocationEnabled: true,
            mapType: mapType == null ? MapType.hybrid : mapType,
            onMapCreated: (controller) {
              debugPrint(
                  '🔆 🔆 🔆 🔆 🔆 🔆 onMapCreated ... markers on Map ...  🔆 🔆 🔆 🔆 ');
              _completer.complete(controller);
              _mapController = controller;
              _setMarkers();
            },
            onTap: (latLng) {
              Navigator.push(context, SlideRightRoute(
                widget: Commenter(latLng),
              ));
            },
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
              onTap: () {
                Navigator.pop(context);
              },
              child: Card(
                elevation: 16,
                color: Colors.blue[300],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      StreamBuilder<List<TrackData>>(
                          stream: trackerBloc.trackStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              _tracks = snapshot.data;
                            }
                            return Text(
                              '${_tracks.length}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24),
                            );
                          }),
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
                      Text('${getFormattedDateHourMinSec()}',
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
  }
}

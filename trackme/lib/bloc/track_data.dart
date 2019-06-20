/*
####### Generated by JavaToDart Wed Dec 19 22:12:26 SAST 2018
####### rigged up by AM Esq.
*/

class TrackData {
  double latitude;
  double longitude;
  String created;
  dynamic address, event, location;
  dynamic position, places;

  TrackData({
    this.latitude,
    this.longitude,
    this.address,
    this.position, this.places, this.event, this.location,
    this.created,
  });

  TrackData.fromJson(Map data) {
    this.latitude = data['latitude'];
    this.longitude = data['longitude'];
    this.created = data['created'];
    this.address = data['address'];
    this.position = data['position'];
    this.places = data['places'];
    this.event = data['event'];
    this.location = data['location'];
  }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['created'] = created;
    map['places'] = places;
    map['address'] = address;
    map['event'] = event;
    map['location'] = location;

    if (places != null) map['places'] = places;
    if (position != null) map['position'] = position;

    return map;
  }
}
import 'package:senior_citizen_app/models/location.dart';
import 'package:senior_citizen_app/others/constants.dart';
import 'package:senior_citizen_app/others/network.dart';

class HospitalData {
  UserLocation userLocation;
  List<Hospital> hospitalList;
  HospitalData();
  getNearbyHospital() async {
    this.hospitalList = List<Hospital>();
    userLocation = UserLocation();

    await userLocation.getLocation().then((value) {
      this.userLocation = value;
    });
    // print('Location ${userLocation.longitude} and ${userLocation.latitude}');
    Uri url = Uri.parse(
        'https://api.tomtom.com/search/2/nearbySearch/.json?key=$kTomsApiKey&lat=${userLocation.latitude}&lon=${userLocation.longitude}&radius=2000&limit=10&categorySet=7321');
    NetworkHelper networkHelper = NetworkHelper(url);
    var data;
    await networkHelper.getData().then((value) {
      data = value;
    });
    // print(data);
    var hospitals = data['results'];
    this.hospitalList = [];
    for (var h in hospitals) {
      String locationUrl = '', placeName = '';
      double locationLat = h['position']['lat'];
      double locationLon = h['position']['lon'];
      Uri uri = Uri.parse(
          'https://api.opencagedata.com/geocode/v1/json?q=$locationLat+$locationLon&key=$kOpenCageApiKey');
      NetworkHelper _networkHelper = NetworkHelper(uri);
      var _data = await _networkHelper.getData();
      var hosData = _data['results'][0];
      placeName = hosData['components']['road'];
      locationUrl = hosData['annotations']['OSM']['url'];
      uri = Uri.parse(
          'https://api.tomtom.com/routing/1/calculateRoute/${userLocation.latitude},${userLocation.longitude}:$locationLat,$locationLon/json?key=$kTomsApiKey');
      NetworkHelper _network = NetworkHelper(uri);
      var distanceData = await _network.getData();
      double hospitalDistance =
          distanceData['routes'][0]['summary']['lengthInMeters'] / 1000;

      Hospital hospital = Hospital(h['poi']['name'], h['position']['lat'],
          h['position']['lon'], locationUrl, placeName, hospitalDistance);

      try {
        this.hospitalList.add(hospital);
      } catch (e) {
        print(e);
      }
    }
    return this;
  }
}

class Hospital {
  String hospitalName, hospitalLocationUrl, hospitalPlace;
  double hospitalLocationLatitude, hospitalLocationLongitude, hospitalDistance;

  Hospital(this.hospitalName, this.hospitalLocationLatitude,
      this.hospitalLocationLongitude,
      [this.hospitalLocationUrl, this.hospitalPlace, this.hospitalDistance]);
}

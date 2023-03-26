import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  final Uri url;
  NetworkHelper(this.url);
  Future getData() async {
    // print("123");
    http.Response response = await http.get(url);
    // print('Response ${response.body}');
    if (response.statusCode == 200) {
      // print('response ${response.body}');
      var data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ImageClass {
  String name, url;
  ImageClass({this.name, this.url});
}

class ImageModel {
  List<ImageClass> images;
  ImageModel();

  ImageClass imageData;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();

    map['name'] = this.imageData.name.toString();
    map['url'] = this.imageData.url.toString();

    return map;
  }

  fromMap(Map<String, dynamic> map) {
    ImageClass image = ImageClass();
    image.name = map['name'];
    image.url = map['url'];
    return image;
  }

  List<ImageClass> getAllImages(QuerySnapshot snapshot) {
    images = List<ImageClass>();
    List<DocumentSnapshot> documents = snapshot.docs;
    for (var data in documents) {
      Map map = data.data();
      this.images.add(this.fromMap(map));
    }
    return this.images;
  }

  Map<String, dynamic> getData(List<QueryDocumentSnapshot> documents) {
    images = List<ImageClass>();
    for (var data in documents) {
      Map map = data.data();
      this.images.add(this.fromMap(map));
    }
    Map<String, dynamic> imgdata = Map<String, dynamic>();
    for (var image in this.images) {
      imgdata[image.name] = image.url;
    }
    return imgdata;
  }

  List<ImageClass> searchImages(String name) {
    List<ImageClass> imagesFound = List<ImageClass>();
    for (var image in this.images) {
      if (image.name.toLowerCase().substring(0, name.length) ==
          name.toLowerCase()) {
        imagesFound.add(image);
      }
    }
    return imagesFound;
  }
}

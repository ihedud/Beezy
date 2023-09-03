import 'package:cloud_firestore/cloud_firestore.dart';

class Avatar {
  List<Food> foodList = <Food>[];
  List<Hygiene> hygieneList = <Hygiene>[];
  List<Toy> toyList = <Toy>[];
  List<Sleep> sleepList = <Sleep>[];
  // int foodID = 0;
  // int hygieneID = 0;
  // int toyID = 0;
  //int sleepID = 0;
  double food = 0;
  double hygiene = 0;
  double toys = 0;
  double sleep = 0;

  Avatar();

  Avatar.fromFirestore(
      Map<String, dynamic> json)
      : food = json['food'],
        hygiene = json['hygiene'],
        toys = json['toys'],
        sleep = json['sleep'] {}
}

Stream<Avatar?> userBeeboSnapshot(String userUID) {
  final db = FirebaseFirestore.instance;
  final stream =
      db.doc("/users/$userUID/beebo/beebo").snapshots();
  return stream.map((doc) {
    if (doc.exists) {
      Map<String, dynamic>? data = doc.data();
      if (data != null) {
        return Avatar.fromFirestore(data);
      }
    }
    return null;
  });
}

class Item {
  //int id = 0;
  int amount = 0;
  double fillAmount = 1;
  String name = '';
  String assetPath = '';
  bool isRepresented = false;
}

class Food extends Item {
  //int foodID = 0;
}

class Hygiene extends Item {
  //int hygieneID = 0;
}

class Toy extends Item {
  //int toyID = 0;
}

class Sleep extends Item {
  //int sleepID = 0;
}
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class Avatar {
  List<Item> foodList = <Item>[];
  List<Item> hygieneList = <Item>[];
  List<Item> toysList = <Item>[];
  List<Item> sleepList = <Item>[];
  // int foodID = 0;
  // int hygieneID = 0;
  // int toyID = 0;
  //int sleepID = 0;
  double food = 0;
  double hygiene = 0;
  double toys = 0;
  double sleep = 0;
  int selectedButtonIndex = 0;

  Avatar.fromFirestore(
      Map<String, dynamic> json, List<Item> foodList, List<Item> hygieneList, List<Item> toysList, List<Item> sleepList)
      : food = json['food'],
        hygiene = json['hygiene'],
        toys = json['toys'],
        sleep = json['sleep'],
        selectedButtonIndex = json['selectedButtonIndex'] {
this.foodList = foodList;
this.hygieneList = hygieneList;
this.toysList = toysList;
this.sleepList = sleepList;
        }
}

Stream<Avatar> userBeeboSnapshot(String userUID) {
  final db = FirebaseFirestore.instance;

  final foodStream =
      db.collection("/users/$userUID/beebo/beebo/foodList").snapshots();

      final hygieneStream =
      db.collection("/users/$userUID/beebo/beebo/hygieneList").snapshots();

      final toysStream =
      db.collection("/users/$userUID/beebo/beebo/toysList").snapshots();

      final sleepStream =
      db.collection("/users/$userUID/beebo/beebo/sleepList").snapshots();

  final controller = StreamController<Avatar>();

  final List<Item> foodList = [];
  final List<Item> hygieneList = [];
  final List<Item> toysList = [];
  final List<Item> sleepList = [];

  foodStream.listen((queryFood) {
    foodList.clear();
    for (final foodDoc in queryFood.docs) {
      foodList.add(Item.fromFirestore(foodDoc.id, foodDoc.data()));
    }
    updateController(controller, foodList, hygieneList, toysList, sleepList, userUID);
  });

  hygieneStream.listen((queryHygiene) {
    hygieneList.clear();
    for (final hygieneDoc in queryHygiene.docs) {
      hygieneList.add(Item.fromFirestore(hygieneDoc.id, hygieneDoc.data()));
    }
    updateController(controller, foodList, hygieneList, toysList, sleepList, userUID);
  });

  toysStream.listen((queryToys) {
    toysList.clear();
    for (final toysDoc in queryToys.docs) {
      toysList.add(Item.fromFirestore(toysDoc.id, toysDoc.data()));
    }
    updateController(controller, foodList, hygieneList, toysList, sleepList, userUID);
  });

  sleepStream.listen((querySleep) {
    sleepList.clear();
    for (final sleepDoc in querySleep.docs) {
      sleepList.add(Item.fromFirestore(sleepDoc.id, sleepDoc.data()));
    }
    updateController(controller, foodList, hygieneList, toysList, sleepList, userUID);
  });

  return controller.stream;
}

void updateController(StreamController<Avatar> controller,
    List<Item> foodList, List<Item> hygieneList, List<Item> toysList, List<Item> sleepList, String userUID) {
  final db = FirebaseFirestore.instance;

  db.collection("/users/$userUID/beebo").get().then((query) {
    late Avatar beebo;
    for (final doc in query.docs) {
      beebo = Avatar.fromFirestore(doc.data(), foodList, hygieneList, toysList, sleepList);
    }
    controller.add(beebo);
  }).catchError((error) {
    print(error);
  });
}

// Stream<Avatar?> userBeeboSnapshot(String userUID) {
//   final db = FirebaseFirestore.instance;
//   final stream =
//       db.doc("/users/$userUID/beebo/beebo").snapshots();
//   return stream.map((doc) {
//     if (doc.exists) {
//       Map<String, dynamic>? data = doc.data();
//       if (data != null) {
//         return Avatar.fromFirestore(data);
//       }
//     }
//     return null;
//   });
// }

class Item {
  String id = '';
  int amount = 0;
  double fillAmount = 1;
  String name = '';
  String assetPath = '';

  Item.fromFirestore(this.id, 
      Map<String, dynamic> json)
      : amount = json['amount'],
        fillAmount = json['fillAmount'],
        name = json['name'],
        assetPath = json['assetPath'];
}

// class Food extends Item {
//   int foodID = 0;
// }

// class Hygiene extends Item {
//   int hygieneID = 0;
// }

// class Toy extends Item {
//   int toyID = 0;
// }

// class Sleep extends Item {
//   int sleepID = 0;
// }
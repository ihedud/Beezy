import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class HoneyRush {
  bool daytime = true;
  bool hasRolled = false;
  bool isRolling = false;
  int temporaryNectar = 0;
  int nectar = 0;
  List<HoneyProfile> allProfiles = <HoneyProfile>[];

  HoneyRush.fromFirestore(
      Map<String, dynamic> json, List<HoneyProfile> allProfilesData)
      : daytime = json['daytime'],
        hasRolled = json['hasRolled'],
        isRolling = json['isRolling'],
        temporaryNectar = json['temporaryNectar'],
        nectar = json['nectar'] {
    allProfiles = allProfilesData;
  }
}

class HoneyProfile {
  String id = '';
  String name = '';
  String avatarTypePath = '';
  int lifes = 3;
  int playedCards = 0;
  bool hasHoneyFever = false;
  int daysPassed = 0;

  HoneyProfile.fromFirestore(this.id, Map<String, dynamic> json)
      : name = json['name'],
        avatarTypePath = json['avatarTypePath'],
        lifes = json['lifes'],
        playedCards = json['playedCards'],
        daysPassed = json['daysPassed'],
        hasHoneyFever = json['hasHoneyFever'];
}

Stream<HoneyRush> userHoneyRushSnapshots(String userUID) {
  final db = FirebaseFirestore.instance;

  final profilesStream =
      db.collection("/users/$userUID/honeyRush/honeyRush/profiles").snapshots();

  final honeyRushStream =
      db.doc("/users/$userUID/honeyRush/honeyRush").snapshots();

  final controller = StreamController<HoneyRush>();

  final List<HoneyProfile> profiles = [];

  profilesStream.listen((queryProfiles) {
    profiles.clear();
    for (final profileDoc in queryProfiles.docs) {
      profiles
          .add(HoneyProfile.fromFirestore(profileDoc.id, profileDoc.data()));
    }
    updateController(controller, profiles, userUID);
  });

  honeyRushStream.listen((honeyRushDoc) {
    updateController(controller, profiles, userUID);
  });

  return controller.stream;
}

void updateController(StreamController<HoneyRush> controller,
    List<HoneyProfile> profiles, String userUID) {
  final db = FirebaseFirestore.instance;

  db.collection("/users/$userUID/honeyRush").get().then((query) {
    late HoneyRush honeyRush;
    for (final doc in query.docs) {
      honeyRush = HoneyRush.fromFirestore(doc.data(), profiles);
    }
    controller.add(honeyRush);
  }).catchError((error) {
    print(error);
  });
}

class HoneyState {
  //bool daytime = true;
  int honey = 0;
  //int nectar = 0;
  List<String> narrative = [
    'story 1',
    'story 2',
    'story 3',
    'story 4',
    'story 5'
  ];
}

class HoneyCard {
  String imagePath = '';
  String description = '';
  int price = 0;
  void Function() effect;

  HoneyCard(
      {required this.imagePath,
      required this.description,
      required this.price,
      required this.effect});
}

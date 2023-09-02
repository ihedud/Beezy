import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HoneyRush {
  bool daytime = true;
  bool hasRolled = false;
  bool isRolling = false;
  int temporaryNectar = 0;
  int nectar = 0;
  int honey = 0;
  int narrativeSpot = 0;
  int card1 = 0;
  int card2 = 0;
  int card3 = 0;
  bool cardSlot1 = false;
  bool cardSlot2 = false;
  bool cardSlot3 = false;
  bool isCarding = false;
  int playedCardsNum = 0;
  String diaryText = '';
  List<HoneyProfile> allProfiles = <HoneyProfile>[];
  TextEditingController textController = TextEditingController();

  HoneyRush.fromFirestore(
      Map<String, dynamic> json, List<HoneyProfile> allProfilesData)
      : daytime = json['daytime'],
        hasRolled = json['hasRolled'],
        isRolling = json['isRolling'],
        temporaryNectar = json['temporaryNectar'],
        nectar = json['nectar'],
        honey = json['honey'],
        diaryText = json['diaryText'],
        cardSlot1 = json['cardSlot1'],
        cardSlot2 = json['cardSlot2'],
        cardSlot3 = json['cardSlot3'],
        card1 = json['card1'],
        card2 = json['card2'],
        card3 = json['card3'],
        isCarding = json['isCarding'],
        playedCardsNum = json['playedCardsNum'],
        narrativeSpot = json['narrativeSpot'] {
    allProfiles = allProfilesData;
    textController.text = diaryText;
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
  String narrative1 = 'Suddenly, the wasp found a really beautiful ';
  String narrative2 =
      ' flower, which caught its attention. It was magestic. Its color was vibrant and bright, but it still looked delicate somehow. After spending some time playing around it, the wasp, seeing as it was a ';
  String narrative3 =
      ' decided to rest next to a field. However, lucky as it was, there were some kids playing ';
  String narrative4 =
      ' on it. They seemed to be having an exceptional time running around and laughing. It was at that moment that it knew. It was time to sting somebody.';
  List<String> spot1 = ['blue', 'red', 'yellow', 'pink'];
  List<String> spot2 = ['aries', 'piscis', 'scorpio', 'taurus'];
  List<String> spot3 = ['basketball', 'tennis', 'soccer', 'baseball'];
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

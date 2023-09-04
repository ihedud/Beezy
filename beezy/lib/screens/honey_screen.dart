import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/honey.dart';

class HoneyScreen extends StatelessWidget {
  final String userUID;
  final Function(int) updatePoints;
  final Function(bool) updateHasWon;

  const HoneyScreen(
      {Key? key,
      required this.userUID,
      required this.updatePoints,
      required this.updateHasWon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userHoneyRushSnapshots(userUID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorWidget(snapshot.error!);
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case ConnectionState.active:
            return _HoneyScreen(
                userUID: userUID,
                honeyRush: snapshot.data!,
                updatePoints: updatePoints,
                updateHasWon: updateHasWon);
          case ConnectionState.none:
            return ErrorWidget("The stream was wrong (connectionState.none)");
          case ConnectionState.done:
            return ErrorWidget("The stream has ended??");
        }
      },
    );
  }
}

class _HoneyScreen extends StatefulWidget {
  const _HoneyScreen(
      {required this.updatePoints,
      required this.updateHasWon,
      required this.honeyRush,
      required this.userUID});
  final Function(int) updatePoints;
  final Function(bool) updateHasWon;
  final HoneyRush honeyRush;
  final String userUID;

  @override
  State<_HoneyScreen> createState() => _HoneyScreenState();
}

Future<void> updateHasHoneyFever(
    String userUID, bool newValue, String profileID) async {
  try {
    DocumentReference profileRef = FirebaseFirestore.instance
        .doc('/users/$userUID/honeyRush/honeyRush/profiles/$profileID');
    await profileRef.update({'hasHoneyFever': newValue});
  } catch (e) {
    print('Error updating hasHoneyFever: $e');
  }
}

Future<void> updateDaysPassed(
    String userUID, int newValue, String profileID) async {
  try {
    DocumentReference profileRef = FirebaseFirestore.instance
        .doc('/users/$userUID/honeyRush/honeyRush/profiles/$profileID');
    await profileRef.update({'daysPassed': newValue});
  } catch (e) {
    print('Error updating hasHoneyFever: $e');
  }
}

Future<void> updateDaytime(String userUID) async {
  try {
    DocumentReference daytimeRef =
        FirebaseFirestore.instance.doc('/users/$userUID/honeyRush/honeyRush');
    final daytimeSnap = await daytimeRef.get();
    await daytimeRef.update({'daytime': !daytimeSnap['daytime']});
    if (daytimeSnap['daytime']) {
      updateHasRolled(userUID, false);
      updateCardSlots(userUID, false, 4);
      updatePlayedCardsNum(userUID, 0);
    }
  } catch (e) {
    print('Error updating hasHoneyFever: $e');
  }
}

Future<void> updateHasRolled(String userUID, bool newValue) async {
  try {
    DocumentReference hasRolledRef =
        FirebaseFirestore.instance.doc('/users/$userUID/honeyRush/honeyRush');
    await hasRolledRef.update({'hasRolled': newValue});
  } catch (e) {
    print('Error updating hasRolled: $e');
  }
}

Future<void> updateIsRolling(String userUID, bool newValue) async {
  try {
    DocumentReference isRollingRef =
        FirebaseFirestore.instance.doc('/users/$userUID/honeyRush/honeyRush');
    await isRollingRef.update({'isRolling': newValue});
  } catch (e) {
    print('Error updating isRolling: $e');
  }
}

Future<void> updateIsCarding(String userUID, bool newValue) async {
  try {
    DocumentReference isCardingRef =
        FirebaseFirestore.instance.doc('/users/$userUID/honeyRush/honeyRush');
    await isCardingRef.update({'isCarding': newValue});
  } catch (e) {
    print('Error updating isCarding: $e');
  }
}

Future<void> updateTemporaryNectar(String userUID, int newValue) async {
  try {
    DocumentReference tempNectarRef =
        FirebaseFirestore.instance.doc('/users/$userUID/honeyRush/honeyRush');
    await tempNectarRef.update({'temporaryNectar': newValue});
  } catch (e) {
    print('Error updating temporaryNectar: $e');
  }
}

Future<void> updateNectar(String userUID, int newValue) async {
  try {
    DocumentReference nectarRef =
        FirebaseFirestore.instance.doc('/users/$userUID/honeyRush/honeyRush');
    await nectarRef.update({'nectar': newValue});
  } catch (e) {
    print('Error updating nectar: $e');
  }
}

Future<void> updateHoney(String userUID, int newValue) async {
  try {
    DocumentReference honeyRef =
        FirebaseFirestore.instance.doc('/users/$userUID/honeyRush/honeyRush');
    await honeyRef.update({'honey': newValue});
  } catch (e) {
    print('Error updating honey: $e');
  }
}

Future<void> updateDiary(String userUID, String newValue) async {
  try {
    DocumentReference diaryRef =
        FirebaseFirestore.instance.doc('/users/$userUID/honeyRush/honeyRush');
    await diaryRef.update({'diaryText': newValue});
  } catch (e) {
    print('Error updating diaryText: $e');
  }
}

Future<void> updateCards(
    String userUID, int newValue1, int newValue2, int newValue3) async {
  try {
    DocumentReference cardRef =
        FirebaseFirestore.instance.doc('/users/$userUID/honeyRush/honeyRush');
    await cardRef.update({'card1': newValue1});
    await cardRef.update({'card2': newValue2});
    await cardRef.update({'card3': newValue3});
  } catch (e) {
    print('Error updating cards: $e');
  }
}

Future<void> updateCardSlots(String userUID, bool newValue, int slot) async {
  try {
    DocumentReference cardRef =
        FirebaseFirestore.instance.doc('/users/$userUID/honeyRush/honeyRush');
    if (slot == 0) {
      await cardRef.update({'cardSlot1': newValue});
    } else if (slot == 1) {
      await cardRef.update({'cardSlot2': newValue});
    } else if (slot == 2) {
      await cardRef.update({'cardSlot3': newValue});
    } else if (slot == 4) {
      await cardRef.update({
        'cardSlot1': newValue,
        'cardSlot2': newValue,
        'cardSlot3': newValue
      });
    }
  } catch (e) {
    print('Error updating cardSlots: $e');
  }
}

Future<void> updatePlayedCardsNum(String userUID, int newValue) async {
  try {
    DocumentReference honeyRef =
        FirebaseFirestore.instance.doc('/users/$userUID/honeyRush/honeyRush');
    await honeyRef.update({'playedCardsNum': newValue});
  } catch (e) {
    print('Error updating playedCardsNum: $e');
  }
}

Future<void> updateHoneyFeverState(String userUID) async {
  final profileRef = await FirebaseFirestore.instance
      .collection('/users/$userUID/honeyRush/honeyRush/profiles')
      .get();
  for (final doc in profileRef.docs) {
    if (doc.get('hasHoneyFever') == true) {
      if (doc.get('daysPassed') >= 3) {
        updateHasHoneyFever(userUID, false, doc.id);
        updateDaysPassed(userUID, 0, doc.id);
      } else {
        updateDaysPassed(userUID, doc.get('daysPassed') + 1, doc.id);
      }
    }
  }
}

class _HoneyScreenState extends State<_HoneyScreen> {
  List<HoneyCard> generatedCards = [];
  List<bool> generatedSlots = [false, false, false];
  List<HoneyCard> playedCards = [];
  List<HoneyCard> allCards = [];
  HoneyState state = HoneyState();
  bool isEditingDiary = false;
  int selectedNPC = 9;

  @override
  void initState() {
    super.initState();
    allCards = [
      HoneyCard(
          imagePath: "cards/flower_patch.png",
          description: "Generate 2 honey.",
          price: 2,
          effect: () {
            updateMyHoney(widget.honeyRush.honey + 2);
            widget.honeyRush.honey += 2;
          }),
      HoneyCard(
          imagePath: "cards/flower_field.png",
          description: "Generate 3 honey.",
          price: 3,
          effect: () {
            updateMyHoney(widget.honeyRush.honey + 3);
            widget.honeyRush.honey += 3;
          }),
      HoneyCard(
          imagePath: "cards/pollen.png",
          description: "Generate 1 honey.",
          price: 1,
          effect: () {
            updateMyHoney(widget.honeyRush.honey + 1);
            widget.honeyRush.honey += 1;
          }),
          HoneyCard(
          imagePath: "cards/nectar_card.png",
          description: "Your nectar is increased by 1.",
          price: 0,
          effect: () {
            updateMyNectar(1);
          }),
          HoneyCard(
          imagePath: "cards/honey_stash.png",
          description: "Your nectar is increased by 2.",
          price: 0,
          effect: () {
            updateMyNectar(2);
          }),
          HoneyCard(
          imagePath: "cards/honeycomb.png",
          description: "Your nectar is increased by 3.",
          price: 0,
          effect: () {
            updateMyNectar(3);
          })
    ];

    generatedCards.clear();

    generatedCards.add(allCards[widget.honeyRush.card1]);
    generatedCards.add(allCards[widget.honeyRush.card2]);
    generatedCards.add(allCards[widget.honeyRush.card3]);

    generatedSlots = [
      widget.honeyRush.cardSlot1,
      widget.honeyRush.cardSlot2,
      widget.honeyRush.cardSlot3
    ];

    if (widget.honeyRush.playedCardsNum > 0) {
      for (int i = 0; i < 3; i++) {
        if (!generatedSlots[i]) {
          playedCards.add(generatedCards[i]);
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.honeyRush.hasRolled && widget.honeyRush.daytime) {
        showVoting();
        updateTemporaryNectar(widget.userUID, 0);
      }
      if (widget.honeyRush.isRolling) {
        showDice();
      }
      if (widget.honeyRush.isCarding) {
        showCards();
      }
    });
  }

  List<Widget> getProfiles() {
    List<Widget> allProfiles = [];
    for (HoneyProfile profile in widget.honeyRush.allProfiles) {
      allProfiles.add(buildProfile(profile));
    }
    return allProfiles;
  }

  Widget buildProfile(HoneyProfile profile) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Container(
            height: 100,
            decoration: BoxDecoration(
                color: profile.lifes == 0
                    ? const Color.fromARGB(255, 189, 165, 104)
                    : profile.hasHoneyFever
                        ? const Color.fromARGB(255, 187, 155, 76)
                        : const Color.fromARGB(255, 255, 223, 142),
                border: Border.all(
                    color: const Color.fromARGB(143, 20, 14, 5), width: 2),
                borderRadius: BorderRadius.circular(10.0)),
            child: Row(children: [
              const SizedBox(width: 5),
              Column(children: [
                const SizedBox(height: 2),
                SizedBox(
                  height: 73,
                  child: Image.asset(profile.avatarTypePath),
                ),
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                )
              ]),
              const Spacer(),
              widget.honeyRush.daytime &&
                      profile.lifes > 0 &&
                      !profile.hasHoneyFever
                  ? Column(children: [
                      SizedBox(
                          height: 40,
                          child: Row(children: [
                            SizedBox(
                                width: 30,
                                child: Image.asset(profile.lifes == 0
                                    ? 'heart_empty.png'
                                    : 'heart_full.png')),
                            SizedBox(
                                width: 30,
                                child: Image.asset(profile.lifes >= 2
                                    ? 'heart_full.png'
                                    : 'heart_empty.png')),
                            SizedBox(
                                width: 30,
                                child: Image.asset(profile.lifes == 3
                                    ? 'heart_full.png'
                                    : 'heart_empty.png'))
                          ])),
                      getNPCPlayedCards(profile.playedCards)
                    ])
                  : Row(children: [
                      SizedBox(
                          width: 30,
                          child: Image.asset(profile.lifes == 0
                              ? 'heart_empty.png'
                              : 'heart_full.png')),
                      SizedBox(
                          width: 30,
                          child: Image.asset(profile.lifes >= 2
                              ? 'heart_full.png'
                              : 'heart_empty.png')),
                      SizedBox(
                          width: 30,
                          child: Image.asset(profile.lifes == 3
                              ? 'heart_full.png'
                              : 'heart_empty.png'))
                    ]),
              const Spacer()
            ])));
  }

  Widget profiles() {
    return SizedBox(
        width: 270,
        height: 520,
        child: Stack(children: [
          Positioned.fill(
            child: Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 223, 142),
                    border: Border.all(
                        color: const Color.fromARGB(143, 20, 14, 5), width: 4),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                        width: 230,
                        height: 80,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 250, 208, 100),
                            border: Border.all(
                                color: const Color.fromARGB(143, 20, 14, 5),
                                width: 2),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Row(children: [
                          const SizedBox(width: 3),
                          Image.asset('bee_avatar_1.png'),
                          SizedBox(
                              width: 49, child: Image.asset('heart_full.png')),
                          SizedBox(
                              width: 49, child: Image.asset('heart_full.png')),
                          SizedBox(
                              width: 49, child: Image.asset('heart_full.png'))
                        ])),
                    const SizedBox(height: 5),
                    Expanded(
                      child: SizedBox(
                          width: 210,
                          child: ListView(
                              scrollDirection: Axis.vertical,
                              children: getProfiles())),
                    )
                  ],
                )),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 15,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 223, 142),
                border: Border(
                    right: BorderSide(
                        color: Color.fromARGB(143, 20, 14, 5), width: 4),
                    top: BorderSide(
                        color: Color.fromARGB(143, 20, 14, 5), width: 4),
                    bottom: BorderSide(
                        color: Color.fromARGB(143, 20, 14, 5), width: 4)),
              ),
            ),
          ),
        ]));
  }

  Widget story() {
    return SizedBox(
        width: 300,
        height: 300,
        child: Stack(children: [
          Positioned.fill(
            child: Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 223, 142),
                    border: Border.all(
                        color: const Color.fromARGB(143, 20, 14, 5), width: 4),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                            text: state.narrative1,
                          ),
                          TextSpan(
                            text: state.spot1[widget.honeyRush.narrativeSpot],
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: state.narrative2,
                          ),
                          TextSpan(
                            text: state.spot2[widget.honeyRush.narrativeSpot],
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: state.narrative3,
                          ),
                          TextSpan(
                            text: state.spot3[widget.honeyRush.narrativeSpot],
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: state.narrative4,
                          ),
                        ],
                      ),
                    ))),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 15,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 223, 142),
                border: Border(
                    left: BorderSide(
                        color: Color.fromARGB(143, 20, 14, 5), width: 4),
                    top: BorderSide(
                        color: Color.fromARGB(143, 20, 14, 5), width: 4),
                    bottom: BorderSide(
                        color: Color.fromARGB(143, 20, 14, 5), width: 4)),
              ),
            ),
          ),
        ]));
  }

  Widget diary() {
    return SizedBox(
        width: 300,
        height: 215,
        child: Stack(children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 223, 142),
                  border: Border.all(
                      color: const Color.fromARGB(143, 20, 14, 5), width: 4),
                  borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 15,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 223, 142),
                border: Border(
                    left: BorderSide(
                        color: Color.fromARGB(143, 20, 14, 5), width: 4),
                    top: BorderSide(
                        color: Color.fromARGB(143, 20, 14, 5), width: 4),
                    bottom: BorderSide(
                        color: Color.fromARGB(143, 20, 14, 5), width: 4)),
              ),
            ),
          ),
          Positioned(
              left: 10,
              top: 10,
              child: Column(children: [
                Text("Bee's / Wasp's Diary:",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        )),
                isEditingDiary
                    ? ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxHeight: 170, maxWidth: 280),
                        child: TextField(
                          focusNode: FocusNode(onKey: (node, event) {
                            if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                              updateDiary(widget.userUID,
                                  widget.honeyRush.textController.text);
                              widget.honeyRush.diaryText =
                                  widget.honeyRush.textController.text;
                              setState(() {
                                isEditingDiary = false;
                                node.unfocus();
                              });
                              return KeyEventResult.handled;
                            }
                            return KeyEventResult.ignored;
                          }),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          autofocus: true,
                          controller: widget.honeyRush.textController,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          setState(() {
                            isEditingDiary = true;
                          });
                        },
                        child: SizedBox(
                          width: 280,
                          height: 170,
                          child: SingleChildScrollView(
                            child: Text(widget.honeyRush.diaryText),
                          ),
                        ))
              ]))
        ]));
  }

  Widget dayNight() {
    return Row(children: [
      SizedBox(
          width: 250,
          height: 70,
          child: Stack(children: [
            Positioned(
                left: 0,
                top: 24,
                child: SizedBox(
                    width: 250,
                    height: 22,
                    child: Stack(children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 79, 179, 197),
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 15,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 79, 179, 197),
                            border: Border(
                                right:
                                    BorderSide(color: Colors.black, width: 2),
                                top: BorderSide(color: Colors.black, width: 2),
                                bottom:
                                    BorderSide(color: Colors.black, width: 2)),
                          ),
                        ),
                      )
                    ]))),
            widget.honeyRush.daytime
                ? Positioned(
                    left: 90,
                    child: SizedBox(width: 70, child: Image.asset('sun.png')))
                : Container()
          ])),
      SizedBox(
          width: 250,
          height: 60,
          child: Stack(children: [
            Positioned(
                right: 0,
                top: 19,
                child: SizedBox(
                    width: 250,
                    height: 22,
                    child: Stack(children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 23, 38, 104),
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 15,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 23, 38, 104),
                            border: Border(
                                left: BorderSide(color: Colors.black, width: 2),
                                top: BorderSide(color: Colors.black, width: 2),
                                bottom:
                                    BorderSide(color: Colors.black, width: 2)),
                          ),
                        ),
                      ),
                    ]))),
            widget.honeyRush.daytime
                ? Container()
                : Positioned(
                    right: 95,
                    child: SizedBox(width: 60, child: Image.asset('moon.png')))
          ]))
    ]);
  }

  Widget honeyStrip(int num, double width, Color fullColor) {
    return Container(
      width: width,
      height: 18,
      decoration: BoxDecoration(
          color: widget.honeyRush.honey >= num
              ? fullColor
              : const Color.fromARGB(255, 252, 241, 191),
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(10.0)),
    );
  }

  Widget honeycomb() {
    return Stack(children: [
      Column(children: [
        honeyStrip(100, 120, const Color.fromARGB(255, 230, 146, 38)),
        honeyStrip(90, 120, const Color.fromARGB(255, 230, 146, 38)),
        honeyStrip(80, 160, const Color.fromARGB(255, 240, 172, 84)),
        honeyStrip(70, 160, const Color.fromARGB(255, 240, 172, 84)),
        honeyStrip(60, 200, const Color.fromARGB(255, 230, 146, 38)),
        honeyStrip(50, 200, const Color.fromARGB(255, 230, 146, 38)),
        honeyStrip(40, 160, const Color.fromARGB(255, 240, 172, 84)),
        honeyStrip(30, 160, const Color.fromARGB(255, 240, 172, 84)),
        honeyStrip(20, 120, const Color.fromARGB(255, 230, 146, 38)),
        honeyStrip(10, 120, const Color.fromARGB(255, 230, 146, 38)),
      ]),
      Positioned(
        top: 63,
        left: 73,
        child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 252, 241, 191),
                border: Border.all(width: 4, color: Colors.black)),
            child: Center(
                child: Text("${widget.honeyRush.honey}%",
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 18)))),
      ),
    ]);
  }

  Widget getCards() {
    return Row(
      children: [
        card(0),
        const SizedBox(width: 10),
        card(1),
        const SizedBox(width: 10),
        card(2)
      ],
    );
  }

  Widget getRandomCards() {
    return Row(
      children: [
        randomCard(0),
        const SizedBox(width: 10),
        randomCard(1),
        const SizedBox(width: 10),
        randomCard(2)
      ],
    );
  }

  Widget card(int slot) {
    if (generatedSlots[slot] && generatedCards.isNotEmpty) {
      return ElevatedButton(
          onPressed: () {
            if (updateMyNectar(-generatedCards[slot].price)) {
              updateCardSlots(widget.userUID, false, slot);
              playedCards.add(generatedCards[slot]);
              updatePlayedCardsNum(
                  widget.userUID, widget.honeyRush.playedCardsNum + 1);
              widget.honeyRush.playedCardsNum++;
              if (slot == 0) {
                widget.honeyRush.cardSlot1 = false;
              } else if (slot == 1) {
                widget.honeyRush.cardSlot2 = false;
              } else if (slot == 2) {
                widget.honeyRush.cardSlot3 = false;
              }
              generatedSlots = [
                widget.honeyRush.cardSlot1,
                widget.honeyRush.cardSlot2,
                widget.honeyRush.cardSlot3
              ];
              generatedCards[slot].effect();
            }
          },
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              )),
          child: Container(
              width: 140,
              height: 180,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 251, 239),
                  border: Border.all(color: Colors.black, width: 3),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Stack(children: [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(children: [
                      SizedBox(
                          height: 80,
                          child: Image.asset(generatedCards[slot].imagePath)),
                      const Spacer(),
                      Text(generatedCards[slot].description,
                          textAlign: TextAlign.center)
                    ])),
                Positioned(
                    top: 5,
                    right: 5,
                    child: Text(generatedCards[slot].price.toString(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)))
              ])));
    }
    return Container(
      width: 140,
      height: 180,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 223, 142),
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(10.0)),
    );
  }

  Widget randomCard(int slot) {
    return Container(
        width: 140,
        height: 180,
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 251, 239),
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              SizedBox(
                  height: 80,
                  child: Image.asset(generatedCards[slot].imagePath)),
              const Spacer(),
              Text(generatedCards[slot].description,
                  textAlign: TextAlign.center)
            ])));
  }

  Widget getPlayedCards() {
    return Stack(children: [
      SizedBox(
          width: 450,
          child: Row(
            children: [
              const Spacer(),
              playedCard(playedCards.isNotEmpty, 0),
              const SizedBox(width: 10),
              playedCard(playedCards.length > 1, 1),
              const SizedBox(width: 10),
              playedCard(playedCards.length > 2, 2),
              const Spacer()
            ],
          )),
      Positioned(
        top: 20,
        left: 0,
        child: Row(children: [
          const SizedBox(width: 30),
          Text(widget.honeyRush.nectar.toString(),
              style: const TextStyle(fontSize: 22)),
          SizedBox(width: 40, child: Image.asset("nectar.png"))
        ]),
      )
    ]);
  }

  Widget getNPCPlayedCards(int playedCardsNPC) {
    return SizedBox(
        height: 45,
        child: Row(
          children: [
            playedCardNPC(playedCardsNPC > 0),
            const SizedBox(width: 2),
            playedCardNPC(playedCardsNPC > 1),
            const SizedBox(width: 2),
            playedCardNPC(playedCardsNPC > 2),
          ],
        ));
  }

  Widget playedCard(bool active, int slot) {
    if (active) {
      return Tooltip(
          message: playedCards[slot].description,
          child: Container(
              width: 70,
              height: 90,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 251, 239),
                  border: Border.all(color: Colors.black, width: 3),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                      height: 60,
                      child: Image.asset(playedCards[slot].imagePath)))));
    }
    return Container(
      width: 70,
      height: 90,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 223, 142),
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(10.0)),
    );
  }

  Widget playedCardNPC(bool active) {
    if (active) {
      return Container(
        width: 28,
        height: 40,
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 251, 239),
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(5.0)),
      );
    }
    return const SizedBox(
      width: 35,
      height: 45,
    );
  }

  Widget cardsButton() {
    return Row(children: [
      SizedBox(
          width: 50,
          height: 50,
          child: Stack(children: [
            Image.asset("restart.png"),
            Positioned(
                top: 10,
                right: 10,
                child: SizedBox(width: 30, child: Image.asset("cards.png")))
          ])),
      const SizedBox(width: 15),
      const Text("2", style: TextStyle(fontSize: 20)),
      SizedBox(width: 40, child: Image.asset("points.png"))
    ]);
  }

  Widget dicesButton() {
    return Row(children: [
      SizedBox(
          width: 50,
          height: 50,
          child: Stack(children: [
            Image.asset("restart.png"),
            Positioned(
                top: 12,
                right: 12,
                child: SizedBox(width: 25, child: Image.asset("dices.png")))
          ])),
      const SizedBox(width: 15),
      const Text("2", style: TextStyle(fontSize: 20)),
      SizedBox(width: 40, child: Image.asset("points.png")),
    ]);
  }

  void generateCards() {
    generatedCards.clear();
    int randomNumber1 = Random().nextInt(allCards.length);
    int randomNumber2 = Random().nextInt(allCards.length);
    int randomNumber3 = Random().nextInt(allCards.length);
    updateCards(widget.userUID, randomNumber1, randomNumber2, randomNumber3);
    widget.honeyRush.card1 = randomNumber1;
    widget.honeyRush.card2 = randomNumber2;
    widget.honeyRush.card3 = randomNumber3;

    updateCardSlots(widget.userUID, true, 4);

    widget.honeyRush.cardSlot1 = true;
    widget.honeyRush.cardSlot2 = true;
    widget.honeyRush.cardSlot3 = true;

    generatedSlots = [
      widget.honeyRush.cardSlot1,
      widget.honeyRush.cardSlot2,
      widget.honeyRush.cardSlot3
    ];

    generatedCards.add(allCards[randomNumber1]);
    generatedCards.add(allCards[randomNumber2]);
    generatedCards.add(allCards[randomNumber3]);
  }

  void rollDice() {
    int randomNumber = Random().nextInt(6) + 1;
    updateTemporaryNectar(widget.userUID, randomNumber);
    widget.honeyRush.temporaryNectar = randomNumber;
  }

  void randomizeHoneyFever(int slot) {
    if (slot == 9) {
      int random = Random().nextInt(6);
      if ((widget.honeyRush.allProfiles[random].lifes == 0 ||
              widget.honeyRush.allProfiles[random].hasHoneyFever) &&
          random != 0) {
        updateHasHoneyFever(
            widget.userUID, true, widget.honeyRush.allProfiles[random - 1].id);
      } else if ((widget.honeyRush.allProfiles[random].lifes == 0 ||
              widget.honeyRush.allProfiles[random].hasHoneyFever) &&
          random == 0) {
        updateHasHoneyFever(
            widget.userUID, true, widget.honeyRush.allProfiles[5].id);
      } else {
        updateHasHoneyFever(
            widget.userUID, true, widget.honeyRush.allProfiles[random].id);
      }
    } else {
      bool getsHoneyFever = Random().nextDouble() < 0.8;
      if (!getsHoneyFever) {
        int random = Random().nextInt(6);
        if (widget.honeyRush.allProfiles[random].lifes == 0 ||
            widget.honeyRush.allProfiles[random].hasHoneyFever) {
          updateHasHoneyFever(
              widget.userUID, true, widget.honeyRush.allProfiles[slot].id);
        } else {
          updateHasHoneyFever(
              widget.userUID, true, widget.honeyRush.allProfiles[random].id);
        }
      } else {
        updateHasHoneyFever(
            widget.userUID, true, widget.honeyRush.allProfiles[slot].id);
      }
    }
  }

  bool updateMyNectar(int newValue) {
    if (newValue >= 0 || widget.honeyRush.nectar >= -newValue) {
      updateNectar(widget.userUID, widget.honeyRush.nectar + newValue);
      return true;
    }
    return false;
  }

  void updateMyHoney(int newValue) {
    if (newValue >= 100) {
      updateHoney(widget.userUID, 100);
      widget.updateHasWon(true);
    } else {
      updateHoney(widget.userUID, newValue);
    }
  }

  Future<dynamic> showDice() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('How much nectar do I get today?'),
            content: SizedBox(
                height: 150,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 90, child: Image.asset("dices.png")),
                      Text(widget.honeyRush.temporaryNectar.toString(),
                          style: const TextStyle(fontSize: 30))
                    ])),
            actions: [
              widget.honeyRush.hasRolled
                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      TextButton(
                        onPressed: () {
                          if (widget.updatePoints(-2)) {
                            updateIsRolling(widget.userUID, true);
                            widget.honeyRush.isRolling = true;
                            rollDice();
                            Navigator.of(context).pop();
                          }
                        },
                        child: dicesButton(),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () {
                          updateIsRolling(widget.userUID, false);
                          updateMyNectar(widget.honeyRush.temporaryNectar);
                          generateCards();
                          Navigator.of(context).pop();
                          showCards();
                          widget.updatePoints(0);
                        },
                        child: const Text('Continue',
                            style: TextStyle(fontSize: 22)),
                      )
                    ])
                  : TextButton(
                      onPressed: () {
                        rollDice();
                        updateHasRolled(widget.userUID, true);
                        widget.honeyRush.hasRolled = true;
                        Navigator.of(context).pop();
                        showDice();
                      },
                      child: const Text('Roll', style: TextStyle(fontSize: 22)),
                    ),
            ],
          );
        });
  }

  Widget voteProfile(int index, BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: widget.honeyRush.allProfiles[index].lifes == 0 ||
                widget.honeyRush.allProfiles[index].hasHoneyFever
            ? Container(
                height: 80,
                width: 180,
                decoration: BoxDecoration(
                    color: widget.honeyRush.allProfiles[index].lifes == 0
                        ? const Color.fromARGB(255, 189, 165, 104)
                        : const Color.fromARGB(255, 187, 155, 76),
                    border: Border.all(
                        color: const Color.fromARGB(143, 17, 12, 4), width: 2),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Row(children: [
                  const SizedBox(width: 5),
                  SizedBox(
                    height: 65,
                    child: Image.asset(
                        widget.honeyRush.allProfiles[index].avatarTypePath),
                  ),
                  const Spacer(),
                  Text(
                    widget.honeyRush.allProfiles[index].name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color.fromARGB(143, 61, 29, 7)),
                  ),
                  const Spacer()
                ]))
            : GestureDetector(
                onTap: () {
                  setState(() {
                    selectedNPC = index;
                    Navigator.of(context).pop();
                    showVoting();
                  });
                },
                child: Container(
                    height: 80,
                    width: 180,
                    decoration: BoxDecoration(
                        color: selectedNPC == index
                            ? const Color.fromARGB(255, 255, 192, 97)
                            : const Color.fromARGB(255, 255, 223, 142),
                        border: Border.all(
                            color: selectedNPC == index
                                ? const Color.fromARGB(143, 20, 14, 5)
                                : const Color.fromARGB(143, 17, 12, 4),
                            width: 2),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Row(children: [
                      const SizedBox(width: 5),
                      SizedBox(
                        height: 65,
                        child: Image.asset(
                            widget.honeyRush.allProfiles[index].avatarTypePath),
                      ),
                      const Spacer(),
                      Text(
                        widget.honeyRush.allProfiles[index].name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color.fromARGB(143, 61, 29, 7)),
                      ),
                      const Spacer()
                    ]))));
  }

  Future<dynamic> showVoting() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Who is the Wasp?'),
            content: SizedBox(
                height: 180,
                child: Column(children: [
                  Row(children: [
                    voteProfile(0, context),
                    const SizedBox(width: 10),
                    voteProfile(1, context),
                    const SizedBox(width: 10),
                    voteProfile(2, context)
                  ]),
                  Row(children: [
                    voteProfile(3, context),
                    const SizedBox(width: 10),
                    voteProfile(4, context),
                    const SizedBox(width: 10),
                    voteProfile(5, context)
                  ])
                ])),
            actions: [
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  randomizeHoneyFever(selectedNPC);
                  Navigator.of(context).pop();
                  showDice();
                },
                child: Text(selectedNPC == 9 ? 'Skip Vote' : 'Continue',
                    style: const TextStyle(fontSize: 22)),
              )
            ],
          );
        });
  }

  Future<dynamic> showCards() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Which cards can I play today?'),
            content: getRandomCards(),
            actions: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(
                  onPressed: () {
                    if (widget.updatePoints(-2)) {
                      updateIsCarding(widget.userUID, true);
                      widget.honeyRush.isCarding = true;
                      generateCards();
                      Navigator.of(context).pop();
                    }
                  },
                  child: cardsButton(),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () {
                    updateIsCarding(widget.userUID, false);
                    Navigator.of(context).pop();
                    widget.updatePoints(0);
                  },
                  child: const Text('Continue', style: TextStyle(fontSize: 22)),
                )
              ])
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(children: [
          const SizedBox(height: 10),
          story(),
          const SizedBox(height: 5),
          diary()
        ]),
        const Spacer(),
        Column(children: [
          dayNight(),
          honeycomb(),
          const Spacer(),
          getPlayedCards(),
          const Spacer(),
          getCards(),
          const Spacer()
        ]),
        const Spacer(),
        profiles(),
      ],
    ));
  }
}

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/honey.dart';

class HoneyScreen extends StatelessWidget {
  final String userUID;
  final Function(int) updatePoints;

  const HoneyScreen(
      {Key? key, required this.userUID, required this.updatePoints})
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
            );
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
      {super.key,
      required this.updatePoints,
      required this.honeyRush,
      required this.userUID});
  final Function(int) updatePoints;
  final HoneyRush honeyRush;
  final String userUID;

  @override
  State<_HoneyScreen> createState() => _HoneyScreenState();
}

class _HoneyScreenState extends State<_HoneyScreen> {
  //List<HoneyProfile> npcList = [
  // HoneyProfile(
  //     name: "Laura",
  //     avatarTypePath: "bee_avatar_2.png",
  //     lifes: 3,
  //     playedCards: 1),
  // HoneyProfile(
  //     name: "Pol",
  //     avatarTypePath: "bee_avatar_3.png",
  //     lifes: 2,
  //     playedCards: 0),
  // HoneyProfile(
  //     name: "Laia",
  //     avatarTypePath: "bee_avatar_4.png",
  //     lifes: 3,
  //     playedCards: 2),
  // HoneyProfile(
  //     name: "Júlia",
  //     avatarTypePath: "bee_avatar_5.png",
  //     lifes: 0,
  //     playedCards: 1),
  // HoneyProfile(
  //     name: "Biel",
  //     avatarTypePath: "bee_avatar_6.png",
  //     lifes: 1,
  //     playedCards: 2),
  // HoneyProfile(
  //     name: "Nora",
  //     avatarTypePath: "bee_avatar_7.png",
  //     lifes: 3,
  //     playedCards: 3),
  //];
  List<HoneyCard> allCards = [];
  List<HoneyCard> generatedCards = [];
  List<bool> generatedSlots = [true, true, true];
  HoneyState state = HoneyState();
  TextEditingController textController = TextEditingController();
  bool isEditingDiary = false;
  String diaryText = 'Write your thoughts...';
  List<HoneyCard> playedCards = [];
  bool hasRolled = false;
  int temporaryNectar = 0;
  int selectedNPC = 9;

  @override
  void initState() {
    super.initState();
    widget.honeyRush.allProfiles[1].hasHoneyFever = true;
    allCards = [
      HoneyCard(
          imagePath: "cards/flower_patch.png",
          description: "Generate 2 honey.",
          price: 2,
          effect: () {
            state.honey += 2;
          }),
      HoneyCard(
          imagePath: "cards/flower_field.png",
          description: "Generate 3 honey.",
          price: 3,
          effect: () {
            state.honey += 3;
          }),
      HoneyCard(
          imagePath: "cards/pollen.png",
          description: "Generate 1 honey.",
          price: 1,
          effect: () {
            state.honey += 1;
          })
    ];

    state.honey = Random().nextInt(21) + 60;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showVoting();
    });
  }

  Future<void> updateHasHoneyFever(bool newValue, String profileID) async {
    try {
      DocumentReference profileRef = FirebaseFirestore.instance.doc(
          '/users/${widget.userUID}/honeyRush/honeyRush/profiles/$profileID');

      await profileRef.update({'hasHoneyFever': newValue});
    } catch (e) {
      print('Error updating hasHoneyFever: $e');
    }
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
                    ? Color.fromARGB(255, 189, 165, 104)
                    : profile.hasHoneyFever
                        ? Color.fromARGB(255, 187, 155, 76)
                        : Color.fromARGB(255, 255, 223, 142),
                border:
                    Border.all(color: Color.fromARGB(143, 20, 14, 5), width: 2),
                borderRadius: BorderRadius.circular(10.0)),
            child: Row(children: [
              const SizedBox(width: 5),
              Column(children: [
                SizedBox(height: 2),
                Container(
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
              Spacer(),
              state.daytime && profile.lifes > 0 && !profile.hasHoneyFever
                  ? Container(
                      child: Column(children: [
                      Container(
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
                    ]))
                  : Container(
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
              Spacer()
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
                    color: Color.fromARGB(255, 255, 223, 142),
                    border: Border.all(
                        color: Color.fromARGB(143, 20, 14, 5), width: 4),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Container(
                        width: 230,
                        height: 80,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 250, 208, 100),
                            border: Border.all(
                                color: Color.fromARGB(143, 20, 14, 5),
                                width: 2),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Row(children: [
                          SizedBox(width: 3),
                          Container(child: Image.asset('bee_avatar_1.png')),
                          Container(
                              width: 49, child: Image.asset('heart_full.png')),
                          Container(
                              width: 49, child: Image.asset('heart_full.png')),
                          Container(
                              width: 49, child: Image.asset('heart_full.png'))
                        ])),
                    SizedBox(height: 5),
                    Expanded(
                      child: Container(
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
                  color: Color.fromARGB(255, 255, 223, 142),
                  border: Border.all(
                      color: Color.fromARGB(143, 20, 14, 5), width: 4),
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
                  color: Color.fromARGB(255, 255, 223, 142),
                  border: Border.all(
                      color: Color.fromARGB(143, 20, 14, 5), width: 4),
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
                              setState(() {
                                diaryText = textController.text;
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
                          controller: textController,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          setState(() {
                            isEditingDiary = true;
                          });
                        },
                        child: Container(
                          width: 280,
                          height: 170,
                          child: SingleChildScrollView(
                            child: Text(diaryText),
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
                              color: Color.fromARGB(255, 79, 179, 197),
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
            state.daytime
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
                              color: Color.fromARGB(255, 23, 38, 104),
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
            state.daytime
                ? Container()
                : Positioned(
                    right: 95,
                    child: SizedBox(width: 60, child: Image.asset('moon.png')))
          ]))
    ]);
  }

  Widget honeycomb() {
    return Stack(children: [
      Container(
          child: Column(children: [
        Container(
          width: 120,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey == 100
                  ? Color.fromARGB(255, 230, 146, 38)
                  : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 120,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 90
                  ? Color.fromARGB(255, 230, 146, 38)
                  : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 160,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 80
                  ? Color.fromARGB(255, 240, 172, 84)
                  : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 160,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 70
                  ? Color.fromARGB(255, 240, 172, 84)
                  : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 200,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 60
                  ? Color.fromARGB(255, 230, 146, 38)
                  : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 200,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 50
                  ? Color.fromARGB(255, 230, 146, 38)
                  : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 160,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 40
                  ? Color.fromARGB(255, 240, 172, 84)
                  : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 160,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 30
                  ? Color.fromARGB(255, 240, 172, 84)
                  : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 120,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 20
                  ? Color.fromARGB(255, 230, 146, 38)
                  : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 120,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 10
                  ? Color.fromARGB(255, 230, 146, 38)
                  : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        )
      ])),
      Positioned(
        top: 63,
        left: 73,
        child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 252, 241, 191),
                border: Border.all(width: 4, color: Colors.black)),
            child: Center(
                child: Text("${state.honey}%",
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 18)))),
      ),
    ]);
  }

  Widget getCards() {
    return Row(
      children: [
        card(0),
        SizedBox(width: 10),
        card(1),
        SizedBox(width: 10),
        card(2)
      ],
    );
  }

  Widget getRandomCards() {
    return Row(
      children: [
        randomCard(0),
        SizedBox(width: 10),
        randomCard(1),
        SizedBox(width: 10),
        randomCard(2)
      ],
    );
  }

  Widget card(int slot) {
    if (generatedSlots[slot] && generatedCards.length > 0) {
      return ElevatedButton(
          onPressed: () {
            setState(() {
              if (updateNectar(-generatedCards[slot].price)) {
                playedCards.add(generatedCards[slot]);
                generatedSlots[slot] = false;
                generatedCards[slot].effect();
              }
            });
          },
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              )),
          child: Container(
              width: 140,
              height: 180,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 251, 239),
                  border: Border.all(color: Colors.black, width: 3),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Stack(children: [
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(children: [
                      Container(
                          height: 80,
                          child: Image.asset(generatedCards[slot].imagePath)),
                      Spacer(),
                      Text(generatedCards[slot].description,
                          textAlign: TextAlign.center)
                    ])),
                Positioned(
                    top: 5,
                    right: 5,
                    child: Text(generatedCards[slot].price.toString(),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)))
              ])));
    }
    return Container(
      width: 140,
      height: 180,
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 223, 142),
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(10.0)),
    );
  }

  Widget randomCard(int slot) {
    return Container(
        width: 140,
        height: 180,
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 251, 239),
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(children: [
              Container(
                  height: 80,
                  child: Image.asset(generatedCards[slot].imagePath)),
              Spacer(),
              Text(generatedCards[slot].description,
                  textAlign: TextAlign.center)
            ])));
  }

  Widget getPlayedCards() {
    return Stack(children: [
      Container(
          width: 450,
          child: Row(
            children: [
              Spacer(),
              playedCard(playedCards.length > 0, 0),
              SizedBox(width: 10),
              playedCard(playedCards.length > 1, 1),
              SizedBox(width: 10),
              playedCard(playedCards.length > 2, 2),
              Spacer()
            ],
          )),
      Positioned(
        top: 20,
        left: 0,
        child: Row(children: [
          SizedBox(width: 30),
          Text(state.nectar.toString(), style: TextStyle(fontSize: 22)),
          Container(width: 40, child: Image.asset("nectar.png"))
        ]),
      )
    ]);
  }

  Widget getNPCPlayedCards(int playedCardsNPC) {
    return Container(
        height: 45,
        child: Row(
          children: [
            playedCardNPC(playedCardsNPC > 0),
            SizedBox(width: 2),
            playedCardNPC(playedCardsNPC > 1),
            SizedBox(width: 2),
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
                  color: Color.fromARGB(255, 255, 251, 239),
                  border: Border.all(color: Colors.black, width: 3),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                      height: 60,
                      child: Image.asset(playedCards[slot].imagePath)))));
    }
    return Container(
      width: 70,
      height: 90,
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 223, 142),
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
            color: Color.fromARGB(255, 255, 251, 239),
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
      ElevatedButton(
          onPressed: () {
            //setState(() {
            generateCards();
            widget.updatePoints(-2);
            //});
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 255, 245, 202),
              shape: CircleBorder(),
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0)),
          child: Container(
              width: 50,
              height: 50,
              child: Stack(children: [
                Image.asset("restart.png"),
                Positioned(
                    top: 10,
                    right: 10,
                    child:
                        Container(width: 30, child: Image.asset("cards.png")))
              ]))),
      SizedBox(width: 15),
      Text("2", style: TextStyle(fontSize: 20)),
      Container(width: 40, child: Image.asset("points.png"))
    ]);
  }

  Widget dicesButton() {
    return Row(children: [
      Container(
          width: 50,
          height: 50,
          child: Stack(children: [
            Image.asset("restart.png"),
            Positioned(
                top: 12,
                right: 12,
                child: Container(width: 25, child: Image.asset("dices.png")))
          ])),
      SizedBox(width: 15),
      Text("2", style: TextStyle(fontSize: 20)),
      Container(width: 40, child: Image.asset("points.png")),
    ]);
  }

  void generateCards() {
    setState(() {
      generatedCards.clear();
      int randomNumber1 = Random().nextInt(allCards.length);
      int randomNumber2 = Random().nextInt(allCards.length);
      int randomNumber3 = Random().nextInt(allCards.length);

      generatedCards.add(allCards[randomNumber1]);
      generatedCards.add(allCards[randomNumber2]);
      generatedCards.add(allCards[randomNumber3]);
    });
  }

  void rollDice() {
    int randomNumber = Random().nextInt(6) + 1;
    temporaryNectar = randomNumber;
  }

  void randomizeHoneyFever(int slot) {
    if (slot == 9) {
      int random = Random().nextInt(6);
      if ((widget.honeyRush.allProfiles[random].lifes == 0 ||
              widget.honeyRush.allProfiles[random].hasHoneyFever) &&
          random != 0) {
        updateHasHoneyFever(true, widget.honeyRush.allProfiles[random - 1].id);
      } else if ((widget.honeyRush.allProfiles[random].lifes == 0 ||
              widget.honeyRush.allProfiles[random].hasHoneyFever) &&
          random == 0) {
        updateHasHoneyFever(true, widget.honeyRush.allProfiles[5].id);
      } else {
        updateHasHoneyFever(true, widget.honeyRush.allProfiles[random].id);
      }
    } else {
      updateHasHoneyFever(
          Random().nextDouble() < 0.8, widget.honeyRush.allProfiles[slot].id);
      if (!widget.honeyRush.allProfiles[slot].hasHoneyFever) {
        int random = Random().nextInt(6);
        if (widget.honeyRush.allProfiles[random].lifes == 0 ||
            widget.honeyRush.allProfiles[random].hasHoneyFever) {
          updateHasHoneyFever(true, widget.honeyRush.allProfiles[slot].id);
        } else {
          updateHasHoneyFever(true, widget.honeyRush.allProfiles[random].id);
        }
      }
    }
  }

  bool updateNectar(int newValue) {
    if (newValue >= 0 || state.nectar >= -newValue) {
      setState(() {
        if (100 - state.nectar <= newValue) {
          state.nectar = 100;
        } else {
          state.nectar += newValue;
        }
      });
      return true;
    }
    return false;
  }

  Future<dynamic> showDice() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('How much nectar do I get today?'),
            content: Container(
                height: 150,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(width: 90, child: Image.asset("dices.png")),
                      Text(temporaryNectar.toString(),
                          style: TextStyle(fontSize: 30))
                    ])),
            actions: [
              hasRolled
                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            rollDice();
                            widget.updatePoints(-2);
                            Navigator.of(context).pop();
                            showDice();
                          });
                        },
                        child: dicesButton(),
                      ),
                      SizedBox(width: 20),
                      TextButton(
                        onPressed: () {
                          updateNectar(temporaryNectar);
                          generateCards();
                          Navigator.of(context).pop();
                          showCards();
                        },
                        child: Text('Continue', style: TextStyle(fontSize: 22)),
                      )
                    ])
                  : TextButton(
                      onPressed: () {
                        setState(() {
                          rollDice();
                          hasRolled = true;
                          Navigator.of(context).pop();
                          showDice();
                        });
                      },
                      child: Text('Roll', style: TextStyle(fontSize: 22)),
                    ),
            ],
          );
        });
  }

  Future<dynamic> showVoting() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Who is the Wasp?'),
            content: Container(
                height: 180,
                child: Column(children: [
                  Row(children: [
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: widget.honeyRush.allProfiles[0].lifes == 0 ||
                                widget.honeyRush.allProfiles[0].hasHoneyFever
                            ? Container(
                                height: 80,
                                width: 180,
                                decoration: BoxDecoration(
                                    color:
                                        widget.honeyRush.allProfiles[0].lifes == 0
                                            ? Color.fromARGB(255, 189, 165, 104)
                                            : Color.fromARGB(255, 187, 155, 76),
                                    border: Border.all(
                                        color: Color.fromARGB(143, 17, 12, 4),
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Row(children: [
                                  const SizedBox(width: 5),
                                  Container(
                                    height: 65,
                                    child: Image.asset(widget.honeyRush
                                        .allProfiles[0].avatarTypePath),
                                  ),
                                  Spacer(),
                                  Text(
                                    widget.honeyRush.allProfiles[0].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color:
                                                Color.fromARGB(143, 61, 29, 7)),
                                  ),
                                  Spacer()
                                ]))
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedNPC = 0;
                                    Navigator.of(context).pop();
                                    showVoting();
                                  });
                                },
                                child: Container(
                                    height: 80,
                                    width: 180,
                                    decoration: BoxDecoration(
                                        color: selectedNPC == 0
                                            ? Color.fromARGB(255, 255, 192, 97)
                                            : Color.fromARGB(
                                                255, 255, 223, 142),
                                        border: Border.all(
                                            color: selectedNPC == 0
                                                ? Color.fromARGB(143, 20, 14, 5)
                                                : Color.fromARGB(
                                                    143, 17, 12, 4),
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    child: Row(children: [
                                      const SizedBox(width: 5),
                                      Container(
                                        height: 65,
                                        child: Image.asset(widget.honeyRush
                                            .allProfiles[0].avatarTypePath),
                                      ),
                                      Spacer(),
                                      Text(
                                        widget.honeyRush.allProfiles[0].name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: Color.fromARGB(
                                                    143, 61, 29, 7)),
                                      ),
                                      Spacer()
                                    ])))),
                    SizedBox(width: 10),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: widget.honeyRush.allProfiles[1].lifes == 0 ||
                                widget.honeyRush.allProfiles[1].hasHoneyFever
                            ? Container(
                                height: 80,
                                width: 180,
                                decoration: BoxDecoration(
                                    color:
                                        widget.honeyRush.allProfiles[1].lifes == 0
                                            ? Color.fromARGB(255, 189, 165, 104)
                                            : Color.fromARGB(255, 187, 155, 76),
                                    border: Border.all(
                                        color: Color.fromARGB(143, 17, 12, 4),
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Row(children: [
                                  const SizedBox(width: 5),
                                  Container(
                                    height: 65,
                                    child: Image.asset(widget.honeyRush
                                        .allProfiles[1].avatarTypePath),
                                  ),
                                  Spacer(),
                                  Text(
                                    widget.honeyRush.allProfiles[1].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color:
                                                Color.fromARGB(143, 61, 29, 7)),
                                  ),
                                  Spacer()
                                ]))
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedNPC = 1;
                                    Navigator.of(context).pop();
                                    showVoting();
                                  });
                                },
                                child: Container(
                                    height: 80,
                                    width: 180,
                                    decoration: BoxDecoration(
                                        color: selectedNPC == 1
                                            ? Color.fromARGB(255, 255, 192, 97)
                                            : Color.fromARGB(
                                                255, 255, 223, 142),
                                        border: Border.all(
                                            color: selectedNPC == 1
                                                ? Color.fromARGB(143, 20, 14, 5)
                                                : Color.fromARGB(
                                                    143, 20, 14, 5),
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    child: Row(children: [
                                      const SizedBox(width: 5),
                                      Container(
                                        height: 65,
                                        child: Image.asset(widget.honeyRush
                                            .allProfiles[1].avatarTypePath),
                                      ),
                                      Spacer(),
                                      Text(
                                        widget.honeyRush.allProfiles[1].name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: Color.fromARGB(
                                                    143, 61, 29, 7)),
                                      ),
                                      Spacer()
                                    ])))),
                    SizedBox(width: 10),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: widget.honeyRush.allProfiles[2].lifes == 0 ||
                                widget.honeyRush.allProfiles[2].hasHoneyFever
                            ? Container(
                                height: 80,
                                width: 180,
                                decoration: BoxDecoration(
                                    color:
                                        widget.honeyRush.allProfiles[2].lifes == 0
                                            ? Color.fromARGB(255, 189, 165, 104)
                                            : Color.fromARGB(255, 187, 155, 76),
                                    border: Border.all(
                                        color: Color.fromARGB(143, 17, 12, 4),
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Row(children: [
                                  const SizedBox(width: 5),
                                  Container(
                                    height: 65,
                                    child: Image.asset(widget.honeyRush
                                        .allProfiles[2].avatarTypePath),
                                  ),
                                  Spacer(),
                                  Text(
                                    widget.honeyRush.allProfiles[2].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color:
                                                Color.fromARGB(143, 61, 29, 7)),
                                  ),
                                  Spacer()
                                ]))
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedNPC = 2;
                                    Navigator.of(context).pop();
                                    showVoting();
                                  });
                                },
                                child: Container(
                                    height: 80,
                                    width: 180,
                                    decoration: BoxDecoration(
                                        color: selectedNPC == 2
                                            ? Color.fromARGB(255, 255, 192, 97)
                                            : Color.fromARGB(
                                                255, 255, 223, 142),
                                        border: Border.all(
                                            color: selectedNPC == 2
                                                ? Color.fromARGB(143, 20, 14, 5)
                                                : Color.fromARGB(
                                                    143, 20, 14, 5),
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    child: Row(children: [
                                      const SizedBox(width: 5),
                                      Container(
                                        height: 65,
                                        child: Image.asset(widget.honeyRush
                                            .allProfiles[2].avatarTypePath),
                                      ),
                                      Spacer(),
                                      Text(
                                        widget.honeyRush.allProfiles[2].name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: Color.fromARGB(
                                                    143, 61, 29, 7)),
                                      ),
                                      Spacer()
                                    ])))),
                  ]),
                  Row(children: [
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: widget.honeyRush.allProfiles[3].lifes == 0 ||
                                widget.honeyRush.allProfiles[3].hasHoneyFever
                            ? Container(
                                height: 80,
                                width: 180,
                                decoration: BoxDecoration(
                                    color:
                                        widget.honeyRush.allProfiles[3].lifes == 0
                                            ? Color.fromARGB(255, 189, 165, 104)
                                            : Color.fromARGB(255, 187, 155, 76),
                                    border: Border.all(
                                        color: Color.fromARGB(143, 17, 12, 4),
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Row(children: [
                                  const SizedBox(width: 5),
                                  Container(
                                    height: 65,
                                    child: Image.asset(widget.honeyRush
                                        .allProfiles[3].avatarTypePath),
                                  ),
                                  Spacer(),
                                  Text(
                                    widget.honeyRush.allProfiles[3].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color:
                                                Color.fromARGB(143, 61, 29, 7)),
                                  ),
                                  Spacer()
                                ]))
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedNPC = 3;
                                    Navigator.of(context).pop();
                                    showVoting();
                                  });
                                },
                                child: Container(
                                    height: 80,
                                    width: 180,
                                    decoration: BoxDecoration(
                                        color: selectedNPC == 3
                                            ? Color.fromARGB(255, 255, 192, 97)
                                            : Color.fromARGB(
                                                255, 255, 223, 142),
                                        border: Border.all(
                                            color: selectedNPC == 3
                                                ? Color.fromARGB(143, 20, 14, 5)
                                                : Color.fromARGB(
                                                    143, 20, 14, 5),
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    child: Row(children: [
                                      const SizedBox(width: 5),
                                      Container(
                                        height: 65,
                                        child: Image.asset(widget.honeyRush
                                            .allProfiles[3].avatarTypePath),
                                      ),
                                      Spacer(),
                                      Text(
                                        widget.honeyRush.allProfiles[3].name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: Color.fromARGB(
                                                    143, 61, 29, 7)),
                                      ),
                                      Spacer()
                                    ])))),
                    SizedBox(width: 10),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: widget.honeyRush.allProfiles[4].lifes == 0 ||
                                widget.honeyRush.allProfiles[4].hasHoneyFever
                            ? Container(
                                height: 80,
                                width: 180,
                                decoration: BoxDecoration(
                                    color:
                                        widget.honeyRush.allProfiles[4].lifes == 0
                                            ? Color.fromARGB(255, 189, 165, 104)
                                            : Color.fromARGB(255, 187, 155, 76),
                                    border: Border.all(
                                        color: Color.fromARGB(143, 17, 12, 4),
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Row(children: [
                                  const SizedBox(width: 5),
                                  Container(
                                    height: 65,
                                    child: Image.asset(widget.honeyRush
                                        .allProfiles[4].avatarTypePath),
                                  ),
                                  Spacer(),
                                  Text(
                                    widget.honeyRush.allProfiles[4].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color:
                                                Color.fromARGB(143, 61, 29, 7)),
                                  ),
                                  Spacer()
                                ]))
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedNPC = 4;
                                    Navigator.of(context).pop();
                                    showVoting();
                                  });
                                },
                                child: Container(
                                    height: 80,
                                    width: 180,
                                    decoration: BoxDecoration(
                                        color: selectedNPC == 4
                                            ? Color.fromARGB(255, 255, 192, 97)
                                            : Color.fromARGB(
                                                255, 255, 223, 142),
                                        border: Border.all(
                                            color: selectedNPC == 4
                                                ? Color.fromARGB(143, 20, 14, 5)
                                                : Color.fromARGB(
                                                    143, 20, 14, 5),
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    child: Row(children: [
                                      const SizedBox(width: 5),
                                      Container(
                                        height: 65,
                                        child: Image.asset(widget.honeyRush
                                            .allProfiles[4].avatarTypePath),
                                      ),
                                      Spacer(),
                                      Text(
                                        widget.honeyRush.allProfiles[4].name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: Color.fromARGB(
                                                    143, 61, 29, 7)),
                                      ),
                                      Spacer()
                                    ])))),
                    SizedBox(width: 10),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: widget.honeyRush.allProfiles[5].lifes == 0 ||
                                widget.honeyRush.allProfiles[5].hasHoneyFever
                            ? Container(
                                height: 80,
                                width: 180,
                                decoration: BoxDecoration(
                                    color:
                                        widget.honeyRush.allProfiles[5].lifes == 0
                                            ? Color.fromARGB(255, 189, 165, 104)
                                            : Color.fromARGB(255, 187, 155, 76),
                                    border: Border.all(
                                        color: Color.fromARGB(143, 17, 12, 4),
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Row(children: [
                                  const SizedBox(width: 5),
                                  Container(
                                    height: 65,
                                    child: Image.asset(widget.honeyRush
                                        .allProfiles[5].avatarTypePath),
                                  ),
                                  Spacer(),
                                  Text(
                                    widget.honeyRush.allProfiles[5].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color:
                                                Color.fromARGB(143, 61, 29, 7)),
                                  ),
                                  Spacer()
                                ]))
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedNPC = 5;
                                    Navigator.of(context).pop();
                                    showVoting();
                                  });
                                },
                                child: Container(
                                    height: 80,
                                    width: 180,
                                    decoration: BoxDecoration(
                                        color: selectedNPC == 5
                                            ? Color.fromARGB(255, 255, 192, 97)
                                            : Color.fromARGB(
                                                255, 255, 223, 142),
                                        border: Border.all(
                                            color: selectedNPC == 5
                                                ? Color.fromARGB(143, 20, 14, 5)
                                                : Color.fromARGB(
                                                    143, 20, 14, 5),
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    child: Row(children: [
                                      const SizedBox(width: 5),
                                      Container(
                                        height: 65,
                                        child: Image.asset(widget.honeyRush
                                            .allProfiles[5].avatarTypePath),
                                      ),
                                      Spacer(),
                                      Text(
                                        widget.honeyRush.allProfiles[5].name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: Color.fromARGB(
                                                    143, 61, 29, 7)),
                                      ),
                                      Spacer()
                                    ])))),
                  ])
                ])),
            actions: [
              SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    randomizeHoneyFever(selectedNPC);
                  });
                  Navigator.of(context).pop();
                  showDice();
                },
                child: Text(selectedNPC == 9 ? 'Skip Vote' : 'Continue',
                    style: TextStyle(fontSize: 22)),
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
            title: Text('Which cards can I play today?'),
            content: getRandomCards(),
            actions: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      generateCards();
                      widget.updatePoints(-2);
                      Navigator.of(context).pop();
                      showCards();
                    });
                  },
                  child: cardsButton(),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Continue', style: TextStyle(fontSize: 22)),
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
          //Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          //dicesButtonOld(),
          //SizedBox(width: 30),
          honeycomb(),
          //]),
          Spacer(),
          getPlayedCards(),
          Spacer(),
          getCards(),
          Spacer()
        ]),
        const Spacer(),
        profiles(),
      ],
    ));
  }
}

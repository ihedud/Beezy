import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/honey.dart';

class HoneyScreen extends StatefulWidget {
  const HoneyScreen({super.key, required this.updatePoints});
  final Function(int) updatePoints;

  @override
  State<HoneyScreen> createState() => _HoneyScreenState();
}

class _HoneyScreenState extends State<HoneyScreen> {
  List<HoneyProfile> npcList = [
    HoneyProfile(name: "Laura", avatarTypePath: "bee_avatar_2.png", lifes: 3),
    HoneyProfile(name: "Pol", avatarTypePath: "bee_avatar_3.png", lifes: 2),
    HoneyProfile(name: "Laia", avatarTypePath: "bee_avatar_4.png", lifes: 3),
    HoneyProfile(name: "Júlia", avatarTypePath: "bee_avatar_5.png", lifes: 0),
    HoneyProfile(name: "Biel", avatarTypePath: "bee_avatar_6.png", lifes: 1),
    HoneyProfile(name: "Nora", avatarTypePath: "bee_avatar_7.png", lifes: 3),
  ];
  List<HoneyCard> generatedCards = [];
  List<bool> generatedSlots = [true, true, true];
  HoneyState state = HoneyState();
  TextEditingController textController = TextEditingController();
  bool isEditingDiary = false;
  String diaryText = 'Write your thoughts...';
  List<HoneyCard> playedCards = [];

  void initState() {
    super.initState();

    generatedCards = [
    HoneyCard(
        imagePath: "cards/flower_patch.png",
        description: "Generate 2 honey.",
        price: 3,
        effect: () {
          state.honey += 2;
        }),
    HoneyCard(
        imagePath: "cards/flower_patch.png",
        description: "Generate 2 honey.",
        price: 3,
        effect: () {
          state.honey += 2;
        }),
    HoneyCard(
        imagePath: "cards/flower_patch.png",
        description: "Generate 2 honey.",
        price: 3,
        effect: () {
          state.honey += 2;
        })
  ];
  }

  List<Widget> getProfiles() {
    List<Widget> allProfiles = [];
    for (HoneyProfile profile in npcList) {
      allProfiles.add(buildProfile(profile));
    }
    return allProfiles;
  }

  Widget buildProfile(HoneyProfile profile) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Container(
            //width: 200,
            height: 100,
            decoration: BoxDecoration(
                color: profile.lifes == 0
                    ? Color.fromARGB(255, 189, 165, 104)
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
                      : 'heart_empty.png')),
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
              color: state.honey == 100 ? Color.fromARGB(255, 230, 146, 38) : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 120,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 90 ? Color.fromARGB(255, 230, 146, 38) : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 160,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 80 ? Color.fromARGB(255, 240, 172, 84) : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 160,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 70 ? Color.fromARGB(255, 240, 172, 84) : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 200,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 60 ? Color.fromARGB(255, 230, 146, 38) : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 200,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 50 ? Color.fromARGB(255, 230, 146, 38) : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 160,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 40 ? Color.fromARGB(255, 240, 172, 84) : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 160,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 30 ? Color.fromARGB(255, 240, 172, 84) : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 120,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 20 ? Color.fromARGB(255, 230, 146, 38) : Color.fromARGB(255, 252, 241, 191),
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        Container(
          width: 120,
          height: 18,
          decoration: BoxDecoration(
              color: state.honey >= 10 ? Color.fromARGB(255, 230, 146, 38) : Color.fromARGB(255, 252, 241, 191),
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

  Widget card(int slot) {
    if (generatedSlots[slot]) {
      return ElevatedButton(
          onPressed: () {
            setState(() {
              playedCards.add(generatedCards[slot]);
              generatedSlots[slot] = false;
              generatedCards[slot].effect();
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
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(children: [
                    Container(
                        height: 80,
                        child: Image.asset(generatedCards[slot].imagePath)),
                    Spacer(),
                    Text(generatedCards[slot].description,
                        textAlign: TextAlign.center)
                  ]))));
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

  Widget getPlayedCards() {
    return Row(
      children: [
        playedCard(playedCards.length > 0, 0),
        SizedBox(width: 10),
        playedCard(playedCards.length > 1, 1),
        SizedBox(width: 10),
        playedCard(playedCards.length > 2, 2)
      ],
    );
  }

  Widget playedCard(bool active, int slot) {
    if (active) {
      return Container(
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
                  child: Image.asset(playedCards[slot].imagePath))));
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

import 'package:flutter/material.dart';
import 'package:beezy/models/avatar.dart';

List<Widget> necessitiesImg = <Widget>[
  const Icon(Icons.cookie, color: Color.fromARGB(143, 20, 14, 5), size: 50),
  const Icon(Icons.soap, color: Color.fromARGB(143, 20, 14, 5), size: 40),
  const Icon(Icons.toys, color: Color.fromARGB(143, 20, 14, 5), size: 50),
  const Icon(Icons.bed, color: Color.fromARGB(143, 20, 14, 5), size: 50),
];

class AvatarScreen extends StatefulWidget {
  const AvatarScreen(
      {super.key, required this.avatar, required this.updatePoints});

  final Avatar avatar;
  final Function(int) updatePoints;

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  final List<bool> selectedNecessity = <bool>[true, false, false, false];
  int selectedButtonIndex = 0;
  List<double> fillAmount = <double>[0.1, 0.5, 0.5, 0.5];

  void selectButton(int index) {
    setState(() {
      selectedButtonIndex = index;
      for (int i = 0; i < selectedNecessity.length; i++) {
        selectedNecessity[i] = i == index;
      }
    });
  }

  void _deleteItem(String name) {
    if (selectedButtonIndex == 0) {
      for (Food foodItem in widget.avatar.foodList) {
        if (foodItem.name == name) {
          setState(() {
            if (foodItem.amount == 1) {
              widget.avatar.foodList
                  .removeWhere((element) => foodItem == element);
              return;
            }
            foodItem.amount--;
          });
          return;
        }
      }
    } else if (selectedButtonIndex == 1) {
      for (Hygiene hygieneItem in widget.avatar.hygieneList) {
        if (hygieneItem.name == name) {
          setState(() {
            if (hygieneItem.amount == 1) {
              widget.avatar.hygieneList
                  .removeWhere((element) => hygieneItem == element);
              return;
            }
            hygieneItem.amount--;
          });
          return;
        }
      }
    } else if (selectedButtonIndex == 2) {
      for (Toy toyItem in widget.avatar.toyList) {
        if (toyItem.name == name) {
          setState(() {
            if (toyItem.amount == 1) {
              widget.avatar.toyList
                  .removeWhere((element) => toyItem == element);
              return;
            }
            toyItem.amount--;
          });
          return;
        }
      }
    } else if (selectedButtonIndex == 3) {
      for (Sleep sleepItem in widget.avatar.sleepList) {
        if (sleepItem.name == name) {
          setState(() {
            if (sleepItem.amount == 1) {
              widget.avatar.sleepList
                  .removeWhere((element) => sleepItem == element);
              return;
            }
            sleepItem.amount--;
          });
          return;
        }
      }
    }
  }

  void _addFood(int id, int foodID, String name, String assetPath, int price,
      double fillAmount) {
    if (widget.updatePoints(-price)) {
      for (Food foodItem in widget.avatar.foodList) {
        if (foodItem.foodID == foodID) {
          setState(() {
            foodItem.amount++;
          });
          return;
        }
      }
      Food food = Food();
      food.id = id;
      food.foodID = foodID;
      food.name = name;
      food.amount = 1;
      food.fillAmount = fillAmount;
      food.assetPath = assetPath;
      setState(() {
        widget.avatar.foodList.add(food);
      });
    }
  }

  void _addHygiene(int id, int hygieneID, String name, String assetPath,
      int price, double fillAmount) {
    if (widget.updatePoints(-price)) {
      for (Hygiene hygieneItem in widget.avatar.hygieneList) {
        if (hygieneItem.hygieneID == hygieneID) {
          setState(() {
            hygieneItem.amount++;
          });
          return;
        }
      }
      Hygiene hygiene = Hygiene();
      hygiene.id = id;
      hygiene.hygieneID = hygieneID;
      hygiene.name = name;
      hygiene.amount = 1;
      hygiene.fillAmount = fillAmount;
      hygiene.assetPath = assetPath;
      setState(() {
        widget.avatar.hygieneList.add(hygiene);
      });
    }
  }

  void _addToy(int id, int toyID, String name, String assetPath, int price,
      double fillAmount) {
    if (widget.updatePoints(-price)) {
      for (Toy toyItem in widget.avatar.toyList) {
        if (toyItem.toyID == toyID) {
          setState(() {
            toyItem.amount++;
          });
          return;
        }
      }
      Toy toy = Toy();
      toy.id = id;
      toy.toyID = toyID;
      toy.name = name;
      toy.amount = 1;
      toy.fillAmount = fillAmount;
      toy.assetPath = assetPath;
      setState(() {
        widget.avatar.toyList.add(toy);
      });
    }
  }

  void _addSleep(int id, int sleepID, String name, String assetPath, int price,
      double fillAmount) {
    if (widget.updatePoints(-price)) {
      for (Sleep sleepItem in widget.avatar.sleepList) {
        if (sleepItem.sleepID == sleepID) {
          setState(() {
            sleepItem.amount++;
          });
          return;
        }
      }
      Sleep sleep = Sleep();
      sleep.id = id;
      sleep.sleepID = sleepID;
      sleep.name = name;
      sleep.amount = 1;
      sleep.fillAmount = fillAmount;
      sleep.assetPath = assetPath;
      setState(() {
        widget.avatar.sleepList.add(sleep);
      });
    }
  }

  Widget _getInventory(int spot) {
    if (selectedNecessity[0]) {
      if (widget.avatar.foodList.elementAtOrNull(spot) != null) {
        return _buildInventory(widget.avatar.foodList.elementAtOrNull(spot)!);
      }
    } else if (selectedNecessity[1]) {
      if (widget.avatar.hygieneList.elementAtOrNull(spot) != null) {
        return _buildInventory(
            widget.avatar.hygieneList.elementAtOrNull(spot)!);
      }
    } else if (selectedNecessity[2]) {
      if (widget.avatar.toyList.elementAtOrNull(spot) != null) {
        return _buildInventory(widget.avatar.toyList.elementAtOrNull(spot)!);
      }
    } else if (selectedNecessity[3]) {
      if (widget.avatar.sleepList.elementAtOrNull(spot) != null) {
        return _buildInventory(widget.avatar.sleepList.elementAtOrNull(spot)!);
      }
    }
    return Container();
  }

  Widget _buildInventory(Item item) {
    item.isRepresented = true;
    return Container(
        padding: const EdgeInsets.all(5),
        child: Stack(
          children: [
            Center(
                child: SizedBox(
                    width: 40,
                    height: 40,
                    child: FittedBox(
                        child: Draggable(
                            data: item,
                            dragAnchorStrategy: pointerDragAnchorStrategy,
                            feedback: SizedBox(
                                width: 40,
                                height: 40,
                                child: FittedBox(
                                    child: Image.asset(item.assetPath))),
                            child: Image.asset(item.assetPath))))),
            Positioned(bottom: 0, left: 0, child: Text('${item.amount}'))
          ],
        ));
  }

  Widget _getInventorySpot(int spot) {
    return Container(
        width: 75,
        height: 75,
        padding: const EdgeInsets.all(5),
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 223, 142),
                border: Border.all(
                    color: const Color.fromARGB(143, 20, 14, 5), width: 1),
                borderRadius: BorderRadius.circular(8)),
            child: _getInventory(spot)));
  }

  Widget _inventoryWidget() {
    return SizedBox(
        width: 638,
        height: 188,
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
                    child: Column(children: [
                      Row(children: [
                        _getInventorySpot(0),
                        _getInventorySpot(1),
                        _getInventorySpot(2),
                        _getInventorySpot(3),
                        _getInventorySpot(4),
                        _getInventorySpot(5),
                        _getInventorySpot(6),
                        _getInventorySpot(7)
                      ]),
                      Row(
                        children: [
                          _getInventorySpot(8),
                          _getInventorySpot(9),
                          _getInventorySpot(10),
                          _getInventorySpot(11),
                          _getInventorySpot(12),
                          _getInventorySpot(13),
                          _getInventorySpot(14),
                          _getInventorySpot(15)
                        ],
                      )
                    ]))),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 15,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 223, 142),
                border: Border(
                    left: BorderSide(
                        color: Color.fromARGB(143, 20, 14, 5), width: 4),
                    right: BorderSide(
                        color: Color.fromARGB(143, 20, 14, 5), width: 4),
                    bottom: BorderSide(
                        color: Color.fromARGB(143, 20, 14, 5), width: 4)),
              ),
            ),
          ),
        ]));
  }

  Widget _shopWidget() {
    return SizedBox(
        width: 190,
        height: 354,
        child: Stack(children: [
          Positioned.fill(
            child: Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 223, 142),
                    border: Border.all(
                        color: const Color.fromARGB(143, 20, 14, 5), width: 4),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                    child: Column(
                      children: [
                        Text('Shop',
                            style: Theme.of(context).textTheme.headlineSmall),
                        Row(
                            children: selectedNecessity[0]
                                ? _getFoodShop()
                                : selectedNecessity[1] ? _getHygieneShop() : selectedNecessity[2]
                                    ? _getToysShop()
                                    : selectedNecessity[3] ? _getSleepShop() : List.empty())
                      ],
                    ))),
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

  Widget _getFoodSpot(
      int foodID, String name, String assetPath, int price, double fillAmount) {
    return Container(
        width: 75,
        height: 75,
        padding: const EdgeInsets.all(5),
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 223, 142),
                border: Border.all(
                    color: const Color.fromARGB(143, 20, 14, 5), width: 1),
                borderRadius: BorderRadius.circular(8)),
            child: Stack(children: [
              Center(
                  child: SizedBox(
                      width: 60,
                      height: 60,
                      child: IconButton(
                        onPressed: () {
                          _addFood(widget.avatar.foodID, foodID, name,
                              assetPath, price, fillAmount);
                          widget.avatar.foodID++;
                        },
                        icon: Image(image: AssetImage(assetPath)),
                      ))),
              Positioned(top: 0, right: 2, child: Text(price.toString()))
            ])));
  }

  Widget _getHygieneSpot(int hygieneID, String name, String assetPath,
      int price, double fillAmount) {
    return Container(
        width: 75,
        height: 75,
        padding: const EdgeInsets.all(5),
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 223, 142),
                border: Border.all(
                    color: const Color.fromARGB(143, 20, 14, 5), width: 1),
                borderRadius: BorderRadius.circular(8)),
            child: Stack(children: [
              Center(
                  child: SizedBox(
                      width: 60,
                      height: 60,
                      child: IconButton(
                        onPressed: () {
                          _addHygiene(widget.avatar.hygieneID, hygieneID, name,
                              assetPath, price, fillAmount);
                          widget.avatar.hygieneID++;
                        },
                        icon: Image(image: AssetImage(assetPath)),
                      ))),
              Positioned(top: 0, right: 3, child: Text(price.toString()))
            ])));
  }

  Widget _getToySpot(int sleepID, String name, String assetPath, int price,
      double fillAmount) {
    return Container(
        width: 75,
        height: 75,
        padding: const EdgeInsets.all(5),
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 223, 142),
                border: Border.all(
                    color: const Color.fromARGB(143, 20, 14, 5), width: 1),
                borderRadius: BorderRadius.circular(8)),
            child: Stack(children: [
              Center(
                  child: SizedBox(
                      width: 60,
                      height: 60,
                      child: IconButton(
                        onPressed: () {
                          _addToy(widget.avatar.toyID, sleepID, name, assetPath,
                              price, fillAmount);
                          widget.avatar.toyID++;
                        },
                        icon: Image(image: AssetImage(assetPath)),
                      ))),
              Positioned(top: 0, right: 3, child: Text(price.toString()))
            ])));
  }

  Widget _getSleepSpot(int sleepID, String name, String assetPath, int price,
      double fillAmount) {
    return Container(
        width: 75,
        height: 75,
        padding: const EdgeInsets.all(5),
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 223, 142),
                border: Border.all(
                    color: const Color.fromARGB(143, 20, 14, 5), width: 1),
                borderRadius: BorderRadius.circular(8)),
            child: Stack(children: [
              Center(
                  child: SizedBox(
                      width: 60,
                      height: 60,
                      child: IconButton(
                        onPressed: () {
                          _addSleep(widget.avatar.sleepID, sleepID, name,
                              assetPath, price, fillAmount);
                          widget.avatar.sleepID++;
                        },
                        icon: Image(image: AssetImage(assetPath)),
                      ))),
              Positioned(top: 0, right: 3, child: Text(price.toString()))
            ])));
  }

  Widget _getEmptySpot() {
    return Container(
        width: 75,
        height: 75,
        padding: const EdgeInsets.all(5),
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 223, 142),
                border: Border.all(
                    color: const Color.fromARGB(143, 20, 14, 5), width: 1),
                borderRadius: BorderRadius.circular(8))));
  }

  List<Widget> _getFoodShop() {
    final List<Widget> foodWidgets = <Widget>[
      Column(children: [
        _getFoodSpot(1, 'Muffin', 'assets/food/muffin.png', 1, 0.1),
        _getFoodSpot(3, 'Soup', 'assets/food/soup.png', 4, 0.3),
        _getFoodSpot(5, 'Spaghetti', 'assets/food/spaghetti.png', 5, 0.5),
        _getFoodSpot(7, 'Pizza', 'assets/food/pizza.png', 7, 0.6),
      ]),
      Column(
        children: [
          _getFoodSpot(2, 'Donut', 'assets/food/donut.png', 2, 0.2),
          _getFoodSpot(4, 'Salad', 'assets/food/salad.png', 4, 0.3),
          _getFoodSpot(6, 'Burger', 'assets/food/burger.png', 5, 0.5),
          _getFoodSpot(8, 'Sushi', 'assets/food/sushi.png', 8, 0.7),
        ],
      )
    ];
    return foodWidgets;
  }

List<Widget> _getHygieneShop() {
    final List<Widget> hygieneWidgets = <Widget>[
      Column(children: [
        _getHygieneSpot(1, 'Soap', 'assets/hygiene/soap.png', 3, 0.1),
        _getHygieneSpot(3, 'Toothbrush', 'assets/hygiene/toothbrush.png', 7, 0.4),
        _getEmptySpot(),
        _getEmptySpot()
      ]),
      Column(
        children: [
          _getHygieneSpot(2, 'Shampoo', 'assets/hygiene/shampoo.png', 5, 0.3),
          _getHygieneSpot(4, 'Shower', 'assets/hygiene/shower.png', 8, 0.5),
          _getEmptySpot(),
          _getEmptySpot()
        ],
      )
    ];
    return hygieneWidgets;
  }

  List<Widget> _getToysShop() {
    final List<Widget> toysWidgets = <Widget>[
      Column(children: [
        _getToySpot(1, 'Ball', 'assets/toys/ball.png', 3, 0.1),
        _getToySpot(3, 'Horse', 'assets/toys/horse.png', 7, 0.4),
        _getToySpot(5, 'Car', 'assets/toys/car.png', 8, 0.5),
        _getToySpot(7, 'Blocks', 'assets/toys/blocks.png', 10, 0.7)
      ]),
      Column(
        children: [
          _getToySpot(2, 'Doll', 'assets/toys/doll.png', 6, 0.3),
          _getToySpot(4, 'Bear', 'assets/toys/bear.png', 8, 0.5),
          _getToySpot(6, 'Puzzle', 'assets/toys/puzzle.png', 9, 0.6),
          _getToySpot(8, 'Dino', 'assets/toys/dino.png', 15, 0.8)
        ],
      )
    ];
    return toysWidgets;
  }

List<Widget> _getSleepShop() {
    final List<Widget> sleepWidgets = <Widget>[
      Column(children: [
        _getSleepSpot(1, 'Tea', 'assets/sleep/tea.png', 6, 0.2),
        _getSleepSpot(3, 'Sleep', 'assets/sleep/sleep.png', 14, 0.7),
        _getEmptySpot(),
        _getEmptySpot()
      ]),
      Column(
        children: [
          _getSleepSpot(2, 'Pills', 'assets/sleep/pills.png', 9, 0.4),
          _getEmptySpot(),
          _getEmptySpot(),
          _getEmptySpot()
        ],
      )
    ];
    return sleepWidgets;
  }

  Widget _necessitiesWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: IntrinsicWidth(
                child: Stack(children: [
              SizedBox(
                  height: 65,
                  child: Row(children: [
                    const SizedBox(width: 50),
                    SizedBox(
                        width: 150.0,
                        height: 40.0,
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: const Color.fromARGB(255, 255, 223, 142),
                                border: Border.all(
                                    width: 4,
                                    color:
                                        const Color.fromARGB(143, 20, 14, 5))),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: fillAmount[index],
                                child: Container(
                                  color:
                                      const Color.fromARGB(255, 230, 146, 38),
                                ),
                              ),
                            )))
                  ])),
              Positioned(
                left: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () => selectButton(index),
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                        color: selectedButtonIndex == index
                            ? const Color.fromARGB(255, 230, 146, 38)
                            : const Color.fromARGB(255, 255, 223, 142),
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 4,
                            color: const Color.fromARGB(143, 20, 14, 5))),
                    child: Center(child: necessitiesImg[index]),
                  ),
                ),
              )
            ])));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: _necessitiesWidget()),
          const Spacer(),
          Expanded(
              child: DragTarget<Item>(onAccept: (item) {
            setState(() {
              _deleteItem(item.name);
              if (fillAmount[selectedButtonIndex] < 1) {
                fillAmount[selectedButtonIndex] =
                    fillAmount[selectedButtonIndex] + item.fillAmount;
                if (fillAmount[selectedButtonIndex] >= 1) {
                  fillAmount[selectedButtonIndex] = 1;
                }
              }
            });
          }, builder:
                  (context, List<dynamic> accepted, List<dynamic> rejected) {
            return SizedBox(
                height: 400,
                width: 300,
                child:
                    FittedBox(child: Image.asset('assets/bee_avatar_1.png')));
          })),
          const Spacer(),
          _shopWidget(),
        ],
      )),
      _inventoryWidget()
    ]));
  }
}

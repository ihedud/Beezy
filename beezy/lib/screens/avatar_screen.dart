import 'package:flutter/material.dart';
import 'package:beezy/models/avatar.dart';

List<Widget> necessitiesImg = <Widget>[
  Container(
      width: 75,
      height: 75,
      padding: const EdgeInsets.all(5),
      child: const Image(image: AssetImage('assets/necessities/hunger.png'))),
  Container(
      width: 75,
      height: 75,
      padding: const EdgeInsets.all(5),
      child: const Image(image: AssetImage('assets/necessities/hygiene.png'))),
  Container(
      width: 75,
      height: 75,
      padding: const EdgeInsets.all(5),
      child: const Image(
          image: AssetImage('assets/necessities/entertainment.png'))),
  Container(
      width: 75,
      height: 75,
      padding: const EdgeInsets.all(5),
      child: const Image(image: AssetImage('assets/necessities/sleep.png'))),
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

  void _addFood(int id, int foodID, String name, String assetPath, int price,
      double fillAmount) {
    widget.updatePoints(-price);
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

  void _deleteFood(String name) {
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
  }

  void _addToy(int id, int toyID, String name, String assetPath, int price) {
    widget.updatePoints(-price);
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
    toy.assetPath = assetPath;
    setState(() {
      widget.avatar.toyList.add(toy);
    });
  }

  Widget _getInventory(int spot) {
    if (selectedNecessity[0]) {
      if (widget.avatar.foodList.elementAtOrNull(spot) != null) {
        return _buildInventory(widget.avatar.foodList.elementAtOrNull(spot)!);
      }
    } else if (selectedNecessity[2]) {
      if (widget.avatar.toyList.elementAtOrNull(spot) != null) {
        return _buildInventory(widget.avatar.toyList.elementAtOrNull(spot)!);
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
            SizedBox(
                width: 65,
                height: 65,
                child: FittedBox(
                    child: Draggable(
                        data: item,
                        dragAnchorStrategy: pointerDragAnchorStrategy,
                        feedback: SizedBox(
                            width: 65,
                            height: 65,
                            child:
                                FittedBox(child: Image.asset(item.assetPath))),
                        child: Image.asset(item.assetPath)))),
            SizedBox(
                width: 20,
                height: 20,
                child: DecoratedBox(
                    decoration: const BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.all(Radius.circular(7))),
                    child: Center(child: Text('${item.amount}'))))
          ],
        ));
  }

  Widget _inventoryWidget() {
    return SizedBox(
        width: 610,
        height: 160,
        child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.amber),
            child: Container(
                padding: const EdgeInsets.all(5),
                child: Column(children: [
                  Row(children: [
                    Container(
                        width: 75,
                        height: 75,
                        padding: const EdgeInsets.all(5),
                        child: DecoratedBox(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(220, 245, 216, 157)),
                            child: _getInventory(0))),
                    Container(
                        width: 75,
                        height: 75,
                        padding: const EdgeInsets.all(5),
                        child: DecoratedBox(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(220, 245, 216, 157)),
                            child: _getInventory(1))),
                    Container(
                        width: 75,
                        height: 75,
                        padding: const EdgeInsets.all(5),
                        child: DecoratedBox(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(220, 245, 216, 157)),
                            child: _getInventory(2))),
                    Container(
                        width: 75,
                        height: 75,
                        padding: const EdgeInsets.all(5),
                        child: DecoratedBox(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(220, 245, 216, 157)),
                            child: _getInventory(3))),
                    Container(
                        width: 75,
                        height: 75,
                        padding: const EdgeInsets.all(5),
                        child: DecoratedBox(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(220, 245, 216, 157)),
                            child: _getInventory(4))),
                    Container(
                        width: 75,
                        height: 75,
                        padding: const EdgeInsets.all(5),
                        child: DecoratedBox(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(220, 245, 216, 157)),
                            child: _getInventory(5))),
                    Container(
                        width: 75,
                        height: 75,
                        padding: const EdgeInsets.all(5),
                        child: DecoratedBox(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(220, 245, 216, 157)),
                            child: _getInventory(6))),
                    Container(
                        width: 75,
                        height: 75,
                        padding: const EdgeInsets.all(5),
                        child: DecoratedBox(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(220, 245, 216, 157)),
                            child: _getInventory(7))),
                  ]),
                  Row(
                    children: [
                      Container(
                          width: 75,
                          height: 75,
                          padding: const EdgeInsets.all(5),
                          child: DecoratedBox(
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(220, 245, 216, 157)),
                              child: _getInventory(8))),
                      Container(
                          width: 75,
                          height: 75,
                          padding: const EdgeInsets.all(5),
                          child: DecoratedBox(
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(220, 245, 216, 157)),
                              child: _getInventory(9))),
                      Container(
                          width: 75,
                          height: 75,
                          padding: const EdgeInsets.all(5),
                          child: DecoratedBox(
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(220, 245, 216, 157)),
                              child: _getInventory(10))),
                      Container(
                          width: 75,
                          height: 75,
                          padding: const EdgeInsets.all(5),
                          child: DecoratedBox(
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(220, 245, 216, 157)),
                              child: _getInventory(11))),
                      Container(
                          width: 75,
                          height: 75,
                          padding: const EdgeInsets.all(5),
                          child: DecoratedBox(
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(220, 245, 216, 157)),
                              child: _getInventory(12))),
                      Container(
                          width: 75,
                          height: 75,
                          padding: const EdgeInsets.all(5),
                          child: DecoratedBox(
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(220, 245, 216, 157)),
                              child: _getInventory(13))),
                      Container(
                          width: 75,
                          height: 75,
                          padding: const EdgeInsets.all(5),
                          child: DecoratedBox(
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(220, 245, 216, 157)),
                              child: _getInventory(14))),
                      Container(
                          width: 75,
                          height: 75,
                          padding: const EdgeInsets.all(5),
                          child: DecoratedBox(
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(220, 245, 216, 157)),
                              child: _getInventory(15))),
                    ],
                  )
                ]))));
  }

  Widget _shopWidget() {
    return SizedBox(
        width: 160,
        height: 475,
        child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.amber),
            child: Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    Text('Shop',
                        style: Theme.of(context).textTheme.headlineMedium),
                    Row(
                        children: selectedNecessity[0]
                            ? _getFoodShop()
                            : selectedNecessity[2]
                                ? _getToysShop()
                                : List.empty())
                  ],
                ))));
  }

  List<Widget> _getFoodShop() {
    final List<Widget> foodWidgets = <Widget>[
      Column(children: [
        Container(
            width: 75,
            height: 85,
            padding: const EdgeInsets.all(5),
            child: DecoratedBox(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(220, 245, 216, 157)),
                child: Column(
                  children: [
                    SizedBox(
                        width: 55,
                        height: 55,
                        child: IconButton(
                          onPressed: () {
                            _addFood(widget.avatar.foodID, 1, 'Muffin',
                                'assets/food/muffin.png', 1, 0.1);
                            widget.avatar.foodID++;
                          },
                          icon: const Image(
                              image: AssetImage('assets/food/muffin.png')),
                        )),
                    const Text('Price: 1')
                  ],
                ))),
        Container(
            width: 75,
            height: 85,
            padding: const EdgeInsets.all(5),
            child: DecoratedBox(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(220, 245, 216, 157)),
                child: Column(
                  children: [
                    SizedBox(
                        width: 55,
                        height: 55,
                        child: IconButton(
                          onPressed: () {
                            _addFood(widget.avatar.foodID, 3, 'Soup',
                                'assets/food/soup.png', 4, 0.3);
                            widget.avatar.foodID++;
                          },
                          icon: const Image(
                              image: AssetImage('assets/food/soup.png')),
                        )),
                    const Text('Price: 4')
                  ],
                ))),
        Container(
            width: 75,
            height: 85,
            padding: const EdgeInsets.all(5),
            child: DecoratedBox(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(220, 245, 216, 157)),
                child: Column(
                  children: [
                    SizedBox(
                        width: 55,
                        height: 55,
                        child: IconButton(
                          onPressed: () {
                            _addFood(widget.avatar.foodID, 5, 'Spaghetti',
                                'assets/food/spaghetti.png', 5, 0.5);
                            widget.avatar.foodID++;
                          },
                          icon: const Image(
                              image: AssetImage('assets/food/spaghetti.png')),
                        )),
                    const Text('Price: 5')
                  ],
                ))),
        Container(
            width: 75,
            height: 85,
            padding: const EdgeInsets.all(5),
            child: const DecoratedBox(
              decoration:
                  BoxDecoration(color: Color.fromARGB(220, 245, 216, 157)),
            )),
        Container(
            width: 75,
            height: 85,
            padding: const EdgeInsets.all(5),
            child: const DecoratedBox(
              decoration:
                  BoxDecoration(color: Color.fromARGB(220, 245, 216, 157)),
            )),
      ]),
      Column(
        children: [
          Container(
              width: 75,
              height: 85,
              padding: const EdgeInsets.all(5),
              child: DecoratedBox(
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(220, 245, 216, 157)),
                  child: Column(
                    children: [
                      SizedBox(
                          width: 55,
                          height: 55,
                          child: IconButton(
                            onPressed: () {
                              _addFood(widget.avatar.foodID, 2, 'Donut',
                                  'assets/food/donut.png', 2, 0.2);
                              widget.avatar.foodID++;
                            },
                            icon: const Image(
                                image: AssetImage('assets/food/donut.png')),
                          )),
                      const Text('Price: 2')
                    ],
                  ))),
          Container(
              width: 75,
              height: 85,
              padding: const EdgeInsets.all(5),
              child: DecoratedBox(
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(220, 245, 216, 157)),
                  child: Column(
                    children: [
                      SizedBox(
                          width: 55,
                          height: 55,
                          child: IconButton(
                            onPressed: () {
                              _addFood(widget.avatar.foodID, 4, 'Salad',
                                  'assets/food/salad.png', 4, 0.3);
                              widget.avatar.foodID++;
                            },
                            icon: const Image(
                                image: AssetImage('assets/food/salad.png')),
                          )),
                      const Text('Price: 4')
                    ],
                  ))),
          Container(
              width: 75,
              height: 85,
              padding: const EdgeInsets.all(5),
              child: const DecoratedBox(
                decoration:
                    BoxDecoration(color: Color.fromARGB(220, 245, 216, 157)),
              )),
          Container(
              width: 75,
              height: 85,
              padding: const EdgeInsets.all(5),
              child: const DecoratedBox(
                decoration:
                    BoxDecoration(color: Color.fromARGB(220, 245, 216, 157)),
              )),
          Container(
              width: 75,
              height: 85,
              padding: const EdgeInsets.all(5),
              child: const DecoratedBox(
                decoration:
                    BoxDecoration(color: Color.fromARGB(220, 245, 216, 157)),
              )),
        ],
      )
    ];
    return foodWidgets;
  }

  List<Widget> _getToysShop() {
    final List<Widget> toysWidgets = <Widget>[
      Column(children: [
        Container(
            width: 75,
            height: 85,
            padding: const EdgeInsets.all(5),
            child: DecoratedBox(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(220, 245, 216, 157)),
                child: Column(
                  children: [
                    SizedBox(
                        width: 55,
                        height: 55,
                        child: IconButton(
                          onPressed: () {
                            _addToy(widget.avatar.toyID, 1, 'Ball',
                                'assets/toys/ball.png', 3);
                            widget.avatar.toyID++;
                          },
                          icon: const Image(
                              image: AssetImage('assets/toys/ball.png')),
                        )),
                    const Text('Price: 3')
                  ],
                ))),
        Container(
            width: 75,
            height: 85,
            padding: const EdgeInsets.all(5),
            child: DecoratedBox(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(220, 245, 216, 157)),
                child: Column(
                  children: [
                    SizedBox(
                        width: 55,
                        height: 55,
                        child: IconButton(
                          onPressed: () {
                            _addToy(widget.avatar.toyID, 3, 'Horse',
                                'assets/toys/horse.png', 8);
                            widget.avatar.toyID++;
                          },
                          icon: const Image(
                              image: AssetImage('assets/toys/horse.png')),
                        )),
                    const Text('Price: 8')
                  ],
                ))),
        Container(
            width: 75,
            height: 85,
            padding: const EdgeInsets.all(5),
            child: const DecoratedBox(
              decoration:
                  BoxDecoration(color: Color.fromARGB(220, 245, 216, 157)),
            )),
        Container(
            width: 75,
            height: 85,
            padding: const EdgeInsets.all(5),
            child: const DecoratedBox(
              decoration:
                  BoxDecoration(color: Color.fromARGB(220, 245, 216, 157)),
            )),
        Container(
            width: 75,
            height: 85,
            padding: const EdgeInsets.all(5),
            child: const DecoratedBox(
              decoration:
                  BoxDecoration(color: Color.fromARGB(220, 245, 216, 157)),
            )),
      ]),
      Column(
        children: [
          Container(
              width: 75,
              height: 85,
              padding: const EdgeInsets.all(5),
              child: DecoratedBox(
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(220, 245, 216, 157)),
                  child: Column(
                    children: [
                      SizedBox(
                          width: 55,
                          height: 55,
                          child: IconButton(
                            onPressed: () {
                              _addToy(widget.avatar.toyID, 2, 'Doll',
                                  'assets/toys/doll.png', 6);
                              widget.avatar.toyID++;
                            },
                            icon: const Image(
                                image: AssetImage('assets/toys/doll.png')),
                          )),
                      const Text('Price: 6')
                    ],
                  ))),
          Container(
              width: 75,
              height: 85,
              padding: const EdgeInsets.all(5),
              child: const DecoratedBox(
                decoration:
                    BoxDecoration(color: Color.fromARGB(220, 245, 216, 157)),
              )),
          Container(
              width: 75,
              height: 85,
              padding: const EdgeInsets.all(5),
              child: const DecoratedBox(
                decoration:
                    BoxDecoration(color: Color.fromARGB(220, 245, 216, 157)),
              )),
          Container(
              width: 75,
              height: 85,
              padding: const EdgeInsets.all(5),
              child: const DecoratedBox(
                decoration:
                    BoxDecoration(color: Color.fromARGB(220, 245, 216, 157)),
              )),
          Container(
              width: 75,
              height: 85,
              padding: const EdgeInsets.all(5),
              child: const DecoratedBox(
                decoration:
                    BoxDecoration(color: Color.fromARGB(220, 245, 216, 157)),
              )),
        ],
      )
    ];
    return toysWidgets;
  }

  Widget _necessitiesWidget() {
    return
        // SizedBox(
        //     width: 80,
        //     height: 310,
        //     child: ToggleButtons(
        //         direction: Axis.vertical,
        //         onPressed: (int index) {
        //           setState(() {
        //             for (int i = 0; i < selectedNecessity.length; i++) {
        //               selectedNecessity[i] = i == index;
        //             }
        //           });
        //         },
        //         selectedBorderColor: Colors.amber[700],
        //         //selectedColor: Colors.amber[100],
        //         fillColor: Colors.amber[200],
        //         //color: Colors.amber[400],
        //         isSelected: selectedNecessity,
        //         children: necessitiesImg));

        Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: IntrinsicWidth(
                child: Row(children: [
              GestureDetector(
                onTap: () => selectButton(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: selectedButtonIndex == index ? 100 : 80,
                  height: selectedButtonIndex == index ? 100 : 80,
                  decoration: BoxDecoration(
                    color: selectedButtonIndex == index
                        ? Colors.amber
                        : const Color.fromARGB(220, 245, 216, 157),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(child: necessitiesImg[index]),
                ),
              ),
              SizedBox(
                  width: 150.0,
                  height: 40.0,
                  child: Container(
                      color: Colors.grey,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: fillAmount[index],
                          child: Container(
                            color: Colors.amber,
                          ),
                        ),
                      )))
            ])));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //SizedBox(width: 100),
          Expanded(child: _necessitiesWidget()),
          const Spacer(),
          DragTarget<Item>(onAccept: (item) {
            setState(() {
              _deleteFood(item.name);
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
          }),
          const Spacer(),
          _shopWidget(),
          const Spacer()
        ],
      ),
      _inventoryWidget()
    ]));
  }
}

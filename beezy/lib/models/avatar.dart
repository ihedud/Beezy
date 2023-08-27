class Avatar {
  //String name = '';
  int satisfactionLevel = 100;
  List<Food> foodList = <Food>[];
  List<Toy> toyList = <Toy>[];
  int foodID = 0;
  int toyID = 0;
}

class Item {
  int id = 0;
  int amount = 0;
  double fillAmount = 1;
  String name = '';
  String assetPath = '';
  bool isRepresented = false;
}

class Food extends Item {
  int foodID = 0;
}

class Toy extends Item {
  int toyID = 0;
}

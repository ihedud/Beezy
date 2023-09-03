class Avatar {
  int satisfactionLevel = 100;
  List<Food> foodList = <Food>[];
  List<Hygiene> hygieneList = <Hygiene>[];
  List<Toy> toyList = <Toy>[];
  List<Sleep> sleepList = <Sleep>[];
  int foodID = 0;
  int hygieneID = 0;
  int toyID = 0;
  int sleepID = 0;
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

class Hygiene extends Item {
  int hygieneID = 0;
}

class Toy extends Item {
  int toyID = 0;
}

class Sleep extends Item {
  int sleepID = 0;
}
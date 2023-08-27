class HoneyProfile {
  String name = '';
  String avatarTypePath = '';
  int lifes = 3;

  HoneyProfile({required this.name, required this.avatarTypePath, required this.lifes});
}

class HoneyState {
  bool daytime = true;
  int honey = 0;
  List<String> narrative = ['story 1', 'story 2', 'story 3', 'story 4', 'story 5'];
}

class HoneyCard {
  String imagePath = '';
  String description = '';
  int price = 0;
  void Function() effect;

  HoneyCard({required this.imagePath, required this.description, required this.price, required this.effect});
}
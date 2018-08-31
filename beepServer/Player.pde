class Player {
  String ip;
  int money;
  boolean selected, ready;
  int team, number;
  
  Player(String ip, int money, boolean selected, int team, int number) {
    this.ip = ip;
    this.money = money;
    this.selected = selected;
    this.team = team;
    this.number = number;
  }
}

import processing.net.*;

Server server;
Config config;

HashMap<String, Player> players;
//HashMap<String, String> clients;
Player[][] teams;

void setup() {
  size(175, 1);
  
  config = new Config("config.txt");

  server = new Server(this, config.port);
  println(server.ip(), config.port);

  reset();
}

void reset() {
  players = new HashMap<String, Player>();
  //clients = new HashMap<String, String>();
  teams = new Player[config.teamCount][config.playersPerTeam];
}

void draw() {
  Client client = server.available();

  if (client != null) {
    String input = client.readString();

    for (String message : input.split("\n")) {
      try {
        computeMessage(message, client);
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  }
}

void computeMessage(String input, Client client) {
  println("in>"+input);
  
  String[] inputSplitted = input.split("~");
  String id = inputSplitted[0];
  if (inputSplitted.length > 1) {
    input = inputSplitted[1];
    println("Message " + input + " received from " + id);
  }
  
  if (input.startsWith("join")) {
    broadcastTeams();
    
    players.put(id, new Player(id, config.money, false, -1, -1));
    //clients.put(client.ip(), id);
  }
  
  if (input.startsWith("disconnect")) {
    disconnect(id);
    
    broadcastTeams();
  }

  if (input.startsWith("team")) {
    if (serverFull()) {
    }

    input = input.substring(4);
    int team = Integer.parseInt(input);
    int count = countTeam(team);

    Player player = players.get(id);
    
    if (count < config.playersPerTeam) {
      if (player.team != -1 && player.number != -1) {
        int oldTeamCount = countTeam(player.team);
  
        if (oldTeamCount-1 > player.number) {
          teams[player.team][player.number] = teams[player.team][oldTeamCount-1];
        }
        teams[player.team][oldTeamCount-1] = null;
      }
  
      player.team = team;
      player.number = count;
      
      teams[team][count] = player;

      broadcastTeams();
    }

    if (serverFull()) { 
      long seed = (long)random(Long.MAX_VALUE);
      config = new Config("config.txt");
      String[] serializedConfig = config.serialize();
      write("config" + join(serializedConfig, ";"));

      write("seed" + seed);

      for (Player target : players.values()) {
        broadcastTeams();

        write(target.ip + "~yourteam" + target.team + ";" + target.number);

        target.selected = false;
      }
    }
  }

  if (input.startsWith("reset")) {
    write("reset");

    reset();
  }

  if (input.startsWith("spawnat")) {
    write(input);
  }

  if (input.startsWith("fireat")) {
    input = input.substring(6);
    String[] inputs = input.split(";");

    /*int type = Integer.parseInt(inputs[4]);

    int team = Integer.parseInt(inputs[2]);
    int number = Integer.parseInt(inputs[3]);*/
    //Player player = teams[team][number];

    //float price = ((type+1)*config.priceFactor);

    //if (player.money >= price) { 
      //player.money -= price;
      write("fireat"+input);
    //}
  }
  
  if (input.startsWith("won")) {
    input = input.substring(3);
    
    //int team = Integer.parseInt(input);
  }
  
  if (input.startsWith("done")) {
    write(input);

    input = input.substring(4);

    Player player = getPlayer(input);
    player.selected = true;

    if (serverDone()) {
      for (Player target : players.values()) {
        target.selected = false;
      }

      write("startfire");
    }
  }

  if (input.startsWith("ready")) {
    input = input.substring(5);
    
    Player player = getPlayer(input);
    
    if (player == null) return;
    
    player.ready = true;

    if (serverReady()) {
      for (Player target : players.values()) {
        target.ready = false;
      }

      write("startnext");
    }
  }
}

int countTeam(int team) {
  int size = 0;

  for (int j = 0; j < config.playersPerTeam; j++) {
    if (teams[team][j] != null) {
      size++;
    } else {
      break;
    }
  }

  return size;
}

int[] countPlayers() {
  int[] playerCount = new int[config.teamCount];

  for (int i = 0; i < config.teamCount; i++) {
    playerCount[i] = countTeam(i);
  }

  return playerCount;
}

boolean serverFull() {
  for (int i = 0; i < config.teamCount; i++) {
    if (countTeam(i) < config.playersPerTeam) {
      return false;
    }
  }

  return true;
}

boolean serverDone() {
  for (int i = 0; i < config.teamCount; i++) {
    for (int j = 0; j < config.playersPerTeam; j++) {
      if (!teams[i][j].selected) return false;
    }
  }
  
  for (int i = 0; i < config.teamCount; i++) {
    for (int j = 0; j < config.playersPerTeam; j++) {
      teams[i][j].selected = false;
    }
  }

  return true;
}

boolean serverReady() {
  for (int i = 0; i < config.teamCount; i++) {
    for (int j = 0; j < config.playersPerTeam; j++) {
      if (!teams[i][j].ready) return false;
    }
  }
  
  for (int i = 0; i < config.teamCount; i++) {
    for (int j = 0; j < config.playersPerTeam; j++) {
      teams[i][j].ready = false;
    }
  }

  return true;
}

void broadcastTeams() {
  String teamList = "";
  int[] playerCount = countPlayers();

  for (int i = 0; i < config.teamCount; i++) {
    teamList += playerCount[i] + ";";
  }

  write("teams"+teamList+config.playersPerTeam);
}

void write(String text) {
  println("out<"+text);
  server.write(text+"\n");
}

enum State {
  CONNECTING (-1), 
    JOINING (0), 
    SPAWNING  (1), 
    GAME (2), 
    PAUSE (3), 
    FINISH (4), 
    END (5);

  private int valuePrivate;

  private State(int valuePrivate) {
    this.valuePrivate = valuePrivate;
  }

  public int value() { 
    return valuePrivate;
  }
}

Player getPlayer(String coded) {
  String[] contents = coded.split(";");

  int team = Integer.parseInt(contents[0]);
  int number = Integer.parseInt(contents[1]);
  return teams[team][number];
}

void disconnect(String id) {
  Player player = players.get(id);
  
  int oldTeamCount = countTeam(player.team);

  if (oldTeamCount-1 > player.number) {
    teams[player.team][player.number] = teams[player.team][oldTeamCount-1];
  }
  
  teams[player.team][oldTeamCount-1] = null;
  
  broadcastTeams();
}

//void disconnectEvent(Client client) {
//  disconnect(clients.get(client.ip()));
//}

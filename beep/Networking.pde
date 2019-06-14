void computeMessage(String input) {
  println(input);
  
  String[] inputSplitted = input.split("~");
  String idSender = inputSplitted[0];
  if (inputSplitted.length > 1) {
    input = inputSplitted[1];
    println("Message " + input + " received from " + idSender);
  }
  
  if (input.startsWith("teams")) {
    input = input.substring(5);
    
    String[] teamList = input.split(";");
    config.teamCount = teamList.length-1;
    config.playersPerTeam = Integer.parseInt(teamList[config.teamCount]);
    teamCount = new int[config.teamCount];
    
    for (int i = 0; i < config.teamCount; i++) {
      teamCount[i] = Integer.parseInt(teamList[i]);
    }
    
    if (state == State.CONNECTING) state = State.JOINING;
  }
  
  
  if (input.startsWith("yourteam")) {
    input = input.substring(8);
    
    String[] contents = input.split(";");
    
    if (id.trim().equals(idSender.trim())) {
      int team = Integer.parseInt(contents[0]);
      int number = Integer.parseInt(contents[1]);
      
      mePlayer = players[team][number];
    }
  }
    
    
  if (input.startsWith("config")) {
    input = input.substring(6);
    
    //try {
      String[] serverConfig = input.split(";");
      config.deserialize(serverConfig);
      saveStrings("data/server-config.txt", serverConfig);
      
      neutral = color(config.neutral);
      
      players = new Player[config.teamCount][config.playersPerTeam];
      
      for (int i = 0; i < config.teamCount; i++) {
        for (int j = 0; j < config.playersPerTeam; j++) {
          Player player = new Player(width/2, -100, teamColor(i));
          
          player.team = i;
          player.number = j;
          
          players[i][j] = player;
        }
      }
    //} catch (Exception e) {
    //  e.printStackTrace();
    //  println("Error retrieving config file  ");
    //}
  }
  
  
  if (input.startsWith("fireat")) {
    input = input.substring(6);
    String[] inputs = input.split(";");

    float xp = Float.parseFloat(inputs[0]);
    float yp = Float.parseFloat(inputs[1]);
    
    int team = Integer.parseInt(inputs[2]);
    int number = Integer.parseInt(inputs[3]);
    Player player = players[team][number];
    
    int type = Integer.parseInt(inputs[4]);
    
    player.shots.add(new Shot(player.xp, player.yp, xp, yp, type));
    if (player != mePlayer) player.money -= (int)((type+1)*config.priceFactor*dist(xp, yp, 0, 0));
  }
  
  
  if (input.startsWith("spawnat")) {
    input = input.substring(7);
    String[] inputs = input.split(";");

    float xp = Float.parseFloat(inputs[0]);
    float yp = Float.parseFloat(inputs[1]);
    
    int team = Integer.parseInt(inputs[2]);
    int number = Integer.parseInt(inputs[3]);
    Player player = players[team][number];
    
    player.xp = xp;
    player.yp = yp;
  }
  
  
  if (input.contains("start")) {
    if (input.contains("fire")) {
      for (int i = 0; i < config.teamCount; i++) {
        for (int j = 0; j < config.playersPerTeam; j++) {
          Player player = players[i][j];
          
          player.fire();
          player.money += player.eco;
          player.done = false;
        }
      }

      state = State.PAUSE;
    } else if (input.contains("next")) {
      state = State.GAME;
      
      int teamsAlive = 0;
      int livingTeam = 0;
      
      for (int i = 0; i < config.teamCount; i++) {
        for (int j = 0; j < config.playersPerTeam; j++) {
          Player player = players[i][j];
          
          if (player.alive) {
            teamsAlive++; 
            livingTeam = i;
            break; 
          }
        }
      }
      
      if (teamsAlive <= 1) {
        state = State.END;
        winner = teamsAlive == 0 ? -1 : livingTeam;
        client.write("won"+winner);
      }
    }

    entered = false;
  }


  if (input.startsWith("seed")) {
    String seed = input.substring(4);
    long seedValue = Long.parseLong(seed);
    randomSeed(seedValue);
    noiseSeed(seedValue);

    genMap();
    state = State.SPAWNING;
  }
  
  
  if (input.startsWith("reset")) {
    reset();
  }
  
  
  if (input.startsWith("done"))  {
    if (state == State.GAME) {
      input = input.substring(4);
      String[] contents = input.split(";");
      
      int team = Integer.parseInt(contents[0]);
      int number = Integer.parseInt(contents[1]);
      
      players[team][number].done = true;
    }
  }
}

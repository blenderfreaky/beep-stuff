import processing.net.*;
import java.util.UUID;
 
PImage map;
ArrayList<Boom> booms;
float xs, ys;
color neutral;
Player[][] players;
Player mePlayer;
Client client;
int player;
State state = State.CONNECTING;
int winner;

boolean entered = false, isHost = true;
Config config;

int[] teamCount;

String id;

void setup() {
  size(1280, 720);

  config = new Config("config.txt");
  
  id = UUID.randomUUID().toString();

  reset();
}

void reset() {
  config = new Config("config.txt");

  textFont(loadFont(config.font));

  client = new Client(this, config.ip, config.port);
  client.write(id + "~join");

  booms = new ArrayList<Boom>();
  state = State.CONNECTING;
}

void draw() {
  //mouseX = min(width, max(0, mouseX));
  //mouseY = min(height, max(0, mouseY));
  
  if (!client.active()) {
    info("Couldn't reach\nserver\nReconnecting..", color(255, 0, 0), true);
    
    client = new Client(this, config.ip, config.port);
  client.write(id + "~join");

    return;
  }

  if (client.available() > 0) { 
    String input = client.readString(); 

    for (String message : input.split("\n")) {
      //try {
      computeMessage(message);
      //} catch (Exception e) {
      //e.printStackTrace();
      //}
    }
  }

  if (state == State.CONNECTING) {
    info("Waiting for\nserver response", color(255), true);
  }

  if (state == State.JOINING) {
    background(0, 0, 35);

    if (teamCount != null) {
      float xSlice = width/config.teamCount;
      float off;

      noStroke();
      textSize(40);
      textAlign(CENTER, CENTER);

      for (int i = 0; i < config.teamCount; i++) {
        boolean mouseOver = mouseX > xSlice*i && mouseY > 0 && mouseX < xSlice*(i+1) && mouseY < height;

        fill(lerpColor(teamColor(i), color(0), mePlayer != null && mePlayer.team == i ? 0.5 : (mouseOver ? 0.2 : 0)));
        off = mouseOver ? 50 : 100;
        rect(xSlice*i+off, off, xSlice - off*2, height - off*2);

        fill(0, 0, 35);
        text(teamCount[i] + " : " + config.playersPerTeam, xSlice*(i+0.5), height/2);
      }
    }
  }

  if (state.value() > State.JOINING.value()) {
    background(0, 0, 35);
    image(map, 0, 0);
  }

  if (state == State.SPAWNING) {
    if (mePlayer != null) {
      for (int i = 0; i < config.teamCount; i++) {
        for (int j = 0; j < config.playersPerTeam; j++) {
          players[i][j].draw();
        }
      }
    }
  }
  
  if (state == State.GAME || state == State.PAUSE || state == State.END) {
    if (state == State.GAME && mePlayer.alive) {
      stroke(255);
      parabola(mePlayer.xp, mePlayer.yp, (mouseX-mePlayer.xp)*config.inputScale, (mouseY-mePlayer.yp)*config.inputScale, 0, mePlayer.me);
      stroke(lerpColor(mePlayer.me, color(0), 0.5));
      parabola(mePlayer.xp, mePlayer.yp, (mouseX-mePlayer.xp)*config.inputScale, (mouseY-mePlayer.yp)*config.inputScale, 4, mePlayer.me);
    }

    map.loadPixels();
    for (int i = 0; i < booms.size(); i++) {
      Boom boom = booms.get(i);

      if (!boom.alive) {
        booms.remove(boom);
        i--;
      } else {
        boom.draw();
      }
    }
    map.updatePixels();

    for (int i = 0; i < config.teamCount; i++) {
      for (int j = 0; j < config.playersPerTeam; j++) {
        players[i][j].update();
      }
    }

    noStroke();
    fill(lerpColor(mePlayer.done ? neutral : mePlayer.me, color(0), 0.5));
    rect(10, 10, 300, 50);
    fill(lerpColor(mePlayer.done ? neutral : mePlayer.me, color(255), 0.2));
    rect(10, 10, max(0, mePlayer.hp/config.hp*300), 50);
    textSize(80);
    textAlign(LEFT, TOP);
    text(mePlayer.money, 10, 10+70+10);
    textSize(40);
    text(mePlayer.eco, 10, 10+70+10+80+10);

    if (state == State.PAUSE && booms.size() == 0) {
      boolean ready = true;

      for (int i = 0; i < config.teamCount; i++) {
        for (int j = 0; j < config.playersPerTeam; j++) {
          if (!players[i][j].alive ? false : (players[i][j].xv != 0 || players[i][j].yv != 0)) {
            ready = false;
          }
        }
      }

      if (ready) client.write("ready"+mePlayer.team+";"+mePlayer.number+"\n");
    }

    if (mePlayer.hp <= 0) {
      client.write("done"+mePlayer.team+";"+mePlayer.number+"\n");
    }
  }

  if (entered) {
    fill(neutral, 31);
    rect(-1, -1, width+1, height+1);
  }

  if (mePlayer != null && !entered && state == State.SPAWNING) {
    client.write("spawnat"+mouseX+";"+mouseY+";"+mePlayer.team+";"+mePlayer.number+"\n");
  }

  if (state == State.END) {
    if (winner == -1) info("Draw", color(255), false);
    else info("Team " + winner + " won!", teamColor(winner), false);
  }
}

void stop() {
  client.write(id + "~disconnect");
} 

enum State {
  CONNECTING (-1), 
    JOINING (0), 
    SPAWNING  (1), 
    GAME (2), 
    PAUSE (3), 
    END (4);

  private int valuePrivate;

  private State(int valuePrivate) {
    this.valuePrivate = valuePrivate;
  }

  public int value() { 
    return valuePrivate;
  }
}

color teamColor(int team) {
  return colorOf(team / (float)(config.teamCount-1f));
}

color colorOf(float value) {
  colorMode(HSB);
  color out = color(value*239/360*255, 255, 148);
  colorMode(RGB);

  return out;
}

void info(String text, color player, boolean block) {
  if (block) background(35);

  textSize(80);
  fill(lerpColor(player, color(255), 0.2));

  textAlign(CENTER, CENTER);
  text(text, width/2, height/2);
}

void mouseReleased() {
  if (mouseButton == LEFT) { //<>//
    if (state == State.JOINING) {
      float xSlice = width/config.teamCount;

      //mouseX = min(width, max(0, mouseX));
      //mouseY = min(height, max(0, mouseY));
      for (int i = 0; i < config.teamCount; i++) {
        boolean mouseOver = mouseX > xSlice*i && mouseY > 0 && mouseX < xSlice*(i+1) && mouseY < height;

        if (mouseOver) {
          client.write(id + "~team" + i);
          return;
        }
      }
    }

    if (state == State.SPAWNING) {
      println(mePlayer);
      client.write("done"+mePlayer.team+";"+mePlayer.number+"\n");
      entered = true;
    }
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount()*0.0025;
  config.inputScale = max(0, config.inputScale-e);
}

void keyPressed() {
  if (!entered && state == State.GAME && mePlayer.alive) {
    int type = key == config.key0 ? 0 : (key == config.key1 ? 1 :
      (key == config.key2 ? 2 : (key == config.key3 ? 3 : 
      (key == config.key4 ? 4 : 5))));

    if (type >= 0 && type <= 4) {
      int cost = (int)((type+1)*config.priceFactor*dist(mouseX-mePlayer.xp, mouseY-mePlayer.yp, 0, 0));

      if (mePlayer.money >= cost) {
        mePlayer.money -= cost;
        client.write("fireat"+(mouseX-mePlayer.xp)*config.inputScale+";"+
          (mouseY-mePlayer.yp)*config.inputScale+";"
          +mePlayer.team+";"+mePlayer.number+";"+type+"\n");
      }
    }
  }

  if (state == State.GAME && (key == config.confirm || key == config.confirmAlt)) {
    client.write("done"+mePlayer.team+";"+mePlayer.number+"\n");
    entered = true;
  }

  if (keyCode == ESC) {
    keyCode = 0;
    key = 0;

    client.write("reset");
  }
}

void genMap() {
  noiseDetail(config.noiseDetail);

  float xOff0 = random(99999);
  float yOff0 = random(99999);

  float[] xOffs = new float[config.teamCount]; 
  for (int i = 0; i < config.teamCount; i++) xOffs[i] = random(99999);

  float[] yOffs = new float[config.teamCount]; 
  for (int i = 0; i < config.teamCount; i++) yOffs[i] = random(99999);

  float[] avgs = new float[config.teamCount];
  int count = 0;

  long seed = (long)random(Long.MAX_VALUE);

  noiseSeed(seed);
  map = createImage(width, height, ARGB);
  map.loadPixels();

  for (int x = 0; x < map.width; x++) {
    float hei = noise(x * config.scale) * config.amplitude + config.baseHeight;

    for (int y = 0; y < map.height; y++) {
      if (y < hei || 
        noise(x * config.floatingScale + xOff0, y * config.floatingScale + yOff0) > 
        config.floatingThreshold) {
        for (int i = 0; i < config.teamCount; i++) {
          avgs[i] += noise(x*config.turfScale+xOffs[i], y*config.turfScale+yOffs[i]);
        }
        //float noisecenter = 0.4749;
        count++;

        map.set(x, height-y, color(255));
      }
    }
  }

  float propabilities[] = new float[config.teamCount];

  for (int i = 0; i < config.teamCount; i++) {
    propabilities[i] = config.turfPropability * avgs[i] / count;
  }

  noiseSeed(seed);

  for (int x = 0; x < map.width; x++) {
    for (int y = 0; y < map.height; y++) {
      color pixel = map.get(x, height-y);

      if (pixel == color(255)) {
        float[] randoms = new float[config.teamCount];
        for (int i = 0; i < config.teamCount; i++) {
          randoms[i] = noise(x*config.turfScale+xOffs[i], y*config.turfScale+yOffs[i]) / propabilities[i];
        }

        int max = 0;
        for (int i = 0; i < config.teamCount; i++) {
          if (randoms[i] > randoms[max]) {
            max = i;
          }
        }

        //println("\n");
        //printArray(randoms);
        if (randoms[max] > config.teamCount * 2) {
          map.set(x, height-y, teamColor(max));

          for (int i = 0; i < config.playersPerTeam; i++) {
            players[max][i].eco++;
          }
        } else {
          map.set(x, height-y, neutral);
        }
      }
    }
  }

  map.updatePixels();
}

class Player {
  float xp, yp;
  float xv, yv;
  float hp;
  int money, eco;
  color me;
  float width, height;
  ArrayList<Shot> shots;
  boolean alive;
  boolean done;
  int team, number;

  Player(float xp, float yp, color me) {
    this.xp = xp;
    this.yp = yp;
    this.me = me;

    this.shots = new ArrayList<Shot>();
    this.alive = true;
    this.done = false;
    configLoad();
  }

  void configLoad() {
    this.money = config.money;
    this.eco = config.eco;
    this.hp = config.hp;
    this.width = config.playerWidth;
    this.height = config.playerHeight;
  }

  void update() {
    if (alive) {
      yv += config.gravity;

      boolean onground = false;

      for (int x = 0; x < width; x++) {
        color pixel = map.get((int)(xp+x-width/2), (int)(yp+height/2));
        if (pixel != color(0, 0)) onground = true;
      }

      if (!onground) {
        xv *= config.airFriction;
        yv *= config.airFriction;
      } else {
        boolean fallingdmg = false;

        for (int x = 0; x < width; x++) {
          color pixel = map.get((int)(xp+x-width/2), (int)(yp+height/2)-1);

          if (pixel != color(0, 0)) {
            yp -= 1;
            fallingdmg = true;
          }
        }

        if (fallingdmg) {
          hp-=dist(xv, yv, 0, 0)*1.5f;
        }

        xv = 0;
        yv = 0;
      }

      if (xp < 0  || xp > map.width) {
        xv *= -config.wallBounce;
        if (xp < 0) xp = 0;
        else xp = map.width;
      }

      if (yp < 0) {
        yv *= -config.wallBounce;
        yp = 1;
      }

      xp += xv;
      yp += yv;

      if (hp <= 0 || yp >= map.height) {
        explode(xp, yp, xv, yv, config.deathPower, config.deathNoise, config.deathCount, config.deathType, config.deathStroke, teamColor(team), team);
        hp = 0;
        alive = false;
      }

      stroke(lerpColor(me, color(0), 0.2));
      strokeWeight(1);
      if (config.showLines || mePlayer == this) {
        for (Shot shot : shots) {
          parabola(shot.xp, shot.yp, shot.xv, shot.yv, shot.type, me);
        }
      }

      draw();
    }
  }

  void draw() {
    fill(lerpColor(me, color(0), 0.5));
    noStroke();
    rect(xp-width/2, yp-height/2, width, height);
    fill(lerpColor(me, color(255), 0.1));
    rect(xp-width/2, yp-height/2, width*hp/config.hp, height);
  }

  void fire() {
    done = false;

    for (Shot shot : shots) {
      if (shot.type < 4) {
        MacroBoom macroboom = new MacroBoom(shot.xp, shot.yp, shot.xv, shot.yv, config.shotPower, config.shotNoise, config.shotCount);
        macroboom.type = abs(shot.type);
        macroboom.childstroke = (abs(shot.type) > 1 ? 2 : 1) * config.shotChildstroke;
        macroboom.team = team;
        macroboom.me = me;
        booms.add(macroboom);
      } else {
        xv += shot.xv;
        yv += shot.yv;
        yp --;
      }
    }

    shots.clear();
  }
}

void parabola(float xp, float yp, float xv, float yv, int type, color me) {
  //println(xp, xv, yp, yv);
  float xl = xp, yl = yp;
  
  while (true) {
    xl = xp;
    yl = yp;

    yv += config.gravity;
    //println("0 " + xv, yv);

    boolean onground = false;
    
    /*if (type == 4) {
      for (int x = 0; x < config.playerWidth; x++) {
        color pixel = map.get((int)(xp+x-config.playerWidth/2), (int)(yp+config.playerHeight/2));
        if (pixel != color(0, 0)) onground = true;
      }
    } else {
      color pixel = map.get((int)(xp), (int)(yp));
      
      if ((type < 2 ? config.friendlyAttackNoclip : config.friendlyTurfNoclip) ? pixel != me : pixel != color(0, 0)) {
        onground = true;
        
        //if (dist(xv, yv, 0, 0) > 10 || dist(xv, yv, 0, 0) < 1) return;
      }
    }*/
    
    if (!onground) {
      xv *= config.airFriction;
      yv *= config.airFriction;
      //println("1 " + xv, yv);
    } else {
      if (type == 4) {
        //return;
      } else {
        yv -= config.groundGravityResistance;
        
        xv *= config.groundFriction;
        yv *= config.groundFriction;
        //println("2 " + xv, yv);
      }
    }

    if (xp < 0  || xp > map.width) {
      xv *= -config.wallBounce;
      if (xp < 0) xp = 0;
      else xp = map.width;
      //println("3 " + xv, yv);
    }

    if (type == 4 && yp < 0) {
      yv *= -config.wallBounce;
      yp = 1;
      //println("4 " + xv, yv);
    }

    xp += xv;
    yp += yv;

    line(xl, yl, xp, yp);

    if (yp >= map.height) {
      return;
    }
  }
}

class Shot {
  float xp, yp, xv, yv;
  int type;

  Shot(float xp, float yp, float xv, float yv, int type) {
    this.xp = xp;
    this.yp = yp;
    this.xv = xv;
    this.yv = yv;
    this.type = type;
  }
}

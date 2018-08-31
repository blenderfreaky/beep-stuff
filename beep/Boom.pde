class Boom {
  float xp, yp, xv, yv;
  boolean alive = true;
  float stroke;
  boolean inground = false;
  int type;
  color me;
  int team;

  Boom(float xp, float yp, float xv, float yv) {
    this.xp = xp;
    this.yp = yp;
    this.xv = xv;
    this.yv = yv;
  }

  void draw() {
    float strokeNorm = stroke;
    stroke = stroke + random(1f);
    
    yv += config.gravity;

    float dist = dist(xv, yv, 0, 0);

    for (int j = 0; j < dist; j += 1) {
      int x = (int)(xp + xv/dist*j);
      int y = (int)(yp + yv/dist*j);

      color pix = map.get(x, y);

      if (pix == color(0, 255)) { 
        DIE(); 
        break;
      } else if ((type < 2 ? config.friendlyAttackNoclip : config.friendlyTurfNoclip) ? pix != me : true) {
        for (int xe = 0; xe < stroke/2; xe++) {
          for (int ye = 0; ye < stroke/2; ye++) {
            if (dist(xe, ye, stroke/4, stroke/4) < stroke/4) {
              int xc = (int)(x+xe-stroke/4);
              int yc = (int)(y+ye-stroke/4);

              color pixel = map.get(xc, yc);
              if (!clippable(pixel)) inground = true;
              if (type == 0) map.set(xc, yc, color(0, 0));
              
              boolean a = type == 1 && inground;
              boolean b = (type == 3 && inground) || (type == 2 && pixel == neutral);
              
              if (a || b) {
                for (int i = 0; i < config.teamCount; i++) {
                  if (pixel == players[i][0].me) {
                    for (int k = 0; k < config.playersPerTeam; k++) {
                      players[i][k].eco--;
                    }
                  }
                }
                
                if(a) map.set(xc, yc, neutral);
                if (b) {
                  for (int k = 0; k < config.playersPerTeam; k++) {
                    players[team][k].eco++;
                  }
                  map.set(xc, yc, me);
                }
              }
            }
          }
        }
      }
    }

    if (AMIDIE()) DIE();

    if (!inground) {
      xv *= config.airFriction;
      yv *= config.airFriction;
    } else {
      if (dist(xv, yv, 0, 0) > 10) DIE();
      yv -= config.groundGravityResistance;

      xv *= config.groundFriction;
      yv *= config.groundFriction;
      if (dist(xv, yv, 0, 0) < 1) DIE();
    }

    if (xp < 0 || xp > width) xv *= -config.wallBounce;

    xp += xv;
    yp += yv;
      
    for (int i = 0; i < config.teamCount; i++) {
      for (int j = 0; j < config.playersPerTeam; j++) {   
        Player player = players[i][j];
        
        if (xp > player.xp && yp > player.yp && xp < player.xp+player.width && yp < player.yp+player.height) {
          player.hp -= 4-type;
          DIE();
        }
      }
    }

    strokeWeight(stroke/2);
    stroke(lerpColor(me, color(255), 1-type/3f));
    point(xp, yp);
    
    stroke = strokeNorm;
  }

  boolean clippable(color pixel) {
    if (pixel == color(0, 0)) return true;
    
    if (type < 2 ? config.friendlyAttackNoclip : config.friendlyTurfNoclip) {
      return pixel == me;
    } else {
      return false;
    }
  }

  boolean AMIDIE() {
    return yp > height;
  }

  void DIE() {
  }
}

class MicroBoom extends Boom {
  MicroBoom(float xp, float yp, float xv, float yv) {
    super(xp, yp, xv, yv);
  }

  void DIE() {
    alive = false;
  }
}

class MacroBoom extends Boom {
  float power, noise;
  int count;
  float childstroke = 4;

  MacroBoom(float xp, float yp, float xv, float yv, float power, float noise, int count) {
    super(xp, yp, xv, yv);

    this.power = power;
    this.noise = noise;
    this.count = count;

    stroke = config.shotStroke;
  }

  void DIE() {
    alive = false;
    explode(xp, yp, power, noise, count, type, childstroke, me, team);
  }
}

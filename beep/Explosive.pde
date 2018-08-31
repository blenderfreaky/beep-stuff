void explode(float x, float y, float power, float noise, int count, int type, float childstroke, color me, int team) {
  explode(x, y, 0, 0, power, noise, count, type, childstroke, me, team);
}

void explode(float x, float y, float xvOff, float yvOff, float power, float noise, int count, int type, float childstroke, color me, int team) {
  for (int i = 0; i < count; i++) {
    float pow = power * random(1-noise, 1);
    float xv = pow * cos((i+random(0, 0.5)) / (float)count * TWO_PI)+xvOff;
    float yv = pow * sin((i+random(0, 0.5)) / (float)count * TWO_PI)+yvOff;

    MicroBoom microboom = new MicroBoom(x, y, xv, yv);
    microboom.type = type;
    microboom.stroke = childstroke;
    microboom.me = me;
    microboom.team = team;

    booms.add(microboom);
  }
}

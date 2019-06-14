class Config {
  float hp, playerWidth, playerHeight;
  int money, eco;
  
  
  float baseHeight;
  float amplitude;
  float scale;
  int noiseDetail;
  
  float floatingScale;
  float floatingThreshold;
  
  float turfPropability;
  float turfScale;
  
  
  float priceFactor;
  float gravity, airFriction, groundFriction, groundGravityResistance;
  float shotPower, shotNoise, shotStroke, shotChildstroke;
  int shotCount;
  float deathPower, deathNoise, deathStroke;
  int deathCount, deathType;
  boolean showLines;
  float wallBounce;
  boolean friendlyAttackNoclip;
  boolean friendlyTurfNoclip;
  

  String font;
  int neutral, red, blue;
  
  
  int teamCount;
  int playersPerTeam;
  
  
  char key0, key1, key2, key3, key4;
  char confirm, confirmAlt;
  float inputScale;
  
  
  String ip;
  int port;
  
  Config(String file) {
    String[] contents = loadStrings(file);
      
    deserialize(contents);
  }
  
  Config(String file, String defaultFile) {
    String[] contents = null;
    try { 
      contents = loadStrings(file);
    } 
    catch(Exception e) { 
      e.printStackTrace();
    }
    
    if (contents == null) {
      contents = loadStrings(defaultFile);
      deserialize(contents);
      saveStrings("data/" + file, serialize());
    } else {
      deserialize(contents);
    }
  }
  
  char decodeChar(String input) {
    switch (input) {
      case "BACKSPACE": return BACKSPACE;
      case "TAB": return TAB;
      case "ENTER": return ENTER;
      case "RETURN": return RETURN;
      case "ESC": return ESC;
      case "DELETE": return DELETE;
      default: return input.charAt(0);
    }
  }
  
  String encodeChar(char input) {
    switch (input) {
      case BACKSPACE: return "BACKSPACE";
      case TAB: return "TAB";
      case ENTER: return "ENTER";
      case RETURN: return "RETURN";
      case ESC: return "ESC";
      case DELETE: return "DELETE";
      default: return "" + input;
    }
  }
  
  boolean decodeBool(String input) {
    switch (input) {
      case "true": return true;
      case "false": return false;
      default: return false;
    }
  }
  
  String encodeBool(boolean input) {
    if (input) {
      return "true";
    } else {
      return "false";
    }
  }
  
  void deserialize(String[] contents) {
    for (String line : contents) {
      String[] components = line.replace(" ", "").split("="); 
      
      switch (components[0]) {
        case "player.hp": hp = Float.parseFloat(components[1]); break;
        case "player.money": money = Integer.parseInt(components[1]); break;
        case "player.eco": eco = Integer.parseInt(components[1]); break;
        case "player.width": playerWidth = Float.parseFloat(components[1]); break;
        case "player.height": playerHeight = Float.parseFloat(components[1]); break;
        
        
        case "map.base_height": baseHeight = Float.parseFloat(components[1]); break;
        case "map.amplitude": amplitude = Float.parseFloat(components[1]); break;
        case "map.scale": scale = Float.parseFloat(components[1]); break;
        case "map.noise_detail": noiseDetail = Integer.parseInt(components[1]); break;
        
        case "map.floating.scale": floatingScale = Float.parseFloat(components[1]); break;
        case "map.floating.threshold": floatingThreshold = Float.parseFloat(components[1]); break;
        
        case "map.turf.propability": turfPropability = Float.parseFloat(components[1]); break;
        case "map.turf.scale": turfScale = Float.parseFloat(components[1]); break;
        
        
        case "game.price_factor": priceFactor = Float.parseFloat(components[1]); break;
        case "game.gravity": gravity = Float.parseFloat(components[1]); break;
        case "game.air_friction": airFriction = Float.parseFloat(components[1]); break;
        case "game.ground_friction": groundFriction = Float.parseFloat(components[1]); break;
        case "game.ground_gravity_resistance": groundGravityResistance = Float.parseFloat(components[1]); break;
        case "game.show_lines": showLines = decodeBool(components[1]); break;
        case "game.wall_bounce": wallBounce = Float.parseFloat(components[1]); break;
        case "game.friendly_attack_noclip": friendlyAttackNoclip = decodeBool(components[1]); break;
        case "game.friendly_turf_noclip": friendlyTurfNoclip = decodeBool(components[1]); break;
        
        case "game.shot.power": shotPower = Float.parseFloat(components[1]); break;
        case "game.shot.noise": shotNoise = Float.parseFloat(components[1]); break;
        case "game.shot.count": shotCount = Integer.parseInt(components[1]); break;
        case "game.shot.stroke": shotStroke = Float.parseFloat(components[1]); break;
        case "game.shot.childstroke": shotChildstroke = Float.parseFloat(components[1]); break;
        
        case "game.death.power": deathPower = Float.parseFloat(components[1]); break;
        case "game.death.noise": deathNoise = Float.parseFloat(components[1]); break;
        case "game.death.count": deathCount = Integer.parseInt(components[1]); break;
        case "game.death.stroke": deathStroke = Float.parseFloat(components[1]); break;
        case "game.death.type": deathType = Integer.parseInt(components[1]); break;
        
        
        case "lobby.team_count": teamCount = Integer.parseInt(components[1]); break;
        case "lobby.players_per_team": playersPerTeam = Integer.parseInt(components[1]); break;
        
        
        case "ui.font": font = components[1]; break;
        case "ui.neutral": neutral = unhex(components[1]); break;
        case "ui.red": red = unhex(components[1]); break;
        case "ui.blue": blue = unhex(components[1]); break;
        
        
        case "controls.key0": key0 = decodeChar(components[1]); break;
        case "controls.key1": key1 = decodeChar(components[1]); break;
        case "controls.key2": key2 = decodeChar(components[1]); break;
        case "controls.key3": key3 = decodeChar(components[1]); break;
        case "controls.key4": key4 = decodeChar(components[1]); break;
        case "controls.confirm": confirm = decodeChar(components[1]); break;
        case "controls.confirm_alt": confirmAlt = decodeChar(components[1]); break;
        case "controls.input_scale": inputScale = Float.parseFloat(components[1]); break;
        
        
        case "net.ip": ip = components[1]; break;
        case "net.port": port = Integer.parseInt(components[1]); break;
        default: break;
      }
    } 
  }
  
  String[] serialize() {
    ArrayList<String> contents = new ArrayList<String>();

    contents.add("player.hp="+hp);
    contents.add("player.money="+money);
    contents.add("player.eco="+eco);
    contents.add("player.width="+playerWidth);
    contents.add("player.height="+playerHeight);
    
    
    contents.add("map.base_height="+baseHeight);
    contents.add("map.amplitude="+amplitude);
    contents.add("map.scale="+scale);
    contents.add("map.noise_detail="+noiseDetail);
    
    contents.add("map.floating.scale="+floatingScale);
    contents.add("map.floating.threshold="+floatingThreshold);
    
    contents.add("map.turf.propability="+turfPropability);
    contents.add("map.turf.scale="+turfScale);
    
    
    contents.add("game.price_factor="+priceFactor);
    contents.add("game.gravity="+gravity);
    contents.add("game.air_friction="+airFriction);
    contents.add("game.ground_friction="+groundFriction);
    contents.add("game.ground_gravity_resistance="+groundGravityResistance);
    contents.add("game.show_lines="+encodeBool(showLines));
    contents.add("game.wall_bounce="+wallBounce);
    contents.add("game.friendly_attack_noclip="+encodeBool(friendlyAttackNoclip));
    contents.add("game.friendly_turf_noclip="+encodeBool(friendlyTurfNoclip));
    
    contents.add("game.shot.power="+shotPower);
    contents.add("game.shot.noise="+shotNoise);
    contents.add("game.shot.count="+shotCount);
    contents.add("game.shot.stroke="+shotStroke);
    contents.add("game.shot.childstroke="+shotChildstroke);
    
    contents.add("game.death.power="+deathPower);
    contents.add("game.death.noise="+deathNoise);
    contents.add("game.death.count="+deathCount);
    contents.add("game.death.stroke="+deathStroke);
    contents.add("game.death.type="+deathType);
    
    
    contents.add("lobby.team_count="+teamCount);
    contents.add("lobby.players_per_team="+playersPerTeam);
    
    
    contents.add("ui.font="+font);
    contents.add("ui.neutral="+hex(neutral));
    contents.add("ui.red="+hex(red));
    contents.add("ui.blue="+hex(blue));
    
    
    contents.add("controls.key0="+encodeChar(key0));
    contents.add("controls.key1="+encodeChar(key1));
    contents.add("controls.key2="+encodeChar(key2));
    contents.add("controls.key3="+encodeChar(key3));
    contents.add("controls.key4="+encodeChar(key4));
    contents.add("controls.confirm="+encodeChar(confirm));
    contents.add("controls.confirm_alt="+encodeChar(confirmAlt));
    contents.add("controls.input_scale="+inputScale);
    
    return contents.toArray(new String[0]);
  }
}

part of coUserver;

class Helga extends Vendor {
  int openCount = 0;
  Helga(String id, String streetName, String tsid, int x, int y) : super(id, streetName, tsid, x, y) {
    type = "Helga";
    itemsForSale = [
	    items["still"].getMap(),
	    items["beer"].getMap(),
	    items["carrot_margarita"].getMap(),
	    items["coffee"].getMap(),
	    items["creamy_martini"].getMap(),
	    items["exotic_juice"].getMap(),
	    items["mabbish_coffee"].getMap(),
	    items["mega_healthy_veggie_juice"].getMap(),
	    items["savory_smoothie"].getMap(),
	    items["slow_gin_fizz"].getMap(),
	    items["spicy_grog"].getMap(),
	    items["tooberry_shake"].getMap()
    ];
    speed = 40;

    states = {
      "idle_stand": new Spritesheet("idle_stand",
        "http://childrenofur.com/assets/entityImages/npc_jabba2__x1_idle_stand_part1_png_1354831705.png",
        3942, 4074, 438, 194, 189, true),
      "idle_stand_2": new Spritesheet("idle_stand",
        "http://childrenofur.com/assets/entityImages/npc_jabba2__x1_idle_stand_part2_png_1354831715.png",
        3942, 2910, 438, 194, 131, true),
      "impatient": new Spritesheet("impatient",
        "http://childrenofur.com/assets/entityImages/npc_jabba2__x1_impatient_png_1354831691.png",
        3942, 2134, 438, 194, 98, true),
      "talk": new Spritesheet("talk",
        "http://childrenofur.com/assets/entityImages/npc_jabba2__x1_talk_png_1354831682.png",
        3942, 1552, 438, 194, 72, true),
      "turn_left": new Spritesheet("turn",
        "http://childrenofur.com/assets/entityImages/npc_jabba2__x1_turn_png_1354831675.png",
        876, 1746, 438, 194, 18, false),
      "turn_right": new Spritesheet("turn_right",
        "http://childrenofur.com/assets/entityImages/npc_jabba2__x1_turn_right_png_1354831667.png",
        876, 1552, 438, 194, 16, false),
      "walk_end": new Spritesheet("walk_end",
        "http://childrenofur.com/assets/entityImages/npc_jabba2__x1_walk_end_png_1354831672.png",
        876, 1552, 438, 194, 15, false),
      "walk_left_end": new Spritesheet("walk_left_end",
        "http://childrenofur.com/assets/entityImages/npc_jabba2__x1_walk_left_end_png_1354831665.png",
        876, 1552, 438, 194, 15, false),
      "walk_left": new Spritesheet("walk_left",
        "http://childrenofur.com/assets/entityImages/npc_jabba2__x1_walk_left_png_1354831662.png",
        876, 1552, 438, 194, 16, true),
      "walk": new Spritesheet("walk",
        "http://childrenofur.com/assets/entityImages/npc_jabba2__x1_walk_png_1354831670.png",
        876, 1552, 438, 194, 16, true),
    };
    currentState = states['idle_stand'];
  }

  void update() {
    if(respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
      // if we just turned, we should say we're facing the other way, then we should start moving (that's why we turned around after all)
      if(currentState.stateName == 'turn_left') {
        // if we turned left, we are no longer facing right
        facingRight = false;
        // reverse direction
        speed = -speed;
        // start walking left
        currentState = states['walk'];
        // respawn when we finish walking
        respawn = new DateTime.now().add(new Duration(milliseconds:(currentState.numFrames / 30 * 1000 * 5000).toInt()));
        return;
      } else if (currentState.stateName == 'turn_right') {
        // if we turned right, we are now facing right
        facingRight = true;
        // reverse direction
        speed = -speed;
        // start walking right
        currentState = states['walk'];
        // respawn when we finish walking
        respawn = new DateTime.now().add(new Duration(milliseconds:(currentState.numFrames / 30 * 1000 * 5000).toInt()));
        return;
      } else {
        // if we haven't just turned
        if(rand.nextInt(2) == 1) {
          // 50% chance of trying to attract buyers
          currentState = states['impatient'];
          // respawn when done
          respawn = new DateTime.now().add(new Duration(milliseconds:(currentState.numFrames / 30 * 1000).toInt()));
        } else {
          // wait
          currentState = states['idle_stand'];
          respawn = null;
        }
        return;
      }
    }
    if(respawn == null) {
      //sometimes move around
      int roll = rand.nextInt(20);
      if(roll > 10 && roll <= 15) {
        // 25% chance to turn left
        currentState = states['turn_left'];
        // no longer facing right
        facingRight = false;
        // respawn after walking left three times
        respawn = new DateTime.now().add(new Duration(milliseconds:(currentState.numFrames / 30 * 1000).toInt() * 3));
      } else if (roll > 15 && roll <= 20) {
        // 25% chance to turn right
        currentState = states['turn_right'];
        // now facing right
        facingRight = true;
        // respawn after walking right three times
        respawn = new DateTime.now().add(new Duration(milliseconds:(currentState.numFrames / 30 * 1000).toInt() * 3));
      } else {
        // 50% chance of nothing happening
      }
    }
  }

  void close({WebSocket userSocket, String email}) {
    openCount -= 1;
    //if no one else has them open
    if(openCount <= 0) {
      openCount = 0;
      currentState = states['idle_stand'];
      int length = (currentState.numFrames / 30 * 1000).toInt();
      respawn = new DateTime.now().add(new Duration(milliseconds:length));
    }
  }
}
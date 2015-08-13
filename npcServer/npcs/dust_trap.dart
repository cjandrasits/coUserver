part of coUserver;

class DustTrap extends NPC {
	DateTime now;
	String streetName, tsid;
	Rectangle hitBox;

	DustTrap(String id, this.streetName, this.tsid, int x, int y) : super(id, x, y) {
		actionTime = 0;
		actions = [];
		type = "Dust Trap";
		speed = 0;

		states = {
			"smackDown": new Spritesheet("smackDown", "http://c2.glitch.bz/items/2012-12-06/dust_trap__x1_smackDown_png_1354833768.png", 990, 1275, 110, 255, 45, false),
			"liftUp": new Spritesheet("liftUp", "http://c2.glitch.bz/items/2012-12-06/dust_trap__x1_up_png_1354833769.png", 880, 510, 110, 255, 16, false),
			"down": new Spritesheet("down", "http://c2.glitch.bz/items/2012-12-06/dust_trap__x1_down_png_1354833768.png", 110, 255, 110, 255, 1, true),
			"up": new Spritesheet("up", "http://c2.glitch.bz/items/2012-12-06/dust_trap__x1_idle_png_1354833764.png", 110, 255, 110, 255, 1, true)
		};
		currentState = states["up"];
		respawn = new DateTime.now();
		hitBox = new Rectangle(x - 25, y + 25, 160, 305);
	}

	void update() {
		// Update clock
		now = new DateTime.now();

		// Check if flipping down has finished
		if (currentState == states["smackDown"] && respawn.compareTo(now) <= 0) {
			// Switch to static down image
			currentState = states["down"];
			// Flip back up in 1 minute
			respawn = now.add(new Duration(minutes: 1));
		}

		// Check if flipping up has finished
		if (currentState == states["liftUp"] && respawn.compareTo(now) <= 0) {
			// Switch to static up image
			currentState = states["up"];
		}

		// Check if down and need to reset
		if (currentState == states["down"] && respawn.compareTo(now) <= 0) {
			// Switch to resetting animation
			currentState = states["liftUp"];
			respawn = now.add(new Duration(milliseconds:(currentState.numFrames / 30 * 1000).toInt()));
		}

		// If it's not already triggered...
		if (currentState == states["up"]) {
			// Go through players on the street checking for collisions
			MetabolicsEndpoint.userSockets.forEach((String username, WebSocket ws) {
				// Get user reference
				Identifier userIdentifier = PlayerUpdateHandler.users[username];

				if (userIdentifier == null || userIdentifier.currentStreet != streetName) {
					// Not on this street
					return;
				}


				if (hitBox.left < userIdentifier.currentX && hitBox.right > userIdentifier.currentX) {
					// User is in the hitbox, they should step on it
					stepOn(userSocket: ws, email: userIdentifier.email);
				}

				// Clear user reference
				userIdentifier = null;
			});
		}
	}

	Future stepOn({WebSocket userSocket, String email}) async {
		currentState = states["smackDown"];
		respawn = now.add(new Duration(milliseconds:(currentState.numFrames / 30 * 1000).toInt()));
		switch (new Random().nextInt(3)) {
			case 0:
				toast("Oh snap!", userSocket);
				break;
			case 1:
			case 2:
				addItemToUser(userSocket, email, items["paper"].getMap(), 1, id);
				toast("+1 piece of paper", userSocket);
				break;
			case 3:
				addItemToUser(userSocket, email, items["bun"].getMap(), 1, id);
				toast("+1 bun", userSocket);
				break;
		}
		return;
	}
}
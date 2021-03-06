part of coUserver;

class IceNubbin extends Plant {
	IceNubbin (String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		actionTime = 2000;
		type = "Ice Nubbin";

		actions.add({
			"action":"collect",
			"actionWord":"breaking the ice",
			"timeRequired":actionTime,
			"enabled":true,
			"requires":[
				{
					"num":4,
					"of":['energy'],
					"error": "You need at least 4 energy to pull off ice cubes."
				},
				{
					"num":1,
					"of":["scraper", "super_scraper"],
					"error": "You need something sharp to cut off ice cubes with."
				}
			]
		});

		states = {
			"1-2-3-4-5" : new Spritesheet("1-2-3-4-5", "http://childrenofur.com/assets/entityImages/ice_knob.png", 290, 84, 58, 84, 5, false),
		};
		currentState = states['1-2-3-4-5'];
		state = new Random().nextInt(currentState.numFrames);
		maxState = 5;
	}

	Future<bool> collect ({WebSocket userSocket, String email}) async {
		bool success = await super.trySetMetabolics(email,energy:-4,imgMin:2,imgRange:2);
		if(!success) {
			return false;
		}

		int numToGive = 1;
		// 1 in 15 chance to get an extra
		if(new Random().nextInt(14) == 14) {
			numToGive = 2;
		}

		// 50% chance to get an ice cube
		// 50% chance to let it melt before you collect it
		if(new Random().nextInt(1) == 1) {
			await InventoryV2.addItemToUser(email, items['ice'].getMap(), numToGive, id);
			StatBuffer.incrementStat("iceNubbinsCollected", 1);
			state--;

			StatCollection.find(email).then((StatCollection stats) {
				stats.ice_scraped += numToGive;
				if (stats.ice_scraped >= 67) {
					Achievement.find("ice_baby").awardTo(email);
				} else if (stats.ice_scraped >= 227) {
					Achievement.find("ice_ice_baby").awardTo(email);
				} else if (stats.ice_scraped >= 467) {
					Achievement.find("on_thin_ice").awardTo(email);
				} else if (stats.ice_scraped >= 877) {
					Achievement.find("cold_as_ice").awardTo(email);
				} else if (stats.ice_scraped >= 1777) {
					Achievement.find("icebreaker").awardTo(email);
				}
			});
			
			if(state < 1) {
				respawn = new DateTime.now().add(new Duration(minutes:2));
				return false;
			}
			return true;
		} else {
			await InventoryV2.addItemToUser(email, items['cup_of_water'].getMap(), 1, id);
			say("You have to grab it faster next time. It melted!");
			return false;
		}
	}
}
part of coUserver;

class PeatBog extends Plant {
	PeatBog(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		actionTime = 5000;
		type = "Peat Bog";

		actions.add({"action":"dig",
			"actionWord":"digging",
			"timeRequired":actionTime,
			"enabled":true,
			"requires":[
				{
					"num":1,
					"of":["shovel", "ace_of_spades"],
					"error": "You can't grip this stuff without a tool."
				},
				{
					"num":10,
					"of":['energy'],
					"error": "You need at least 10 energy to dig."
				}
			]
		});

		states = {
			"5-4-3-2-1" : new Spritesheet("5-4-3-2-1", "http://childrenofur.com/assets/entityImages/peat_x1_5_x1_4_x1_3_x1_2_x1_1__1_png_1354832710.png", 633, 104, 211, 52, 5, false),
		};
		currentState = states['5-4-3-2-1'];
		state = new Random().nextInt(currentState.numFrames);
		maxState = 0;
	}

	@override
	void update() {
		if(state >= currentState.numFrames)
			setActionEnabled("dig", false);

		if(respawn != null && new DateTime.now().compareTo(respawn) >= 0) {
			state = 0;
			setActionEnabled("dig", true);
			respawn = null;
		}

		if(state < maxState)
			state = maxState;
	}

	Future<bool> dig({WebSocket userSocket, String email}) async {
		bool success = await super.trySetMetabolics(email,energy:-10,imgMin:10,imgRange:5);
		if(!success) {
			return false;
		}

		StatBuffer.incrementStat("peatDug", 1);
		state++;
		if(state >= currentState.numFrames) {
			respawn = new DateTime.now().add(new Duration(minutes:2));
		}

		StatCollection.find(email).then((StatCollection stats) {
			stats.peat_harvested++;
			if (stats.peat_harvested >= 41) {
				Achievement.find("re_peater").awardTo(email);
			} else if (stats.peat_harvested >= 283) {
				Achievement.find("compulsive_re_peater").awardTo(email);
			} else if (stats.peat_harvested >= 503) {
				Achievement.find("obsessive_compulsive_re_peater").awardTo(email);
			} else if (stats.peat_harvested >= 1009) {
				Achievement.find("feat_of_peat_excellence").awardTo(email);
			} else if (stats.peat_harvested >= 5003) {
				Achievement.find("saint_peater").awardTo(email);
			}
		});

		//give the player the 'fruits' of their labor
		await InventoryV2.addItemToUser(email, items['peat'].getMap(), 1, id);

		return true;
	}
}
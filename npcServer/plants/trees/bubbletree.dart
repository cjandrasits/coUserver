part of coUserver;

class BubbleTree extends Tree {
	BubbleTree(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		type = "Bubble Tree";

		responses =
		{
			"harvest": [
				"…know the power you hold in your hands…",
				"Bubbles. Precious bubbles. Just for you. Pop-pop!",
				"…which is why harvesting is crucial to… Oh! Shh.",
				"Wait, my tin hat didn't fall in with that haul, right?",
				"…Again? You're up to something, I sense it.",
			],
			"pet": [
				"Wait! Shh. Did you hear that? Never mind. Pretend you didn't.",
				"...a nice BLT: a batterfly, lettuce and tomato sandwich, and...",
				"... big difference between mostly dead and all dead. And...",
				"...shh! Can't talk now! Tin foil hat compromised! More later!…",
				"...went pop! Pop pop pop!  Until it was all dark, and then...",
			],
			"water": [
				"…what's that? Wet? Huh?",
				"Huh? Something for nothing, eh?",
				"I don't trust watering cans. But you're ok.",
				"…all in it together. SHHH! Someone's listening…",
				"…in the caves. But it only LOOKED like an accident…",
			]
		};

		states =
		{
			"maturity_1" : new Spritesheet("maturity_1", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_1_seed_0_119919911_png_1354830122.png", 835, 554, 167, 277, 9, false),
			"maturity_2" : new Spritesheet("maturity_2", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_2_seed_0_119919911_png_1354830123.png", 835, 554, 167, 277, 9, false),
			"maturity_3" : new Spritesheet("maturity_3", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_3_seed_0_119919911_png_1354830125.png", 835, 554, 167, 277, 10, false),
			"maturity_4" : new Spritesheet("maturity_4", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_4_seed_0_119919911_png_1354830127.png", 835, 2493, 167, 277, 44, false),
			"maturity_5" : new Spritesheet("maturity_5", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_5_seed_0_119919911_png_1354830131.png", 835, 3601, 167, 277, 61, false),
			"maturity_6" : new Spritesheet("maturity_6", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_6_seed_0_119919911_png_1354830279.png", 835, 3601, 167, 277, 62, false),
			"maturity_7" : new Spritesheet("maturity_7", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_7_seed_0_119919911_png_1354830283.png", 4008, 831, 167, 277, 72, false),
			"maturity_8" : new Spritesheet("maturity_8", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_8_seed_0_119919911_png_1354830289.png", 4008, 831, 167, 277, 72, false),
			"maturity_9" : new Spritesheet("maturity_9", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_9_seed_0_119919911_png_1354830295.png", 4008, 831, 167, 277, 72, false),
			"maturity_10" : new Spritesheet("maturity_10", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_10_seed_0_119919911_png_1354830301.png", 3173, 1108, 167, 277, 76, false)
		};
		maturity = new Random().nextInt(states.length) + 1;
		currentState = states['maturity_$maturity'];
		state = new Random().nextInt(currentState.numFrames);
		maxState = currentState.numFrames - 1;
	}

	Future<bool> harvest({WebSocket userSocket, String email}) async {
		bool success = await super.harvest(userSocket:userSocket,email:email);

		if(success) {
			StatCollection.find(email).then((StatCollection stats) {
				stats.bubbles_harvested++;
				if (stats.bubbles_harvested >= 101) {
					Achievement.find("good_bubble_farmer").awardTo(email);
				} else if (stats.bubbles_harvested >= 503) {
					Achievement.find("better_bubble_farmer").awardTo(email);
				} else if (stats.bubbles_harvested >= 1009) {
					Achievement.find("second_best_bubble_farmer").awardTo(email);
				} else if (stats.bubbles_harvested >= 5003) {
					Achievement.find("first_best_bubble_farmer").awardTo(email);
				}
			});

			//give the player the 'fruits' of their labor
			await InventoryV2.addItemToUser(email, items['plain_bubble'].getMap(), 1, id);
		}

		return success;
	}
}
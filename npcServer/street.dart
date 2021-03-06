part of coUserver;

class DBStreet {
	@Field() String id, items;

	List<Item> get groundItems => jsonx.decode(items, type: const jsonx.TypeHelper<List<Item>>().type);

	void set groundItems(List<Item> value) {
		items = jsonx.encode(value);
	}
}

class Street {
	static Random rand = new Random();
	Map<String, Quoin> quoins = {};
	Map<String, Plant> plants = {};
	Map<String, NPC> npcs = {};
	Map<String, Door> doors = {};
	Map<String, Map> entityMaps;
	Map<String, Item> groundItems = {};
	Map<String, WebSocket> occupants = {};
	List<Flag> flags = [];
	String label, tsid;

	Street(this.label, this.tsid) {
		entityMaps = {"quoin":quoins, "plant":plants, "npc":npcs, "door":doors, "groundItem":groundItems};

		//attempt to load street occupants from streetEntities folder
		Map entities = getStreetEntities(tsid);
		if (entities['entities'] != null) {
			for (Map entity in entities['entities']) {
				String type = entity['type'];
				int x = entity['x'];
				int y = entity['y'];

				//generate a hopefully unique code that stays the same everytime for this object
				String id = createId(x, y, type, tsid);

				if (type == "Img" || type == "Mood" || type == "Energy" || type == "Currant"
				    || type == "Mystery" || type == "Favor" || type == "Time" || type == "Quarazy") {
					id = "q" + id;
					quoins[id] = new Quoin(id, x, y, type.toLowerCase());
				} else if (type == 'Flag') {
					flags.add(new Flag(id, x, y));
				} else {
					try {
						ClassMirror classMirror = findClassMirror(type.replaceAll(" ", ""));
						if (classMirror.isSubclassOf(findClassMirror("NPC"))) {
							id = "n" + id;
							if (classMirror.isSubclassOf(findClassMirror("Vendor")) ||
							    classMirror == findClassMirror("DustTrap")) {
								// Vendors and dust traps get a street name/TSID to check for collisions
								npcs[id] = classMirror
									.newInstance(new Symbol(""), [id, label, tsid, x, y])
									.reflectee;
							} else {
								npcs[id] = classMirror
									.newInstance(new Symbol(""), [id, x, y, label])
									.reflectee;
							}
						}
						if (classMirror.isSubclassOf(findClassMirror("Plant"))) {
							id = "p" + id;
							plants[id] = classMirror
								.newInstance(new Symbol(""), [id, x, y, label])
								.reflectee;
						}
						if (classMirror.isSubclassOf(findClassMirror("Door"))) {
							id = "d" + id;
							doors[id] = classMirror
								.newInstance(new Symbol(""), [id, label, x, y])
								.reflectee;
						}
					} catch (e) {
						log("Unable to instantiate a class for $type: $e");
					}
				}
			}
		}
	}

	Future loadItems() async {
		PostgreSql dbConn = await dbManager.getConnection();

		String query = "SELECT * FROM streets WHERE id = @tsid";
		DBStreet dbStreet;
		try {
			dbStreet = (await dbConn.query(query, DBStreet, {'tsid':tsid})).first;
			dbStreet.groundItems.forEach((Item item) {
				item.putItemOnGround(item.x, item.y, label);
			});
		} catch (e) {
			//no street in the database
//			print("didn't load a street with tsid $tsid from the db");
		}

		dbManager.closeConnection(dbConn);
	}

	Future persistState() async {
		PostgreSql dbConn = await dbManager.getConnection();

		try {
			String query = "UPDATE streets SET items = @items WHERE id = @id";
			DBStreet dbStreet = new DBStreet()
				..id = tsid
				..groundItems = groundItems.values.toList() ?? [];
			int result = await dbConn.execute(query, dbStreet);
			if(result == 0) {
				query = "INSERT INTO streets(id,items) VALUEs(@id,@items)";
				await dbConn.execute(query, dbStreet);
			}
		} catch (e) {
			print('could not persist $tsid ($label): $e');
		}

		dbManager.closeConnection(dbConn);
	}
}

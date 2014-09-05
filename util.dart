part of coUserver;

Map getStreetEntities(String tsid)
{
	Map entities = {};
	if(tsid != null)
	{
		if(tsid.startsWith("G"))
    		tsid = tsid.replaceFirst("G", "L");
    	File file = new File('./streetEntities/$tsid');
    	if(file.existsSync())
    		entities = JSON.decode(file.readAsStringSync());
	}

	return entities;
}
saveStreetData(Map params)
{
	String tsid = params['tsid'];
	if(tsid.startsWith("G"))
		tsid = tsid.replaceFirst("G", "L");

	List entities = JSON.decode(params['entities']);
	File file = new File('./streetEntities/$tsid');
	if(file.existsSync())
	{
		Map oldFile = JSON.decode(file.readAsStringSync());
		//backup the older file and replace it with this new file
    	File backup = new File('./streetEntities/$tsid.bak');
    	if(backup.existsSync())
    	{
    		Map oldData = JSON.decode(backup.readAsStringSync());
    		List backups = oldData['backups'];
    		backups.add({new DateTime.now().toIso8601String():oldFile});
    		backup.writeAsStringSync(JSON.encode({'backups':backups}));
    	}
    	else
    	{
    		backup.createSync(recursive:true);
	    	Map oldData = {'backups':[{new DateTime.now().toIso8601String():oldFile}]};
	    	backup.writeAsStringSync(JSON.encode(oldData));
    	}
    }
	else
		file.createSync(recursive:true);

	file.writeAsStringSync(JSON.encode({'entities':entities}));


	//save a list of finished and partially finished streets
	File finished = _getFinishedFile();
	Map finishedMap = JSON.decode(finished.readAsStringSync());
	int required = int.parse(params['required']);
	int complete = int.parse(params['complete']);
	bool streetFinished = (required-complete == 0) ? true : false;
	finishedMap[tsid] = {"entitiesRequired":params['required'],
	                     "entitiesComplete":params['complete'],
	                     "streetFinished":streetFinished};
	finished.writeAsStringSync(JSON.encode(finishedMap));
}

void reportBrokenStreet(String tsid, String reason)
{
	if(tsid == null)
		return;

	if(tsid.startsWith("G"))
    	tsid = tsid.replaceFirst("G", "L");

	File finished = _getFinishedFile();
	Map finishedMap = JSON.decode(finished.readAsStringSync());
	Map street = {};
	if(finishedMap[tsid] != null)
	{
		street = finishedMap[tsid];
		street['reported$reason'] = true;
		finishedMap[tsid] = street;
	}
	else
	{
		finishedMap[tsid] = {"entitiesRequired":-1,
    	                     "entitiesComplete":-1,
    	                     "streetFinished":false,
    	                     "reported$reason":true};
	}
	finished.writeAsStringSync(JSON.encode(finishedMap));
}

File _getFinishedFile()
{
	File finished = new File('./streetEntities/finished.json');
	if(!finished.existsSync())
		_createFinishedFile();

	return finished;
}

void _createFinishedFile()
{
	File finished = new File('./streetEntities/finished.json');
	finished.createSync(recursive:true);
	//insert any streets that were finished before this file was created
	Directory streetEntities = new Directory('./streetEntities');
	Map finishedMap = {};
	for(FileSystemEntity entity in streetEntities.listSync(recursive:true))
	{
		String filename = entity.path.substring(entity.path.lastIndexOf('/')+1);
		if(!filename.contains('.'))
		{
			//we'll assume it's incomplete
			finishedMap[filename] = {"entitiesRequired":0,
				                     "entitiesComplete":0,
            	                     "streetFinished":false};
		}
	}
	finished.writeAsStringSync(JSON.encode(finishedMap));
}

String getTsidOfUnfilledStreet()
{
	String tsid = null;

	File file = new File('./streetEntities/streets.json');
	File finished = new File('./streetEntities/finished.json');

	if(!finished.existsSync())
		_createFinishedFile();

	if(!file.existsSync())
		return tsid;

	Map streets = JSON.decode(file.readAsStringSync());
	Map finishedMap = JSON.decode(finished.readAsStringSync());

	//loop through streets to find one that is not finished
	//if they are all finished, take one that is not complete
	String incomplete = null;
	List<String> streetsList = streets.keys.toList();
	streetsList.shuffle();
	for(String t in streetsList)
	{
		if(!finishedMap.containsKey(t))
		{
			tsid = t;
			break;
		}
		else if(!finishedMap[t]['streetFinished'] && !finishedMap[t]['reportedBroken']
			&& !finishedMap[t]['reportedVandalized'] && !finishedMap[t]['reportedFinished'])
        	incomplete = t;
	}

	//tsid may still be null after this
	if(tsid == null)
		tsid = incomplete;

	return tsid;
}

/**
 * Taken from https://stackoverflow.com/questions/20207855/in-dart-given-a-type-name-how-do-you-get-the-type-class-itself/20450672#20450672
 *
 * This method will return a ClassMirror for a class whose name
 * exactly matches the string provided.
 *
 * In the event that a class matching that name does not exist, it will throw
 * an ArgumentError
 **/
ClassMirror findClassMirror(String name)
{
	for (LibraryMirror lib in currentMirrorSystem().libraries.values)
	{
        DeclarationMirror mirror = lib.declarations[MirrorSystem.getSymbol(name)];
        if (mirror != null)
        	return mirror;
  	}
  	throw new ArgumentError("Class $name does not exist");
}

String createId(num x, num y, String type, String tsid)
{
	return (type+x.toString()+y.toString()+tsid).hashCode.toString();
}

/**
 *
 * Log a message out to the console (and possibly a log file through redirection)
 *
 **/
void log(String message)
{
	print("(${new DateTime.now().toString()}) $message");
}

@app.Route('/getSpritesheets')
Future<Map> getSpritesheets(@app.QueryParam('username') String username)
{
	Completer c = new Completer();
	Map<String,String> spritesheets = {};
	File cache = new File('./playerSpritesheets/${username.toLowerCase()}.json');
	if(!cache.existsSync())
	{
		cache.create(recursive:true).then((File cache)
		{
			_getSpritesheetsFromWeb(username).then((Map spritesheets)
    		{
    			cache.writeAsString(JSON.encode(spritesheets))
    				.then((_) => c.complete(spritesheets));
    		});
		});
	}
	else
	{
		try
		{
			c.complete(JSON.decode(cache.readAsStringSync()));
		}
		catch(err){c.complete({});}
	}

	return c.future;
}

Future<Map> _getSpritesheetsFromWeb(String username)
{
	Completer c = new Completer();
	Map spritesheets = {};

	String url = 'http://www.glitchthegame.com/friends/search/?q=${Uri.encodeComponent(username)}';
	http.read(url)
	.then((String response)
	{
		RegExp regex = new RegExp('\/profiles\/(.+)\/" class="friend-name">$username',caseSensitive:false);
		if(regex.hasMatch(response))
		{
			String tsid = regex.firstMatch(response).group(1);

			http.read('http://www.glitchthegame.com/profiles/$tsid').then((String response)
			{
				List<String> sheets = ['base','angry','climb','happy','idle1','idle2','idle3','idleSleepy','jump','surprise'];
				sheets.forEach((String sheet)
                {
                	RegExp regex = new RegExp('"(.+$sheet\.png)"');
                	spritesheets[sheet] = regex.firstMatch(response).group(1);
        		});
				c.complete(spritesheets);
			});
		}
		else
			c.complete(spritesheets);
	});

	return c.future;
}

@app.Route('/getItemByName')
Map getItemByName(@app.QueryParam('name') String name)
{
	try
	{
		ClassMirror classMirror = findClassMirror(name.replaceAll(' ', ''));
		Item item = classMirror.newInstance(new Symbol(""), []).reflectee;
		return item.getMap();
	}
	catch(err)
	{
		return {'status':'FAIL','reason':'Could not find item: $name'};
	}
}

@app.Route('/getStreetFillerStats')
Future<Map> getStreetFillerStats()
{
	Completer c = new Completer();
	File finished = _getFinishedFile();
	finished.readAsString().then((String str)
	{
		File file = new File('./streetEntities/streets.json');
    	Map streets = JSON.decode(file.readAsStringSync());

		int trulyFinished = 0;
		int reportedBroken = 0;
		int reportedFinished = 0;
		int reportedVandalized = 0;
		int entitiesRequired = 0;
		int entitiesComplete = 0;
		Map<String,int> typeTotals = {};

		Map finishedMap = JSON.decode(str);
		finishedMap.forEach((String key, Map value)
		{
			if(value['streetFinished'] == true)
				trulyFinished++;
			if(value['reportedBroken'] == true)
				reportedBroken++;
			if(value['reportedFinished'] == true)
				reportedFinished++;
			if(value['reportedVandalized'] == true)
				reportedVandalized++;
			if(value['entitiesRequired'] != null && value['entitiesRequired'] != -1)
				entitiesRequired += num.parse(value['entitiesRequired'].toString());
			if(value['entitiesComplete'] != null && value['entitiesComplete'] != -1)
				entitiesComplete += num.parse(value['entitiesComplete'].toString());
		});

		Directory dir = new Directory('./streetEntities');
		for(File f in dir.listSync())
		{
			if(f.path.contains('.bak') || f.path.contains('streets.json')
					|| f.path.contains('finished.json'))
				continue;

			Map entityData = JSON.decode(f.readAsStringSync());
			List<Map> entities = entityData['entities'];
			entities.forEach((Map entity)
			{
				if(typeTotals.containsKey(entity['type']))
					typeTotals[entity['type']]++;
				else
					typeTotals[entity['type']] = 1;
			});
		}
		Map data = {'totalStreets':streets.length,'totalReports':finishedMap.length,
		            'entitiesRequired':entitiesRequired,'entitiesComplete':entitiesComplete,
		            'reportedBroken':reportedBroken,'reportedComplete':reportedFinished,
		            'reportedVandalized':reportedVandalized,'typeTotals':typeTotals};
		c.complete(data);
	});

	return c.future;
}

@app.Route('/getInventory/:username')
@Encode()
Future<Inventory> getUserInventory(@app.Attr() PostgreSql dbConn, String username)
{
	Completer c = new Completer();
	String queryString = "select username,inventory_json from inventories where username = @username";
    dbConn.query(queryString,Inventory,{'username':username}).then((List<Inventory> inventories)
    {
    	Inventory inventory = new Inventory()..username=username..inventory_json='[]';
		if(inventories.length > 0)
			inventory = inventories.first;

		c.complete(inventory);
    });

    return c.future;
}

Future<int> addItemToUser(WebSocket userSocket, String username, Map item, int count, String fromObject)
{
	Completer c = new Completer();
	dbManager.getConnection().then((PostgreSql dbConn)
	{
		getUserInventory(dbConn,username).then((Inventory inventory)
    	{
			//save the item in the user's inventory in the database
  			//then send it to the client
    		inventory.addItem(item, count, dbConn).then((int numRows)
    		{
    			sendItemToUser(userSocket,item,count,fromObject);
    			dbManager.closeConnection(dbConn);
    			c.complete(numRows);
    		});
    	});
	});

	return c.future;
}

Future<int> takeItemFromUser(WebSocket userSocket, String username, String itemName, int count)
{
	Completer c = new Completer();
	dbManager.getConnection().then((PostgreSql dbConn)
	{
		getUserInventory(dbConn,username).then((Inventory inventory)
    	{
			inventory.takeItem(itemName,count,dbConn).then((int rowsUpdated)
			{
				if(rowsUpdated > 0)
					takeItem(userSocket,itemName,count);
				dbManager.closeConnection(dbConn);
				c.complete(rowsUpdated);
			});
    	});
	});

	return c.future;
}

Future fireInventoryAtUser(WebSocket userSocket, String username)
{
	Completer c = new Completer();
	dbManager.getConnection().then((PostgreSql dbConn)
    {
		getUserInventory(dbConn,username).then((Inventory inventory)
		{
			inventory.getItems().forEach((Map item)
			{
				sendItemToUser(userSocket,item,1,'');
            });
			dbManager.closeConnection(dbConn);
			c.complete();
		});
    });

	return c.future;
}

sendItemToUser(WebSocket userSocket, Map item, int count, String fromObject)
{
	Map map = {};
	map['giveItem'] = "true";
	map['item'] = item;
	map['num'] = count;
	map['fromObject'] = fromObject;
	userSocket.add(JSON.encode(map));
}

takeItem(WebSocket userSocket, String itemName, int count)
{
	Map map = {};
	map['takeItem'] = "true";
	map['name'] = itemName;
	map['count'] = count;
	userSocket.add(JSON.encode(map));
}
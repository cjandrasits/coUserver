library coUserver;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:mirrors';

import "package:intl/intl.dart";
import "package:slack/slack_io.dart" as slack;
import "package:postgresql/postgresql.dart";
import "package:redstone/server.dart" as app;
import 'package:logging/logging.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:redstone_web_socket/redstone_web_socket.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:http/http.dart' as http;

part 'server.dart';
part 'API_KEYS.dart';
part 'auctions_service.dart';

//common to all server parts
part 'common/identifier.dart';

//chat server parts
part 'chatServer/irc_relay.dart';
part 'chatServer/keep_alive.dart';
part 'chatServer/chat_handler.dart';

//multiplayer server parts
part 'multiplayerServer/player_update_handler.dart';

//npc server (street simulation) parts
part 'npcServer/street_update_handler.dart';
part 'npcServer/street.dart';
part 'npcServer/npcs/piggy.dart';
part 'npcServer/entity.dart';
part 'npcServer/npcs/npc.dart';
part 'npcServer/npcs/streetspiritgroddle.dart';
part 'npcServer/npcs/chicken.dart';

//items
part 'npcServer/npcs/items/item.dart';
part 'npcServer/npcs/items/tool.dart';
part 'npcServer/npcs/items/highclasshoe.dart';
part 'npcServer/npcs/items/fancypick.dart';
part 'npcServer/npcs/items/pick.dart';
part 'npcServer/npcs/items/shovel.dart';
part 'npcServer/npcs/items/bean.dart';
part 'npcServer/npcs/items/cherry.dart';
part 'npcServer/npcs/items/grain.dart';
part 'npcServer/npcs/items/meat.dart';
part 'npcServer/npcs/items/chunkofberyl.dart';
part 'npcServer/npcs/items/chunkofsparkly.dart';
part 'npcServer/npcs/items/chunkofmetalrock.dart';
part 'npcServer/npcs/items/chunkofdullite.dart';
part 'npcServer/npcs/items/modestlysizedruby.dart';
part 'npcServer/npcs/items/generalvapour.dart';
part 'npcServer/npcs/items/allspice.dart';
part 'npcServer/npcs/items/paper.dart';
part 'npcServer/npcs/items/egg.dart';
part 'npcServer/npcs/items/plainbubble.dart';
part 'npcServer/npcs/items/plank.dart';
part 'npcServer/npcs/items/lumpofearth.dart';
part 'npcServer/npcs/items/lumpofloam.dart';

part 'npcServer/spritesheet.dart';
part 'npcServer/plants/plant.dart';
part 'npcServer/plants/tree.dart';
part 'npcServer/plants/fruittree.dart';
part 'npcServer/plants/beantree.dart';
part 'npcServer/plants/gasplant.dart';
part 'npcServer/plants/spiceplant.dart';
part 'npcServer/plants/papertree.dart';
part 'npcServer/plants/eggplant.dart';
part 'npcServer/plants/bubbletree.dart';
part 'npcServer/plants/woodtree.dart';

part 'npcServer/plants/dirtpile.dart';

part 'npcServer/plants/rock.dart';
part 'npcServer/plants/berylrock.dart';
part 'npcServer/plants/sparklyrock.dart';
part 'npcServer/plants/dulliterock.dart';
part 'npcServer/plants/metalrock.dart';
part 'npcServer/quoin.dart';

//various http parts (as opposed to the previous websocket parts)
part 'util.dart';
part 'auction.dart';
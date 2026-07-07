//Decompiled code. Please respect the original copyright.

void() SetMonsterStuff =
{
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.orig_angle = self.angles;
	self.hasmoved = FALSE;
	if ((cvar("coop") <= SPAWN_CRUCIFIED))
	{
		if ((self.chess_team == "black"))
		{
			self.skin = SPAWN_CRUCIFIED;
		}
		else
		{
			self.skin = SPAWNFLAG_LASER;
		}
	}
	else
	{
		if ((cvar("coop") == AS_MELEE))
		{
			self.skin = AS_MELEE;
		}
	}
};

void() chess_pawn =
{
	if ((cvar("coop") != 69))
	{
		monster_knight();
	}
	else
	{
		monster_dog();
	}
	SetMonsterStuff();
	self.netname = "pawn";
};

void() chess_rook =
{
	if ((cvar("coop") != 69))
	{
		monster_ogre();
	}
	else
	{
		monster_enforcer();
	}
	SetMonsterStuff();
	self.netname = "rook";
};

void() chess_knight =
{
	if ((cvar("coop") != 69))
	{
		monster_demon1();
	}
	else
	{
		monster_wizard();
	}
	SetMonsterStuff();
	self.netname = "knight";
};

void() chess_bishop =
{
	if ((cvar("coop") != 69))
	{
		monster_hell_knight();
	}
	else
	{
		monster_army();
	}
	SetMonsterStuff();
	self.netname = "bishop";
};

void() chess_queen =
{
	secret_monsters = MSG_BROADCAST;
	if ((cvar("coop") != 69))
	{
		monster_shambler();
	}
	else
	{
		monster_shalrath();
		secret_monsters = SPAWN_CRUCIFIED;
	}
	SetMonsterStuff();
	self.netname = "queen";
};

void() chess_king =
{
	monster_zombie();
	SetMonsterStuff();
	self.netname = "king";
};

float(float loc) GetX =
{
	return (floor((loc / 10)));
};

float(float loc) GetY =
{
	local float x;

	x = GetX(loc);
	return ((loc - (x * 10)));
};

float() TwoPlayersInGame =
{
	local float num_players;
	local entity trav;

	num_players = MSG_BROADCAST;
	trav = find(world, classname, "player");
	while ((trav != world))
	{
		num_players = (num_players + SPAWN_CRUCIFIED);
		trav = find(trav, classname, "player");
	}
	return ((num_players == SPAWNFLAG_LASER));
};

void() FindLocation =
{
	local vector v1;
	local float loc;

	if (!cvar("movehints"))
	{
		if ((move_hint_piece != world))
			ClearMoveHints();
	}
	else
	{
		if ((move_hint_piece == world))
		{
			if (((current_turn != world) && (current_selected != world)))
			{
				if (((current_turn.is_bot == FALSE) && (current_turn.chess_flags & CF_SELECTED_PIECE)))
					ShowMoveHints(current_selected);
			}
		}
	}
	makevectors(self.v_angle);
	traceline(self.origin, (self.origin + (v_forward * 4000)), TRUE, self);
	current_destination = string_null;
	if ((trace_fraction < SPAWN_CRUCIFIED))
	{
		v1 = (trace_endpos + '256 256 0');
		v1_x = (v1_x / IT_LIGHTNING);
		v1_y = (v1_y / IT_LIGHTNING);
		v1_z = MSG_BROADCAST;
		v1_y = ceil(v1_y);
		if ((v1_y > 8))
		{
			v1_y = 8;
		}
		if ((v1_y < SPAWN_CRUCIFIED))
		{
			v1_y = SPAWN_CRUCIFIED;
		}
		v1_x = ceil(v1_x);
		if ((v1_x > 8))
		{
			v1_x = 8;
		}
		if ((v1_x < SPAWN_CRUCIFIED))
		{
			v1_x = SPAWN_CRUCIFIED;
		}
		loc = ((v1_x * 10) + v1_y);
		current_destination = ftos(loc);
		current_dest_int = loc;
	}
};

void() FindSelection =
{
	local float old_loc;

	old_loc = current_dest_int;
	FindLocation();
	if ((old_loc != current_dest_int))
	{
		current_selected = EntityAtLoc(current_dest_int);
	}
	if (((old_loc != current_dest_int) && (last_highlight != world)))
	{
		setorigin(last_highlight, last_highlight.pos2);
		last_highlight.pos2 = last_highlight.pos1;
		last_highlight.pos1 = last_highlight.origin;
		last_highlight = world;
	}
	if (((old_loc != current_dest_int) && (current_selected != world)))
	{
		if ((current_selected.owner == current_turn))
		{
			HighlightLocation(current_dest_int);
		}
		else
		{
			current_selected = world;
		}
	}
	if (((((!game_checkers && (current_selected != world)) && (current_selected.owner == current_turn)) && (self.last_voice_entity.classname != current_selected.classname)) && (self.last_voice < (time - 1.5))))
	{
		mystuffcmd(current_turn, "play voice/");
		mystuffcmd(current_turn, current_selected.netname);
		mystuffcmd(current_turn, ".wav\n");
		self.last_voice = time;
		self.last_voice_entity = current_selected;
	}
};

void(entity plyr) AllocateMonsters =
{
	local entity monst;
	local string plyr_team;

	if ((game_checkers && !checkers_board_spawned))
	{
		SpawnCheckersBoard();
	}
	plyr_team = plyr.chess_team;
	monst = find(world, chess_team, plyr_team);
	while ((monst != world))
	{
		if (((monst.flags & FL_MONSTER) || monst.ischecker))
		{
			monst.owner = plyr;
		}
		monst = find(monst, chess_team, plyr_team);
	}
	UpdateMonsterColors(plyr);
};

float(float start, float end) ClearPath =
{
	local float step;
	local float loc;
	local float startx;
	local float starty;
	local float endx;
	local float endy;

	startx = GetX(start);
	starty = GetY(start);
	endx = GetX(end);
	endy = GetY(end);
	step = MSG_BROADCAST;
	if ((endy > starty))
	{
		step = SPAWN_CRUCIFIED;
	}
	else
	{
		if ((endy < starty))
		{
			step = CONTENT_EMPTY;
		}
	}
	if ((endx > startx))
	{
		step = (step + 10);
	}
	else
	{
		if ((endx < startx))
		{
			step = (step - 10);
		}
	}
	loc = (start + step);
	while ((loc != end))
	{
		if ((EntityAtLoc(loc) != world))
		{
			return (FALSE);
		}
		loc = (loc + step);
	}
	return (TRUE);
};

float(float loc) CheckersOnBoard =
{
	local float x;
	local float y;

	x = GetX(loc);
	y = GetY(loc);
	return (((x >= 1) && (x <= 8)) && ((y >= 1) && (y <= 8)));
};

void() ClearMoveHints =
{
	local entity hint;
	local entity next_hint;

	hint = move_hint_list;
	while ((hint != world))
	{
		next_hint = hint.move_hint_next;
		remove(hint);
		hint = next_hint;
	}
	move_hint_list = world;
	move_hint_piece = world;
};

void(float loc, float is_capture) AddMoveHint =
{
	local entity hint;
	local vector hint_origin;

	hint = spawn();
	hint.classname = "move_hint";
	hint.movetype = MOVETYPE_NONE;
	hint.solid = SOLID_NOT;
	setmodel(hint, "progs/s_light.spr");
	hint.angles = '90 0 0';
	hint.scale = 0.2;
	if (is_capture)
		hint.colormod = '1 1 0.1';
	else
		hint.colormod = '0.1 1 0.1';
	hint_origin = (LocationToVector(loc) + '0 0 -22');
	setorigin(hint, hint_origin);
	hint.move_hint_next = move_hint_list;
	move_hint_list = hint;
};

float(entity piece, float candidate) CheckersHintLocation =
{
	local float x;
	local float y;

	x = GetX(piece.location);
	y = GetY(piece.location);
	if ((candidate == 1)) return (((x + 1) * 10) + y + 1);
	if ((candidate == 2)) return (((x + 1) * 10) + y - 1);
	if ((candidate == 3)) return (((x - 1) * 10) + y + 1);
	if ((candidate == 4)) return (((x - 1) * 10) + y - 1);
	if ((candidate == 5)) return (((x + 2) * 10) + y + 2);
	if ((candidate == 6)) return (((x + 2) * 10) + y - 2);
	if ((candidate == 7)) return (((x - 2) * 10) + y + 2);
	return (((x - 2) * 10) + y - 2);
};

void(entity piece) ShowMoveHints =
{
	local entity forced_piece;
	local float candidate;
	local float candidate_count;
	local float loc;

	ClearMoveHints();
	if (!cvar("movehints"))
		return;
	if ((piece == world))
		return;
	if ((current_turn == world))
		return;
	if (current_turn.is_bot)
		return;
	if (((piece.owner != current_turn) || action_flag) || gameover)
		return;
	move_hint_piece = piece;
	if (game_checkers)
	{
		forced_piece = world;
		if (checkers_must_jump)
			forced_piece = piece;
		candidate = 1;
		while ((candidate <= 8))
		{
			loc = CheckersHintLocation(piece, candidate);
			if (CheckersBotMoveAllowed(current_turn, forced_piece, piece, loc))
				AddMoveHint(loc, CheckersBotMoveIsJump(piece, loc));
			candidate = (candidate + 1);
		}
		return;
	}
	ChessRebuildOccupancy();
	candidate_count = ChessCandidateCount(piece);
	candidate = 1;
	while ((candidate <= candidate_count))
	{
		loc = ChessCandidateLocation(piece, candidate);
		if (ChessMoveIsLegal(piece, loc, 1))
			AddMoveHint(loc, (ChessCapturedForMove(piece, loc) != world));
		if (ChessCandidateEndsRay(piece, candidate, loc))
			candidate = (floor(((candidate - 1) / 7)) * 7) + 7;
		candidate = (candidate + 1);
	}
};

void() ClearSelectionEffect =
{
	ClearMoveHints();
	if ((selection_effect_piece != world))
	{
		selection_effect_piece.effects = (selection_effect_piece.effects - (selection_effect_piece.effects & EF_RED));
		selection_effect_piece = world;
	}
	if ((light_ent != world))
	{
		light_ent.effects = MSG_BROADCAST;
	}
};

void(entity piece) ShowSelectionEffect =
{
	ClearSelectionEffect();
	if ((piece == world))
	{
		return;
	}
	if (cvar("pr_checkextension"))
	{
		if (checkextension("DP_EF_RED"))
		{
			piece.effects = (piece.effects | EF_RED);
			selection_effect_piece = piece;
			return;
		}
	}
	if ((light_ent != world))
	{
		setorigin(light_ent, (piece.origin + '0 0 96'));
		light_ent.effects = EF_DIMLIGHT;
	}
};

void() CheckersClearCaptureTarget =
{
	checkers_capture_entity = world;
	checkers_capture_location = 0;
	if ((current_selected != world))
	{
		current_selected.enemy = world;
	}
};

void() CheckersClearTurnState =
{
	checkers_must_jump = FALSE;
	checkers_was_jump = FALSE;
	CheckersClearCaptureTarget();
	ClearSelectionEffect();
	current_selected = world;
};

void(string team_name, float loc) SpawnCheckerMan =
{
	local entity oldself;
	local entity piece;

	piece = spawn();
	oldself = self;
	self = piece;
	self.classname = "chess_pawn";
	self.chess_team = team_name;
	self.location = loc;
	self.location_str = ftos(loc);
	self.ischecker = TRUE;
	self.isking = FALSE;
	if ((team_name == "black"))
	{
		self.angles = '0 270 0';
	}
	else
	{
		self.angles = '0 90 0';
	}
	setorigin(self, LocationToVector(loc));
	monster_knight();
	SetMonsterStuff();
	self.flags = (self.flags | FL_MONSTER);
	self.takedamage = DAMAGE_AIM;
	self.pausetime = 100000000;
	self.use = monster_use;
	self.classname = "chess_pawn";
	self.netname = "man";
	self.chess_team = team_name;
	self.location = loc;
	self.location_str = ftos(loc);
	self.ischecker = TRUE;
	self.isking = FALSE;
	SetBoardPieceOrigin(self);
	self = oldself;
};

void(string team_name, float y, float startx) SpawnCheckersRank =
{
	local float x;

	x = startx;
	while ((x <= 8))
	{
		SpawnCheckerMan(team_name, ((x * 10) + y));
		x = (x + 2);
	}
};

float(entity ent) IsChessBoardPiece =
{
	if ((ent.classname == "chess_pawn"))
	{
		return (TRUE);
	}
	if ((ent.classname == "chess_rook"))
	{
		return (TRUE);
	}
	if ((ent.classname == "chess_knight"))
	{
		return (TRUE);
	}
	if ((ent.classname == "chess_bishop"))
	{
		return (TRUE);
	}
	if ((ent.classname == "chess_queen"))
	{
		return (TRUE);
	}
	if ((ent.classname == "chess_king"))
	{
		return (TRUE);
	}
	return (FALSE);
};

void(string team_name) RemoveChessTeamPieces =
{
	local entity trav;
	local entity gone;

	trav = find(world, chess_team, team_name);
	while ((trav != world))
	{
		gone = trav;
		trav = find(trav, chess_team, team_name);
		if (((gone.flags & FL_MONSTER) || IsChessBoardPiece(gone)))
		{
			remove(gone);
		}
	}
};

void(string team_name, string piece_class, float loc) SpawnChessPiece =
{
	local entity oldself;
	local entity piece;

	piece = spawn();
	oldself = self;
	self = piece;
	self.classname = piece_class;
	self.chess_team = team_name;
	self.location = loc;
	self.location_str = ftos(loc);
	self.ischecker = FALSE;
	self.isking = FALSE;
	if ((team_name == "black"))
	{
		self.angles = '0 270 0';
	}
	else
	{
		self.angles = '0 90 0';
	}
	setorigin(self, LocationToVector(loc));
	if ((piece_class == "chess_pawn"))
	{
		chess_pawn();
	}
	else
	{
		if ((piece_class == "chess_rook"))
		{
			chess_rook();
		}
		else
		{
			if ((piece_class == "chess_knight"))
			{
				chess_knight();
			}
			else
			{
				if ((piece_class == "chess_bishop"))
				{
					chess_bishop();
				}
				else
				{
					if ((piece_class == "chess_queen"))
					{
						chess_queen();
					}
					else
					{
						chess_king();
					}
				}
			}
		}
	}
	self.flags = (self.flags | FL_MONSTER);
	self.takedamage = DAMAGE_AIM;
	self.pausetime = 100000000;
	self.use = monster_use;
	self.classname = piece_class;
	self.chess_team = team_name;
	self.location = loc;
	self.location_str = ftos(loc);
	self.ischecker = FALSE;
	self.isking = FALSE;
	self.hasmoved = FALSE;
	SetBoardPieceOrigin(self);
	self = oldself;
};

void(string team_name, float y) SpawnChessBackRank =
{
	SpawnChessPiece(team_name, "chess_rook", (10 + y));
	SpawnChessPiece(team_name, "chess_knight", (20 + y));
	SpawnChessPiece(team_name, "chess_bishop", (30 + y));
	SpawnChessPiece(team_name, "chess_queen", (40 + y));
	SpawnChessPiece(team_name, "chess_king", (50 + y));
	SpawnChessPiece(team_name, "chess_bishop", (60 + y));
	SpawnChessPiece(team_name, "chess_knight", (70 + y));
	SpawnChessPiece(team_name, "chess_rook", (80 + y));
};

void(string team_name, float y) SpawnChessPawns =
{
	local float x;

	x = 1;
	while ((x <= 8))
	{
		SpawnChessPiece(team_name, "chess_pawn", ((x * 10) + y));
		x = (x + 1);
	}
};

void() SpawnChessBoard =
{
	RemoveChessTeamPieces("white");
	RemoveChessTeamPieces("black");
	SpawnChessBackRank("white", 1);
	SpawnChessPawns("white", 2);
	SpawnChessPawns("black", 7);
	SpawnChessBackRank("black", 8);
	checkers_board_spawned = FALSE;
	CheckersClearTurnState();
	if (cvar("cq_debug"))
		bprint("** crownquake chess mode: board spawned\n");
};

void() SpawnCheckersBoard =
{
	if (checkers_board_spawned)
	{
		return;
	}
	RemoveChessTeamPieces("white");
	RemoveChessTeamPieces("black");
	SpawnCheckersRank("white", 1, 1);
	SpawnCheckersRank("white", 2, 2);
	SpawnCheckersRank("white", 3, 1);
	SpawnCheckersRank("black", 6, 2);
	SpawnCheckersRank("black", 7, 1);
	SpawnCheckersRank("black", 8, 2);
	CheckersClearTurnState();
	checkers_board_spawned = TRUE;
	if (cvar("cq_debug"))
		bprint("** crownquake checkers mode: board spawned\n");
};

void(float use_checkers) ResetGameToMode =
{
	ChessPerftCancel();
	CheckersCancelBotSearch();
	ChessCancelBotSearch();
	ClearSelectionEffect();
	game_checkers = use_checkers;
	gameover = FALSE;
	action_flag = FALSE;
	king_dead = FALSE;
	ralcheckmate = FALSE;
	Queening = MSG_BROADCAST;
	QueenEnt = world;
	QueenTo = "";
	current_enemy = world;
	current_selected = world;
	current_dest_int = MSG_BROADCAST;
	LastMoved = world;
	LastMovedLocation = MSG_BROADCAST;
	movenum = MSG_BROADCAST;
	UndoResetStack();
	ChessBotResetRepetition();
	if ((GetBody != world))
	{
		remove(GetBody);
		GetBody = world;
	}
	ClearLastHighlight();
	if (game_checkers)
	{
		checkers_board_spawned = FALSE;
		SpawnCheckersBoard();
	}
	else
	{
		SpawnChessBoard();
	}
	if ((player1 != world))
	{
		player1.frags = MSG_BROADCAST;
		player1.currentammo = MSG_BROADCAST;
		player1.chess_flags = MSG_BROADCAST;
		player1.skin = 1;
		player1.last_moved = world;
		player1.last_move_from = MSG_BROADCAST;
		player1.last_move_to = MSG_BROADCAST;
		AllocateMonsters(player1);
	}
	if ((player2 != world))
	{
		player2.frags = MSG_BROADCAST;
		player2.currentammo = MSG_BROADCAST;
		player2.chess_flags = MSG_BROADCAST;
		player2.skin = 1;
		player2.last_moved = world;
		player2.last_move_from = MSG_BROADCAST;
		player2.last_move_to = MSG_BROADCAST;
		AllocateMonsters(player2);
	}
	CheckersApplyBotCvars();
	if ((player2 != world))
	{
		current_turn = player2;
	}
	else
	{
		current_turn = player1;
	}
	CheckersResetDrawState();
	if ((current_turn != world))
	{
		current_turn.turn_starttime = time;
		if (((single_player && !current_turn.is_bot) && !current_turn.opponent.is_bot))
		{
			setorigin(current_turn.owner, current_turn.origin);
			current_turn.owner.angles = current_turn.angles;
			current_turn.owner.fixangle = TRUE;
		}
		mycentreprint(current_turn, "New game\n");
		mystuffcmd(current_turn, "bf\n");
		UndoPushSnapshot();
		ChessBotRecordPosition(current_turn);
	}
	CheckersMaybeScheduleBotTurn();
	ChessMaybeScheduleBotTurn();
};

float(entity ent, float loc) CheckersCanStepTo =
{
	local float oldy;
	local float newx;
	local float newy;
	local float xchange;
	local float ychange;

	if (!CheckersOnBoard(loc))
	{
		return (FALSE);
	}
	if ((EntityAtLoc(loc) != world))
	{
		return (FALSE);
	}
	oldy = GetY(ent.location);
	newx = GetX(loc);
	newy = GetY(loc);
	xchange = (newx - GetX(ent.location));
	ychange = (newy - oldy);
	if (((fabs(xchange) != 1) || (fabs(ychange) != 1)))
	{
		return (FALSE);
	}
	if (ent.isking)
	{
		return (TRUE);
	}
	if ((ent.chess_team == "white"))
	{
		return ((ychange == 1));
	}
	return ((ychange == -1));
};

float(entity ent, float loc) CheckersCanJumpTo =
{
	local float oldx;
	local float oldy;
	local float newx;
	local float newy;
	local float xchange;
	local float ychange;
	local float midloc;
	local entity mid;

	if (!CheckersOnBoard(loc))
	{
		return (FALSE);
	}
	if ((EntityAtLoc(loc) != world))
	{
		return (FALSE);
	}
	oldx = GetX(ent.location);
	oldy = GetY(ent.location);
	newx = GetX(loc);
	newy = GetY(loc);
	xchange = (newx - oldx);
	ychange = (newy - oldy);
	if (((fabs(xchange) != 2) || (fabs(ychange) != 2)))
	{
		return (FALSE);
	}
	if (!ent.isking)
	{
		if (((ent.chess_team == "white") && (ychange != 2)))
		{
			return (FALSE);
		}
		if (((ent.chess_team == "black") && (ychange != -2)))
		{
			return (FALSE);
		}
	}
	midloc = ((((oldx + newx) / 2) * 10) + ((oldy + newy) / 2));
	mid = EntityAtLoc(midloc);
	if ((mid == world))
	{
		return (FALSE);
	}
	if (((mid.owner == ent.owner) || (mid.chess_team == ent.chess_team)))
	{
		return (FALSE);
	}
	if ((mid.health <= 0))
	{
		return (FALSE);
	}
	return (TRUE);
};

float(entity ent) CheckersPieceCanJump =
{
	if (((ent == world) || !ent.ischecker))
	{
		return (FALSE);
	}
	if (CheckersCanJumpTo(ent, (ent.location + 22)))
	{
		return (TRUE);
	}
	if (CheckersCanJumpTo(ent, (ent.location - 18)))
	{
		return (TRUE);
	}
	if (CheckersCanJumpTo(ent, (ent.location + 18)))
	{
		return (TRUE);
	}
	if (CheckersCanJumpTo(ent, (ent.location - 22)))
	{
		return (TRUE);
	}
	return (FALSE);
};

entity(entity side_owner) CheckersFirstCapturePiece =
{
	local entity trav;

	if ((side_owner == world))
	{
		return (world);
	}
	trav = find(world, chess_team, side_owner.chess_team);
	while ((trav != world))
	{
		if ((((trav.flags & FL_MONSTER) && (trav.health > 0)) && trav.ischecker))
		{
			if (CheckersPieceCanJump(trav))
			{
				return (trav);
			}
		}
		trav = find(trav, chess_team, side_owner.chess_team);
	}
	return (world);
};

float(entity ent) CheckersPieceCanStep =
{
	if (((ent == world) || !ent.ischecker))
	{
		return (FALSE);
	}
	if (CheckersCanStepTo(ent, (ent.location + 11)))
	{
		return (TRUE);
	}
	if (CheckersCanStepTo(ent, (ent.location - 9)))
	{
		return (TRUE);
	}
	if (CheckersCanStepTo(ent, (ent.location + 9)))
	{
		return (TRUE);
	}
	if (CheckersCanStepTo(ent, (ent.location - 11)))
	{
		return (TRUE);
	}
	return (FALSE);
};

float(entity side_owner) CheckersAnyCaptureAvailable =
{
	return (CheckersFirstCapturePiece(side_owner) != world);
};

// Cached form of the above for the bot search. Whether a side has a mandatory
// capture depends only on the side and the current board, but move generation
// asks it once per candidate (~96 times per node), each time re-scanning every
// piece. The cache collapses that to one scan per node; it is only trusted while
// a search is running (checkers_bot_capture_cache_on) and is invalidated on every
// make/unmake so it can never return a stale answer.
float(entity side_owner) CheckersBotSideHasCapture =
{
	if (((checkers_bot_capture_cache_on && checkers_bot_capture_valid) && (checkers_bot_capture_side == side_owner)))
		return (checkers_bot_capture_value);
	checkers_bot_capture_value = (CheckersFirstCapturePiece(side_owner) != world);
	checkers_bot_capture_side = side_owner;
	checkers_bot_capture_valid = TRUE;
	return (checkers_bot_capture_value);
};

float(entity side_owner) CheckersSideHasLegalMove =
{
	local entity trav;

	if ((side_owner == world))
	{
		return (FALSE);
	}
	trav = find(world, chess_team, side_owner.chess_team);
	while ((trav != world))
	{
		if ((((trav.flags & FL_MONSTER) && (trav.health > 0)) && trav.ischecker))
		{
			if (CheckersPieceCanJump(trav))
			{
				return (TRUE);
			}
			if (CheckersPieceCanStep(trav))
			{
				return (TRUE);
			}
		}
		trav = find(trav, chess_team, side_owner.chess_team);
	}
	return (FALSE);
};

float(entity side) CheckersSideCode =
{
	if (((side != world) && (side.chess_team == "white")))
		return (1);
	return (2);
};

void() CheckersBuildPositionSignature =
{
	local entity piece;
	local float i;
	local float square;
	local float half;
	local float bit_index;
	local float bit;
	local float bucket;

	i = MSG_BROADCAST;
	while ((i < 8))
	{
		checkers_signature[i] = MSG_BROADCAST;
		i = (i + 1);
	}
	piece = find(world, chess_team, "white");
	while ((piece != world))
	{
		if ((((piece.flags & FL_MONSTER) && (piece.health > MSG_BROADCAST)) && piece.ischecker))
		{
			square = floor(((((GetX(piece.location) - 1) * 8) + (GetY(piece.location) - 1)) / 2));
			half = floor((square / 16));
			bit_index = (square - (half * 16));
			bit = 1;
			i = MSG_BROADCAST;
			while ((i < bit_index))
			{
				bit = (bit * 2);
				i = (i + 1);
			}
			bucket = half;
			if (piece.isking)
				bucket = (bucket + 2);
			checkers_signature[bucket] = (checkers_signature[bucket] + bit);
		}
		piece = find(piece, chess_team, "white");
	}
	piece = find(world, chess_team, "black");
	while ((piece != world))
	{
		if ((((piece.flags & FL_MONSTER) && (piece.health > MSG_BROADCAST)) && piece.ischecker))
		{
			square = floor(((((GetX(piece.location) - 1) * 8) + (GetY(piece.location) - 1)) / 2));
			half = floor((square / 16));
			bit_index = (square - (half * 16));
			bit = 1;
			i = MSG_BROADCAST;
			while ((i < bit_index))
			{
				bit = (bit * 2);
				i = (i + 1);
			}
			bucket = (4 + half);
			if (piece.isking)
				bucket = (bucket + 2);
			checkers_signature[bucket] = (checkers_signature[bucket] + bit);
		}
		piece = find(piece, chess_team, "black");
	}
};

float(float slot, float side_code) CheckersHistoryPositionMatches =
{
	local float i;
	local float base;

	if ((checkers_history_side[slot] != side_code))
		return (FALSE);
	base = (slot * 8);
	i = MSG_BROADCAST;
	while ((i < 8))
	{
		if ((checkers_history_board[(base + i)] != checkers_signature[i]))
			return (FALSE);
		i = (i + 1);
	}
	return (TRUE);
};

float(float slot, float side_code) CheckersBotPathPositionMatches =
{
	local float i;
	local float base;

	if ((checkers_bot_path_side[slot] != side_code))
		return (FALSE);
	base = (slot * 8);
	i = MSG_BROADCAST;
	while ((i < 8))
	{
		if ((checkers_bot_path_board[(base + i)] != checkers_signature[i]))
			return (FALSE);
		i = (i + 1);
	}
	return (TRUE);
};

void(entity side) CheckersAppendHistoryPosition =
{
	local float slot;
	local float src;
	local float i;

	if ((side == world))
		return;
	if ((checkers_history_count >= CHECKERS_HISTORY_MAX))
	{
		slot = 1;
		while ((slot < CHECKERS_HISTORY_MAX))
		{
			src = (slot * 8);
			i = MSG_BROADCAST;
			while ((i < 8))
			{
				checkers_history_board[(((slot - 1) * 8) + i)] = checkers_history_board[(src + i)];
				i = (i + 1);
			}
			checkers_history_side[(slot - 1)] = checkers_history_side[slot];
			slot = (slot + 1);
		}
		checkers_history_count = (CHECKERS_HISTORY_MAX - 1);
	}
	CheckersBuildPositionSignature();
	slot = checkers_history_count;
	i = MSG_BROADCAST;
	while ((i < 8))
	{
		checkers_history_board[((slot * 8) + i)] = checkers_signature[i];
		i = (i + 1);
	}
	checkers_history_side[slot] = CheckersSideCode(side);
	checkers_history_count = (checkers_history_count + 1);
};

void(string reason) CheckersFinishDraw =
{
	CheckersCancelBotSearch();
	ChessCancelBotSearch();
	gameover = TRUE;
	action_flag = TRUE;
	game_draw_reason = reason;
	CheckersClearTurnState();
	ClearLastHighlight();
	bprint("\xC3\xE8\xE5\xE3\xEB\xE5\xF2\xF3: ");
	bprint(reason);
	bprint("\n");
	if ((current_turn != world))
		mycentreprint(current_turn, reason);
	if (((!single_player && (current_turn != world)) && (current_turn.opponent != world)))
		mycentreprint(current_turn.opponent, reason);
	UndoPushSnapshot();
	Menu_OpenGameOver(world);
};

void() CheckersResetDrawState =
{
	checkers_no_progress_plies = MSG_BROADCAST;
	checkers_turn_progress = FALSE;
	checkers_history_count = MSG_BROADCAST;
	checkers_bot_path_count = MSG_BROADCAST;
	checkers_bot_no_progress_plies = MSG_BROADCAST;
	game_draw_reason = "";
	if (((game_checkers && (current_turn != world))))
		CheckersAppendHistoryPosition(current_turn);
};

float(entity side) CheckersHistoryOccurrenceCount =
{
	local float slot;
	local float count;
	local float side_code;

	if ((side == world))
		return (MSG_BROADCAST);
	CheckersBuildPositionSignature();
	side_code = CheckersSideCode(side);
	slot = MSG_BROADCAST;
	count = MSG_BROADCAST;
	while ((slot < checkers_history_count))
	{
		if (CheckersHistoryPositionMatches(slot, side_code))
			count = (count + 1);
		slot = (slot + 1);
	}
	return (count);
};

float(entity side) CheckersRecordPositionAndCheckDraw =
{
	local float occurrences;

	if (((!game_checkers || (side == world)) || gameover))
		return (FALSE);
	if (checkers_turn_progress)
	{
		checkers_no_progress_plies = MSG_BROADCAST;
		checkers_history_count = MSG_BROADCAST;
	}
	else
	{
		checkers_no_progress_plies = (checkers_no_progress_plies + 1);
	}
	occurrences = CheckersHistoryOccurrenceCount(side);
	CheckersAppendHistoryPosition(side);
	checkers_turn_progress = FALSE;
	if ((occurrences >= 2))
	{
		CheckersFinishDraw("Draw by threefold repetition.");
		return (TRUE);
	}
	if ((checkers_no_progress_plies >= CHECKERS_NO_PROGRESS_LIMIT))
	{
		CheckersFinishDraw("Draw by 80-ply no-progress rule.");
		return (TRUE);
	}
	return (FALSE);
};

float(entity side) CheckersBotPositionOccurrenceCount =
{
	local float slot;
	local float count;
	local float side_code;

	if ((side == world))
		return (MSG_BROADCAST);
	CheckersBuildPositionSignature();
	side_code = CheckersSideCode(side);
	slot = MSG_BROADCAST;
	count = MSG_BROADCAST;
	while ((slot < checkers_history_count))
	{
		if (CheckersHistoryPositionMatches(slot, side_code))
			count = (count + 1);
		slot = (slot + 1);
	}
	slot = MSG_BROADCAST;
	while ((slot < checkers_bot_path_count))
	{
		if (CheckersBotPathPositionMatches(slot, side_code))
			count = (count + 1);
		slot = (slot + 1);
	}
	return (count);
};

float(entity side) CheckersBotPositionWouldRepeat =
{
	return ((CheckersBotPositionOccurrenceCount(side) >= 2));
};

void(entity side) CheckersBotPushPosition =
{
	local float slot;
	local float i;
	local float context1;
	local float context2;
	local float value;

	if (((side == world) || (checkers_bot_path_count >= CHECKERS_BOT_PATH_MAX)))
		return;
	CheckersBuildPositionSignature();
	slot = checkers_bot_path_count;
	context1 = checkers_bot_context_key1[slot];
	context2 = checkers_bot_context_key2[slot];
	i = MSG_BROADCAST;
	while ((i < 8))
	{
		checkers_bot_path_board[((slot * 8) + i)] = checkers_signature[i];
		value = (checkers_signature[i] + i + 1);
		context1 = ((context1 * 7) + value);
		context1 = (context1 - (floor((context1 / 1000003)) * 1000003));
		context2 = ((context2 * 11) + value + (i * 2));
		context2 = (context2 - (floor((context2 / 999983)) * 999983));
		i = (i + 1);
	}
	checkers_bot_path_side[slot] = CheckersSideCode(side);
	value = checkers_bot_path_side[slot];
	context1 = ((context1 * 7) + value + 1);
	context1 = (context1 - (floor((context1 / 1000003)) * 1000003));
	context2 = ((context2 * 11) + value + 3);
	context2 = (context2 - (floor((context2 / 999983)) * 999983));
	checkers_bot_context_key1[(slot + 1)] = context1;
	checkers_bot_context_key2[(slot + 1)] = context2;
	checkers_bot_path_count = (checkers_bot_path_count + 1);
};

float(entity ent) CheckersMaybePromote =
{
	if (((ent == world) || !ent.ischecker))
	{
		return (FALSE);
	}
	if (ent.isking)
	{
		return (FALSE);
	}
	if ((((ent.chess_team == "white") && (GetY(ent.location) == 8)) || ((ent.chess_team == "black") && (GetY(ent.location) == 1))))
	{
		ent.isking = TRUE;
		ent.netname = "king";
		if ((cvar("pr_checkextension") && checkextension("DP_EF_BLUE")))
			ent.effects = (ent.effects | EF_BLUE);
		else
			ent.effects = (ent.effects | EF_BRIGHTLIGHT);
		bprint("\xC3\xE8\xE5\xE3\xEB\xE5\xF2\xF3 piece crowned king\n");
		mysprint(ent.owner, "Checker crowned king\n");
		return (TRUE);
	}
	return (FALSE);
};

void(entity ent, float loc, string reason) CheckersDebugInvalidMove =
{
	if (!cvar("cq_debug"))
	{
		return;
	}
	bprint("** CHECKERS DEBUG: invalid reason=");
	bprint(reason);
	bprint(" team=");
	bprint(ent.chess_team);
	bprint(" piece=");
	bprint(ftos(ent.location));
	bprint(" dest=");
	bprint(ftos(loc));
	bprint(" king=");
	bprint(ftos(ent.isking));
	bprint(" must_jump=");
	bprint(ftos(checkers_must_jump));
	bprint(" any_capture=");
	bprint(ftos(CheckersAnyCaptureAvailable(ent.owner)));
	bprint(" forced_piece=");
	if ((current_selected != world))
	{
		bprint(ftos(current_selected.location));
	}
	else
	{
		bprint("none");
	}
	bprint("\n");
};

float(entity ent, float loc, entity at_loc, float actual_move) CheckersValidMove =
{
	local float oldx;
	local float oldy;
	local float newx;
	local float newy;
	local float midloc;
	local entity mid;

	if (actual_move)
	{
		checkers_invalid_notified = FALSE;
		CheckersClearCaptureTarget();
		checkers_was_jump = FALSE;
		ent.enemy = world;
	}
	if (!ent.ischecker)
	{
		if (actual_move)
		{
			CheckersDebugInvalidMove(ent, loc, "not-checker");
		}
		return (FALSE);
	}
	if (!CheckersOnBoard(loc))
	{
		if (actual_move)
		{
			CheckersDebugInvalidMove(ent, loc, "off-board");
		}
		return (FALSE);
	}
	if ((at_loc != world))
	{
		if (actual_move)
		{
			CheckersDebugInvalidMove(ent, loc, "occupied");
		}
		return (FALSE);
	}
	if ((checkers_must_jump && (ent != current_selected)))
	{
		if (actual_move)
		{
			checkers_invalid_notified = TRUE;
		}
		return (FALSE);
	}
	if ((!checkers_must_jump && CheckersAnyCaptureAvailable(ent.owner)) && !CheckersCanJumpTo(ent, loc))
	{
		if (actual_move)
		{
			checkers_invalid_notified = TRUE;
			CheckersDebugInvalidMove(ent, loc, "mandatory-capture");
		}
		return (FALSE);
	}
	if (CheckersCanStepTo(ent, loc))
	{
		if (checkers_must_jump)
		{
			if (actual_move)
			{
				checkers_invalid_notified = TRUE;
			}
			return (FALSE);
		}
		if (CheckersAnyCaptureAvailable(ent.owner))
		{
			if (actual_move)
			{
				checkers_invalid_notified = TRUE;
			}
			return (FALSE);
		}
		return (TRUE);
	}
	if (CheckersCanJumpTo(ent, loc))
	{
		if (actual_move)
		{
			oldx = GetX(ent.location);
			oldy = GetY(ent.location);
			newx = GetX(loc);
			newy = GetY(loc);
			midloc = ((((oldx + newx) / 2) * 10) + ((oldy + newy) / 2));
			mid = EntityAtLoc(midloc);
			checkers_capture_entity = mid;
			checkers_capture_location = midloc;
			checkers_was_jump = TRUE;
			ent.enemy = mid;
		}
		return (SPAWNFLAG_LASER);
	}
	if (actual_move)
	{
		CheckersDebugInvalidMove(ent, loc, "movement-geometry");
	}
	return (FALSE);
};

float() CheckersBotDepth =
{
	local float depth;

	depth = floor(cvar("checkersbotdepth"));
	if ((depth < 1))
		depth = floor(cvar("botdepth"));
	if ((depth < 1))
	{
		depth = 3;
	}
	if ((depth > 5))
	{
		depth = 5;
	}
	return (depth);
};

float() CheckersBotQuiescenceDepth =
{
	local float depth;

	depth = floor(cvar("botqdepth"));
	if ((depth < MSG_BROADCAST))
		depth = MSG_BROADCAST;
	if ((depth > 6))
		depth = 6;
	return (depth);
};

float() CheckersBotDelay =
{
	local float delay;

	delay = cvar("botdelay");
	if ((delay <= MSG_BROADCAST))
	{
		delay = 0.5;
	}
	if ((delay > 5))
	{
		delay = 5;
	}
	return (delay);
};

float() CheckersBotWorkLimit =
{
	local float configured;
	local float depth;

	configured = floor(cvar("checkersbotwork"));
	if ((configured > MSG_BROADCAST))
	{
		if ((configured < 100)) configured = 100;
		if ((configured > 5000)) configured = 5000;
		return (configured);
	}
	depth = CheckersBotDepth();
	if ((depth == 1)) return (300);
	if ((depth == 2)) return (600);
	if ((depth == 3)) return (900);
	if ((depth == 4)) return (1300);
	return (1800);
};

float() ComputerVsComputerGame =
{
	if (!single_player)
		return (FALSE);
	if (((player1 == world) || (player2 == world)))
		return (FALSE);
	return (player1.is_bot && player2.is_bot);
};

void() HideComputerVsComputerPointers =
{
	if (!ComputerVsComputerGame())
		return;
	if ((player1.pointer != world))
		setmodel(player1.pointer, "progs/null.mdl");
	if ((player2.pointer != world))
		setmodel(player2.pointer, "progs/null.mdl");
	if (((player1.owner != world) && (player1.owner.pointer != world)))
		setmodel(player1.owner.pointer, "progs/null.mdl");
	if (((player2.owner != world) && (player2.owner.pointer != world)))
		setmodel(player2.owner.pointer, "progs/null.mdl");
};

void() CheckersApplyBotCvars =
{
	local float bot_side;

	if ((player1 != world))
	{
		player1.is_bot = FALSE;
		if (single_player)
		{
			setmodel(player1, "progs/headcam.mdl");
		}
	}
	if ((player2 != world))
	{
		player2.is_bot = FALSE;
		if (single_player)
		{
			setmodel(player2, "progs/headcam.mdl");
		}
	}
	if (!single_player)
	{
		return;
	}
	if (((player1 != world) && (player1.chess_team == "black")))
	{
		player1.netname = "Black";
	}
	if (((player2 != world) && (player2.chess_team == "white")))
	{
		player2.netname = "White";
	}
	if (((game_checkers && (player1 != world)) && (player1.chess_team == "black")))
	{
		player1.netname = "Red";
	}
	if (((game_checkers && (player2 != world)) && (player2.chess_team == "white")))
	{
		player2.netname = "Black";
	}
	bot_side = floor(cvar("bot"));
	if ((((bot_side == 1) || (bot_side == 3)) && (player1 != world)))
	{
		player1.is_bot = TRUE;
		if (game_checkers)
			player1.netname = "Red Computer";
		else
			player1.netname = "Black Computer";
		setmodel(player1, "progs/null.mdl");
	}
	if ((((bot_side == 2) || (bot_side == 3)) && (player2 != world)))
	{
		player2.is_bot = TRUE;
		if (game_checkers)
			player2.netname = "Black Computer";
		else
			player2.netname = "White Computer";
		setmodel(player2, "progs/null.mdl");
	}
	HideComputerVsComputerPointers();
};

float(entity ent, float loc) CheckersBotMoveIsJump =
{
	if (((fabs((GetX(loc) - GetX(ent.location))) == 2) && (fabs((GetY(loc) - GetY(ent.location))) == 2)))
	{
		return (TRUE);
	}
	return (FALSE);
};

entity(entity ent, float loc) CheckersBotCapturedEntity =
{
	local float midloc;

	if (!CheckersBotMoveIsJump(ent, loc))
	{
		return (world);
	}
	midloc = ((((GetX(ent.location) + GetX(loc)) / 2) * 10) + ((GetY(ent.location) + GetY(loc)) / 2));
	return (EntityAtLoc(midloc));
};

float(entity ent, float loc) CheckersBotWouldPromote =
{
	if (ent.isking)
	{
		return (FALSE);
	}
	if ((((ent.chess_team == "white") && (GetY(loc) == 8)) || ((ent.chess_team == "black") && (GetY(loc) == 1))))
	{
		return (TRUE);
	}
	return (FALSE);
};

float(entity side, entity forced_piece, entity piece, float loc) CheckersBotMoveAllowed =
{
	local float must_capture;

	if ((piece == world))
	{
		return (FALSE);
	}
	if ((((piece.owner != side) || !piece.ischecker) || (piece.health <= MSG_BROADCAST)))
	{
		return (FALSE);
	}
	if (((forced_piece != world) && (piece != forced_piece)))
	{
		return (FALSE);
	}
	if (CheckersCanJumpTo(piece, loc))
	{
		return (TRUE);
	}
	if ((forced_piece != world))
	{
		return (FALSE);
	}
	must_capture = CheckersBotSideHasCapture(side);
	if (must_capture)
	{
		return (FALSE);
	}
	return (CheckersCanStepTo(piece, loc));
};

float(entity piece) CheckersBotPieceLive =
{
	if ((piece == world))
		return (FALSE);
	return (((piece.flags & FL_MONSTER) && (piece.health > MSG_BROADCAST)) && piece.ischecker);
};

float(entity side, float loc) CheckersBotFriendlyManAt =
{
	local entity piece;

	piece = EntityAtLoc(loc);
	if (!CheckersBotPieceLive(piece))
		return (FALSE);
	return ((piece.owner == side) && !piece.isking);
};

float(entity side, float total_pieces) CheckersBotBackRankScore =
{
	local entity piece;
	local float home_rank;
	local float guards;
	local float score;

	if ((side == world))
		return (MSG_BROADCAST);
	if ((side.chess_team == "white"))
		home_rank = 1;
	else
		home_rank = 8;
	piece = find(world, chess_team, side.chess_team);
	while ((piece != world))
	{
		if ((CheckersBotPieceLive(piece) && !piece.isking))
		{
			if ((GetY(piece.location) == home_rank))
				guards = (guards + 1);
		}
		piece = find(piece, chess_team, side.chess_team);
	}
	if ((guards > 2))
		guards = 2;
	score = (guards * 3);
	if ((guards == 2))
		score = (score + 3);
	if ((total_pieces <= 8))
		score = (score * 0.5);
	return (score);
};

float(entity side) CheckersBotDoubleCornerScore =
{
	local float anchor;
	local float support1;
	local float support2;

	if ((side == world))
		return (MSG_BROADCAST);
	// Standard squares 1/5-6 and their reflection form the double corners.
	if ((side.chess_team == "white"))
	{
		anchor = 71;
		support1 = 62;
		support2 = 82;
	}
	else
	{
		anchor = 28;
		support1 = 17;
		support2 = 37;
	}
	if (!CheckersBotFriendlyManAt(side, anchor))
		return (MSG_BROADCAST);
	if ((CheckersBotFriendlyManAt(side, support1) || CheckersBotFriendlyManAt(side, support2)))
		return (7);
	return (2);
};

float(entity piece) CheckersBotMobilityScore =
{
	local float moves;

	if (!CheckersBotPieceLive(piece))
		return (MSG_BROADCAST);
	if (CheckersCanStepTo(piece, (piece.location + 11))) moves = (moves + 1);
	if (CheckersCanStepTo(piece, (piece.location - 9))) moves = (moves + 1);
	if (CheckersCanStepTo(piece, (piece.location + 9))) moves = (moves + 1);
	if (CheckersCanStepTo(piece, (piece.location - 11))) moves = (moves + 1);
	return (moves * 2);
};

float(entity side_to_move, float own_count, float opponent_count, float total_pieces) CheckersBotOppositionScore =
{
	local entity piece;
	local float target_odd_rank;
	local float pieces_in_system;
	local float rank;
	local float rank_is_odd;
	local float system_is_odd;
	local float white_has_opposition;
	local float bonus;

	if ((((side_to_move == world) || (own_count != opponent_count)) || (total_pieces > 10)))
		return (MSG_BROADCAST);
	target_odd_rank = (side_to_move.chess_team == "white");
	piece = find(world, chess_team, "white");
	while ((piece != world))
	{
		if (CheckersBotPieceLive(piece))
		{
			rank = GetY(piece.location);
			rank_is_odd = (rank - (floor((rank / 2)) * 2));
			if ((rank_is_odd == target_odd_rank))
				pieces_in_system = (pieces_in_system + 1);
		}
		piece = find(piece, chess_team, "white");
	}
	piece = find(world, chess_team, "black");
	while ((piece != world))
	{
		if (CheckersBotPieceLive(piece))
		{
			rank = GetY(piece.location);
			rank_is_odd = (rank - (floor((rank / 2)) * 2));
			if ((rank_is_odd == target_odd_rank))
				pieces_in_system = (pieces_in_system + 1);
		}
		piece = find(piece, chess_team, "black");
	}
	system_is_odd = (pieces_in_system - (floor((pieces_in_system / 2)) * 2));
	if ((side_to_move.chess_team == "white"))
		white_has_opposition = system_is_odd;
	else
		white_has_opposition = !system_is_odd;
	if ((total_pieces <= 6))
		bonus = 6;
	else if ((total_pieces <= 8))
		bonus = 4;
	else
		bonus = 2;
	if (((checkers_bot_side.chess_team == "white") == white_has_opposition))
		return (bonus);
	return (MSG_BROADCAST - bonus);
};

float(entity hunter, entity prey, float hunter_count, float prey_count, float total_pieces) CheckersBotEndgamePressureScore =
{
	local entity target;
	local entity piece;
	local float target_x;
	local float target_y;
	local float distance;
	local float nearest;
	local float kings;
	local float left;
	local float right;
	local float below;
	local float above;
	local float score;

	if (((hunter == world) || (prey == world)))
		return (MSG_BROADCAST);
	if (((total_pieces > 6) || (prey_count != 1)))
		return (MSG_BROADCAST);
	if ((hunter_count <= prey_count))
		return (MSG_BROADCAST);
	target = find(world, chess_team, prey.chess_team);
	while (((target != world) && !CheckersBotPieceLive(target)))
		target = find(target, chess_team, prey.chess_team);
	if ((target == world))
		return (MSG_BROADCAST);
	target_x = GetX(target.location);
	target_y = GetY(target.location);
	nearest = 99;
	piece = find(world, chess_team, hunter.chess_team);
	while ((piece != world))
	{
		if ((CheckersBotPieceLive(piece) && piece.isking))
		{
			kings = (kings + 1);
			distance = (fabs((GetX(piece.location) - target_x)) + fabs((GetY(piece.location) - target_y)));
			if ((distance < nearest))
				nearest = distance;
			if ((GetX(piece.location) < target_x)) left = TRUE;
			if ((GetX(piece.location) > target_x)) right = TRUE;
			if ((GetY(piece.location) < target_y)) below = TRUE;
			if ((GetY(piece.location) > target_y)) above = TRUE;
		}
		piece = find(piece, chess_team, hunter.chess_team);
	}
	if (!kings)
		return (MSG_BROADCAST);
	if ((nearest < 14))
		score = ((14 - nearest) * 2);
	if ((left && right)) score = (score + 8);
	if ((below && above)) score = (score + 8);
	if ((target.isking && ((target.location == 71) || (target.location == 28))))
		score = (score - 6);
	return (score);
};

float(entity piece, float tempo_weight) CheckersBotPieceScore =
{
	local float score;
	local float locx;
	local float locy;
	local float progress;

	if (!CheckersBotPieceLive(piece))
		return (MSG_BROADCAST);
	locx = GetX(piece.location);
	locy = GetY(piece.location);
	if (piece.isking)
		score = 175;
	else
	{
		score = 100;
		if ((piece.chess_team == "white"))
			progress = (locy - 1);
		else
			progress = (8 - locy);
		score = (score + (progress * tempo_weight));
	}
	if (((locx >= 3) && (locx <= 6)) && ((locy >= 3) && (locy <= 6)))
	{
		if (piece.isking)
			score = (score + 8);
		else
			score = (score + 3);
	}
	if ((((locx == 1) || (locx == 8)) || (locy == 1)) || (locy == 8))
	{
		if (piece.isking)
			score = (score - 5);
		else
			score = (score - 1);
	}
	if (CheckersPieceCanJump(piece))
		score = (score + 16);
	return (score);
};

float(entity side_to_move) CheckersBotEvaluate =
{
	local entity trav;
	local float score;
	local float own_men;
	local float own_kings;
	local float opponent_men;
	local float opponent_kings;
	local float own_count;
	local float opponent_count;
	local float total_pieces;
	local float total_men;
	local float own_material;
	local float opponent_material;
	local float material_difference;
	local float tempo_weight;

	if (((checkers_bot_side == world) || (checkers_bot_side.opponent == world)))
		return (MSG_BROADCAST);
	if (!CheckersSideHasLegalMove(checkers_bot_side))
		return (-90000);
	if (!CheckersSideHasLegalMove(checkers_bot_side.opponent))
		return (90000);
	trav = find(world, chess_team, checkers_bot_side.chess_team);
	while ((trav != world))
	{
		if (CheckersBotPieceLive(trav))
		{
			if (trav.isking) own_kings = (own_kings + 1);
			else own_men = (own_men + 1);
		}
		trav = find(trav, chess_team, checkers_bot_side.chess_team);
	}
	trav = find(world, chess_team, checkers_bot_side.opponent.chess_team);
	while ((trav != world))
	{
		if (CheckersBotPieceLive(trav))
		{
			if (trav.isking) opponent_kings = (opponent_kings + 1);
			else opponent_men = (opponent_men + 1);
		}
		trav = find(trav, chess_team, checkers_bot_side.opponent.chess_team);
	}
	own_count = (own_men + own_kings);
	opponent_count = (opponent_men + opponent_kings);
	total_pieces = (own_count + opponent_count);
	total_men = (own_men + opponent_men);
	if ((total_men >= 16)) tempo_weight = 2;
	else if ((total_men >= 9)) tempo_weight = 1;
	else tempo_weight = 3;
	trav = find(world, chess_team, checkers_bot_side.chess_team);
	while ((trav != world))
	{
		if (CheckersBotPieceLive(trav))
		{
			score = (score + CheckersBotPieceScore(trav, tempo_weight));
			score = (score + CheckersBotMobilityScore(trav));
		}
		trav = find(trav, chess_team, checkers_bot_side.chess_team);
	}
	trav = find(world, chess_team, checkers_bot_side.opponent.chess_team);
	while ((trav != world))
	{
		if (CheckersBotPieceLive(trav))
		{
			score = (score - CheckersBotPieceScore(trav, tempo_weight));
			score = (score - CheckersBotMobilityScore(trav));
		}
		trav = find(trav, chess_team, checkers_bot_side.opponent.chess_team);
	}
	score = (score + CheckersBotBackRankScore(checkers_bot_side, total_pieces));
	score = (score - CheckersBotBackRankScore(checkers_bot_side.opponent, total_pieces));
	score = (score + CheckersBotDoubleCornerScore(checkers_bot_side));
	score = (score - CheckersBotDoubleCornerScore(checkers_bot_side.opponent));
	own_material = ((own_men * 100) + (own_kings * 175));
	opponent_material = ((opponent_men * 100) + (opponent_kings * 175));
	material_difference = (own_material - opponent_material);
	if ((total_pieces < 24))
		score = (score + ((material_difference * (24 - total_pieces)) / 48));
	score = (score + CheckersBotOppositionScore(side_to_move, own_count, opponent_count, total_pieces));
	if ((own_material > opponent_material))
		score = (score + CheckersBotEndgamePressureScore(checkers_bot_side, checkers_bot_side.opponent, own_count, opponent_count, total_pieces));
	else if ((opponent_material > own_material))
		score = (score - CheckersBotEndgamePressureScore(checkers_bot_side.opponent, checkers_bot_side, opponent_count, own_count, total_pieces));
	if ((side_to_move == checkers_bot_side)) score = (score + 2);
	else if ((side_to_move == checkers_bot_side.opponent)) score = (score - 2);
	return (score);
};

float CHECKERS_TT_SIZE = 257;
float CHECKERS_TT_EXACT = 1;
float CHECKERS_TT_LOWER = 2;
float CHECKERS_TT_UPPER = 3;
float CHECKERS_MOVE_PLY_MAX = 32;
float CHECKERS_MOVES_PER_PLY = 64;
// Direct-mapped and deliberately small: it survives iterative-deepening passes,
// but is cleared before every real move so stale game state cannot leak in.
float checkers_tt_valid[257];
float checkers_tt_key1[257];
float checkers_tt_key2[257];
float checkers_tt_depth[257];
float checkers_tt_score[257];
float checkers_tt_flag[257];
float checkers_tt_best_from[257];
float checkers_tt_best_to[257];
float checkers_tt_position_key1;
float checkers_tt_position_key2;
float checkers_tt_hits;
float checkers_tt_cutoffs;
float checkers_tt_stores;
float checkers_search_move_from[2048];
float checkers_search_move_to[2048];
float checkers_search_move_order[2048];
float checkers_bot_previous_root_from;
float checkers_bot_previous_root_to;
float checkers_bot_skip_previous_root;

void() CheckersBotResetTranspositionTable =
{
	local float i;

	i = MSG_BROADCAST;
	while ((i < CHECKERS_TT_SIZE))
	{
		checkers_tt_valid[i] = FALSE;
		i = (i + 1);
	}
	checkers_tt_hits = MSG_BROADCAST;
	checkers_tt_cutoffs = MSG_BROADCAST;
	checkers_tt_stores = MSG_BROADCAST;
};

void() CheckersBotResetSearchContext =
{
	local float slot;
	local float i;
	local float value;
	local float context1;
	local float context2;

	// Repetition makes otherwise identical boards path-dependent. Seed the TT
	// context with real-game history; CheckersBotPushPosition extends it per ply.
	context1 = 43;
	context2 = 71;
	slot = MSG_BROADCAST;
	while ((slot < checkers_history_count))
	{
		i = MSG_BROADCAST;
		while ((i < 8))
		{
			value = (checkers_history_board[((slot * 8) + i)] + i + 1);
			context1 = ((context1 * 7) + value);
			context1 = (context1 - (floor((context1 / 1000003)) * 1000003));
			context2 = ((context2 * 11) + value + (i * 2));
			context2 = (context2 - (floor((context2 / 999983)) * 999983));
			i = (i + 1);
		}
		value = checkers_history_side[slot];
		context1 = ((context1 * 7) + value + 1);
		context1 = (context1 - (floor((context1 / 1000003)) * 1000003));
		context2 = ((context2 * 11) + value + 3);
		context2 = (context2 - (floor((context2 / 999983)) * 999983));
		slot = (slot + 1);
	}
	checkers_bot_context_key1[0] = context1;
	checkers_bot_context_key2[0] = context2;
};

void(entity side, entity forced_piece) CheckersBotBuildTranspositionKey =
{
	local float i;
	local float value;
	local float side_code;
	local float forced_location;
	local float occurrences;

	CheckersBuildPositionSignature();
	checkers_tt_position_key1 = 17;
	checkers_tt_position_key2 = 29;
	i = MSG_BROADCAST;
	while ((i < 8))
	{
		value = (checkers_signature[i] + i + 1);
		checkers_tt_position_key1 = ((checkers_tt_position_key1 * 7) + value);
		checkers_tt_position_key1 = (checkers_tt_position_key1 - (floor((checkers_tt_position_key1 / 1000003)) * 1000003));
		checkers_tt_position_key2 = ((checkers_tt_position_key2 * 11) + value + (i * 2));
		checkers_tt_position_key2 = (checkers_tt_position_key2 - (floor((checkers_tt_position_key2 / 999983)) * 999983));
		i = (i + 1);
	}
	side_code = CheckersSideCode(side);
	forced_location = MSG_BROADCAST;
	if ((forced_piece != world))
		forced_location = forced_piece.location;
	occurrences = CheckersBotPositionOccurrenceCount(side);
	value = (((side_code * 100) + forced_location) + (checkers_bot_no_progress_plies * 1000) + (occurrences * 100000));
	checkers_tt_position_key1 = ((checkers_tt_position_key1 * 7) + value);
	checkers_tt_position_key1 = (checkers_tt_position_key1 - (floor((checkers_tt_position_key1 / 1000003)) * 1000003));
	checkers_tt_position_key2 = ((checkers_tt_position_key2 * 11) + (value * 3) + 7);
	checkers_tt_position_key2 = (checkers_tt_position_key2 - (floor((checkers_tt_position_key2 / 999983)) * 999983));
	value = checkers_bot_context_key1[checkers_bot_path_count];
	checkers_tt_position_key1 = ((checkers_tt_position_key1 * 7) + value);
	checkers_tt_position_key1 = (checkers_tt_position_key1 - (floor((checkers_tt_position_key1 / 1000003)) * 1000003));
	value = checkers_bot_context_key2[checkers_bot_path_count];
	checkers_tt_position_key2 = ((checkers_tt_position_key2 * 11) + value);
	checkers_tt_position_key2 = (checkers_tt_position_key2 - (floor((checkers_tt_position_key2 / 999983)) * 999983));
};

float(float key1) CheckersBotTranspositionIndex =
{
	return (key1 - (floor((key1 / CHECKERS_TT_SIZE)) * CHECKERS_TT_SIZE));
};

void(float key1, float key2, float depth, float score, float flag, float best_from, float best_to) CheckersBotStoreTransposition =
{
	local float slot;

	if (checkers_bot_abort)
		return;
	slot = CheckersBotTranspositionIndex(key1);
	if (((checkers_tt_valid[slot] && (checkers_tt_key1[slot] == key1)) && (checkers_tt_key2[slot] == key2)) && (checkers_tt_depth[slot] > depth))
		return;
	checkers_tt_valid[slot] = TRUE;
	checkers_tt_key1[slot] = key1;
	checkers_tt_key2[slot] = key2;
	checkers_tt_depth[slot] = depth;
	checkers_tt_score[slot] = score;
	checkers_tt_flag[slot] = flag;
	checkers_tt_best_from[slot] = best_from;
	checkers_tt_best_to[slot] = best_to;
	checkers_tt_stores = (checkers_tt_stores + 1);
};

float(float loc, float candidate) CheckersBotCandidateDestination =
{
	if ((candidate == MSG_BROADCAST)) return (loc + 22);
	if ((candidate == 1)) return (loc - 18);
	if ((candidate == 2)) return (loc + 18);
	if ((candidate == 3)) return (loc - 22);
	if ((candidate == 4)) return (loc + 11);
	if ((candidate == 5)) return (loc - 9);
	if ((candidate == 6)) return (loc + 9);
	return (loc - 11);
};

float(entity side, entity forced_piece, float ply, float preferred_from, float preferred_to) CheckersBotGenerateOrderedMoves =
{
	local entity piece;
	local float base;
	local float count;
	local float candidate;
	local float destination;
	local float order;
	local float x;
	local float y;
	local float i;
	local float j;
	local float best_index;
	local float swap;

	if (((ply < MSG_BROADCAST) || (ply >= CHECKERS_MOVE_PLY_MAX)))
	{
		checkers_bot_abort = TRUE;
		return (MSG_BROADCAST);
	}
	base = (floor(ply) * CHECKERS_MOVES_PER_PLY);
	if ((forced_piece != world)) piece = forced_piece;
	else piece = find(world, chess_team, side.chess_team);
	while ((piece != world))
	{
		if ((((piece.flags & FL_MONSTER) && (piece.health > MSG_BROADCAST)) && piece.ischecker))
		{
			candidate = MSG_BROADCAST;
			while ((candidate < 8))
			{
				destination = CheckersBotCandidateDestination(piece.location, candidate);
				if (CheckersBotMoveAllowed(side, forced_piece, piece, destination))
				{
					if ((count >= CHECKERS_MOVES_PER_PLY))
					{
						checkers_bot_abort = TRUE;
						return (count);
					}
					order = (8 - candidate);
					if (((piece.location == preferred_from) && (destination == preferred_to)))
						order = (order + 1000000);
					if (CheckersBotMoveIsJump(piece, destination))
						order = (order + 100000);
					if (CheckersBotWouldPromote(piece, destination))
						order = (order + 10000);
					x = GetX(destination);
					y = GetY(destination);
					if ((((x >= 3) && (x <= 6)) && (y >= 3)) && (y <= 6))
						order = (order + 100);
					checkers_search_move_from[(base + count)] = piece.location;
					checkers_search_move_to[(base + count)] = destination;
					checkers_search_move_order[(base + count)] = order;
					count = (count + 1);
				}
				candidate = (candidate + 1);
			}
		}
		if ((forced_piece != world)) piece = world;
		else piece = find(piece, chess_team, side.chess_team);
	}
	i = MSG_BROADCAST;
	while ((i < count))
	{
		best_index = i;
		j = (i + 1);
		while ((j < count))
		{
			if ((checkers_search_move_order[(base + j)] > checkers_search_move_order[(base + best_index)]))
				best_index = j;
			j = (j + 1);
		}
		if ((best_index != i))
		{
			swap = checkers_search_move_from[(base + i)];
			checkers_search_move_from[(base + i)] = checkers_search_move_from[(base + best_index)];
			checkers_search_move_from[(base + best_index)] = swap;
			swap = checkers_search_move_to[(base + i)];
			checkers_search_move_to[(base + i)] = checkers_search_move_to[(base + best_index)];
			checkers_search_move_to[(base + best_index)] = swap;
			swap = checkers_search_move_order[(base + i)];
			checkers_search_move_order[(base + i)] = checkers_search_move_order[(base + best_index)];
			checkers_search_move_order[(base + best_index)] = swap;
		}
		i = (i + 1);
	}
	return (count);
};

float(entity side, entity forced_piece, float depth, float alpha, float beta) CheckersBotSearch;

float(entity side, entity forced_piece, entity piece, float loc, float depth, float alpha, float beta) CheckersBotMoveSearchScore =
{
	local entity captured;
	local float captured_health;
	local float captured_ischecker;
	local float captured_location;
	local float old_location;
	local float old_isking;
	local float promoted;
	local float score;
	local float is_jump;
	local float continues_jump;
	local entity next_side;
	local entity next_forced_piece;
	local float old_path_count;
	local float old_no_progress;

	checkers_bot_work = (checkers_bot_work + 1);
	if ((checkers_bot_work > checkers_bot_work_limit))
	{
		checkers_bot_abort = TRUE;
		return (-1234567);
	}
	if (!CheckersBotMoveAllowed(side, forced_piece, piece, loc))
	{
		return (-1234567);
	}
	is_jump = CheckersBotMoveIsJump(piece, loc);
	captured = CheckersBotCapturedEntity(piece, loc);
	captured_health = MSG_BROADCAST;
	captured_ischecker = FALSE;
	captured_location = MSG_BROADCAST;
	if ((captured != world))
	{
		captured_health = captured.health;
		captured_ischecker = captured.ischecker;
		captured_location = captured.location;
	}
	old_location = piece.location;
	old_isking = piece.isking;
	promoted = CheckersBotWouldPromote(piece, loc);
	piece.location = loc;
	if ((captured != world))
	{
		captured.health = -10;
		captured.location = MSG_BROADCAST;
		captured.ischecker = FALSE;
	}
	if (promoted)
	{
		piece.isking = TRUE;
	}
	checkers_bot_capture_valid = FALSE;
	continues_jump = ((is_jump && !promoted) && CheckersPieceCanJump(piece));
	if (continues_jump)
	{
		next_side = side;
		next_forced_piece = piece;
	}
	else
	{
		next_side = side.opponent;
		next_forced_piece = world;
	}
	old_no_progress = checkers_bot_no_progress_plies;
	if ((is_jump || promoted))
		checkers_bot_no_progress_plies = MSG_BROADCAST;
	else
		checkers_bot_no_progress_plies = (checkers_bot_no_progress_plies + 1);
	if ((CheckersSideHasLegalMove(next_side) && ((checkers_bot_no_progress_plies >= CHECKERS_NO_PROGRESS_LIMIT) || CheckersBotPositionWouldRepeat(next_side))))
	{
		score = MSG_BROADCAST;
	}
	else
	{
		old_path_count = checkers_bot_path_count;
		CheckersBotPushPosition(next_side);
		if (continues_jump)
			score = CheckersBotSearch(next_side, next_forced_piece, depth, alpha, beta);
		else
			score = CheckersBotSearch(next_side, next_forced_piece, (depth - 1), alpha, beta);
		checkers_bot_path_count = old_path_count;
	}
	checkers_bot_no_progress_plies = old_no_progress;
	piece.location = old_location;
	piece.isking = old_isking;
	if ((captured != world))
	{
		captured.health = captured_health;
		captured.location = captured_location;
		captured.ischecker = captured_ischecker;
	}
	checkers_bot_capture_valid = FALSE;
	if (checkers_bot_abort)
		return (-1234567);
	return (score);
};

float(entity side, entity forced_piece, float depth, float alpha, float beta) CheckersBotSearch =
{
	local entity piece;
	local float best;
	local float score;
	local float maximize;
	local float quiescence_depth;
	local float original_alpha;
	local float original_beta;
	local float key1;
	local float key2;
	local float slot;
	local float preferred_from;
	local float preferred_to;
	local float move_count;
	local float move_index;
	local float move_base;
	local float move_from;
	local float move_to;
	local float best_from;
	local float best_to;
	local float flag;

	if ((side == world))
	{
		return (CheckersBotEvaluate(side));
	}
	if ((depth <= MSG_BROADCAST))
	{
		quiescence_depth = CheckersBotQuiescenceDepth();
		// Captures are mandatory, so a capture position is not a valid static
		// evaluation point. Finish any active multi-jump even at the limit.
		if ((forced_piece == world))
		{
			if ((depth <= (MSG_BROADCAST - quiescence_depth)))
				return (CheckersBotEvaluate(side));
			if (!CheckersBotSideHasCapture(side))
				return (CheckersBotEvaluate(side));
		}
	}
	if (checkers_bot_abort)
		return (MSG_BROADCAST);
	CheckersBotBuildTranspositionKey(side, forced_piece);
	key1 = checkers_tt_position_key1;
	key2 = checkers_tt_position_key2;
	slot = CheckersBotTranspositionIndex(key1);
	preferred_from = MSG_BROADCAST;
	preferred_to = MSG_BROADCAST;
	if (((checkers_tt_valid[slot] && (checkers_tt_key1[slot] == key1)) && (checkers_tt_key2[slot] == key2)))
	{
		checkers_tt_hits = (checkers_tt_hits + 1);
		preferred_from = checkers_tt_best_from[slot];
		preferred_to = checkers_tt_best_to[slot];
		if ((checkers_tt_depth[slot] >= depth))
		{
			if ((checkers_tt_flag[slot] == CHECKERS_TT_EXACT))
			{
				checkers_tt_cutoffs = (checkers_tt_cutoffs + 1);
				return (checkers_tt_score[slot]);
			}
			if (((checkers_tt_flag[slot] == CHECKERS_TT_LOWER) && (checkers_tt_score[slot] > alpha)))
				alpha = checkers_tt_score[slot];
			else if (((checkers_tt_flag[slot] == CHECKERS_TT_UPPER) && (checkers_tt_score[slot] < beta)))
				beta = checkers_tt_score[slot];
			if ((alpha >= beta))
			{
				checkers_tt_cutoffs = (checkers_tt_cutoffs + 1);
				return (checkers_tt_score[slot]);
			}
		}
	}
	original_alpha = alpha;
	original_beta = beta;
	maximize = (side == checkers_bot_side);
	if (maximize)
	{
		best = -100000;
	}
	else
	{
		best = 100000;
	}
	move_count = CheckersBotGenerateOrderedMoves(side, forced_piece, checkers_bot_path_count, preferred_from, preferred_to);
	if (checkers_bot_abort)
		return (MSG_BROADCAST);
	move_base = (floor(checkers_bot_path_count) * CHECKERS_MOVES_PER_PLY);
	move_index = MSG_BROADCAST;
	while ((move_index < move_count))
	{
		move_from = checkers_search_move_from[(move_base + move_index)];
		move_to = checkers_search_move_to[(move_base + move_index)];
		piece = EntityAtLoc(move_from);
		if ((piece != world))
		{
			score = CheckersBotMoveSearchScore(side, forced_piece, piece, move_to, depth, alpha, beta);
			if ((score != -1234567))
			{
				if (maximize)
				{
					if ((score > best))
					{
						best = score;
						best_from = move_from;
						best_to = move_to;
					}
					if ((best > alpha)) alpha = best;
				}
				else
				{
					if ((score < best))
					{
						best = score;
						best_from = move_from;
						best_to = move_to;
					}
					if ((best < beta)) beta = best;
				}
				if ((beta <= alpha))
					move_index = move_count;
			}
		}
		move_index = (move_index + 1);
	}
	if ((move_count == MSG_BROADCAST))
	{
		if (maximize) best = -90000;
		else best = 90000;
	}
	flag = CHECKERS_TT_EXACT;
	if ((best <= original_alpha)) flag = CHECKERS_TT_UPPER;
	else if ((best >= original_beta)) flag = CHECKERS_TT_LOWER;
	CheckersBotStoreTransposition(key1, key2, depth, best, flag, best_from, best_to);
	return (best);
};

float(entity piece, float loc) CheckersBotRootBonus =
{
	local float score;
	local float locx;
	local float locy;

	score = (random() * 0.01);
	if (CheckersBotMoveIsJump(piece, loc))
	{
		score = (score + 2);
	}
	if (CheckersBotWouldPromote(piece, loc))
	{
		score = (score + 1);
	}
	locx = GetX(loc);
	locy = GetY(loc);
	if (((locx >= 3) && (locx <= 6)) && ((locy >= 3) && (locy <= 6)))
	{
		score = (score + 0.5);
	}
	return (score);
};

void(entity piece, float loc) CheckersBotConsiderRootMove =
{
	local float score;

	if (((checkers_bot_skip_previous_root && (piece.location == checkers_bot_previous_root_from)) && (loc == checkers_bot_previous_root_to)))
		return;
	score = CheckersBotMoveSearchScore(current_turn, current_selected, piece, loc, checkers_bot_search_depth, -100000, 100000);
	if ((score == -1234567))
	{
		return;
	}
	score = (score + CheckersBotRootBonus(piece, loc));
	if (((checkers_bot_best_piece == world) || (score > checkers_bot_best_score)) || ((score == checkers_bot_best_score) && (random() < 0.5)))
	{
		checkers_bot_best_piece = piece;
		checkers_bot_best_dest = loc;
		checkers_bot_best_score = score;
	}
};

void() CheckersBotChooseIteration =
{
	local entity trav;
	local entity previous_piece;

	checkers_bot_best_piece = world;
	checkers_bot_best_dest = MSG_BROADCAST;
	checkers_bot_best_score = -100000;
	checkers_bot_side = current_turn;
	checkers_bot_skip_previous_root = FALSE;
	if ((checkers_bot_previous_root_from != MSG_BROADCAST))
	{
		previous_piece = EntityAtLoc(checkers_bot_previous_root_from);
		if (((previous_piece != world) && (previous_piece.chess_team == current_turn.chess_team)))
			CheckersBotConsiderRootMove(previous_piece, checkers_bot_previous_root_to);
	}
	if (checkers_bot_abort)
		return;
	checkers_bot_skip_previous_root = TRUE;
	if (checkers_must_jump)
	{
		trav = current_selected;
	}
	else
	{
		trav = find(world, chess_team, current_turn.chess_team);
	}
	while (((trav != world) && !checkers_bot_abort))
	{
		if (((trav == current_selected) || !checkers_must_jump))
		{
			if ((((trav.flags & FL_MONSTER) && (trav.health > MSG_BROADCAST)) && trav.ischecker))
			{
				CheckersBotConsiderRootMove(trav, (trav.location + 22));
				CheckersBotConsiderRootMove(trav, (trav.location - 18));
				CheckersBotConsiderRootMove(trav, (trav.location + 18));
				CheckersBotConsiderRootMove(trav, (trav.location - 22));
				CheckersBotConsiderRootMove(trav, (trav.location + 11));
				CheckersBotConsiderRootMove(trav, (trav.location - 9));
				CheckersBotConsiderRootMove(trav, (trav.location + 9));
				CheckersBotConsiderRootMove(trav, (trav.location - 11));
			}
		}
		if (checkers_must_jump)
		{
			trav = world;
		}
		else
		{
			trav = find(trav, chess_team, current_turn.chess_team);
		}
	}
	checkers_bot_skip_previous_root = FALSE;
};

void() CheckersBotChooseMove =
{
	local entity completed_piece;
	local float completed_dest;
	local float completed_score;
	local float completed_depth;
	local float target_depth;

	completed_piece = world;
	completed_dest = MSG_BROADCAST;
	completed_score = -100000;
	completed_depth = MSG_BROADCAST;
	target_depth = CheckersBotDepth();
	checkers_bot_work_limit = CheckersBotWorkLimit();
	checkers_bot_search_depth = 1;
	checkers_bot_work = MSG_BROADCAST;
	checkers_bot_path_count = MSG_BROADCAST;
	checkers_bot_no_progress_plies = checkers_no_progress_plies;
	checkers_bot_previous_root_from = MSG_BROADCAST;
	checkers_bot_previous_root_to = MSG_BROADCAST;
	CheckersBotResetTranspositionTable();
	CheckersBotResetSearchContext();
	checkers_bot_capture_valid = FALSE;
	checkers_bot_capture_cache_on = TRUE;
	while ((checkers_bot_search_depth <= target_depth))
	{
		checkers_bot_abort = FALSE;
		CheckersBotChooseIteration();
		if (checkers_bot_abort)
		{
			if (cvar("botdebug"))
			{
				bprint("** Checkers computer depth ");
				bprint(ftos(checkers_bot_search_depth));
				bprint(" exceeded work budget ");
				bprint(ftos(checkers_bot_work_limit));
				bprint("\n");
			}
			checkers_bot_search_depth = (target_depth + 1);
		}
		else
		{
			if ((checkers_bot_best_piece != world))
			{
				completed_piece = checkers_bot_best_piece;
				completed_dest = checkers_bot_best_dest;
				completed_score = checkers_bot_best_score;
				completed_depth = checkers_bot_search_depth;
				checkers_bot_previous_root_from = checkers_bot_best_piece.location;
				checkers_bot_previous_root_to = checkers_bot_best_dest;
			}
			checkers_bot_search_depth = (checkers_bot_search_depth + 1);
		}
	}
	checkers_bot_capture_cache_on = FALSE;
	checkers_bot_capture_valid = FALSE;
	checkers_bot_best_piece = completed_piece;
	checkers_bot_best_dest = completed_dest;
	checkers_bot_best_score = completed_score;
	if (cvar("botdebug"))
	{
		bprint("** Checkers computer completed depth ");
		bprint(ftos(completed_depth));
		bprint(", work ");
		bprint(ftos(checkers_bot_work));
		bprint(", TT hits/cutoffs/stores ");
		bprint(ftos(checkers_tt_hits));
		bprint("/");
		bprint(ftos(checkers_tt_cutoffs));
		bprint("/");
		bprint(ftos(checkers_tt_stores));
		bprint("\n");
	}
};

float() CheckersBotPositionChecksum =
{
	local entity piece;
	local float checksum;

	checksum = MSG_BROADCAST;
	piece = find(world, chess_team, "white");
	while ((piece != world))
	{
		if (((piece.ischecker && (piece.health > MSG_BROADCAST)) && (piece.flags & FL_MONSTER)))
			checksum = (checksum + (piece.location * 17) + (piece.isking * 101));
		piece = find(piece, chess_team, "white");
	}
	piece = find(world, chess_team, "black");
	while ((piece != world))
	{
		if (((piece.ischecker && (piece.health > MSG_BROADCAST)) && (piece.flags & FL_MONSTER)))
			checksum = (checksum + (piece.location * 31) + (piece.isking * 211));
		piece = find(piece, chess_team, "black");
	}
	return (checksum);
};

float() CheckersBotLiveCount =
{
	local entity piece;
	local float count;

	count = MSG_BROADCAST;
	piece = find(world, chess_team, "white");
	while ((piece != world))
	{
		if (((piece.ischecker && (piece.health > MSG_BROADCAST)) && (piece.flags & FL_MONSTER)))
			count = (count + 1);
		piece = find(piece, chess_team, "white");
	}
	piece = find(world, chess_team, "black");
	while ((piece != world))
	{
		if (((piece.ischecker && (piece.health > MSG_BROADCAST)) && (piece.flags & FL_MONSTER)))
			count = (count + 1);
		piece = find(piece, chess_team, "black");
	}
	return (count);
};

void(string reason) CheckersBotFailSafe =
{
	bprint("** CHECKERS COMPUTER ERROR: ");
	bprint(reason);
	bprint("; continuing as a human player\n");
	cvar_set("bot", "0");
	CheckersApplyBotCvars();
	action_flag = FALSE;
	current_selected = world;
	ClearSelectionEffect();
	ClearLastHighlight();
};

float(entity actor, entity piece, float loc) CheckersExecuteBotMove =
{
	local vector dest_org;
	local entity eatloc;

	if (((piece == world) || (actor == world)))
	{
		return (FALSE);
	}
	current_selected = piece;
	current_dest_int = loc;
	current_destination = ftos(loc);
	if (!CanMove(current_selected, current_dest_int, TRUE))
	{
		return (FALSE);
	}
	action_flag = TRUE;
	ClearSelectionEffect();
	ClearLastHighlight();
	dest_org = LocationToVector(current_dest_int);
	setorigin(dest_ent, dest_org);
	mystuffcmd(actor, "play effects/button.wav\n");
	WalkToDest(actor);
	bprint("\xC3\xE8\xE5\xE3\xEB\xE5\xF2\xF3: ");
	if ((current_selected.chess_team == "white"))
	{
		bprint("Black ");
	}
	else
	{
		bprint("Red ");
	}
	if (current_selected.isking)
	{
		bprint("king ");
	}
	else
	{
		bprint("piece ");
	}
	bprint(ftos(current_selected.location));
	eatloc = current_selected.enemy;
	if ((eatloc == world))
	{
		bprint(" - ");
	}
	else
	{
		bprint(" x ");
	}
	bprint(ftos(current_dest_int));
	bprint("\n");
	current_turn.last_moved = current_selected;
	current_turn.last_move_from = current_selected.location;
	current_turn.last_move_to = current_dest_int;
	LastMoved = current_selected;
	LastMovedLocation = current_dest_int;
	current_selected.location = current_dest_int;
	current_selected.hasmoved = TRUE;
	current_turn.chess_flags = (current_turn.chess_flags - (current_turn.chess_flags & CF_SELECTED_PIECE));
	return (TRUE);
};

void() CheckersBotThink =
{
	local float checksum_before;
	local float count_before;

	if ((self == checkers_bot_thinker))
	{
		checkers_bot_thinker = world;
	}
	if (((!game_checkers || gameover) || (current_turn == world)))
	{
		remove(self);
		return;
	}
	if (!current_turn.is_bot)
	{
		remove(self);
		return;
	}
	if (action_flag)
	{
		self.nextthink = (time + 0.2);
		checkers_bot_thinker = self;
		return;
	}
	if (((current_turn.owner != world) && current_turn.owner.menu_screen))
	{
		self.nextthink = (time + 0.5);
		checkers_bot_thinker = self;
		return;
	}
	if ((!bot_think_announced && (time >= bot_think_deadline)))
	{
		mysprint(current_turn, "Computer thinking\n");
		bot_think_announced = TRUE;
	}
	checksum_before = CheckersBotPositionChecksum();
	count_before = CheckersBotLiveCount();
	CheckersBotChooseMove();
	if (((CheckersBotPositionChecksum() != checksum_before) || (CheckersBotLiveCount() != count_before)))
	{
		CheckersBotFailSafe("search state was not restored");
		remove(self);
		return;
	}
	if ((checkers_bot_best_piece == world))
	{
		remove(self);
		if (!CheckersSideHasLegalMove(current_turn))
		{
			CheckCheckersGameOver();
		}
		else
		{
			CheckersBotFailSafe("no completed move despite legal moves");
		}
		return;
	}
	if (!CheckersExecuteBotMove(current_turn, checkers_bot_best_piece, checkers_bot_best_dest))
	{
		CheckersBotFailSafe("live validation rejected selected move");
		remove(self);
		return;
	}
	remove(self);
};

void() CheckersCancelBotSearch =
{
	if ((checkers_bot_thinker != world))
	{
		remove(checkers_bot_thinker);
		checkers_bot_thinker = world;
	}
	checkers_bot_abort = FALSE;
};

void() CheckersMaybeScheduleBotTurn =
{
	CheckersCancelBotSearch();
	if (((!game_checkers || gameover) || (current_turn == world)))
	{
		return;
	}
	if (!current_turn.is_bot)
	{
		return;
	}
	if (action_flag)
	{
		return;
	}
	checkers_bot_thinker = spawn();
	setmodel(checkers_bot_thinker, "progs/null.mdl");
	checkers_bot_thinker.think = CheckersBotThink;
	checkers_bot_thinker.nextthink = (time + CheckersBotDelay());
	bot_think_deadline = (time + BOT_THINK_ANNOUNCE_DELAY);
	bot_think_announced = FALSE;
};

float(entity ent, float loc, entity at_loc, float actual_move) CheckValidMove =
{
	local float oldx;
	local float oldy;
	local float newx;
	local float newy;
	local float xchange;
	local float ychange;
	local float pawning_loc;
	local float valid;
	local float castle_loc;
	local entity castle;
	local entity pawning_ent;
	local string str;

	if (game_checkers)
	{
		return (CheckersValidMove(ent, loc, at_loc, actual_move));
	}
	oldx = GetX(ent.location);
	oldy = GetY(ent.location);
	newx = GetX(loc);
	newy = GetY(loc);
	xchange = (newx - oldx);
	ychange = (newy - oldy);
	if (((((newx == MSG_BROADCAST) || (newy == MSG_BROADCAST)) || (newx == TE_LIGHTNING3)) || (newy == TE_LIGHTNING3)))
	{
		return (MSG_BROADCAST);
	}
	if (actual_move)
	{
		king_castle_move_flag = FALSE;
		en_passant_flag = FALSE;
	}
	valid = FALSE;
	if ((ent.classname == "chess_pawn"))
	{
		if ((ent.chess_team == "black"))
		{
			if ((newx != oldx))
			{
				if (((fabs((newx - oldx)) == SPAWN_CRUCIFIED) && ((oldy - newy) == SPAWN_CRUCIFIED)))
				{
					pawning_loc = ((newx * 10) + oldy);
					pawning_ent = EntityAtLoc(pawning_loc);
					if ((((((newy == AS_MELEE) && (at_loc == world)) && (pawning_ent != world)) && (pawning_ent.owner == ent.owner.opponent)) && (pawning_ent == current_turn.opponent.last_moved)))
					{
						pawning_enemy = pawning_ent;
						en_passant_flag = TRUE;
						return (SPAWNFLAG_LASER);
					}
					else
					{
						return (((at_loc != world) * SPAWNFLAG_LASER));
					}
				}
			}
			else
			{
				if ((((oldy - newy) == SPAWN_CRUCIFIED) || ((((oldy - newy) == SPAWNFLAG_LASER) && !ent.hasmoved) && ClearPath(ent.location, loc))))
				{
					return ((at_loc == world));
				}
			}
		}
		else
		{
			if ((newx != oldx))
			{
				if (((fabs((newx - oldx)) == SPAWN_CRUCIFIED) && ((oldy - newy) == CONTENT_EMPTY)))
				{
					pawning_loc = ((newx * 10) + oldy);
					pawning_ent = EntityAtLoc(pawning_loc);
					if ((((((newy == TE_LIGHTNING2) && (at_loc == world)) && (pawning_ent != world)) && (pawning_ent.owner == ent.owner.opponent)) && (pawning_ent == current_turn.opponent.last_moved)))
					{
						pawning_enemy = pawning_ent;
						en_passant_flag = TRUE;
						return (SPAWNFLAG_LASER);
					}
					else
					{
						return (((at_loc != world) * SPAWNFLAG_LASER));
					}
				}
			}
			else
			{
				if ((((oldy - newy) == CONTENT_EMPTY) || ((((oldy - newy) == -2) && !ent.hasmoved) && ClearPath(ent.location, loc))))
				{
					return ((at_loc == world));
				}
			}
		}
	}
	else
	{
		if ((ent.classname == "chess_rook"))
		{
			if (((oldx == newx) || (oldy == newy)))
			{
				if (ClearPath(ent.location, loc))
				{
					return (((at_loc != world) + SPAWN_CRUCIFIED));
				}
				else
				{
					return (MSG_BROADCAST);
				}
			}
			else
			{
				return (MSG_BROADCAST);
			}
		}
		else
		{
			if ((ent.classname == "chess_knight"))
			{
				if ((((fabs((newx - oldx)) == SPAWNFLAG_LASER) && (fabs((newy - oldy)) == SPAWN_CRUCIFIED)) || ((fabs((newx - oldx)) == SPAWN_CRUCIFIED) && (fabs((newy - oldy)) == SPAWNFLAG_LASER))))
				{
					return (((at_loc != world) + SPAWN_CRUCIFIED));
				}
				else
				{
					return (MSG_BROADCAST);
				}
			}
			else
			{
				if ((ent.classname == "chess_bishop"))
				{
					xchange = fabs(xchange);
					ychange = fabs(ychange);
					if ((xchange == ychange))
					{
						if (ClearPath(ent.location, loc))
						{
							valid = TRUE;
						}
					}
					if (valid)
					{
						return (((at_loc != world) + SPAWN_CRUCIFIED));
					}
					else
					{
						return (MSG_BROADCAST);
					}
				}
				else
				{
					if ((ent.classname == "chess_queen"))
					{
						xchange = fabs(xchange);
						ychange = fabs(ychange);
						if (((xchange == ychange) || ((newx == oldx) || (newy == oldy))))
						{
							if (ClearPath(ent.location, loc))
							{
								valid = TRUE;
							}
						}
						if (valid)
						{
							return (((at_loc != world) + SPAWN_CRUCIFIED));
						}
						else
						{
							return (MSG_BROADCAST);
						}
					}
					else
					{
						if ((ent.classname == "chess_king"))
						{
							if (((fabs((newx - oldx)) <= SPAWN_CRUCIFIED) && (fabs((newy - oldy)) <= SPAWN_CRUCIFIED)))
							{
								return (((at_loc != world) + SPAWN_CRUCIFIED));
							}
							else
							{
								if ((!ent.hasmoved && (oldy == newy)))
								{
									if ((fabs(xchange) == SPAWNFLAG_LASER))
									{
										if (!actual_move)
											return (MSG_BROADCAST);
										if ((newx < oldx))
										{
											castle_loc = (10 + GetY(ent.location));
											castle_destination = ((oldx - SPAWN_CRUCIFIED) * 10);
										}
										else
										{
											castle_loc = (80 + GetY(ent.location));
											castle_destination = ((oldx + SPAWN_CRUCIFIED) * 10);
										}
										castle = EntityAtLoc(castle_loc);
										if ((((castle.classname == "chess_rook") && !castle.hasmoved) && ClearPath(castle.location, current_selected.location)))
										{
											castle_to_move = castle;
											castle_destination = (castle_destination + GetY(ent.location));
											king_castle_move_flag = TRUE;
											return (SPAWN_CRUCIFIED);
										}
									}
								}
								else
								{
									return (valid);
								}
							}
						}
						else
						{
							bprint("Tried to move a non-piece??\n");
							return (MSG_BROADCAST);
						}
					}
				}
			}
		}
	}
};

entity(float loc) CrappyEntityAtLoc =
{
	local entity eal_ent;

	eal_ent = findradius('0 0 0', 400);
	while (eal_ent)
	{
		if ((((eal_ent.flags & FL_MONSTER) && (eal_ent.health > MSG_BROADCAST)) && (eal_ent.location == loc)))
		{
			return (eal_ent);
		}
		eal_ent = eal_ent.chain;
	}
	return (world);
};

entity(float loc) EntityAtLoc =
{
	local entity eal_trav;
	local float runcount;

	runcount = MSG_BROADCAST;
	eal_trav = find(world, chess_team, "white");
	while (((eal_trav != world) && (runcount < 100)))
	{
		if (((eal_trav.flags & FL_MONSTER) && (eal_trav.health > MSG_BROADCAST)))
		{
			if ((eal_trav.location == loc))
			{
				return (eal_trav);
			}
			runcount = (runcount + SPAWN_CRUCIFIED);
			if ((runcount >= 99))
			{
				bprint("E@Loc: Emergency runaway abort\n");
				bprint("Notify the crownquake maintainer\n");
			}
		}
		eal_trav = find(eal_trav, chess_team, "white");
	}
	runcount = MSG_BROADCAST;
	eal_trav = find(world, chess_team, "black");
	while (((eal_trav != world) && (runcount < 100)))
	{
		if (((eal_trav.flags & FL_MONSTER) && (eal_trav.health > MSG_BROADCAST)))
		{
			if ((eal_trav.location == loc))
			{
				return (eal_trav);
			}
			runcount = (runcount + SPAWN_CRUCIFIED);
			if ((runcount >= 99))
			{
				bprint("E@Loc: Emergency runaway abort\n");
				bprint("Notify the crownquake maintainer\n");
			}
		}
		eal_trav = find(eal_trav, chess_team, "black");
	}
	return (world);
};

entity(float loc) newEntityAtLoc =
{
	local string ealocstr;
	local entity eal_ent;

	ealocstr = ftos(loc);
	eal_ent = find(world, location_str, ealocstr);
	return (eal_ent);
};

void() random_pawn_speech =
{
	local float rnd;

	rnd = (random() * SECRET_1ST_DOWN);
	if ((rnd < SPAWN_CRUCIFIED))
	{
		mystuffcmd(current_turn, "play voice/pawn/hwhat2.wav\n");
	}
	else
	{
		if ((rnd < SPAWNFLAG_LASER))
		{
			mystuffcmd(current_turn, "play voice/pawn/hwhat3.wav\n");
		}
		else
		{
			if ((rnd < AS_MELEE))
			{
				mystuffcmd(current_turn, "play voice/pawn/hwhat4.wav\n");
			}
			else
			{
				if ((rnd < SECRET_1ST_DOWN))
				{
					mystuffcmd(current_turn, "play voice/pawn/hwhat5.wav\n");
				}
			}
		}
	}
};

void() random_scrag_speech =
{
	local float rnd;

	rnd = (random() * SPAWNFLAG_LASER);
	if ((rnd < SPAWN_CRUCIFIED))
	{
		mystuffcmd(current_turn, "play wizard/widle1.wav\n");
	}
	else
	{
		if ((rnd < SPAWNFLAG_LASER))
		{
			mystuffcmd(current_turn, "play wizard/widle2.wav\n");
		}
	}
};

void() random_king_speech =
{
	local float rnd;

	rnd = (random() * SPAWNFLAG_LASER);
	if ((rnd < SPAWN_CRUCIFIED))
	{
		mystuffcmd(current_turn, "play zombie/z_idle1.wav\n");
	}
	else
	{
		if ((rnd < SPAWNFLAG_LASER))
		{
			mystuffcmd(current_turn, "play zombie/z_idle.wav\n");
		}
	}
};

void() random_fiend_speech =
{
	local float rnd;

	rnd = (random() * SPAWNFLAG_LASER);
	if ((rnd < SPAWN_CRUCIFIED))
	{
		mystuffcmd(current_turn, "play demon/idle1.wav\n");
	}
	else
	{
		if ((rnd < SPAWNFLAG_LASER))
		{
			mystuffcmd(current_turn, "play demon/dpain1.wav\n");
		}
	}
};

void() random_bishop_speech =
{
	local float rnd;

	rnd = (random() * AS_MELEE);
	if ((rnd < SPAWN_CRUCIFIED))
	{
		mystuffcmd(current_turn, "play voice/bishop/tuwhat1.wav\n");
	}
	else
	{
		if ((rnd < SPAWNFLAG_LASER))
		{
			mystuffcmd(current_turn, "play voice/bishop/tuwhat2.wav\n");
		}
		else
		{
			if ((rnd < AS_MELEE))
			{
				mystuffcmd(current_turn, "play voice/bishop/tuwhat3.wav\n");
			}
		}
	}
};

void() random_rook_speech =
{
	local float rnd;

	rnd = (random() * TE_WIZSPIKE);
	if ((rnd < SPAWN_CRUCIFIED))
	{
		mystuffcmd(current_turn, "play voice/rook/pissed1.wav\n");
	}
	else
	{
		if ((rnd < SPAWNFLAG_LASER))
		{
			mystuffcmd(current_turn, "play voice/rook/ready.wav\n");
		}
		else
		{
			if ((rnd < AS_MELEE))
			{
				mystuffcmd(current_turn, "play voice/rook/what1.wav\n");
			}
			else
			{
				if ((rnd < SECRET_1ST_DOWN))
				{
					mystuffcmd(current_turn, "play voice/rook/what2.wav\n");
				}
				else
				{
					if ((rnd < TE_LIGHTNING1))
					{
						mystuffcmd(current_turn, "play voice/rook/what3.wav\n");
					}
					else
					{
						if ((rnd < TE_LIGHTNING2))
						{
							mystuffcmd(current_turn, "play voice/rook/what4.wav\n");
						}
						else
						{
							if ((rnd < TE_WIZSPIKE))
							{
								mystuffcmd(current_turn, "play voice/rook/what5.wav\n");
							}
						}
					}
				}
			}
		}
	}
};

void(entity ent, float loc) CheckersExplainInvalidMove =
{
	local entity at_loc;

	if ((ent == world))
		return;
	if (!ent.ischecker)
	{
		mysprint(ent.owner, "Invalid move: the selected entity is not a checkers piece.\n");
		return;
	}
	if (!CheckersOnBoard(loc))
	{
		mysprint(ent.owner, "Invalid move: the destination is outside the board.\n");
		return;
	}
	at_loc = EntityAtLoc(loc);
	if ((at_loc != world))
	{
		mysprint(ent.owner, "Invalid move: a checkers piece can only move to an empty square.\n");
		return;
	}
	if ((checkers_must_jump && (ent != current_selected)))
	{
		mysprint(ent.owner, "Invalid move: finish the multi-jump with the currently selected piece.\n");
		return;
	}
	if ((checkers_must_jump || CheckersAnyCaptureAvailable(ent.owner)))
	{
		mysprint(ent.owner, "Invalid move: a capture is available and must be taken by jumping an enemy piece.\n");
		return;
	}
	if (ent.isking)
		mysprint(ent.owner, "Invalid king move: checkers kings move one square diagonally in either direction, or capture by jumping diagonally.\n");
	else
		mysprint(ent.owner, "Invalid piece move: pieces move one square diagonally forward, or capture by jumping diagonally forward.\n");
};

float(entity ent, float loc, float actual_move) CanMove =
{
	local entity at_loc;
	local float result;

	at_loc = EntityAtLoc(loc);
	if ((((at_loc != world) && (at_loc.owner == ent.owner)) && (at_loc != ignore_canmove)))
	{
		if (actual_move)
		{
			if ((at_loc == ent))
			{
				if ((game_checkers && checkers_must_jump))
				{
					mycentreprint(ent.owner, "You must finish the jump");
					return (FALSE);
				}
				if ((ent.owner.chess_flags & CF_SELECTED_PIECE))
				{
					mysprint(ent.owner, "Selection cleared\n");
					mystuffcmd(self, "play effects/button.wav\n");
					castle_to_move = world;
					king_castle_move_flag = FALSE;
					ent.owner.chess_flags = (ent.owner.chess_flags - (ent.owner.chess_flags & CF_SELECTED_PIECE));
					ClearSelectionEffect();
				}
			}
			else
			{
				if (!game_checkers)
				{
					ChessRebuildOccupancy();
					ChessExplainInvalidMove(ent, loc);
				}
				else
					CheckersExplainInvalidMove(ent, loc);
			}
		}
		return (FALSE);
	}
	if ((!game_checkers && actual_move))
	{
		ChessRebuildOccupancy();
		if (!ChessMoveIsLegal(ent, loc, 1))
		{
			ChessExplainInvalidMove(ent, loc);
			return (FALSE);
		}
	}
	result = CheckValidMove(ent, loc, at_loc, actual_move);
	if ((result == MSG_BROADCAST))
	{
		if (actual_move)
		{
			if (!game_checkers)
				mysprint(ent.owner, "Move rejected because the live board changed; select the piece and try again.\n");
			else
				CheckersExplainInvalidMove(ent, loc);
		}
		return (FALSE);
	}
	if (((result == SPAWNFLAG_LASER) && !game_checkers))
	{
		if (actual_move)
		{
			if (en_passant_flag)
			{
				at_loc = pawning_enemy;
			}
			ent.enemy = at_loc;
			ent.think = FoundTarget;
			ent.nextthink = (time + 0.1);
			current_enemy = at_loc;
			at_loc.enemy = ent;
			at_loc.think = FoundTarget;
			at_loc.nextthink = (time + 0.1);
			ent.owner.skin = SPAWN_CRUCIFIED;
			at_loc.owner.skin = SPAWNFLAG_LASER;
		}
	}
	if (actual_move)
	{
		ent.owner.chess_flags = (ent.owner.chess_flags - (ent.owner.chess_flags & CF_CHECK_NOTIFY));
	}
	return (TRUE);
};

vector(float loc) LocationToVector =
{
	local vector dest_org;

	dest_org_y = GetY(loc);
	dest_org_x = GetX(loc);
	dest_org_z = MSG_BROADCAST;
	dest_org = (dest_org * IT_LIGHTNING);
	dest_org = (((dest_org - '256 256 0') - '32 32 0') - (VEC_HULL_MIN_z * '0 0 1'));
	return (dest_org);
};

void() ClearLastHighlight =
{
	if ((last_highlight != world))
	{
		setorigin(last_highlight, last_highlight.pos2);
		last_highlight.pos2 = last_highlight.pos1;
		last_highlight.pos1 = last_highlight.origin;
		last_highlight = world;
	}
};

void() ProcessSelection =
{
	local vector dest_org;
	local float rnd;
	local float locy;
	local float locx;
	local entity eatloc;
	local entity clicked_piece;
	local string my_color;

	if (action_flag)
	{
		return;
	}
	if (((current_turn != self) && !single_player))
	{
		return;
	}
	if ((current_selected == world) && (current_destination != ""))
	{
		clicked_piece = EntityAtLoc(current_dest_int);
		if (((clicked_piece != world) && (clicked_piece.owner != world)) && (clicked_piece.owner != current_turn))
		{
			if ((game_checkers && (current_turn.chess_team == "white")))
				my_color = "Black";
			else if ((game_checkers && (current_turn.chess_team == "black")))
				my_color = "Red";
			else if ((current_turn.chess_team == "white"))
				my_color = "White";
			else
				my_color = "Black";
			mysprint(self, strcat("That is your opponent's piece. You are playing ", my_color, ".\n"));
		}
	}
	if ((current_selected != world))
	{
		if (!(current_turn.chess_flags & CF_SELECTED_PIECE))
		{
			if (game_checkers)
			{
				if (CheckersAnyCaptureAvailable(current_turn))
				{
					if (!CheckersPieceCanJump(current_selected))
					{
						mysprint(self, "Cannot select that piece: another piece has a mandatory capture.\n");
						ClearLastHighlight();
						current_selected = world;
						return;
					}
				}
				else if (!CheckersPieceCanStep(current_selected))
				{
					mysprint(self, "Cannot select that piece: it is blocked and has no legal moves.\n");
					ClearLastHighlight();
					current_selected = world;
					return;
				}
			}
			else
			{
				ChessRebuildOccupancy();
				if (!ChessPieceHasLegalMove(current_selected))
				{
					mysprint(self, "Cannot select that piece: it has no legal moves in this position.\n");
					ClearLastHighlight();
					current_selected = world;
					return;
				}
			}
			current_turn.chess_flags = (current_turn.chess_flags | CF_SELECTED_PIECE);
			if ((game_checkers && current_selected.ischecker))
			{
				if (current_selected.isking)
				{
					mysprint(self, "King selected\n");
				}
				else
				{
					mysprint(self, "Piece selected\n");
				}
			}
			else
			{
			if ((current_selected.classname == "chess_pawn"))
			{
				mysprint(self, "Pawn selected\n");
			}
			else
			{
				if ((current_selected.classname == "chess_rook"))
				{
					mysprint(self, "Rook selected\n");
				}
				else
				{
					if ((current_selected.classname == "chess_knight"))
					{
						mysprint(self, "Knight selected\n");
					}
					else
					{
						if ((current_selected.classname == "chess_bishop"))
						{
							mysprint(self, "Bishop selected\n");
						}
						else
						{
							if ((current_selected.classname == "chess_queen"))
							{
								mysprint(self, "Queen selected\n");
							}
							else
							{
								if ((current_selected.classname == "chess_king"))
								{
									mysprint(self, "King selected\n");
								}
							}
						}
					}
				}
			}
			}
			mystuffcmd(self, "play effects/button.wav\n");
			ShowSelectionEffect(current_selected);
			ShowMoveHints(current_selected);
			if (!game_checkers)
			{
				if ((current_selected.classname == "chess_pawn"))
				{
					if (secret_monsters)
					{
						mystuffcmd(current_turn, "play dog/idle.wav\n");
					}
					else
					{
						random_pawn_speech();
					}
				}
				if ((current_selected.classname == "chess_bishop"))
				{
					if (secret_monsters)
					{
						random_pawn_speech();
					}
					else
					{
						random_bishop_speech();
					}
				}
				if ((current_selected.classname == "chess_knight"))
				{
					if (secret_monsters)
					{
						random_scrag_speech();
					}
					else
					{
						random_fiend_speech();
					}
				}
				if ((current_selected.classname == "chess_rook"))
				{
					if (secret_monsters)
					{
						random_bishop_speech();
					}
					else
					{
						random_rook_speech();
					}
				}
				if ((current_selected.classname == "chess_queen"))
				{
					if (secret_monsters)
					{
						mystuffcmd(current_turn, "play shalrath/sight.wav\n");
					}
					else
					{
						mystuffcmd(current_turn, "play shambler/sidle.wav\n");
					}
				}
				else
				{
					if ((current_selected.classname == "chess_king"))
					{
						random_king_speech();
					}
				}
			}
		}
		else
		{
			if ((current_destination != ""))
			{
					if (CanMove(current_selected, current_dest_int, TRUE))
					{
						action_flag = TRUE;
						ClearSelectionEffect();
						ClearLastHighlight();
						dest_org = LocationToVector(current_dest_int);
						setorigin(dest_ent, dest_org);
						mystuffcmd(self, "play effects/button.wav\n");
					if ((current_selected.think != FoundTarget))
					{
						WalkToDest(self);
						if (!game_checkers)
						{
							if ((current_selected.classname == "chess_pawn"))
							{
								if (secret_monsters)
								{
									mystuffcmd(current_turn, "play dog/dsight.wav\n");
								}
								else
								{
									mystuffcmd(current_turn, "play voice/pawn/hyessir4.wav\n");
								}
							}
							if ((current_selected.classname == "chess_bishop"))
							{
								if (secret_monsters)
								{
									mystuffcmd(current_turn, "play voice/pawn/hyessir4.wav\n");
								}
								else
								{
									rnd = (random() * AS_MELEE);
									if ((rnd < SPAWN_CRUCIFIED))
									{
										mystuffcmd(current_turn, "play voice/bishop/tuyessr1.wav\n");
									}
									else
									{
										if ((rnd < SPAWNFLAG_LASER))
										{
											mystuffcmd(current_turn, "play voice/bishop/tuyessr2.wav\n");
										}
										else
										{
											if ((rnd < AS_MELEE))
											{
												mystuffcmd(current_turn, "play voice/bishop/tuyessr3.wav\n");
											}
										}
									}
								}
							}
							if ((current_selected.classname == "chess_knight"))
							{
								if (secret_monsters)
								{
									mystuffcmd(current_turn, "play wizard/wsight.wav\n");
								}
								else
								{
									mystuffcmd(current_turn, "play demon/sight2.wav\n");
								}
							}
							if ((current_selected.classname == "chess_rook"))
							{
								if (secret_monsters)
								{
									rnd = (random() * AS_MELEE);
									if ((rnd < SPAWN_CRUCIFIED))
									{
										mystuffcmd(current_turn, "play voice/bishop/tuyessr1.wav\n");
									}
									else
									{
										if ((rnd < SPAWNFLAG_LASER))
										{
											mystuffcmd(current_turn, "play voice/bishop/tuyessr2.wav\n");
										}
										else
										{
											if ((rnd < AS_MELEE))
											{
												mystuffcmd(current_turn, "play voice/bishop/tuyessr3.wav\n");
											}
										}
									}
								}
								else
								{
									rnd = (random() * SECRET_1ST_DOWN);
									if ((rnd < SPAWN_CRUCIFIED))
									{
										mystuffcmd(current_turn, "play voice/rook/yessir1.wav\n");
									}
									else
									{
										if ((rnd < SPAWNFLAG_LASER))
										{
											mystuffcmd(current_turn, "play voice/rook/yessir2.wav\n");
										}
										else
										{
											if ((rnd < AS_MELEE))
											{
												mystuffcmd(current_turn, "play voice/rook/yessir3.wav\n");
											}
											else
											{
												if ((rnd < SECRET_1ST_DOWN))
												{
													mystuffcmd(current_turn, "play voice/rook/yessir4.wav\n");
												}
											}
										}
									}
								}
							}
							if ((current_selected.classname == "chess_queen"))
							{
								if (secret_monsters)
								{
									mystuffcmd(current_turn, "play shalrath/idle.wav\n");
								}
								else
								{
									rnd = (random() * SPAWNFLAG_LASER);
									if ((rnd < SPAWN_CRUCIFIED))
									{
										mystuffcmd(current_turn, "play shambler/melee1.wav\n");
									}
									else
									{
										if ((rnd < SPAWNFLAG_LASER))
										{
											mystuffcmd(current_turn, "play shambler/melee2.wav\n");
										}
									}
								}
							}
							if ((current_selected.classname == "chess_king"))
							{
								rnd = (random() * SPAWNFLAG_LASER);
								if ((rnd < SPAWN_CRUCIFIED))
								{
									mystuffcmd(current_turn, "play zombie/z_pain1.wav\n");
								}
								else
								{
									if ((rnd < SPAWNFLAG_LASER))
									{
										mystuffcmd(current_turn, "play zombie/z_pain.wav\n");
									}
								}
							}
						}
					}
					if (game_checkers)
					{
						bprint("\xC3\xE8\xE5\xE3\xEB\xE5\xF2\xF3: ");
						if ((current_selected.chess_team == "white"))
						{
							bprint("Black ");
						}
						else
						{
							bprint("Red ");
						}
						if (current_selected.isking)
						{
							bprint("king ");
						}
						else
						{
							bprint("piece ");
						}
						bprint(ftos(current_selected.location));
						eatloc = current_selected.enemy;
						if ((eatloc == world))
						{
							bprint(" - ");
						}
						else
						{
							bprint(" x ");
						}
						bprint(ftos(current_dest_int));
						bprint("\n");
					}
					else
					{
						if ((current_selected.chess_team == "white"))
						{
							movenum = (movenum + SPAWN_CRUCIFIED);
						}
						bprint("** ");
						current_selected.location_str = ftos(movenum);
						bprint(current_selected.location_str);
						if ((current_selected.chess_team == "black"))
						{
							bprint("a");
						}
						if ((king_castle_move_flag == TRUE))
						{
							bprint(": O-O");
							if ((GetX(current_dest_int) == AS_MELEE))
							{
								bprint("-O");
							}
							bprint("\n");
						}
						else
						{
							bprint(": [");
							locx = GetX(current_selected.location);
							if ((locx <= SECRET_1ST_DOWN))
							{
								bprint("Q");
							}
							else
							{
								if ((locx >= TE_LIGHTNING1))
								{
									bprint("K");
								}
							}
							if (((locx == SPAWN_CRUCIFIED) || (locx == 8)))
							{
								bprint("R");
							}
							else
							{
								if (((locx == SPAWNFLAG_LASER) || (locx == TE_WIZSPIKE)))
								{
									bprint("Kt");
								}
								else
								{
									if (((locx == AS_MELEE) || (locx == TE_LIGHTNING2)))
									{
										bprint("B");
									}
								}
							}
							if ((current_selected.chess_team == "white"))
							{
								locy = GetY(current_selected.location);
							}
							else
							{
								locy = (TE_LIGHTNING3 - GetY(current_selected.location));
							}
							current_selected.location_str = ftos(locy);
							bprint(current_selected.location_str);
							bprint("] ");
							if ((current_selected.classname == "chess_pawn"))
							{
								bprint("P");
							}
							else
							{
								if ((current_selected.classname == "chess_bishop"))
								{
									bprint("B");
								}
								else
								{
									if ((current_selected.classname == "chess_knight"))
									{
										bprint("Kt");
									}
									else
									{
										if ((current_selected.classname == "chess_rook"))
										{
											bprint("R");
										}
										else
										{
											if ((current_selected.classname == "chess_queen"))
											{
												bprint("Q");
											}
											else
											{
												if ((current_selected.classname == "chess_king"))
												{
													bprint("K");
												}
											}
										}
									}
								}
							}
							eatloc = current_selected.enemy;
							if ((eatloc == world))
							{
								bprint(" - ");
							}
							else
							{
								bprint(" x ");
								if ((eatloc.classname == "chess_pawn"))
								{
									bprint("P");
								}
								else
								{
									if ((eatloc.classname == "chess_bishop"))
									{
										bprint("B");
									}
									else
									{
										if ((eatloc.classname == "chess_knight"))
										{
											bprint("Kt");
										}
										else
										{
											if ((eatloc.classname == "chess_rook"))
											{
												bprint("R");
											}
											else
											{
												if ((eatloc.classname == "chess_queen"))
												{
													bprint("Q");
												}
												else
												{
													if ((eatloc.classname == "chess_king"))
													{
														bprint("K");
													}
												}
											}
										}
									}
								}
								bprint(" [");
							}
							locx = GetX(current_dest_int);
							if ((locx <= SECRET_1ST_DOWN))
							{
								bprint("Q");
							}
							else
							{
								if ((locx >= TE_LIGHTNING1))
								{
									bprint("K");
								}
							}
							if (((locx == SPAWN_CRUCIFIED) || (locx == 8)))
							{
								bprint("R");
							}
							else
							{
								if (((locx == SPAWNFLAG_LASER) || (locx == TE_WIZSPIKE)))
								{
									bprint("Kt");
								}
								else
								{
									if (((locx == AS_MELEE) || (locx == TE_LIGHTNING2)))
									{
										bprint("B");
									}
								}
							}
							if ((current_selected.chess_team == "white"))
							{
								locy = GetY(current_dest_int);
							}
							else
							{
								locy = (TE_LIGHTNING3 - GetY(current_dest_int));
							}
							current_selected.location_str = ftos(locy);
							bprint(current_selected.location_str);
							if ((eatloc != world))
							{
								bprint("]");
							}
							bprint("\n");
						}
					}
					current_turn.last_moved = current_selected;
					current_turn.last_move_from = current_selected.location;
					current_turn.last_move_to = current_dest_int;
					LastMoved = current_selected;
					LastMovedLocation = current_dest_int;
					current_selected.location = current_dest_int;
					current_selected.hasmoved = TRUE;
					current_turn.chess_flags = (current_turn.chess_flags - CF_SELECTED_PIECE);
				}
			}
		}
	}
};

void(entity client) WalkToDest =
{
	local entity etemp;

	current_selected.goalentity = dest_ent;
	current_turn.last_moved = current_selected;
	etemp = self;
	self = current_selected;
	current_selected.th_walk();
	self = etemp;
	current_selected.ideal_yaw = vectoyaw((dest_ent.origin - current_selected.origin));
};

void() message_think =
{
	mycentreprint(message_target, message_text);
	self.nextthink = (time + SPAWN_CRUCIFIED);
};

void() welcome_mesg =
{
	local entity oldent;

	oldent = self;
	self = oldent.owner;
	self.lastmarked = SPAWN_CRUCIFIED;
	self.marker1 = self.origin;
	self.marker1a = self.v_angle;
	self = oldent;
	if ((!self.owner.spectator && !menu_startup_pending))
	{
		sprint(self.owner, "** You are playing ");
		sprint(self.owner, self.owner.chess_team);
		sprint(self.owner, "\n");
	}
	sprint(self.owner, "  -------------------------\n");
	sprint(self.owner, "\s     C R O W N Q U A K E\n");
	sprint(self.owner, "  -------------------------\n");
	sprint(self.owner, "Build: 2026-07-06-menu24\n");
	if ((!menu_startup_pending && game_checkers))
	{
		sprint(self.owner, "Mode: Checkers\n");
	}
	else if (!menu_startup_pending)
	{
		sprint(self.owner, "Mode: Chess\n");
	}
	stuffcmd(self.owner, "crosshair 1\n");
	stuffcmd(self.owner, "bind F1 \"impulse 241\"\n");
	stuffcmd(self.owner, "bind F2 \"impulse 242\"\n");
	stuffcmd(self.owner, "bind h \"impulse 200\"\n");
	// Vanilla Quake pauses local games while the console is open, so local play
	// must resume for a frame before the impulse can reach QuakeC.  A network
	// game keeps running and should leave each player's console open.
	if (single_player)
		stuffcmd(self.owner, "alias undo \"toggleconsole; wait; impulse 61\"\n");
	else
		stuffcmd(self.owner, "alias undo impulse 61\n");
	stuffcmd(self.owner, "bind u \"impulse 61\"\n");
	stuffcmd(self.owner, "bind shift +speed\n");
	if (!self.owner.spectator)
	{
		Menu_OpenStartupModeSelect();
	}
	if (self.owner.spectator)
	{
		sprint(self.owner, "** ");
		sprint(self.owner, current_turn.netname);
		sprint(self.owner, " is playing ");
		sprint(self.owner, current_turn.chess_team);
		sprint(self.owner, "\n");
		sprint(self.owner, "** ");
		sprint(self.owner, current_turn.opponent.netname);
		sprint(self.owner, " is playing ");
		sprint(self.owner, current_turn.opponent.chess_team);
		sprint(self.owner, "\n");
		sprint(self.owner, "*** You are a spectator ***\n");
		sprint(self.owner, "It is now ");
		sprint(self.owner, current_turn.netname);
		sprint(self.owner, "'s turn\n");
	}
	remove(self);
};

void() Promotion_TimeOut =
{
	if ((QueenEnt.classname == "chess_pawn"))
	{
		QueenTo = "chess_queen";
		MakeQueen();
	}
	remove(self);
};

void() become_queen =
{
	local entity toent;

	QueenTo = "chess_queen";
	QueenEnt = self;
	toent = spawn();
	setmodel(toent, "progs/null.mdl");
	toent.think = Promotion_TimeOut;
	toent.nextthink = (time + SVC_INTERMISSION);
};

entity(entity own) get_king =
{
	local entity trav;

	trav = find(world, classname, "chess_king");
	while ((trav != world))
	{
		if ((trav.owner == own))
		{
			return (trav);
		}
		trav = find(trav, classname, "chess_king");
	}
	return (world);
};

void() CheckersFinishMove =
{
	local entity jumped;
	local float promoted;

	jumped = checkers_capture_entity;
	if ((jumped != world))
	{
		checkers_turn_progress = TRUE;
		spawn_tfog(jumped.origin);
		jumped.health = -10;
		jumped.location = 0;
		jumped.ischecker = FALSE;
		Killed(jumped, self);
		current_turn.frags = (current_turn.frags + 1);
		current_turn.currentammo = current_turn.frags;
	}
	CheckersClearCaptureTarget();
	promoted = CheckersMaybePromote(self);
	if (promoted)
		checkers_turn_progress = TRUE;
	if (((checkers_was_jump && !promoted) && CheckersPieceCanJump(self)))
	{
		checkers_must_jump = TRUE;
		checkers_was_jump = FALSE;
		current_selected = self;
		current_turn.chess_flags = (current_turn.chess_flags | CF_SELECTED_PIECE);
		ShowSelectionEffect(self);
		ShowMoveHints(self);
		action_flag = FALSE;
		mystuffcmd(current_turn, "bf\n");
		CheckersMaybeScheduleBotTurn();
		return;
	}
	CheckersClearTurnState();
	next_turn();
};

void() CheckCheckersGameOver =
{
	local entity loser;
	local entity winner;

	loser = current_turn;
	winner = current_turn.opponent;
	game_draw_reason = "";
	action_flag = TRUE;
	gameover = TRUE;
	CheckersClearTurnState();
	if ((winner != world))
	{
		mycentreprint(winner, "YOU HAVE WON!");
		winner.skin = SPAWN_CRUCIFIED;
	}
	if ((loser != world))
	{
		mycentreprint(loser, "You have lost.");
		loser.skin = MSG_BROADCAST;
	}
	bprint("\xC3\xE8\xE5\xE3\xEB\xE5\xF2\xF3 game over: ");
	if ((winner != world))
	{
		bprint(winner.netname);
	}
	else
	{
		bprint("opponent");
	}
	bprint(" wins\n");
	// Snapshot the terminal position so the last move can still be taken back
	// from the game-over menu (UndoRestore clears the game-over state).
	UndoPushSnapshot();
	Menu_OpenGameOver(winner);
};

void() next_turn =
{
	local entity side_to_move;

	if (game_checkers)
	{
		CheckersClearTurnState();
	}
	if (!game_checkers)
	{
		side_to_move = current_turn.opponent;
		ChessRebuildOccupancy();
		if (!ChessHasLegalMove(side_to_move))
		{
			ChessFinishNoLegalMoves(side_to_move, current_turn);
			return;
		}
		if (ChessInCheck(side_to_move))
		{
			sound(side_to_move, CHAN_AUTO, "voice/check.wav", SPAWN_CRUCIFIED, ATTN_NONE);
			bprint(side_to_move.netname);
			bprint(" is in check\n");
		}
	}
	if (((single_player && !current_turn.is_bot) && !current_turn.opponent.is_bot))
	{
		current_turn.v_angle = current_turn.owner.v_angle;
		current_turn.v_angle_y = anglemod(current_turn.v_angle_y);
		current_turn.origin = current_turn.owner.origin;
	}
	ClearSelectionEffect();
	ClearLastHighlight();
	current_turn.chess_flags = (current_turn.chess_flags - (current_turn.chess_flags & CF_SELECTED_PIECE));
	current_turn.chess_flags = (current_turn.chess_flags - (current_turn.chess_flags & CF_TIME_NOTIFY));
	current_turn.chess_flags = (current_turn.chess_flags - (current_turn.chess_flags & CF_CHECK_NOTIFY));
	if (!single_player)
	{
		setmodel(current_turn.pointer, "progs/null.mdl");
	}
	current_turn.opponent.impulse = MSG_BROADCAST;
	current_turn = current_turn.opponent;
	current_dest_int = MSG_BROADCAST;
	if ((game_checkers && !CheckersSideHasLegalMove(current_turn)))
	{
		CheckCheckersGameOver();
		return;
	}
	if ((game_checkers && CheckersRecordPositionAndCheckDraw(current_turn)))
		return;
	if (!single_player)
	{
		setmodel(current_turn.pointer, "progs/s_light.spr");
		current_turn.pointer.scale = 0.5;
		mycentreprint(current_turn, "Your turn\n");
	}
	else if (!ComputerVsComputerGame())
	{
		if ((game_checkers && (current_turn.chess_team == "white")))
		{
			mysprint(current_turn, "Current turn: Black\n");
		}
		else if ((game_checkers && (current_turn.chess_team == "black")))
		{
			mysprint(current_turn, "Current turn: Red\n");
		}
		else if ((current_turn.chess_team == "white"))
		{
			mysprint(current_turn, "Current turn: White\n");
		}
		else
		{
			mysprint(current_turn, "Current turn: Black\n");
		}
	}
	mystuffcmd(current_turn, "bf\n");
	if ((random() < 0.5))
	{
		mystuffcmd(current_turn, "play buttons/switch02.wav\n");
	}
	else
	{
		mystuffcmd(current_turn, "play buttons/switch04.wav\n");
	}
	current_turn.turn_starttime = time;
	current_selected = world;
	current_turn.chess_flags = (current_turn.chess_flags | CF_CHECK_NOTIFY);
	if (((single_player && !current_turn.is_bot) && !current_turn.opponent.is_bot))
	{
		setorigin(current_turn.owner, current_turn.origin);
		msg_entity = current_turn.owner;
		WriteByte(MSG_ONE, SVC_SETVIEWANGLES);
		WriteAngle(MSG_ONE, current_turn.v_angle_x);
		WriteAngle(MSG_ONE, current_turn.v_angle_y);
		WriteAngle(MSG_ONE, current_turn.v_angle_z);
		current_turn.fixangle = TRUE;
	}
	action_flag = FALSE;
	UndoPushSnapshot();
	ChessBotRecordPosition(current_turn);
	CheckersMaybeScheduleBotTurn();
	ChessMaybeScheduleBotTurn();
};

void(entity side_to_move, entity winner) ChessFinishNoLegalMoves =
{
	local entity human_side;
	local float checkmate;

	checkmate = ChessInCheck(side_to_move);
	game_draw_reason = "";
	gameover = TRUE;
	action_flag = TRUE;
	ClearSelectionEffect();
	ClearLastHighlight();
	current_selected = world;
	if (checkmate)
	{
		ralcheckmate = TRUE;
		sound(winner, CHAN_AUTO, "voice/chckmate.wav", SPAWN_CRUCIFIED, ATTN_NONE);
		bprint("** Checkmate: ");
		bprint(winner.netname);
		bprint(" wins\n");
		winner.skin = SPAWN_CRUCIFIED;
		side_to_move.skin = MSG_BROADCAST;
	}
	else
	{
		bprint("** Stalemate: draw\n");
		game_draw_reason = "Draw by stalemate.";
		winner = world;
	}
	if (single_player)
	{
		human_side = world;
		if ((((player1 != world) && !player1.is_bot) && ((player2 != world) && player2.is_bot)))
			human_side = player1;
		else if ((((player2 != world) && !player2.is_bot) && ((player1 != world) && player1.is_bot)))
			human_side = player2;
		if ((human_side != world))
		{
			if ((winner == world))
				mycentreprint(human_side, "Draw by stalemate.");
			else if ((winner == human_side))
				mycentreprint(human_side, "YOU HAVE WON!");
			else
				mycentreprint(human_side, "You have lost.");
		}
	}
	else
	{
		if ((winner != world))
			mycentreprint(winner, "YOU HAVE WON!");
		if (checkmate)
			mycentreprint(side_to_move, "You have lost.");
		else
			mycentreprint(side_to_move, "Draw by stalemate.");
	}
	// Snapshot the terminal position so the last move can still be taken back
	// from the game-over menu (UndoRestore clears the game-over state).
	UndoPushSnapshot();
	Menu_OpenGameOver(winner);
};

entity(entity monst) FindNewEnemy =
{
	local string other_team;
	local entity trav;

	if (!king_dead)
	{
		return (world);
	}
	if ((monst.chess_team == "black"))
	{
		other_team = "white";
	}
	else
	{
		other_team = "black";
	}
	trav = find(world, chess_team, other_team);
	while (((trav != world) && ((((trav.chess_team != other_team) || (trav.health <= MSG_BROADCAST)) || !(trav.flags & FL_MONSTER)) || (trav.enemy == world))))
	{
		trav = find(trav, chess_team, other_team);
	}
	if ((trav != world))
	{
		return (trav);
	}
	else
	{
		trav = find(world, chess_team, other_team);
		while (((trav != world) && (((trav.chess_team != other_team) || (trav.health <= MSG_BROADCAST)) || !(trav.flags & FL_MONSTER))))
		{
			trav = find(trav, chess_team, other_team);
		}
		return (trav);
	}
};

void(float loc) HighlightLocation =
{
	local entity trav;
	local string loc_str;

	loc_str = ftos(loc);
	trav = find(world, targetname, loc_str);
	while (((trav != world) && (trav.classname != "door")))
	{
		trav = find(trav, targetname, loc_str);
	}
	if ((trav != world))
	{
		setorigin(trav, trav.pos2);
		trav.pos2 = trav.pos1;
		trav.pos1 = trav.origin;
		last_highlight = trav;
	}
};

void() CheckGameOver =
{
	local entity ent1;
	local entity ent2;
	local entity e1trav;
	local entity e2trav;
	local float found;

	if (!king_dead)
	{
		self.health = -10;
		king_dead = TRUE;
		sound(self, CHAN_AUTO, "boss1/death.wav", SPAWN_CRUCIFIED, ATTN_NONE);
		action_flag = TRUE;
		found = FALSE;
		e1trav = find(world, chess_team, "white");
		while (((e1trav != world) && !found))
		{
			e1trav = find(e1trav, chess_team, "white");
			if ((e1trav != world))
			{
				if ((((e1trav.flags & FL_MONSTER) && (e1trav.health > MSG_BROADCAST)) && (e1trav.classname != "chess_king")))
				{
					found = TRUE;
				}
			}
		}
		if ((e1trav != world))
		{
			ent1 = e1trav;
		}
		else
		{
			return;
		}
		found = FALSE;
		e2trav = find(world, chess_team, "black");
		while (((e2trav != world) && !found))
		{
			e2trav = find(e2trav, chess_team, "black");
			if ((e2trav != world))
			{
				if ((((e2trav.flags & FL_MONSTER) && (e2trav.health > MSG_BROADCAST)) && (e2trav.classname != "chess_king")))
				{
					found = TRUE;
				}
			}
		}
		if ((e2trav != world))
		{
			ent2 = e2trav;
		}
		else
		{
			return;
		}
		while (((e1trav != world) || (e2trav != world)))
		{
			ent1.enemy = ent2;
			ent1.think = FoundTarget;
			ent1.nextthink = (time + 0.1);
			ent2.enemy = ent1;
			ent2.think = FoundTarget;
			ent2.nextthink = (time + 0.1);
			if ((e1trav != world))
			{
				found = FALSE;
				e1trav = find(e1trav, chess_team, "white");
				while (((e1trav != world) && !found))
				{
					e1trav = find(e1trav, chess_team, "white");
					if ((e1trav != world))
					{
						if ((((e1trav.flags & FL_MONSTER) && (e1trav.health > MSG_BROADCAST)) && (e1trav.classname != "chess_king")))
						{
							found = TRUE;
						}
					}
				}
				if ((e1trav != world))
				{
					ent1 = e1trav;
				}
			}
			if ((e2trav != world))
			{
				found = FALSE;
				e2trav = find(e2trav, chess_team, "black");
				while (((e2trav != world) && !found))
				{
					e2trav = find(e2trav, chess_team, "black");
					if ((e2trav != world))
					{
						if ((((e2trav.flags & FL_MONSTER) && (e2trav.health > MSG_BROADCAST)) && (e2trav.classname != "chess_king")))
						{
							found = TRUE;
						}
					}
				}
				if ((e2trav != world))
				{
					ent2 = e2trav;
				}
			}
		}
		if ((teamplay > MSG_BROADCAST))
		{
			if ((self.owner.opponent.flags & FL_CLIENT))
			{
				mycentreprint(self.owner.opponent, "YOU HAVE WON!");
				self.owner.opponent.skin = SPAWN_CRUCIFIED;
			}
			if ((self.owner.flags & FL_CLIENT))
			{
				mycentreprint(self.owner, "You have lost..");
				self.owner.opponent.skin = MSG_BROADCAST;
			}
		}
	}
};

void(entity plyr) UpdateMonsterColors =
{
	local entity trav;

	if ((cvar("coop") != AS_MELEE))
	{
		return;
	}
	trav = find(world, chess_team, plyr.chess_team);
	while ((trav != world))
	{
		if ((((trav.flags & FL_MONSTER) && (trav.classname != "chess_king")) && (trav.classname != "chess_queen")))
		{
			trav.colormap = plyr.colormap;
		}
		trav = find(trav, chess_team, plyr.chess_team);
	}
};

float(entity ent, entity ignore) CanDie =
{
	local entity trav;
	local string team_str;

	if ((ent.chess_team == "white"))
	{
		team_str = "black";
	}
	else
	{
		team_str = "white";
	}
	trav = find(world, chess_team, team_str);
	while ((trav != world))
	{
		if (((trav.owner != ent.owner) && (trav != ignore)))
		{
			if (((trav.flags & FL_MONSTER) && (trav.health > MSG_BROADCAST)))
			{
				if (CanMove(trav, ent.location, FALSE))
				{
					return (TRUE);
				}
			}
		}
		trav = find(trav, chess_team, team_str);
	}
	return (FALSE);
};

void(entity ent, string msg) mycentreprint =
{
	ent.last_message = msg;
	if ((ent.classname == "info_player_start"))
	{
		if (((ent.owner != world) && ent.owner.menu_screen))
		{
			return;
		}
		centerprint(ent.owner, msg);
	}
	else
	{
		if (ent.menu_screen)
		{
			return;
		}
		centerprint(ent, msg);
	}
};

void(entity ent, string cmd) mystuffcmd =
{
	if ((ent.classname == "info_player_start"))
	{
		stuffcmd(ent.owner, cmd);
	}
	else
	{
		stuffcmd(ent, cmd);
	}
};

void(entity ent, string cmd) mysprint =
{
	if ((ent.classname == "info_player_start"))
	{
		sprint(ent.owner, cmd);
	}
	else
	{
		sprint(ent, cmd);
	}
};

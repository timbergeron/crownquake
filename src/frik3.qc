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
		v1_x = ceil(v1);
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
	if (((((current_selected != world) && (current_selected.owner == current_turn)) && (self.last_voice_entity.classname != current_selected.classname)) && (self.last_voice < (time - 1.5))))
	{
		mystuffcmd(current_turn, "play voice/");
		mystuffcmd(current_turn, current_selected.netname);
		mystuffcmd(current_turn, ".wav\n");
		self.last_voice = time;
		self.last_voice_entity = current_selected;
	}
};

void() CameraPos =
{
	local vector ideal_pos;
	local vector ideal_vec;
	local float ideal_len;
	local float ideal_vec_len;

	makevectors(self.v_angle);
	ideal_pos = (v_forward * -350);
	if ((ideal_pos_z < MSG_BROADCAST))
	{
		ideal_pos_z = MSG_BROADCAST;
	}
	self.dest = ideal_pos;
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
		self.angles = '0 180 0';
	}
	else
	{
		self.angles = '0 0 0';
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
	checkers_must_jump = FALSE;
	checkers_was_jump = FALSE;
	checkers_capture_entity = world;
	checkers_capture_location = 0;
	checkers_board_spawned = TRUE;
	bprint("** crownquake checkers mode: board spawned\n");
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
		}
		trav = find(trav, chess_team, side_owner.chess_team);
	}
	return (FALSE);
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
		ent.effects = (ent.effects | EF_BRIGHTLIGHT);
		bprint("** Checkers man crowned king\n");
		mysprint(ent.owner, "Checker crowned king\n");
		return (TRUE);
	}
	return (FALSE);
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
		checkers_capture_entity = world;
		checkers_capture_location = 0;
		checkers_was_jump = FALSE;
		ent.enemy = world;
	}
	if (!ent.ischecker)
	{
		return (FALSE);
	}
	if (!CheckersOnBoard(loc))
	{
		return (FALSE);
	}
	if ((at_loc != world))
	{
		return (FALSE);
	}
	if ((checkers_must_jump && (ent != current_selected)))
	{
		if (actual_move)
		{
			mycentreprint(ent.owner, "You must finish the jump");
		}
		return (FALSE);
	}
	if (CheckersCanStepTo(ent, loc))
	{
		if (checkers_must_jump)
		{
			if (actual_move)
			{
				mycentreprint(ent.owner, "You must jump again");
			}
			return (FALSE);
		}
		if (CheckersAnyCaptureAvailable(ent.owner))
		{
			if (actual_move)
			{
				mycentreprint(ent.owner, "You must capture");
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
	return (FALSE);
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
	local float rtemp_loc;
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
										if ((RalCanDie(ent, world) == TRUE))
										{
											if (actual_move)
											{
												mycentreprint(current_turn, "Cannot castle out of Check");
											}
											return (MSG_BROADCAST);
										}
										rtemp_loc = ent.location;
										if ((newx < oldx))
										{
											ent.location = (((oldx - SPAWN_CRUCIFIED) * 10) + oldy);
										}
										else
										{
											ent.location = (((oldx + SPAWN_CRUCIFIED) * 10) + oldy);
										}
										if ((RalCanDie(ent, world) == TRUE))
										{
											ent.location = rtemp_loc;
											if (actual_move)
											{
												mycentreprint(ent.owner, "Cannot castle through Check");
											}
											return (MSG_BROADCAST);
										}
										ent.location = rtemp_loc;
										rtemp_loc = ent.location;
										ent.location = loc;
										if ((RalCanDie(ent, world) == TRUE))
										{
											ent.location = rtemp_loc;
											if (actual_move)
											{
												mycentreprint(ent.owner, "Cannot castle into Check");
											}
											return (MSG_BROADCAST);
										}
										ent.location = rtemp_loc;
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

float(entity ent, float loc, float actual_move) CanMove =
{
	local entity at_loc;
	local entity king;
	local float result;
	local float temp_loc;

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
					mycentreprint(ent.owner, "Selection cleared\n");
					mystuffcmd(self, "play effects/button.wav\n");
					castle_to_move = world;
					king_castle_move_flag = FALSE;
					ent.owner.chess_flags = (ent.owner.chess_flags - (ent.owner.chess_flags & CF_SELECTED_PIECE));
					light_ent.effects = MSG_BROADCAST;
				}
			}
			else
			{
				mycentreprint(ent.owner, "You already have a piece there..");
			}
		}
		return (FALSE);
	}
	result = CheckValidMove(ent, loc, at_loc, actual_move);
	if ((result == MSG_BROADCAST))
	{
		if (actual_move)
		{
			mycentreprint(ent.owner, "Invalid move for that piece");
		}
		return (FALSE);
	}
	else
	{
		if (actual_move)
		{
			if (!game_checkers)
			{
				temp_loc = ent.location;
				ent.location = loc;
				king = get_king(ent.owner);
				ignore_canmove = at_loc;
				if (CanDie(king, at_loc))
				{
					mycentreprint(ent.owner, "This move places your King in danger");
					ent.location = temp_loc;
					return (FALSE);
				}
				ignore_canmove = world;
				ent.location = temp_loc;
			}
		}
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

void() ProcessSelection =
{
	local vector dest_org;
	local float rnd;
	local float locy;
	local float locx;
	local entity eatloc;

	if (action_flag)
	{
		return;
	}
	if (((current_turn != self) && !single_player))
	{
		return;
	}
	if ((current_selected != world))
	{
		if (!(current_turn.chess_flags & CF_SELECTED_PIECE))
		{
			current_turn.chess_flags = (current_turn.chess_flags | CF_SELECTED_PIECE);
			if ((game_checkers && current_selected.ischecker))
			{
				if (current_selected.isking)
				{
					mycentreprint(self, "King selected");
				}
				else
				{
					mycentreprint(self, "Man selected");
				}
			}
			else
			{
			if ((current_selected.classname == "chess_pawn"))
			{
				mycentreprint(self, "Pawn selected");
			}
			else
			{
				if ((current_selected.classname == "chess_rook"))
				{
					mycentreprint(self, "Rook selected");
				}
				else
				{
					if ((current_selected.classname == "chess_knight"))
					{
						mycentreprint(self, "Knight selected");
					}
					else
					{
						if ((current_selected.classname == "chess_bishop"))
						{
							mycentreprint(self, "Bishop selected");
						}
						else
						{
							if ((current_selected.classname == "chess_queen"))
							{
								mycentreprint(self, "Queen selected");
							}
							else
							{
								if ((current_selected.classname == "chess_king"))
								{
									mycentreprint(self, "King selected");
								}
							}
						}
					}
				}
			}
			}
			mystuffcmd(self, "play effects/button.wav\n");
			if ((light_ent.origin != (current_selected.origin + '0 0 96')))
			{
				setorigin(light_ent, (current_selected.origin + '0 0 96'));
			}
			light_ent.effects = EF_DIMLIGHT;
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
		else
		{
			if ((current_destination != ""))
			{
				if (CanMove(current_selected, current_dest_int, TRUE))
				{
					action_flag = TRUE;
					light_ent.effects = MSG_BROADCAST;
					dest_org = LocationToVector(current_dest_int);
					setorigin(dest_ent, dest_org);
					mystuffcmd(self, "play effects/button.wav\n");
					if ((current_selected.think != FoundTarget))
					{
						WalkToDest(self);
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
	AddMarker();
	self = oldent;
	if (!self.owner.spectator)
	{
		sprint(self.owner, "** You are playing");
		sprint(self.owner, self.owner.chess_team);
		sprint(self.owner, "\n");
	}
	sprint(self.owner, "crownquake\n  -------------------------\n     C R O W N Q U A K E\n  -------------------------\n");
	sprint(self.owner, "Original QUESS by the IMPACT TEAM; v1.34a mods by Ralgha\n");
	if (game_checkers)
	{
		sprint(self.owner, "Mode: Checkers\n");
	}
	else
	{
		sprint(self.owner, "Mode: Chess\n");
	}
	sprint(self.owner, "See readme.txt for more detailed information\n");
	sprint(self.owner, "Right Mouse to back up\n");
	sprint(self.owner, "Shift to go forward\n");
	sprint(self.owner, "Left Mouse to select/deselect piece\n");
	sprint(self.owner, "H for a list of keys\n");
	stuffcmd(self.owner, "crosshair 1\n");
	stuffcmd(self.owner, "bind F1 \"impulse 241\"\n");
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
};

void() CheckersFinishMove =
{
	local entity jumped;
	local float promoted;

	jumped = checkers_capture_entity;
	if ((jumped != world))
	{
		spawn_tfog(jumped.origin);
		jumped.health = -10;
		jumped.location = 0;
		jumped.ischecker = FALSE;
		Killed(jumped, self);
		current_turn.frags = (current_turn.frags + 1);
		current_turn.currentammo = current_turn.frags;
	}
	checkers_capture_entity = world;
	checkers_capture_location = 0;
	if ((current_selected != world))
	{
		current_selected.enemy = world;
	}
	promoted = CheckersMaybePromote(self);
	if (((checkers_was_jump && !promoted) && CheckersPieceCanJump(self)))
	{
		checkers_must_jump = TRUE;
		checkers_was_jump = FALSE;
		current_selected = self;
		current_turn.chess_flags = (current_turn.chess_flags | CF_SELECTED_PIECE);
		if ((light_ent != world))
		{
			setorigin(light_ent, (self.origin + '0 0 96'));
			light_ent.effects = EF_DIMLIGHT;
		}
		action_flag = FALSE;
		mycentreprint(current_turn, "Jump again");
		mystuffcmd(current_turn, "bf\n");
		return;
	}
	checkers_must_jump = FALSE;
	checkers_was_jump = FALSE;
	next_turn();
};

void() CheckCheckersGameOver =
{
	local entity loser;
	local entity winner;

	loser = current_turn;
	winner = current_turn.opponent;
	action_flag = TRUE;
	gameover = TRUE;
	checkers_must_jump = FALSE;
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
	bprint("** Checkers game over: ");
	if ((winner != world))
	{
		bprint(winner.netname);
	}
	else
	{
		bprint("opponent");
	}
	bprint(" wins\n");
};

void() next_turn =
{
	local entity king;

	if (!game_checkers)
	{
		king = get_king(current_turn.opponent);
		if (RalCanDie(king, world))
		{
			CheckOrMate();
		}
		if ((ralcheckmate == TRUE))
		{
			return;
		}
	}
	if (single_player)
	{
		current_turn.v_angle = current_turn.owner.v_angle;
		current_turn.v_angle_y = anglemod(current_turn.v_angle_y);
		current_turn.origin = current_turn.owner.origin;
	}
	light_ent.effects = MSG_BROADCAST;
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
	if (!single_player)
	{
		setmodel(current_turn.pointer, "progs/s_bubble.spr");
		mycentreprint(current_turn, "Your turn\n");
	}
	else
	{
		if ((current_turn.chess_team == "white"))
		{
			mycentreprint(current_turn, "Current turn: White\n");
		}
		else
		{
			mycentreprint(current_turn, "Current turn: Black\n");
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
	if (single_player)
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
		centerprint(ent.owner, msg);
	}
	else
	{
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

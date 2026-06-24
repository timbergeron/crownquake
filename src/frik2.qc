//Decompiled code. Please respect the original copyright.

float(entity rtarget, entity rignore) RalCanDie =
{
	local entity tempent;
	local float result;
	local string enteamstr;

	if ((rtarget.chess_team == "white"))
	{
		enteamstr = "black";
	}
	else
	{
		enteamstr = "white";
	}
	tempent = find(world, chess_team, enteamstr);
	while ((tempent != world))
	{
		if ((((tempent != rignore) && (tempent.flags & FL_MONSTER)) && (tempent.health > MSG_BROADCAST)))
		{
			result = CheckValidMove(tempent, rtarget.location, rtarget, FALSE);
			if ((result > MSG_BROADCAST))
			{
				return (TRUE);
			}
		}
		tempent = find(tempent, chess_team, enteamstr);
	}
	return (FALSE);
};

float(entity ent, float loc) CanMoveKingLive =
{
	local entity at_loc;
	local entity king;
	local float result;
	local float temp_loc;

	at_loc = EntityAtLoc(loc);
	if (((at_loc != world) && (at_loc.owner == ent.owner)))
	{
		return (FALSE);
	}
	result = CheckValidMove(ent, loc, at_loc, FALSE);
	if ((result == MSG_BROADCAST))
	{
		return (FALSE);
	}
	else
	{
		temp_loc = ent.location;
		ent.location = loc;
		king = get_king(ent.owner);
		if (RalCanDie(king, at_loc))
		{
			ent.location = temp_loc;
			return (FALSE);
		}
		ent.location = temp_loc;
	}
	return (TRUE);
};

float(float loc, string team_str) FriendlyCanMove =
{
	local entity raltrav;
	local string debuginfo;

	raltrav = find(world, chess_team, team_str);
	while ((raltrav != world))
	{
		if (((raltrav.health > MSG_BROADCAST) && (raltrav.flags & FL_MONSTER)))
		{
			if (CanMoveKingLive(raltrav, loc))
			{
				return (TRUE);
			}
		}
		raltrav = find(raltrav, chess_team, team_str);
	}
	return (FALSE);
};

float(float rsx, float rsy, float rdx, float rdy) NextSquareToLoc =
{
	local float retloc;
	local float retx;
	local float rety;
	local string debuginfo;

	if ((rsy > rdy))
	{
		rety = (rsy - SPAWN_CRUCIFIED);
	}
	else
	{
		if ((rsy < rdy))
		{
			rety = (rsy + SPAWN_CRUCIFIED);
		}
		else
		{
			rety = rsy;
		}
	}
	if ((rsx > rdx))
	{
		retx = (rsx - SPAWN_CRUCIFIED);
	}
	else
	{
		if ((rsx < rdx))
		{
			retx = (rsx + SPAWN_CRUCIFIED);
		}
		else
		{
			retx = rsx;
		}
	}
	retloc = ((retx * 10) + rety);
	debuginfo = ftos(retloc);
	return (retloc);
};

float() IsCheckmate =
{
	local entity ratt2;
	local entity rking;
	local entity tattacker;
	local entity rattacker;
	local float rcanblock;
	local float rnumattackers;
	local float rkx;
	local float rky;
	local float rax;
	local float ray;
	local float rtemploc;
	local float rfcm;
	local string debuginfo;

	rking = get_king(current_turn.opponent);
	rcanblock = FALSE;
	rkx = GetX(rking.location);
	rky = GetY(rking.location);
	CanMoveKingLive(rking, (((rkx + SPAWN_CRUCIFIED) * 10) + (rky + SPAWN_CRUCIFIED)));
	if (((((((((CanMoveKingLive(rking, (((rkx + SPAWN_CRUCIFIED) * 10) + (rky + SPAWN_CRUCIFIED))) || CanMoveKingLive(rking, (((rkx + SPAWN_CRUCIFIED) * 10) + (rky + SPAWN_CRUCIFIED)))) || CanMoveKingLive(rking, (((rkx + SPAWN_CRUCIFIED) * 10) + rky))) || CanMoveKingLive(rking, (((rkx + SPAWN_CRUCIFIED) * 10) + (rky - SPAWN_CRUCIFIED)))) || CanMoveKingLive(rking, ((rkx * 10) + (rky + SPAWN_CRUCIFIED)))) || CanMoveKingLive(rking, ((rkx * 10) + (rky - SPAWN_CRUCIFIED)))) || CanMoveKingLive(rking, (((rkx - SPAWN_CRUCIFIED) * 10) + (rky + SPAWN_CRUCIFIED)))) || CanMoveKingLive(rking, (((rkx - SPAWN_CRUCIFIED) * 10) + rky))) || CanMoveKingLive(rking, (((rkx - SPAWN_CRUCIFIED) * 10) + (rky - SPAWN_CRUCIFIED)))))
	{
		return (FALSE);
	}
	tattacker = find(world, chess_team, rking.owner.opponent.chess_team);
	while ((tattacker != world))
	{
		if ((tattacker.owner != rking.owner))
		{
			if (((tattacker.flags & FL_MONSTER) && (tattacker.health > MSG_BROADCAST)))
			{
				if (CanMove(tattacker, rking.location, FALSE))
				{
					rnumattackers = (rnumattackers + SPAWN_CRUCIFIED);
					if ((rnumattackers == SPAWNFLAG_LASER))
					{
						ratt2 = tattacker;
					}
					else
					{
						rattacker = tattacker;
					}
				}
			}
		}
		tattacker = find(tattacker, chess_team, rking.owner.opponent.chess_team);
	}
	if ((rnumattackers > SPAWN_CRUCIFIED))
	{
		rattacker.enemy = rking;
		if ((rattacker != current_selected))
		{
			HighlightLocation(rattacker.location);
		}
		rattacker.think = FoundTarget;
		rattacker.nextthink = (time + 0.1);
		current_enemy = rking;
		ratt2.enemy = rking;
		if ((ratt2 != current_selected))
		{
			HighlightLocation(ratt2.location);
		}
		ratt2.think = FoundTarget;
		ratt2.nextthink = (time + 0.1);
		current_selected = rattacker;
		rking.enemy = ratt2;
		rking.think = FoundTarget;
		rking.nextthink = (time + 0.1);
		HighlightLocation(rking.location);
		if (((LastMoved != rattacker) && (LastMoved != ratt2)))
		{
			HighlightLocation(LastMovedLocation);
		}
		return (TRUE);
	}
	if (FriendlyCanMove(rattacker.location, rking.chess_team))
	{
		return (FALSE);
	}
	rkx = GetX(rking.location);
	rky = GetY(rking.location);
	rax = GetX(rattacker.location);
	ray = GetY(rattacker.location);
	if (((rattacker.classname == "chess_knight") || ((fabs((rax - rkx)) <= SPAWN_CRUCIFIED) && (fabs((ray - rky)) <= SPAWN_CRUCIFIED))))
	{
		rattacker.enemy = rking;
		rattacker.think = FoundTarget;
		rattacker.nextthink = (time + 0.1);
		current_enemy = rking;
		current_selected = rattacker;
		rking.enemy = rattacker;
		rking.think = FoundTarget;
		rking.nextthink = (time + 0.1);
		HighlightLocation(rking.location);
		if (((LastMoved != rattacker) && (LastMoved != ratt2)))
		{
			HighlightLocation(LastMovedLocation);
		}
		return (TRUE);
	}
	rtemploc = NextSquareToLoc(rkx, rky, rax, ray);
	rcanblock = FALSE;
	while ((rtemploc != rattacker.location))
	{
		rfcm = FriendlyCanMove(rtemploc, rking.chess_team);
		if ((rfcm == TRUE))
		{
			rcanblock = TRUE;
		}
		rkx = GetX(rtemploc);
		rky = GetY(rtemploc);
		rtemploc = NextSquareToLoc(rkx, rky, rax, ray);
	}
	if ((rcanblock == TRUE))
	{
		return (FALSE);
	}
	else
	{
		rattacker.enemy = rking;
		rattacker.think = FoundTarget;
		rattacker.nextthink = (time + 0.1);
		current_enemy = rking;
		current_selected = rattacker;
		rking.enemy = rattacker;
		rking.think = FoundTarget;
		rking.nextthink = (time + 0.1);
		HighlightLocation(rking.location);
		if (((LastMoved != rattacker) && (LastMoved != ratt2)))
		{
			HighlightLocation(LastMovedLocation);
		}
		return (TRUE);
	}
};

void() CheckOrMate =
{
	if ((IsCheckmate() == FALSE))
	{
		sound(current_turn, CHAN_AUTO, "voice/check.wav", SPAWN_CRUCIFIED, ATTN_NONE);
		bprint("** ");
		bprint(current_turn.opponent.netname);
		bprint(" is in Check!\n");
	}
	else
	{
		sound(current_turn, CHAN_AUTO, "voice/chckmate.wav", SPAWN_CRUCIFIED, ATTN_NONE);
		mystuffcmd(current_turn, "say Checkmate!\n");
		bprint("** ");
		bprint(current_turn.chess_team);
		bprint(" has won the game!\n");
		ralcheckmate = TRUE;
	}
};

void(float m_num) DoMarker =
{
	local vector m_org;
	local vector m_angle;

	if ((m_num == SPAWN_CRUCIFIED))
	{
		m_org = self.marker1;
		m_angle = self.marker1a;
	}
	else
	{
		if ((m_num == SPAWNFLAG_LASER))
		{
			m_org = self.marker2;
			m_angle = self.marker2a;
		}
		else
		{
			if ((m_num == AS_MELEE))
			{
				m_org = self.marker3;
				m_angle = self.marker3a;
			}
			else
			{
				if ((m_num == SECRET_1ST_DOWN))
				{
					m_org = self.marker4;
					m_angle = self.marker4a;
				}
				else
				{
					if ((m_num == TE_LIGHTNING1))
					{
						m_org = self.marker5;
						m_angle = self.marker5a;
					}
					else
					{
						if ((m_num == TE_LIGHTNING2))
						{
							m_org = self.marker6;
							m_angle = self.marker6a;
						}
						else
						{
							if ((m_num == TE_WIZSPIKE))
							{
								m_org = self.marker7;
								m_angle = self.marker7a;
							}
							else
							{
								if ((m_num == 8))
								{
									m_org = self.marker8;
									m_angle = self.marker8a;
								}
							}
						}
					}
				}
			}
		}
	}
	if ((m_org != '0 0 0'))
	{
		spawn_tfog(m_org);
		setorigin(self, m_org);
		self.angles = m_angle;
		self.fixangle = SPAWN_CRUCIFIED;
	}
	else
	{
		sprint(self, "Marker not set.\n");
	}
};

void() AddMarker =
{
	local float tfloat;
	local string tstr;

	tfloat = (self.lastmarked + SPAWN_CRUCIFIED);
	if ((tfloat > 8))
	{
		tfloat = SPAWN_CRUCIFIED;
	}
	tstr = ftos(tfloat);
	sprint(self, "Added marker ");
	sprint(self, tstr);
	sprint(self, "\n");
	self.lastmarked = tfloat;
	if ((tfloat == SPAWN_CRUCIFIED))
	{
		self.marker1 = self.origin;
		self.marker1a = self.v_angle;
	}
	else
	{
		if ((tfloat == SPAWNFLAG_LASER))
		{
			self.marker2 = self.origin;
			self.marker2a = self.v_angle;
		}
		else
		{
			if ((tfloat == AS_MELEE))
			{
				self.marker3 = self.origin;
				self.marker3a = self.v_angle;
			}
			else
			{
				if ((tfloat == SECRET_1ST_DOWN))
				{
					self.marker4 = self.origin;
					self.marker4a = self.v_angle;
				}
				else
				{
					if ((tfloat == TE_LIGHTNING1))
					{
						self.marker5 = self.origin;
						self.marker5a = self.v_angle;
					}
					else
					{
						if ((tfloat == TE_LIGHTNING2))
						{
							self.marker6 = self.origin;
							self.marker6a = self.v_angle;
						}
						else
						{
							if ((tfloat == TE_WIZSPIKE))
							{
								self.marker7 = self.origin;
								self.marker7a = self.v_angle;
							}
							else
							{
								if ((tfloat == 8))
								{
									self.marker8 = self.origin;
									self.marker8a = self.v_angle;
								}
							}
						}
					}
				}
			}
		}
	}
};

void(float cx, float cy) SEAL =
{
	local entity atloc;

	atloc = EntityAtLoc(((cx * 10) + cy));
	if ((atloc == world))
	{
		sprint(self, " ");
		return;
	}
	if ((game_checkers && atloc.ischecker))
	{
		if ((atloc.chess_team == "white"))
		{
			if (atloc.isking)
			{
				sprint(self, "K");
			}
			else
			{
				sprint(self, "M");
			}
		}
		else
		{
			if (atloc.isking)
			{
				sprint(self, "k");
			}
			else
			{
				sprint(self, "m");
			}
		}
		return;
	}
	if ((atloc.chess_team == "white"))
	{
		if ((atloc.classname == "chess_pawn"))
		{
			sprint(self, "P");
		}
		else
		{
			if ((atloc.classname == "chess_bishop"))
			{
				sprint(self, "B");
			}
			else
			{
				if ((atloc.classname == "chess_knight"))
				{
					sprint(self, "N");
				}
				else
				{
					if ((atloc.classname == "chess_rook"))
					{
						sprint(self, "R");
					}
					else
					{
						if ((atloc.classname == "chess_king"))
						{
							sprint(self, "K");
						}
						else
						{
							if ((atloc.classname == "chess_queen"))
							{
								sprint(self, "Q");
							}
						}
					}
				}
			}
		}
	}
	else
	{
		if ((atloc.classname == "chess_pawn"))
		{
			sprint(self, "ð");
		}
		else
		{
			if ((atloc.classname == "chess_bishop"))
			{
				sprint(self, "â");
			}
			else
			{
				if ((atloc.classname == "chess_knight"))
				{
					sprint(self, "î");
				}
				else
				{
					if ((atloc.classname == "chess_rook"))
					{
						sprint(self, "ò");
					}
					else
					{
						if ((atloc.classname == "chess_king"))
						{
							sprint(self, "ë");
						}
						else
						{
							if ((atloc.classname == "chess_queen"))
							{
								sprint(self, "ñ");
							}
						}
					}
				}
			}
		}
	}
};

void() ShowBoard =
{
	local float c_x;
	local float c_y;
	local string ctstr;

	c_x = SPAWN_CRUCIFIED;
	sprint(self, "\n+---+---+---+---+---+---+---+---+\n");
	if (!single_player)
	{
		ctstr = self.chess_team;
	}
	else
	{
		ctstr = current_turn.chess_team;
	}
	if ((ctstr == "white"))
	{
		c_y = 8;
		while ((c_y > MSG_BROADCAST))
		{
			sprint(self, "| ");
			while ((c_x < TE_LIGHTNING3))
			{
				SEAL(c_x, c_y);
				if ((c_x != 8))
				{
					sprint(self, " | ");
				}
				c_x = (c_x + SPAWN_CRUCIFIED);
			}
			sprint(self, " |\n+---+---+---+---+---+---+---+---+\n");
			c_y = (c_y - SPAWN_CRUCIFIED);
			c_x = SPAWN_CRUCIFIED;
		}
	}
	else
	{
		c_y = SPAWN_CRUCIFIED;
		c_x = 8;
		while ((c_y < TE_LIGHTNING3))
		{
			sprint(self, "| ");
			while ((c_x > MSG_BROADCAST))
			{
				SEAL(c_x, c_y);
				if ((c_x != SPAWN_CRUCIFIED))
				{
					sprint(self, " | ");
				}
				c_x = (c_x - SPAWN_CRUCIFIED);
			}
			sprint(self, " |\n+---+---+---+---+---+---+---+---+\n");
			c_y = (c_y + SPAWN_CRUCIFIED);
			c_x = 8;
		}
	}
};

void() SpawnExplosion =
{
	local entity oself;
	local entity explo;

	oself = self;
	explo = spawn();
	self = explo;
	setorigin(self, oself.origin);
	setsize(self, '0 0 0', '0 0 0');
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel(self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1();
	self = oself;
};

void() Q_Stuff =
{
	self.yaw_speed = 20;
	self.view_ofs = '0 0 25';
	self.use = monster_use;
	self.ideal_yaw = (self.angles * '0 1 0');
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setorigin(self, (self.origin + '0 0 16'));
	droptofloor();
	self.pausetime = 100000000;
	spawn_tfog(self.origin);
	self.th_stand();
	sound(self, CHAN_VOICE, "player/udeath.wav", SPAWN_CRUCIFIED, ATTN_NORM);
	if (secret_monsters)
	{
		ThrowGib("progs/h_dog.mdl", -40);
	}
	else
	{
		ThrowGib("progs/h_knight.mdl", -40);
	}
	ThrowGib("progs/gib1.mdl", -50);
	ThrowGib("progs/gib2.mdl", -60);
	ThrowGib("progs/gib3.mdl", -45);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	SpawnExplosion();
};

void() Q_Queen =
{
	bprint("** Promoted to Queen\n");
	if (!secret_monsters)
	{
		setmodel(self, "progs/shambler.mdl");
		self.health = 600;
		self.th_stand = sham_stand1;
		self.th_walk = sham_walk1;
		self.th_run = sham_run1;
		self.th_die = sham_die;
		self.th_melee = sham_melee;
		self.th_missile = sham_magic1;
		self.th_pain = sham_pain;
	}
	else
	{
		self.health = 400;
		setmodel(self, "progs/shalrath.mdl");
		self.attack_state = AS_MISSILE;
		self.th_stand = shal_stand;
		self.th_walk = shal_walk1;
		self.th_run = shal_run1;
		self.th_die = shalrath_die;
		self.th_pain = shalrath_pain;
		self.th_missile = shal_attack1;
	}
	self.classname = "chess_queen";
	self.netname = "queen";
	setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);
};

void() Q_Rook =
{
	bprint("** Promoted to Rook\n");
	self.classname = "chess_rook";
	self.netname = "rook";
	if (!secret_monsters)
	{
		setmodel(self, "progs/ogre.mdl");
		setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);
		self.health = 200;
		self.th_stand = ogre_stand1;
		self.th_walk = ogre_walk1;
		self.th_run = ogre_run1;
		self.th_die = ogre_die;
		self.th_melee = ogre_melee;
		self.th_missile = ogre_nail1;
		self.th_pain = ogre_pain;
	}
	else
	{
		setmodel(self, "progs/enforcer.mdl");
		setsize(self, VEC_HULL_MIN, '16 16 40');
		self.health = 80;
		self.th_stand = enf_stand1;
		self.th_walk = enf_walk1;
		self.th_run = enf_run1;
		self.th_pain = enf_pain;
		self.th_die = enf_die;
		self.th_missile = enf_atk1;
	}
};

void() Q_Knight =
{
	bprint("** Promoted to Knight\n");
	self.classname = "chess_knight";
	self.netname = "knight";
	if (!secret_monsters)
	{
		setmodel(self, "progs/demon.mdl");
		setsize(self, VEC_HULL2_MIN, VEC_HULL2_MAX);
		self.health = 300;
		self.th_stand = demon1_stand1;
		self.th_walk = demon1_walk1;
		self.th_run = demon1_run1;
		self.th_die = demon_die;
		self.th_melee = Demon_MeleeAttack;
		self.th_missile = demon1_jump1;
		self.th_pain = demon1_pain;
	}
	else
	{
		setmodel(self, "progs/wizard.mdl");
		setsize(self, VEC_HULL_MIN, '16 16 40');
		self.health = 80;
		self.th_stand = wiz_stand1;
		self.th_walk = wiz_walk1;
		self.th_run = wiz_run1;
		self.th_missile = Wiz_Missile;
		self.th_pain = Wiz_Pain;
		self.th_die = wiz_die;
	}
};

void() Q_Bishop =
{
	bprint("** Promoted to Bishop\n");
	self.classname = "chess_bishop";
	self.netname = "bishop";
	if (!secret_monsters)
	{
		setmodel(self, "progs/hknight.mdl");
		setsize(self, VEC_HULL_MIN, '16 16 40');
		self.health = 250;
		self.th_stand = hknight_stand1;
		self.th_walk = hknight_walk1;
		self.th_run = hknight_run1;
		self.th_melee = hknight_melee;
		self.th_missile = hknight_magicc1;
		self.th_pain = hknight_pain;
		self.th_die = hknight_die;
	}
	else
	{
		setmodel(self, "progs/soldier.mdl");
		setsize(self, VEC_HULL_MIN, '16 16 40');
		self.health = 55;
		self.th_stand = army_stand1;
		self.th_walk = army_walk1;
		self.th_run = army_run1;
		self.th_missile = army_atk;
		self.th_pain = army_pain;
		self.th_die = army_die;
	}
};

void() MakeQueen =
{
	local entity oself;

	oself = self;
	self = QueenEnt;
	if (secret_monsters)
	{
		self.attack_state = AS_MISSILE;
	}
	Queening = MSG_BROADCAST;
	if ((QueenTo == "chess_queen"))
	{
		Q_Queen();
	}
	if ((QueenTo == "chess_rook"))
	{
		Q_Rook();
	}
	if ((QueenTo == "chess_knight"))
	{
		Q_Knight();
	}
	if ((QueenTo == "chess_bishop"))
	{
		Q_Bishop();
	}
	Q_Stuff();
	self = oself;
	next_turn();
};

void() GrabMe =
{
	local entity grabber;
	local float tyaw;
	local entity exitspot;
	local vector spawnorg;
	local vector so2;

	if ((random() > 0.5))
	{
		spawnorg = '260 0 50';
		so2 = '-260 0 10';
	}
	else
	{
		spawnorg = '-260 0 50';
		so2 = '260 0 10';
	}
	spawn_fog(spawnorg);
	exitspot = spawn();
	setorigin(exitspot, so2);
	setsize(exitspot, '0 0 0', '0 0 0');
	exitspot.velocity = '0 0 0';
	exitspot.solid = SOLID_NOT;
	exitspot.movetype = MOVETYPE_NONE;
	setmodel(exitspot, "progs/null.mdl");
	exitspot.think = SUB_Remove;
	exitspot.nextthink = (time + 20);
	grabber = spawn();
	grabber.owner = exitspot;
	setorigin(grabber, spawnorg);
	setsize(grabber, VEC_HULL2_MIN, VEC_HULL2_MAX);
	tyaw = vectoyaw((GetBody.origin - grabber.origin));
	grabber.angles_y = anglemod(tyaw);
	grabber.velocity = '0 0 0';
	grabber.solid = SOLID_SLIDEBOX;
	grabber.movetype = MOVETYPE_STEP;
	setmodel(grabber, "progs/demon.mdl");
	grabber.classname = "grabber";
	grabber.touch = Grabber_JumpTouch;
	grabber.th_stand = demon1_stand1;
	grabber.th_walk = demon1_walk1;
	grabber.th_run = demon1_run1;
	grabber.th_die = demon_die;
	grabber.th_melee = Demon_MeleeAttack;
	grabber.th_missile = demon1_jump1;
	grabber.th_pain = demon1_pain;
	grabber.think = grab_jump4;
	grabber.nextthink = (time + 0.1);
};

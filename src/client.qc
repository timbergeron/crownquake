//Decompiled code. Please respect the original copyright.
void(entity attacker, float damage) player_pain;
void() player_stand1;
void(vector org, entity death_owner) spawn_tdeath;
float modelindex_eyes;
float modelindex_player;
float intermission_running;
float intermission_exittime;

void() info_intermission =
{
};

void() SetChangeParms =
{
	if ((self.health <= MSG_BROADCAST))
	{
		SetNewParms();
		return;
	}
	self.items = (self.items - (self.items & (((((IT_KEY1 | IT_KEY2) | IT_INVISIBILITY) | IT_INVULNERABILITY) | IT_SUIT) | IT_QUAD)));
	if ((self.health > 100))
	{
		self.health = 100;
	}
	if ((self.health < 50))
	{
		self.health = 50;
	}
	parm1 = self.items;
	parm2 = self.health;
	parm3 = self.armorvalue;
	if ((self.ammo_shells < 25))
	{
		parm4 = 25;
	}
	else
	{
		parm4 = self.ammo_shells;
	}
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;
	parm8 = self.weapon;
	parm9 = (self.armortype * 100);
};

void() SetNewParms =
{
	parm1 = (IT_SHOTGUN | IT_AXE);
	parm2 = 100;
	parm3 = MSG_BROADCAST;
	parm4 = 25;
	parm5 = MSG_BROADCAST;
	parm6 = MSG_BROADCAST;
	parm7 = MSG_BROADCAST;
	parm8 = 1;
	parm9 = MSG_BROADCAST;
};

void() DecodeLevelParms =
{
	if (serverflags)
	{
		if ((world.model == "maps/start.bsp"))
		{
			SetNewParms();
		}
	}
	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.weapon = parm8;
	self.armortype = (parm9 * 0.01);
};

entity() FindIntermission =
{
	local entity spot;
	local float cyc;

	spot = find(world, classname, "info_intermission");
	if (spot)
	{
		cyc = (random() * WEAPON_SPIKES);
		while ((cyc > 1))
		{
			spot = find(spot, classname, "info_intermission");
			if (!spot)
			{
				spot = find(spot, classname, "info_intermission");
			}
			cyc = (cyc - 1);
		}
		return (spot);
	}
	spot = find(world, classname, "info_player_start");
	if (spot)
	{
		return (spot);
	}
	spot = find(world, classname, "testplayerstart");
	if (spot)
	{
		return (spot);
	}
	objerror("FindIntermission: no spot");
	return (world);
};
string nextmap;

void() GotoNextMap =
{
	if (cvar("samelevel"))
	{
		changelevel(mapname);
	}
	else
	{
		changelevel(nextmap);
	}
};

void() ExitIntermission =
{
	if (deathmatch)
	{
		GotoNextMap();
		return;
	}
	intermission_exittime = (time + 1);
	intermission_running = (intermission_running + 1);
	if ((intermission_running == WEAPON_ROCKET))
	{
		if ((world.model == "maps/e1m7.bsp"))
		{
			WriteByte(MSG_ALL, SVC_CDTRACK);
			WriteByte(MSG_ALL, WEAPON_ROCKET);
			WriteByte(MSG_ALL, AS_MELEE);
			if (!cvar("registered"))
			{
				WriteByte(MSG_ALL, SVC_FINALE);
				WriteString(MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task in the other three\nhaunted lands of Quake. Or are you? If\nyou don't register Quake, you'll never\nknow what awaits you in the Realm of\nBlack Magic, the Netherworld, and the\nElder World!");
			}
			else
			{
				WriteByte(MSG_ALL, SVC_FINALE);
				WriteString(MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!");
			}
			return;
		}
		else
		{
			if ((world.model == "maps/e2m6.bsp"))
			{
				WriteByte(MSG_ALL, SVC_CDTRACK);
				WriteByte(MSG_ALL, WEAPON_ROCKET);
				WriteByte(MSG_ALL, AS_MELEE);
				WriteByte(MSG_ALL, SVC_FINALE);
				WriteString(MSG_ALL, "The Rune of Black Magic throbs evilly in\nyour hand and whispers dark thoughts\ninto your brain. You learn the inmost\nlore of the Hell-Mother; Shub-Niggurath!\nYou now know that she is behind all the\nterrible plotting which has led to so\nmuch death and horror. But she is not\ninviolate! Armed with this Rune, you\nrealize that once all four Runes are\ncombined, the gate to Shub-Niggurath's\nPit will open, and you can face the\nWitch-Goddess herself in her frightful\notherworld cathedral.");
				return;
			}
			else
			{
				if ((world.model == "maps/e3m6.bsp"))
				{
					WriteByte(MSG_ALL, SVC_CDTRACK);
					WriteByte(MSG_ALL, WEAPON_ROCKET);
					WriteByte(MSG_ALL, AS_MELEE);
					WriteByte(MSG_ALL, SVC_FINALE);
					WriteString(MSG_ALL, "The charred viscera of diabolic horrors\nbubble viscously as you seize the Rune\nof Hell Magic. Its heat scorches your\nhand, and its terrible secrets blight\nyour mind. Gathering the shreds of your\ncourage, you shake the devil's shackles\nfrom your soul, and become ever more\nhard and determined to destroy the\nhideous creatures whose mere existence\nthreatens the souls and psyches of all\nthe population of Earth.");
					return;
				}
				else
				{
					if ((world.model == "maps/e4m7.bsp"))
					{
						WriteByte(MSG_ALL, SVC_CDTRACK);
						WriteByte(MSG_ALL, WEAPON_ROCKET);
						WriteByte(MSG_ALL, AS_MELEE);
						WriteByte(MSG_ALL, SVC_FINALE);
						WriteString(MSG_ALL, "Despite the awful might of the Elder\nWorld, you have achieved the Rune of\nElder Magic, capstone of all types of\narcane wisdom. Beyond good and evil,\nbeyond life and death, the Rune\npulsates, heavy with import. Patient and\npotent, the Elder Being Shub-Niggurath\nweaves her dire plans to clear off all\nlife from the Earth, and bring her own\nfoul offspring to our world! For all the\ndwellers in these nightmare dimensions\nare her descendants! Once all Runes of\nmagic power are united, the energy\nbehind them will blast open the Gateway\nto Shub-Niggurath, and you can travel\nthere to foil the Hell-Mother's plots\nin person.");
						return;
					}
				}
			}
		}
		GotoNextMap();
	}
	if ((intermission_running == AS_MELEE))
	{
		if (!cvar("registered"))
		{
			WriteByte(MSG_ALL, SVC_SELLSCREEN);
			return;
		}
		if (((serverflags & 15) == 15))
		{
			WriteByte(MSG_ALL, SVC_FINALE);
			WriteString(MSG_ALL, "Now, you have all four Runes. You sense\ntremendous invisible forces moving to\nunseal ancient barriers. Shub-Niggurath\nhad hoped to use the Runes Herself to\nclear off the Earth, but now instead,\nyou will use them to enter her home and\nconfront her as an avatar of avenging\nEarth-life. If you defeat her, you will\nbe remembered forever as the savior of\nthe planet. If she conquers, it will be\nas if you had never been born.");
			return;
		}
	}
	GotoNextMap();
};

void() IntermissionThink =
{
	if ((time < intermission_exittime))
	{
		return;
	}
	if (((!self.button0 && !self.button1) && !self.button2))
	{
		return;
	}
	ExitIntermission();
};

void() execute_changelevel =
{
	local entity pos;

	intermission_running = 1;
	if (deathmatch)
	{
		intermission_exittime = (time + TE_LIGHTNING1);
	}
	else
	{
		intermission_exittime = (time + WEAPON_ROCKET);
	}
	WriteByte(MSG_ALL, SVC_CDTRACK);
	WriteByte(MSG_ALL, AS_MELEE);
	WriteByte(MSG_ALL, AS_MELEE);
	pos = FindIntermission();
	other = find(world, classname, "player");
	while ((other != world))
	{
		other.view_ofs = '0 0 0';
		other.v_angle = pos.mangle;
		other.angles = pos.mangle;
		other.fixangle = TRUE;
		other.nextthink = (time + 0.5);
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = MSG_BROADCAST;
		setorigin(other, pos.origin);
		other = find(other, classname, "player");
	}
	WriteByte(MSG_ALL, SVC_INTERMISSION);
};

void() changelevel_touch =
{
	local entity pos;

	if ((other.classname != "player"))
	{
		return;
	}
	if (cvar("noexit"))
	{
		T_Damage(other, self, self, 50000);
		return;
	}
	bprint(other.netname);
	bprint(" exited the level\n");
	nextmap = self.map;
	SUB_UseTargets();
	if (((self.spawnflags & 1) && (deathmatch == MSG_BROADCAST)))
	{
		GotoNextMap();
		return;
	}
	self.touch = SUB_Null;
	self.think = execute_changelevel;
	self.nextthink = (time + 0.1);
};

void() trigger_changelevel =
{
	if (!self.map)
	{
		objerror("chagnelevel trigger doesn't have map");
	}
	InitTrigger();
	self.touch = changelevel_touch;
};
void() set_suicide_frame;

void() respawn =
{
	if (coop)
	{
		CopyToBodyQue(self);
		setspawnparms(self);
		PutClientInServer();
	}
	else
	{
		if (deathmatch)
		{
			CopyToBodyQue(self);
			SetNewParms();
			PutClientInServer();
		}
		else
		{
			localcmd("restart\n");
		}
	}
};

void() ClientKill =
{
	bprint(self.netname);
	bprint(" suicides\n");
	set_suicide_frame();
	self.modelindex = modelindex_player;
	self.frags = (self.frags - WEAPON_ROCKET);
	respawn();
};

float(vector v) CheckSpawnPoint =
{
	return (FALSE);
};

entity() SelectSpawnPoint =
{
	local entity spot;

	spot = find(world, classname, "info_player_start");
	if ((spot == world))
	{
		spot = spawn();
		spot.solid = SOLID_NOT;
		setmodel(spot, "progs/null.mdl");
		spot.movetype = MOVETYPE_NONE;
		spot.velocity = '0 0 0';
		spot.nextthink = (time + 9999999);
		spot.think = SUB_Remove;
		setorigin(spot, player1.origin);
		setsize(spot, '0 0 0', '0 0 0');
		bprint("** ");
		bprint(self.netname);
		bprint(" is an observer\n");
		self.spectator = TRUE;
	}
	return (spot);
};
void() PlayerDie;

float() PregameFlyActive =
{
	return (menu_startup_pending || (((current_turn == world) && (player2 == world)) && (message_entity != world)));
};

void() PutClientInServer =
{
	local entity spot;
	local entity etemp;
	local string str;

	self.classname = "player";
	self.health = 100;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_FLY;
	self.show_hostile = MSG_BROADCAST;
	self.max_health = 100;
	self.flags = (((FL_CLIENT | FL_SWIM) | FL_FLY) | FL_GODMODE);
	self.air_finished = (time + 12);
	self.dmg = WEAPON_ROCKET;
	self.super_damage_finished = MSG_BROADCAST;
	self.radsuit_finished = MSG_BROADCAST;
	self.invisible_finished = MSG_BROADCAST;
	self.invincible_finished = MSG_BROADCAST;
	self.effects = MSG_BROADCAST;
	self.invincible_time = MSG_BROADCAST;
	DecodeLevelParms();
	W_SetCurrentAmmo();
	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	self.deadflag = DEAD_NO;
	self.pausetime = MSG_BROADCAST;
	spot = SelectSpawnPoint();
	self.origin = (spot.origin + '0 0 1');
	self.angles = spot.angles;
	self.fixangle = TRUE;
	setsize(self, '0 0 0', '0 0 0');
	self.view_ofs = '0 0 2';
	player_stand1();
	if ((deathmatch || coop))
	{
		makevectors(self.angles);
		spawn_tfog((self.origin + (v_forward * 20)));
	}
	if ((dest_ent == world))
	{
		dest_ent = spawn();
		setsize(dest_ent, '0 0 0', '0 0 0');
	}
	if ((light_ent == world))
	{
		light_ent = spawn();
		light_ent.classname = "chess_light";
		light_ent.owner = self;
		setsize(light_ent, '0 0 0', '0 0 0');
		setmodel(light_ent, "progs/null.mdl");
		setorigin(light_ent, self.origin);
	}
	self.currentammo = MSG_BROADCAST;
	if (!self.spectator)
	{
		LaserTargeterToggle(self);
	}
	single_player = (cvar("teamplay") == MSG_BROADCAST);
	if (((current_turn == world) && !self.spectator))
	{
		game_checkers = (cvar("checkers") != MSG_BROADCAST);
	}
	if (!self.spectator)
	{
		setmodel(self, "progs/headcam.mdl");
	}
	else
	{
		setmodel(self, "progs/eyes.mdl");
	}
	modelindex_eyes = self.modelindex;
	self.skin = 1;
	modelindex_player = self.modelindex;
	if (!self.spectator)
	{
		if ((single_player == 1))
		{
			player1 = spot;
			player1.netname = "Black";
			spot.owner = self;
			spot.v_angle = spot.angles;
			AllocateMonsters(spot);
			spot.view_ofs = '0 0 22';
			setmodel(spot, "progs/headcam.mdl");
			spot.skin = 1;
			spot = find(spot, classname, "info_player_start");
			if ((spot == world))
			{
				dprint("Only one info_player_start found\n");
				localcmd("disconnect\n");
				return;
			}
			player2 = spot;
			player2.netname = "White";
			spot.owner = self;
			spot.v_angle = spot.angles;
			player1.opponent = player2;
			player2.opponent = player1;
			AllocateMonsters(spot);
			spot.view_ofs = '0 0 22';
			setmodel(spot, "progs/headcam.mdl");
			spot.skin = 1;
			time_per_turn = cvar("timelimit");
			current_turn = player2;
			self.origin = (spot.origin + '0 0 1');
			self.angles = spot.angles;
			self.fixangle = TRUE;
			current_turn.turn_starttime = time;
			current_selected = world;
			action_flag = TRUE;
			if (Menu_ResumeRestartSelection())
			{
			}
			else if (((floor(cvar("bot")) == 1) || (floor(cvar("bot")) == 2)))
			{
				menu_startup_shown = TRUE;
				Menu_StartNewGame(game_checkers);
			}
			else
			{
				Menu_OpenStartupModeSelect();
			}
		}
		else
		{
			if (TwoPlayersInGame())
			{
				player2 = self;
				time_per_turn = cvar("timelimit");
				self.team = WEAPON_ROCKET;
				self.chess_team = spot.chess_team;
				remove(spot);
				AllocateMonsters(self);
				if ((single_player == MSG_BROADCAST))
				{
					if ((message_entity != world))
					{
						message_entity.nextthink = MSG_BROADCAST;
					}
					self.opponent = player1;
					player1.opponent = self;
				}
				else
				{
					current_turn = self;
					self.opponent = self;
				}
				if (((single_player == MSG_BROADCAST) && !menu_startup_pending))
				{
					Menu_RestoreGameBindsAll();
					if ((random() < 0.5))
					{
						current_turn = self;
					}
					else
					{
						current_turn = self.opponent;
					}
					current_turn.turn_starttime = time;
					current_selected = world;
					mycentreprint(current_turn, "Your turn");
					mystuffcmd(current_turn, "bf\n");
					if ((random() < 0.5))
					{
						mystuffcmd(current_turn, "play buttons/switch02.wav\n");
					}
					else
					{
						mystuffcmd(current_turn, "play buttons/switch04.wav\n");
					}
				}
				if (menu_startup_pending)
				{
					action_flag = TRUE;
					Menu_EnablePregameFlyBinds(self);
				}
				else
				{
					action_flag = MSG_BROADCAST;
				}
			}
			else
			{
				player1 = self;
				self.team = 1;
				self.chess_team = spot.chess_team;
				remove(spot);
				AllocateMonsters(self);
				action_flag = TRUE;
				if (!Menu_ResumeRestartSelection())
				{
					Menu_OpenStartupModeSelect();
				}
			}
		}
	}
	etemp = spawn();
	etemp.think = welcome_mesg;
	etemp.nextthink = (time + 1);
	etemp.owner = self;
};

void() info_player_start =
{
};

void() info_player_start2 =
{
};

void() testplayerstart =
{
};

void() info_player_deathmatch =
{
};

void() info_player_coop =
{
};

void() NextLevel =
{
	local entity o;

	if ((mapname == "start"))
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else
		{
			if (!(serverflags & 1))
			{
				mapname = "e1m1";
				serverflags = (serverflags + 1);
			}
			else
			{
				if (!(serverflags & WEAPON_ROCKET))
				{
					mapname = "e2m1";
					serverflags = (serverflags + WEAPON_ROCKET);
				}
				else
				{
					if (!(serverflags & WEAPON_SPIKES))
					{
						mapname = "e3m1";
						serverflags = (serverflags + WEAPON_SPIKES);
					}
					else
					{
						if (!(serverflags & WEAPON_BIG))
						{
							mapname = "e4m1";
							serverflags = (serverflags + WEAPON_BIG);
						}
						else
						{
							mapname = "start";
							serverflags = (serverflags - 15);
						}
					}
				}
			}
		}
		o = spawn();
		o.map = mapname;
	}
	else
	{
		o = find(world, classname, "trigger_changelevel");
		if (!o)
		{
			mapname = "start";
			o = spawn();
			o.map = mapname;
		}
	}
	nextmap = o.map;
	gameover = TRUE;
	if ((o.nextthink < time))
	{
		o.think = execute_changelevel;
		o.nextthink = (time + 0.1);
	}
};

void() CheckRules =
{
	local float timelimit;
	local float fraglimit;

	if (gameover)
	{
		return;
	}
	timelimit = (cvar("timelimit") * 60);
	fraglimit = cvar("fraglimit");
	if ((timelimit && (time >= timelimit)))
	{
		NextLevel();
		return;
	}
	if ((fraglimit && (self.frags >= fraglimit)))
	{
		NextLevel();
		return;
	}
};

void() PlayerDeathThink =
{
	local entity old_self;
	local float forward;

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen(self.velocity);
		forward = (forward - 20);
		if ((forward <= MSG_BROADCAST))
		{
			self.velocity = '0 0 0';
		}
		else
		{
			self.velocity = (forward * normalize(self.velocity));
		}
	}
	if ((self.deadflag == DEAD_DEAD))
	{
		if (((self.button2 || self.button1) || self.button0))
		{
			return;
		}
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}
	if (((!self.button2 && !self.button1) && !self.button0))
	{
		return;
	}
	self.button0 = MSG_BROADCAST;
	self.button1 = MSG_BROADCAST;
	self.button2 = MSG_BROADCAST;
	respawn();
};

void() PlayerJump =
{
	local vector start;
	local vector end;

	if ((self.flags & FL_WATERJUMP))
	{
		return;
	}
	if ((self.waterlevel >= WEAPON_ROCKET))
	{
		if ((self.watertype == CONTENT_WATER))
		{
			self.velocity_z = 100;
		}
		else
		{
			if ((self.watertype == CONTENT_SLIME))
			{
				self.velocity_z = 80;
			}
			else
			{
				self.velocity_z = 50;
			}
		}
		if ((self.swim_flag < time))
		{
			self.swim_flag = (time + 1);
			if ((random() < 0.5))
			{
				sound(self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			}
			else
			{
				sound(self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
			}
		}
		return;
	}
	if (!(self.flags & FL_ONGROUND))
	{
		return;
	}
	if (!(self.flags & FL_JUMPRELEASED))
	{
		return;
	}
	self.flags = (self.flags - (self.flags & FL_JUMPRELEASED));
	self.flags = (self.flags - FL_ONGROUND);
	self.button2 = MSG_BROADCAST;
	sound(self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
	self.velocity_z = (self.velocity_z + 270);
};
.float dmgtime;

void() WaterMove =
{
	if ((self.movetype == MOVETYPE_NOCLIP))
	{
		return;
	}
	if ((self.health < MSG_BROADCAST))
	{
		return;
	}
	if ((self.waterlevel != AS_MELEE))
	{
		if ((self.air_finished < time))
		{
			sound(self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		}
		else
		{
			if ((self.air_finished < (time + TE_LIGHTNING3)))
			{
				sound(self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
			}
		}
		self.air_finished = (time + 12);
		self.dmg = WEAPON_ROCKET;
	}
	else
	{
		if ((self.air_finished < time))
		{
			if ((self.pain_finished < time))
			{
				self.dmg = (self.dmg + WEAPON_ROCKET);
				if ((self.dmg > 15))
				{
					self.dmg = 10;
				}
				T_Damage(self, world, world, self.dmg);
				self.pain_finished = (time + 1);
			}
		}
	}
	if (!self.waterlevel)
	{
		if ((self.flags & FL_INWATER))
		{
			sound(self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = (self.flags - FL_INWATER);
		}
		return;
	}
	if ((self.watertype == CONTENT_LAVA))
	{
		if ((self.dmgtime < time))
		{
			if ((self.radsuit_finished > time))
			{
				self.dmgtime = (time + 1);
			}
			else
			{
				self.dmgtime = (time + 0.2);
			}
			T_Damage(self, world, world, (10 * self.waterlevel));
		}
	}
	else
	{
		if ((self.watertype == CONTENT_SLIME))
		{
			if (((self.dmgtime < time) && (self.radsuit_finished < time)))
			{
				self.dmgtime = (time + 1);
				T_Damage(self, world, world, (WEAPON_SPIKES * self.waterlevel));
			}
		}
	}
	if (!(self.flags & FL_INWATER))
	{
		if ((self.watertype == CONTENT_LAVA))
		{
			sound(self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		}
		if ((self.watertype == CONTENT_WATER))
		{
			sound(self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		}
		if ((self.watertype == CONTENT_SLIME))
		{
			sound(self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);
		}
		self.flags = (self.flags + FL_INWATER);
		self.dmgtime = MSG_BROADCAST;
	}
	if (!(self.flags & FL_WATERJUMP))
	{
		self.velocity = (self.velocity - (((0.8 * self.waterlevel) * frametime) * self.velocity));
	}
};

void() CheckWaterJump =
{
	local vector start;
	local vector end;

	makevectors(self.angles);
	start = self.origin;
	start_z = (start_z + WEAPON_BIG);
	v_forward_z = MSG_BROADCAST;
	normalize(v_forward);
	end = (start + (v_forward * 24));
	traceline(start, end, TRUE, self);
	if ((trace_fraction < 1))
	{
		start_z = ((start_z + self.maxs_z) - WEAPON_BIG);
		end = (start + (v_forward * 24));
		self.movedir = (trace_plane_normal * -50);
		traceline(start, end, TRUE, self);
		if ((trace_fraction == 1))
		{
			self.flags = (self.flags | FL_WATERJUMP);
			self.velocity_z = 225;
			self.flags = (self.flags - (self.flags & FL_JUMPRELEASED));
			self.teleport_time = (time + WEAPON_ROCKET);
			return;
		}
	}
};

void() PlayerPreThink =
{
	local float mspeed;
	local float aspeed;
	local float r;
	local float old_vel_speed;
	local float diff;
	local float ftemp;
	local float old_loc;
	local float pregame_fly;
	local vector vdiff;
	local float fly_speed;

	if (intermission_running)
	{
		IntermissionThink();
		return;
	}
	if ((self.view_ofs == '0 0 0'))
	{
		return;
	}
	if ((self.last_color != self.colormap))
	{
		UpdateMonsterColors(self);
	}
	makevectors(self.v_angle);
	CheckRules();
	if ((self.deadflag >= DEAD_DEAD))
	{
		PlayerDeathThink();
		return;
	}
	if ((self.deadflag == DEAD_DYING))
	{
		return;
	}
	pregame_fly = PregameFlyActive();
	if (pregame_fly)
	{
		self.movetype = MOVETYPE_NOCLIP;
		self.finaldest_y = MOVETYPE_NOCLIP;
		self.solid = SOLID_NOT;
		self.flags = (self.flags | FL_FLY);
		self.flags = (self.flags | FL_GODMODE);
		self.flags = (self.flags | FL_SWIM);
		self.flags = (self.flags | FL_ONGROUND);
		self.waterlevel = MSG_BROADCAST;
	}
	else if (((self.movetype == MOVETYPE_NOCLIP) && !self.spectator))
	{
		self.movetype = MOVETYPE_FLY;
		self.finaldest_y = MOVETYPE_FLY;
	}
	if ((self.flags & FL_FLY))
	{
		if ((self.flags & FL_ONGROUND))
		{
			self.flags = (self.flags - FL_ONGROUND);
		}
		makevectors(self.v_angle);
		self.velocity = ((v_forward * self.movement_x) + (v_right * self.movement_y));
		self.velocity_z = (self.velocity_z + self.movement_z);
		if (self.button2)
		{
			self.velocity_z = (self.velocity_z + 200);
		}
		fly_speed = vlen(self.velocity);
		if ((fly_speed > 2000))
		{
			self.velocity = (normalize(self.velocity) * 2000);
		}
	}
	self.oldorigin = self.origin;
	self.last_vel = self.velocity;
	if (pregame_fly)
	{
		return;
	}
	if ((((((current_turn != world) && ((current_turn == self) || single_player)) && !current_turn.is_bot) && !action_flag) && !self.menu_screen))
	{
		if ((((time_per_turn > 25) && (current_turn.turn_starttime < ((time - time_per_turn) + 15))) && !(current_turn.chess_flags & CF_TIME_NOTIFY)))
		{
			mycentreprint(self, "You have 15 seconds to move");
			current_turn.chess_flags = (current_turn.chess_flags | CF_TIME_NOTIFY);
		}
		else
		{
			if (((time_per_turn > MSG_BROADCAST) && (current_turn.turn_starttime < (time - time_per_turn))))
			{
				sprint(self, "Time Expired: you have forfeited your turn\n");
				next_turn();
			}
			else
			{
				if (!(current_turn.chess_flags & CF_SELECTED_PIECE))
				{
					FindSelection();
				}
				else
				{
					old_loc = current_dest_int;
					FindLocation();
					if ((old_loc != current_dest_int))
					{
						if ((last_highlight != world))
						{
							setorigin(last_highlight, last_highlight.pos2);
							last_highlight.pos2 = last_highlight.pos1;
							last_highlight.pos1 = last_highlight.origin;
							last_highlight = world;
						}
						if (CanMove(current_selected, current_dest_int, FALSE))
						{
							HighlightLocation(current_dest_int);
						}
					}
				}
			}
		}
	}
};

void() CheckPowerups =
{
	if ((self.health <= MSG_BROADCAST))
	{
		return;
	}
	if (self.invisible_finished)
	{
		if ((self.invisible_sound < time))
		{
			sound(self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = (time + ((random() * AS_MELEE) + 1));
		}
		if ((self.invisible_finished < (time + AS_MELEE)))
		{
			if ((self.invisible_time == 1))
			{
				sprint(self, "Ring of Shadows magic is fading\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = (time + 1);
			}
			if ((self.invisible_time < time))
			{
				self.invisible_time = (time + 1);
				stuffcmd(self, "bf\n");
			}
		}
		if ((self.invisible_finished < time))
		{
			self.items = (self.items - IT_INVISIBILITY);
			self.invisible_finished = MSG_BROADCAST;
			self.invisible_time = MSG_BROADCAST;
		}
		self.frame = MSG_BROADCAST;
		self.modelindex = modelindex_eyes;
	}
	else
	{
		self.modelindex = modelindex_player;
	}
	if (self.invincible_finished)
	{
		if ((self.invincible_finished < (time + AS_MELEE)))
		{
			if ((self.invincible_time == 1))
			{
				sprint(self, "Protection is almost burned out\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = (time + 1);
			}
			if ((self.invincible_time < time))
			{
				self.invincible_time = (time + 1);
				stuffcmd(self, "bf\n");
			}
		}
		if ((self.invincible_finished < time))
		{
			self.items = (self.items - IT_INVULNERABILITY);
			self.invincible_time = MSG_BROADCAST;
			self.invincible_finished = MSG_BROADCAST;
		}
		if ((self.invincible_finished > time))
		{
			self.effects = (self.effects | EF_DIMLIGHT);
		}
		else
		{
			self.effects = (self.effects - (self.effects & EF_DIMLIGHT));
		}
	}
	if (self.super_damage_finished)
	{
		if ((self.super_damage_finished < (time + AS_MELEE)))
		{
			if ((self.super_time == 1))
			{
				sprint(self, "Quad Damage is wearing off\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = (time + 1);
			}
			if ((self.super_time < time))
			{
				self.super_time = (time + 1);
				stuffcmd(self, "bf\n");
			}
		}
		if ((self.super_damage_finished < time))
		{
			self.items = (self.items - IT_QUAD);
			self.super_damage_finished = MSG_BROADCAST;
			self.super_time = MSG_BROADCAST;
		}
		if ((self.super_damage_finished > time))
		{
			self.effects = (self.effects | EF_DIMLIGHT);
		}
		else
		{
			self.effects = (self.effects - (self.effects & EF_DIMLIGHT));
		}
	}
	if (self.radsuit_finished)
	{
		self.air_finished = (time + 12);
		if ((self.radsuit_finished < (time + AS_MELEE)))
		{
			if ((self.rad_time == 1))
			{
				sprint(self, "Air supply in Biosuit expiring\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = (time + 1);
			}
			if ((self.rad_time < time))
			{
				self.rad_time = (time + 1);
				stuffcmd(self, "bf\n");
			}
		}
		if ((self.radsuit_finished < time))
		{
			self.items = (self.items - IT_SUIT);
			self.rad_time = MSG_BROADCAST;
			self.radsuit_finished = MSG_BROADCAST;
		}
	}
};

void() PlayerPostThink =
{
	local float mspeed;
	local float aspeed;
	local float r;

	if ((self.view_ofs == '0 0 0'))
	{
		return;
	}
	if (self.deadflag)
	{
		return;
	}
	if (PregameFlyActive())
	{
		setorigin(self, (self.origin + (self.last_vel * frametime)));
	}
	else if ((self.flags & FL_FLY))
	{
		traceline(self.origin, (self.origin + (self.last_vel * frametime)), TRUE, world);
		if ((trace_fraction == 1))
		{
			setorigin(self, trace_endpos);
		}
		else
		{
			trace_endpos = (self.origin + (self.last_vel * frametime));
			traceline((trace_endpos + (trace_plane_normal * CF_CHECK_NOTIFY)), trace_endpos, TRUE, world);
			trace_endpos = (trace_endpos + (trace_plane_normal * 1));
			setorigin(self, trace_endpos);
		}
	}
	if ((self.origin_z < MSG_BROADCAST))
	{
		self.origin_z = MSG_BROADCAST;
	}
	if ((single_player && (current_turn != world)))
	{
		setorigin(current_turn, self.origin);
		current_turn.angles = self.v_angle;
		current_turn.angles_x = (CONTENT_EMPTY * current_turn.angles_x);
	}
	W_WeaponFrame();
	if (!(self.flags & FL_ONGROUND))
	{
		self.jump_flag = self.velocity_z;
	}
	CheckPowerups();
};

void() ClientConnect =
{
	bprint("** ");
	bprint(self.netname);
	bprint(" entered the game\n");
	if (intermission_running)
	{
		ExitIntermission();
	}
};

void() ClientDisconnect =
{
	ChessPerftCancel();
	CheckersCancelBotSearch();
	ChessCancelBotSearch();
	if (gameover)
	{
		return;
	}
	bprint(self.netname);
	bprint(" left the game with ");
	bprint(ftos(self.frags));
	bprint(" frags\n");
	sound(self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
	set_suicide_frame();
};

void(entity targ, entity attacker) ClientObituary =
{
	local float rnum;
	local string deathstring;
	local string deathstring2;

	rnum = random();
	if ((targ.classname == "player"))
	{
		if ((attacker.classname == "teledeath"))
		{
			bprint(targ.netname);
			bprint(" was telefragged by ");
			bprint(attacker.owner.netname);
			bprint("\n");
			attacker.owner.frags = (attacker.owner.frags + 1);
			return;
		}
		if ((attacker.classname == "teledeath2"))
		{
			bprint("Satan's power deflects ");
			bprint(targ.netname);
			bprint("'s telefrag\n");
			targ.frags = (targ.frags - 1);
			return;
		}
		if ((attacker.classname == "player"))
		{
			if ((targ == attacker))
			{
				attacker.frags = (attacker.frags - 1);
				bprint(targ.netname);
				if (((targ.weapon == IT_LIGHTNING) && (targ.waterlevel > 1)))
				{
					bprint(" discharges into the water.\n");
					return;
				}
				if ((targ.weapon == IT_GRENADE_LAUNCHER))
				{
					bprint(" tries to put the pin back in\n");
				}
				else
				{
					bprint(" becomes bored with life\n");
				}
				return;
			}
			else
			{
				if ((((teamplay == WEAPON_ROCKET) && (targ.team > MSG_BROADCAST)) && (targ.team == attacker.team)))
				{
					if ((rnum < 0.25))
					{
						deathstring = " mows down a teammate\n";
					}
					else
					{
						if ((rnum < 0.5))
						{
							deathstring = " checks his glasses\n";
						}
						else
						{
							if ((rnum < 0.75))
							{
								deathstring = " gets a frag for the other team\n";
							}
							else
							{
								deathstring = " loses another friend\n";
							}
						}
					}
					bprint(attacker.netname);
					bprint(deathstring);
					attacker.frags = (attacker.frags - 1);
					return;
				}
				else
				{
					attacker.frags = (attacker.frags + 1);
					rnum = attacker.weapon;
					if ((rnum == IT_AXE))
					{
						deathstring = " was ax-murdered by ";
						deathstring2 = "\n";
					}
					if ((rnum == IT_SHOTGUN))
					{
						deathstring = " chewed on ";
						deathstring2 = "'s boomstick\n";
					}
					if ((rnum == IT_SUPER_SHOTGUN))
					{
						deathstring = " ate 2 loads of ";
						deathstring2 = "'s buckshot\n";
					}
					if ((rnum == IT_NAILGUN))
					{
						deathstring = " was nailed by ";
						deathstring2 = "\n";
					}
					if ((rnum == IT_SUPER_NAILGUN))
					{
						deathstring = " was punctured by ";
						deathstring2 = "\n";
					}
					if ((rnum == IT_GRENADE_LAUNCHER))
					{
						deathstring = " eats ";
						deathstring2 = "'s pineapple\n";
						if ((targ.health < -40))
						{
							deathstring = " was gibbed by ";
							deathstring2 = "'s grenade\n";
						}
					}
					if ((rnum == IT_ROCKET_LAUNCHER))
					{
						deathstring = " rides ";
						deathstring2 = "'s rocket\n";
						if ((targ.health < -40))
						{
							deathstring = " was gibbed by ";
							deathstring2 = "'s rocket\n";
						}
					}
					if ((rnum == IT_LIGHTNING))
					{
						deathstring = " accepts ";
						if ((attacker.waterlevel > 1))
						{
							deathstring2 = "'s discharge\n";
						}
						else
						{
							deathstring2 = "'s shaft\n";
						}
					}
					bprint(targ.netname);
					bprint(deathstring);
					bprint(attacker.netname);
					bprint(deathstring2);
				}
			}
			return;
		}
		else
		{
			targ.frags = (targ.frags - 1);
			bprint(targ.netname);
			if ((attacker.flags & FL_MONSTER))
			{
				if ((attacker.classname == "monster_army"))
				{
					bprint(" was shot by a Grunt\n");
				}
				if ((attacker.classname == "monster_demon1"))
				{
					bprint(" was eviscerated by a Fiend\n");
				}
				if ((attacker.classname == "monster_dog"))
				{
					bprint(" was mauled by a Rottweiler\n");
				}
				if ((attacker.classname == "monster_dragon"))
				{
					bprint(" was fried by a Dragon\n");
				}
				if ((attacker.classname == "monster_enforcer"))
				{
					bprint(" was blasted by an Enforcer\n");
				}
				if ((attacker.classname == "monster_fish"))
				{
					bprint(" was fed to the Rotfish\n");
				}
				if ((attacker.classname == "monster_hell_knight"))
				{
					bprint(" was slain by a Death Knight\n");
				}
				if ((attacker.classname == "monster_knight"))
				{
					bprint(" was slashed by a Knight\n");
				}
				if ((attacker.classname == "monster_ogre"))
				{
					bprint(" was destroyed by an Ogre\n");
				}
				if ((attacker.classname == "monster_oldone"))
				{
					bprint(" became one with Shub-Niggurath\n");
				}
				if ((attacker.classname == "monster_shalrath"))
				{
					bprint(" was exploded by a Vore\n");
				}
				if ((attacker.classname == "monster_shambler"))
				{
					bprint(" was smashed by a Shambler\n");
				}
				if ((attacker.classname == "monster_tarbaby"))
				{
					bprint(" was slimed by a Spawn\n");
				}
				if ((attacker.classname == "monster_vomit"))
				{
					bprint(" was vomited on by a Vomitus\n");
				}
				if ((attacker.classname == "monster_wizard"))
				{
					bprint(" was scragged by a Scrag\n");
				}
				if ((attacker.classname == "monster_zombie"))
				{
					bprint(" joins the Zombies\n");
				}
				return;
			}
			if ((attacker.classname == "explo_box"))
			{
				bprint(" blew up\n");
				return;
			}
			if (((attacker.solid == SOLID_BSP) && (attacker != world)))
			{
				bprint(" was squished\n");
				return;
			}
			if (((attacker.classname == "trap_shooter") || (attacker.classname == "trap_spikeshooter")))
			{
				bprint(" was spiked\n");
				return;
			}
			if ((attacker.classname == "fireball"))
			{
				bprint(" ate a lavaball\n");
				return;
			}
			if ((attacker.classname == "trigger_changelevel"))
			{
				bprint(" tried to leave\n");
				return;
			}
			rnum = targ.watertype;
			if ((rnum == CONTENT_WATER))
			{
				if ((random() < 0.5))
				{
					bprint(" sleeps with the fishes\n");
				}
				else
				{
					bprint(" sucks it down\n");
				}
				return;
			}
			else
			{
				if ((rnum == CONTENT_SLIME))
				{
					if ((random() < 0.5))
					{
						bprint(" gulped a load of slime\n");
					}
					else
					{
						bprint(" can't exist on slime alone\n");
					}
					return;
				}
				else
				{
					if ((rnum == CONTENT_LAVA))
					{
						if ((targ.health < -15))
						{
							bprint(" burst into flames\n");
							return;
						}
						if ((random() < 0.5))
						{
							bprint(" turned into hot slag\n");
						}
						else
						{
							bprint(" visits the Volcano God\n");
						}
						return;
					}
				}
			}
			if ((targ.deathtype == "falling"))
			{
				targ.deathtype = "";
				bprint(" fell to his death\n");
				return;
			}
			bprint(" died\n");
		}
	}
};

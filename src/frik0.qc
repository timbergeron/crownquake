//Decompiled code. Please respect the original copyright.
void() movetarget_f;
void() t_movetarget;
void() knight_walk1;
void() knight_bow6;
void() knight_bow1;
void() knight_jig1;
void() dog_jig1;
void() ai_turn;
void() grab_walk1;

void(vector org) spawn_fog =
{
	local entity s;

	s = spawn();
	s.origin = org;
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_TELEPORT);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
};
float current_yaw;
entity sight_entity;
float sight_entity_time;

float(float v) anglemod =
{
	while ((v >= 360))
	{
		v = (v - 360);
	}
	while ((v < MSG_BROADCAST))
	{
		v = (v + 360);
	}
	return (v);
};

void() movetarget_f =
{
	if (!self.targetname)
	{
		objerror("monster_movetarget: no targetname");
	}
	self.solid = SOLID_TRIGGER;
	self.touch = t_movetarget;
	setsize(self, '-8 -8 -8', '8 8 8');
};

void() path_corner =
{
	movetarget_f();
};

void() t_movetarget =
{
	local entity temp;

	if ((other.movetarget != self))
	{
		return;
	}
	if (other.enemy)
	{
		return;
	}
	temp = self;
	self = other;
	other = temp;
	if ((self.classname == "monster_ogre"))
	{
		sound(self, CHAN_VOICE, "ogre/ogdrag.wav", LASERTARG_ON, ATTN_IDLE);
	}
	self.movetarget = find(world, targetname, other.target);
	self.goalentity = find(world, targetname, other.target);
	self.ideal_yaw = vectoyaw((self.goalentity.origin - self.origin));
	if (!self.movetarget)
	{
		self.pausetime = (time + 999999);
		self.th_stand();
		return;
	}
};

float(entity targ) range =
{
	local vector spot1;
	local vector spot2;
	local float r;

	spot1 = (self.origin + self.view_ofs);
	spot2 = (targ.origin + targ.view_ofs);
	r = vlen((spot1 - spot2));
	if ((r < 120))
	{
		return (RANGE_MELEE);
	}
	if ((r < 500))
	{
		return (RANGE_NEAR);
	}
	if ((r < 1000))
	{
		return (RANGE_MID);
	}
	return (RANGE_FAR);
};

float(entity targ) visible =
{
	local vector spot1;
	local vector spot2;

	spot1 = (self.origin + self.view_ofs);
	spot2 = (targ.origin + targ.view_ofs);
	traceline(spot1, spot2, TRUE, self);
	if ((trace_inopen && trace_inwater))
	{
		return (FALSE);
	}
	if ((trace_fraction == LASERTARG_ON))
	{
		return (TRUE);
	}
	return (FALSE);
};

float(entity targ) infront =
{
	local vector vec;
	local float dot;

	makevectors(self.angles);
	vec = normalize((targ.origin - self.origin));
	dot = (vec * v_forward);
	if ((dot > 0.3))
	{
		return (TRUE);
	}
	return (FALSE);
};

void() HuntTarget =
{
	self.goalentity = self.enemy;
	self.think = self.th_run;
	self.ideal_yaw = vectoyaw((self.enemy.origin - self.origin));
	self.nextthink = (time + 0.1);
	SUB_AttackFinished(LASERTARG_ON);
};

void() SightSound =
{
	local float rsnd;

	if ((self.classname == "monster_ogre"))
	{
		sound(self, CHAN_VOICE, "ogre/ogwake.wav", LASERTARG_ON, ATTN_NORM);
	}
	else
	{
		if ((self.classname == "monster_knight"))
		{
			sound(self, CHAN_VOICE, "knight/ksight.wav", LASERTARG_ON, ATTN_NORM);
		}
		else
		{
			if ((self.classname == "monster_shambler"))
			{
				sound(self, CHAN_VOICE, "shambler/ssight.wav", LASERTARG_ON, ATTN_NORM);
			}
			else
			{
				if ((self.classname == "monster_demon1"))
				{
					sound(self, CHAN_VOICE, "demon/sight2.wav", LASERTARG_ON, ATTN_NORM);
				}
				else
				{
					if ((self.classname == "monster_wizard"))
					{
						sound(self, CHAN_VOICE, "wizard/wsight.wav", LASERTARG_ON, ATTN_NORM);
					}
					else
					{
						if ((self.classname == "monster_zombie"))
						{
							sound(self, CHAN_VOICE, "zombie/z_idle.wav", LASERTARG_ON, ATTN_NORM);
						}
						else
						{
							if ((self.classname == "monster_dog"))
							{
								sound(self, CHAN_VOICE, "dog/dsight.wav", LASERTARG_ON, ATTN_NORM);
							}
							else
							{
								if ((self.classname == "monster_hell_knight"))
								{
									sound(self, CHAN_VOICE, "hknight/sight1.wav", LASERTARG_ON, ATTN_NORM);
								}
								else
								{
									if ((self.classname == "monster_tarbaby"))
									{
										sound(self, CHAN_VOICE, "blob/sight1.wav", LASERTARG_ON, ATTN_NORM);
									}
									else
									{
										if ((self.classname == "monster_vomit"))
										{
											sound(self, CHAN_VOICE, "blob/sight1.wav", LASERTARG_ON, ATTN_NORM);
										}
										else
										{
											if ((self.classname == "monster_enforcer"))
											{
												rsnd = rint((random() * AS_MELEE));
												if ((rsnd == LASERTARG_ON))
												{
													sound(self, CHAN_VOICE, "enforcer/sight1.wav", LASERTARG_ON, ATTN_NORM);
												}
												else
												{
													if ((rsnd == AS_SLIDING))
													{
														sound(self, CHAN_VOICE, "enforcer/sight2.wav", LASERTARG_ON, ATTN_NORM);
													}
													else
													{
														if ((rsnd == MSG_BROADCAST))
														{
															sound(self, CHAN_VOICE, "enforcer/sight3.wav", LASERTARG_ON, ATTN_NORM);
														}
														else
														{
															sound(self, CHAN_VOICE, "enforcer/sight4.wav", LASERTARG_ON, ATTN_NORM);
														}
													}
												}
											}
											else
											{
												if ((self.classname == "monster_army"))
												{
													sound(self, CHAN_VOICE, "soldier/sight1.wav", LASERTARG_ON, ATTN_NORM);
												}
												else
												{
													if ((self.classname == "monster_shalrath"))
													{
														sound(self, CHAN_VOICE, "shalrath/sight.wav", LASERTARG_ON, ATTN_NORM);
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
};

void() FoundTarget =
{
	if ((self.enemy.classname == "player"))
	{
		sight_entity = self;
		sight_entity_time = time;
	}
	self.show_hostile = (time + LASERTARG_ON);
	SightSound();
	HuntTarget();
};

float() FindTarget =
{
	return (FALSE);
};

float(entity ent) BoardPieceEntity =
{
	local float x;
	local float y;

	if ((ent == world))
		return (FALSE);
	if ((ent.chess_team == ""))
		return (FALSE);
	x = floor((ent.location / 10));
	y = (ent.location - (x * 10));
	if (((((x < 1) || (x > 8)) || (y < 1)) || (y > 8)))
		return (FALSE);
	if (ent.ischecker)
		return (TRUE);
	if ((ent.classname == "chess_pawn"))
		return (TRUE);
	if ((ent.classname == "chess_rook"))
		return (TRUE);
	if ((ent.classname == "chess_knight"))
		return (TRUE);
	if ((ent.classname == "chess_bishop"))
		return (TRUE);
	if ((ent.classname == "chess_queen"))
		return (TRUE);
	return (ent.classname == "chess_king");
};

void(entity ent) SetBoardPieceOrigin =
{
	if (!BoardPieceEntity(ent))
		return;
	setorigin(ent, LocationToVector(ent.location));
};

void(float dist) ai_forward =
{
	walkmove(self.angles_y, dist);
};

void(float dist) ai_back =
{
	walkmove((self.angles_y + 180), dist);
};

void(float dist) ai_pain =
{
	ai_back(dist);
};

void(float dist) ai_painforward =
{
	walkmove(self.ideal_yaw, dist);
};

void(float dist) ai_walk =
{
	local float ftemp;
	local float tyaw;
	local vector move_vec;
	local vector v1;
	local vector v2;

	movedist = dist;
	if ((self.classname == "monster_dragon"))
	{
		movetogoal(dist);
		return;
	}
	if (FindTarget())
	{
		return;
	}
	if ((self.classname != "grabber"))
	{
		if ((self.angles_y != self.ideal_yaw))
		{
			ChangeYaw();
		}
		if (((self.origin_x == self.goalentity.origin_x) && (self.origin_y == self.goalentity.origin_y)))
		{
			if ((self.ideal_yaw != self.orig_angle_y))
			{
				self.ideal_yaw = self.orig_angle_y;
			}
			ChangeYaw();
		}
	}
	v1 = self.origin;
	v2 = self.goalentity.origin;
	v1_z = MSG_BROADCAST;
	v2_z = MSG_BROADCAST;
	ftemp = vlen((v1 - v2));
	move_vec = (self.goalentity.origin - self.origin);
	move_vec_z = MSG_BROADCAST;
	move_vec = (normalize(move_vec) * dist);
	if (((dist >= ftemp) || (ftemp <= CF_HAS_MOVED)))
	{
		if (BoardPieceEntity(self))
			setorigin(self, self.goalentity.origin);
		else
		{
			self.origin = self.goalentity.origin;
			droptofloor();
		}
		if ((self.classname == "grabber"))
		{
			if ((self.weapon != IT_ROCKET_LAUNCHER))
			{
				self.goalentity = self.owner;
				self.weapon = IT_ROCKET_LAUNCHER;
				tyaw = vectoyaw((self.goalentity.origin - self.origin));
				self.angles_y = anglemod(tyaw);
				grab_walk1();
			}
			else
			{
				spawn_fog(self.origin);
				remove(self.owner);
				remove(GetBody);
				remove(self);
				GetBody = world;
			}
			return;
		}
		if ((self.angles_y == self.orig_angle_y))
		{
			if (((!game_checkers && (self.classname == "chess_pawn")) && ((GetY(self.location) == CF_HAS_MOVED) || (GetY(self.location) == LASERTARG_ON))))
			{
				become_queen();
				if (current_turn.is_bot)
				{
					ChessBotPromotePawn();
					return;
				}
				mysprint(self.owner, "Pawn Promotion!\nPress Del to cycle piece\n");
				mysprint(self.owner, "Click to promote\n");
				mycentreprint(self.owner, "Promoting to: Queen\n");
				Queening = LASERTARG_ON;
			}
			self.th_stand();
			if (king_castle_move_flag)
			{
				spawn_tfog(castle_to_move.origin);
				castle_to_move.location = castle_destination;
				SetBoardPieceOrigin(castle_to_move);
				spawn_tfog(castle_to_move.origin);
				sound(castle_to_move, CHAN_AUTO, "misc/r_tele4.wav", LASERTARG_ON, ATTN_NORM);
			}
			king_castle_move_flag = MSG_BROADCAST;
			if (!Queening)
			{
				if (game_checkers)
				{
					CheckersFinishMove();
				}
				else
				{
					next_turn();
				}
			}
			else
			{
				if ((cvar("coop") == 69))
				{
					dog_jig1();
				}
				else
				{
					knight_jig1();
				}
			}
		}
		return;
	}
	setorigin(self, (self.origin + move_vec));
	self.nextthink = (time + 0.05);
};

void() ai_stand =
{
	if (((king_dead && (self.enemy == world)) && (self.classname != "chess_king")))
	{
		self.enemy = FindNewEnemy(self);
		if ((FindNewEnemy(self) != world))
		{
			HuntTarget();
		}
	}
};

void() ai_turn =
{
	if (FindTarget())
	{
		return;
	}
	ChangeYaw();
};

void(vector dest3) ChooseTurn =
{
	local vector dir;
	local vector newdir;

	dir = (self.origin - dest3);
	newdir_x = trace_plane_normal_y;
	newdir_y = (MSG_BROADCAST - trace_plane_normal_x);
	newdir_z = MSG_BROADCAST;
	if (((dir * newdir) > MSG_BROADCAST))
	{
		dir_x = (MSG_BROADCAST - trace_plane_normal_y);
		dir_y = trace_plane_normal_x;
	}
	else
	{
		dir_x = trace_plane_normal_y;
		dir_y = (MSG_BROADCAST - trace_plane_normal_x);
	}
	dir_z = MSG_BROADCAST;
	self.ideal_yaw = vectoyaw(dir);
};

float() FacingIdeal =
{
	local float delta;

	delta = anglemod((self.angles_y - self.ideal_yaw));
	if (((delta > 45) && (delta < 315)))
	{
		return (FALSE);
	}
	return (TRUE);
};
float() WizardCheckAttack;
float() DogCheckAttack;

float() CheckAnyAttack =
{
	if (!enemy_vis)
	{
		return (FALSE);
	}
	if ((self.classname == "monster_army"))
	{
		return (SoldierCheckAttack());
	}
	if ((self.classname == "monster_ogre"))
	{
		return (OgreCheckAttack());
	}
	if ((self.classname == "monster_shambler"))
	{
		return (ShamCheckAttack());
	}
	if ((self.classname == "monster_demon1"))
	{
		return (DemonCheckAttack());
	}
	if ((self.classname == "monster_dog"))
	{
		return (DogCheckAttack());
	}
	if ((self.classname == "monster_wizard"))
	{
		return (WizardCheckAttack());
	}
	return (CheckAttack());
};

void() ai_run_melee =
{
	self.ideal_yaw = enemy_yaw;
	ChangeYaw();
	if (FacingIdeal())
	{
		self.th_melee();
		self.attack_state = AS_STRAIGHT;
	}
};

void() ai_run_missile =
{
	self.ideal_yaw = enemy_yaw;
	ChangeYaw();
	if (FacingIdeal())
	{
		if ((self.classname != "chess_pawn"))
		{
			self.th_missile();
		}
		else
		{
			self.th_melee();
		}
		self.attack_state = AS_STRAIGHT;
	}
};

void() ai_run_slide =
{
	local float ofs;

	self.ideal_yaw = enemy_yaw;
	ChangeYaw();
	if (self.lefty)
	{
		ofs = 90;
	}
	else
	{
		ofs = -90;
	}
	if (walkmove((self.ideal_yaw + ofs), movedist))
	{
		return;
	}
	self.lefty = (LASERTARG_ON - self.lefty);
	walkmove((self.ideal_yaw - ofs), movedist);
};

void(float dist) ai_run =
{
	local vector delta;
	local vector goal_vec;
	local float axis;
	local float direct;
	local float ang_rint;
	local float ang_floor;
	local float ang_ceil;
	local string str;

	movedist = dist;
	if ((!king_dead && !((self.enemy == current_enemy) || (self.enemy == current_selected))))
	{
		self.enemy = world;
		self.th_stand();
	}
	if ((self.enemy.health <= MSG_BROADCAST))
	{
		self.enemy = world;
		if ((self.oldenemy.health > MSG_BROADCAST))
		{
			self.enemy = self.oldenemy;
			HuntTarget();
		}
		self.enemy = FindNewEnemy(self);
		if (((self.enemy == world) && (FindNewEnemy(self) != world)))
		{
			HuntTarget();
		}
		else
		{
			if (self.movetarget)
			{
				self.th_walk();
			}
			else
			{
				self.th_stand();
			}
		}
		return;
	}
	enemy_vis = visible(self.enemy);
	if (enemy_vis)
	{
		self.search_time = (time + TE_LIGHTNING1);
	}
	enemy_infront = infront(self.enemy);
	enemy_range = range(self.enemy);
	enemy_yaw = vectoyaw((self.enemy.origin - self.origin));
	if (((vlen((self.origin - self.enemy.origin)) > (IT_LIGHTNING * AS_MELEE)) && !king_dead))
	{
		self.attack_state = AS_MISSILE;
	}
	if ((self.attack_state == AS_MISSILE))
	{
		ai_run_missile();
		return;
	}
	if ((self.attack_state == AS_MELEE))
	{
		ai_run_melee();
		return;
	}
	if (CheckAnyAttack())
	{
		return;
	}
	if ((self.attack_state == AS_SLIDING))
	{
		ai_run_slide();
		return;
	}
	if (king_dead)
	{
		movetogoal(dist);
	}
	else
	{
		goal_vec = (self.goalentity.origin - self.origin);
		goal_vec_z = MSG_BROADCAST;
		if ((vlen(goal_vec) > CF_TIME_NOTIFY))
		{
			goal_vec = normalize(goal_vec);
			setorigin(self, (self.origin + (goal_vec * dist)));
		}
	}
};

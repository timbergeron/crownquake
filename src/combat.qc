//Decompiled code. Please respect the original copyright.
void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;
void() monster_death_use;

float(entity targ, entity inflictor) CanDamage =
{
	if ((targ.movetype == MOVETYPE_PUSH))
	{
		traceline(inflictor.origin, (0.5 * (targ.absmin + targ.absmax)), TRUE, self);
		if ((trace_fraction == LASERTARG_ON))
		{
			return (TRUE);
		}
		if ((trace_ent == targ))
		{
			return (TRUE);
		}
		return (FALSE);
	}
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if ((trace_fraction == LASERTARG_ON))
	{
		return (TRUE);
	}
	traceline(inflictor.origin, (targ.origin + '15 15 0'), TRUE, self);
	if ((trace_fraction == LASERTARG_ON))
	{
		return (TRUE);
	}
	traceline(inflictor.origin, (targ.origin + '-15 -15 0'), TRUE, self);
	if ((trace_fraction == LASERTARG_ON))
	{
		return (TRUE);
	}
	traceline(inflictor.origin, (targ.origin + '-15 15 0'), TRUE, self);
	if ((trace_fraction == LASERTARG_ON))
	{
		return (TRUE);
	}
	traceline(inflictor.origin, (targ.origin + '15 -15 0'), TRUE, self);
	if ((trace_fraction == LASERTARG_ON))
	{
		return (TRUE);
	}
	return (FALSE);
};

void(entity targ, entity attacker) Killed =
{
	local entity oself;

	oself = self;
	self = targ;
	if ((self.health < -99))
	{
		self.health = -99;
	}
	self.enemy = attacker;
	if ((self.flags & FL_MONSTER))
	{
		killed_monsters = (killed_monsters + LASERTARG_ON);
		WriteByte(MSG_ALL, SVC_KILLEDMONSTER);
	}
	ClientObituary(self, attacker);
	if (!king_dead)
	{
		if ((GetBody != world))
		{
			remove(GetBody);
		}
		GetBody = self;
	}
	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;
	monster_death_use();
	self.th_die();
	self = oself;
};

void(entity targ, entity inflictor, entity attacker, float damage) T_Damage =
{
	local vector dir;
	local entity oldself;
	local float save;
	local float points;
	local float take;
	local vector vel;
	local vector org;

	if (!targ.takedamage)
	{
		return;
	}
	damage_attacker = attacker;
	if (!king_dead)
	{
		damage = (damage * CF_SELECTED_PIECE);
		if ((targ != current_selected.enemy))
		{
			damage = MSG_BROADCAST;
		}
	}
	save = ceil((targ.armortype * damage));
	if ((save >= targ.armorvalue))
	{
		save = targ.armorvalue;
		targ.armortype = MSG_BROADCAST;
		targ.items = (targ.items - (targ.items & ((IT_ARMOR1 | IT_ARMOR2) | IT_ARMOR3)));
	}
	targ.armorvalue = (targ.armorvalue - save);
	take = ceil((damage - save));
	if ((targ.flags & FL_CLIENT))
	{
		targ.dmg_take = (targ.dmg_take + take);
		targ.dmg_save = (targ.dmg_save + save);
		targ.dmg_inflictor = inflictor;
	}
	if (((inflictor != world) && (targ.movetype == MOVETYPE_WALK)))
	{
		dir = (targ.origin - ((inflictor.absmin + inflictor.absmax) * 0.5));
		dir = normalize(dir);
		targ.velocity = (targ.velocity + ((dir * damage) * CF_HAS_MOVED));
	}
	if ((targ.flags & FL_GODMODE))
	{
		return;
	}
	if ((targ.invincible_finished >= time))
	{
		if ((self.invincible_sound < time))
		{
			sound(targ, CHAN_ITEM, "items/protect3.wav", LASERTARG_ON, ATTN_NORM);
			self.invincible_sound = (time + AS_SLIDING);
		}
		return;
	}
	if ((((teamplay == LASERTARG_ON) && (targ.team > MSG_BROADCAST)) && (targ.team == attacker.team)))
	{
		return;
	}
	if (((king_dead == TRUE) && (targ.classname == "chess_king")))
	{
		if ((targ.enemy == world))
		{
			targ.enemy = attacker;
			targ.think = FoundTarget;
			targ.nextthink = (time + 0.1);
		}
		return;
	}
	if (((targ == current_selected.enemy) || king_dead))
	{
		targ.health = (targ.health - take);
		vel = normalize((((dir + (('1 0 0' * random()) * 10)) + (('0 1 0' * random()) * 10)) + (('0 0 1' * random()) * 10)));
		vel = (vel * TE_LIGHTNING1);
		org = targ.origin;
		SpawnBlood(org, vel, take);
	}
	if ((targ.health <= MSG_BROADCAST))
	{
		Killed(targ, attacker);
		if (!king_dead)
		{
			WalkToDest(current_turn);
			if ((targ.classname == "chess_pawn"))
			{
				points = LASERTARG_ON;
			}
			else
			{
				if (((targ.classname == "chess_bishop") || (targ.classname == "chess_knight")))
				{
					points = AS_MELEE;
				}
				else
				{
					if ((targ.classname == "chess_rook"))
					{
						points = TE_LIGHTNING1;
					}
					else
					{
						if ((targ.classname == "chess_queen"))
						{
							points = TE_LIGHTNING3;
						}
					}
				}
			}
			current_selected.enemy = world;
			current_turn.frags = (current_turn.frags + points);
			current_turn.currentammo = current_turn.frags;
		}
		else
		{
			if ((attacker.classname == "chess_king"))
			{
				attacker.enemy = world;
			}
		}
		return;
	}
	oldself = self;
	self = targ;
	if (king_dead)
	{
		if (((self.flags & FL_MONSTER) && (attacker != world)))
		{
			if (((self != attacker) && (attacker != self.enemy)))
			{
				if ((self.owner != attacker.owner))
				{
					if ((self.enemy.classname == "player"))
					{
						self.oldenemy = self.enemy;
					}
					self.enemy = attacker;
					FoundTarget();
				}
			}
		}
	}
	if (self.th_pain)
	{
		if ((self != current_selected))
		{
			self.pain_finished = (time + TE_LIGHTNING1);
			self.th_pain(attacker, take);
		}
	}
	self = oldself;
};

void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
	local float points;
	local entity head;
	local vector org;

	head = findradius(inflictor.origin, (damage + 40));
	while (head)
	{
		if ((head != ignore))
		{
			if ((head.takedamage && ((!king_dead && (head == current_selected.enemy)) || king_dead)))
			{
				org = (head.origin + ((head.mins + head.maxs) * 0.5));
				points = (0.5 * vlen((inflictor.origin - org)));
				if ((points < MSG_BROADCAST))
				{
					points = MSG_BROADCAST;
				}
				points = (damage - points);
				if ((head == attacker))
				{
					points = (points * 0.5);
				}
				if ((points > MSG_BROADCAST))
				{
					if (CanDamage(head, inflictor))
					{
						if ((head.classname == "monster_shambler"))
						{
							T_Damage(head, inflictor, attacker, (points * 0.5));
						}
						else
						{
							T_Damage(head, inflictor, attacker, points);
						}
					}
				}
			}
		}
		head = head.chain;
	}
};

void(entity attacker, float damage) T_BeamDamage =
{
	local float points;
	local entity head;

	head = findradius(attacker.origin, (damage + 40));
	while (head)
	{
		if (head.takedamage)
		{
			points = (0.5 * vlen((attacker.origin - head.origin)));
			if ((points < MSG_BROADCAST))
			{
				points = MSG_BROADCAST;
			}
			points = (damage - points);
			if ((head == attacker))
			{
				points = (points * 0.5);
			}
			if ((points > MSG_BROADCAST))
			{
				if (CanDamage(head, attacker))
				{
					if ((head.classname == "monster_shambler"))
					{
						T_Damage(head, attacker, attacker, (points * 0.5));
					}
					else
					{
						T_Damage(head, attacker, attacker, points);
					}
				}
			}
		}
		head = head.chain;
	}
};

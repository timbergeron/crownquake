//Decompiled code. Please respect the original copyright.
float(float v) anglemod;
void() knight_atk1;
void() knight_runatk1;
void() ogre_smash1;
void() ogre_swing1;
void() sham_smash1;
void() sham_swingr1;
void() sham_swingl1;
float() DemonCheckAttack;
void(float side) Demon_Melee;
void(vector dest3) ChooseTurn;
void() ai_face;
float enemy_vis;
float enemy_infront;
float enemy_range;
float enemy_yaw;

void() knight_attack =
{
	local float len;

	len = vlen(((self.enemy.origin + self.enemy.view_ofs) - (self.origin + self.view_ofs)));
	if ((len < 80))
	{
		knight_atk1();
	}
	else
	{
		knight_runatk1();
	}
};

float() CheckAttack =
{
	local vector spot1;
	local vector spot2;
	local entity targ;
	local float chance;

	targ = self.enemy;
	spot1 = (self.origin + self.view_ofs);
	spot2 = (targ.origin + targ.view_ofs);
	traceline(spot1, spot2, FALSE, self);
	if ((trace_ent != targ))
	{
		return (FALSE);
	}
	if ((trace_inopen && trace_inwater))
	{
		return (FALSE);
	}
	if ((enemy_range == RANGE_MELEE))
	{
		if (!(secret_monsters && (self.classname != "chess_pawn")))
		{
			if (self.th_melee)
			{
				if ((self.classname == "monster_knight"))
				{
					knight_attack();
				}
				else
				{
					self.th_melee();
				}
				return (TRUE);
			}
		}
	}
	if (!self.th_missile)
	{
		return (FALSE);
	}
	if ((time < self.attack_finished))
	{
		return (FALSE);
	}
	if ((enemy_range == RANGE_FAR))
	{
		return (FALSE);
	}
	if ((enemy_range == RANGE_MELEE))
	{
		chance = 0.9;
		self.attack_finished = MSG_BROADCAST;
	}
	else
	{
		if ((enemy_range == RANGE_NEAR))
		{
			if (self.th_melee)
			{
				chance = 0.2;
			}
			else
			{
				chance = 0.4;
			}
		}
		else
		{
			if ((enemy_range == RANGE_MID))
			{
				if (self.th_melee)
				{
					chance = 0.05;
				}
				else
				{
					chance = 0.1;
				}
			}
			else
			{
				chance = MSG_BROADCAST;
			}
		}
	}
	if ((random() < chance))
	{
		self.th_missile();
		SUB_AttackFinished((AS_SLIDING * random()));
		return (TRUE);
	}
	return (FALSE);
};

void() ai_face =
{
	self.ideal_yaw = vectoyaw((self.enemy.origin - self.origin));
	ChangeYaw();
};
float(entity targ) infront;
float(entity targ) range;

void(float d) ai_charge =
{
	local vector goal_vec;

	ai_face();
	if (king_dead)
	{
		movetogoal(d);
	}
	else
	{
		if ((vlen((self.origin - self.goalentity.origin)) > (CF_TIME_NOTIFY + d)))
		{
			goal_vec = normalize((self.goalentity.origin - self.origin));
			setorigin(self, (self.origin + (goal_vec * d)));
		}
	}
};

void() ai_charge_side =
{
	local vector dtemp;
	local float heading;

	self.ideal_yaw = vectoyaw((self.enemy.origin - self.origin));
	ChangeYaw();
	makevectors(self.angles);
	dtemp = (self.enemy.origin - (SVC_INTERMISSION * v_right));
	heading = vectoyaw((dtemp - self.origin));
	walkmove(heading, 20);
};

void() ai_melee =
{
	local vector delta;
	local float ldmg;

	if (!self.enemy)
	{
		return;
	}
	delta = (self.enemy.origin - self.origin);
	if ((vlen(delta) > 60))
	{
		return;
	}
	ldmg = (((random() + random()) + random()) * AS_MELEE);
	T_Damage(self.enemy, self, self, ldmg);
};

void() ai_melee_side =
{
	local vector delta;
	local float ldmg;

	if (!self.enemy)
	{
		return;
	}
	ai_charge_side();
	delta = (self.enemy.origin - self.origin);
	if ((vlen(delta) > 60))
	{
		return;
	}
	if (!CanDamage(self.enemy, self))
	{
		return;
	}
	ldmg = (((random() + random()) + random()) * AS_MELEE);
	T_Damage(self.enemy, self, self, ldmg);
};

float() SoldierCheckAttack =
{
	local vector spot1;
	local vector spot2;
	local entity targ;
	local float chance;

	targ = self.enemy;
	spot1 = (self.origin + self.view_ofs);
	spot2 = (targ.origin + targ.view_ofs);
	traceline(spot1, spot2, FALSE, self);
	if ((trace_inopen && trace_inwater))
	{
		return (FALSE);
	}
	if ((trace_ent != targ))
	{
		return (FALSE);
	}
	if ((time < self.attack_finished))
	{
		return (FALSE);
	}
	if ((enemy_range == RANGE_FAR))
	{
		return (FALSE);
	}
	if ((enemy_range == RANGE_MELEE))
	{
		chance = 0.9;
	}
	else
	{
		if ((enemy_range == RANGE_NEAR))
		{
			chance = 0.4;
		}
		else
		{
			if ((enemy_range == RANGE_MID))
			{
				chance = 0.05;
			}
			else
			{
				chance = MSG_BROADCAST;
			}
		}
	}
	if ((random() < chance))
	{
		self.th_missile();
		SUB_AttackFinished((LASERTARG_ON + random()));
		if ((random() < 0.3))
		{
			self.lefty = !self.lefty;
		}
		return (TRUE);
	}
	return (FALSE);
};

float() ShamCheckAttack =
{
	local vector spot1;
	local vector spot2;
	local entity targ;
	local float chance;

	sprint(player1, "shambler check attack\n");
	if ((enemy_range == RANGE_MELEE))
	{
		CanDamage(self.enemy, self);
		if ((random() && (random() > 0.4)))
		{
			self.attack_state = AS_MELEE;
			return (TRUE);
		}
	}
	if ((time < self.attack_finished))
	{
		return (FALSE);
	}
	if ((enemy_range == RANGE_FAR))
	{
		return (FALSE);
	}
	self.attack_state = AS_MISSILE;
	SUB_AttackFinished((AS_SLIDING + (AS_SLIDING * random())));
	return (TRUE);
};

float() OgreCheckAttack =
{
	local vector spot1;
	local vector spot2;
	local entity targ;
	local float chance;

	if (((enemy_range == RANGE_MELEE) && (self.enemy.classname != "chess_king")))
	{
		CanDamage(self.enemy, self);
		if ((random() && (random() > 0.4)))
		{
			self.attack_state = AS_MELEE;
			return (TRUE);
		}
	}
	if ((time < self.attack_finished))
	{
		return (FALSE);
	}
	if (!enemy_vis)
	{
		return (FALSE);
	}
	targ = self.enemy;
	spot1 = (self.origin + self.view_ofs);
	spot2 = (targ.origin + targ.view_ofs);
	traceline(spot1, spot2, FALSE, self);
	if ((trace_inopen && trace_inwater))
	{
		return (FALSE);
	}
	if ((trace_ent != targ))
	{
		return (FALSE);
	}
	if ((time < self.attack_finished))
	{
		return (FALSE);
	}
	if ((enemy_range == RANGE_FAR))
	{
		return (FALSE);
	}
	else
	{
		if ((enemy_range == RANGE_NEAR))
		{
			chance = 0.1;
		}
		else
		{
			if ((enemy_range == RANGE_MID))
			{
				chance = 0.05;
			}
			else
			{
				chance = MSG_BROADCAST;
			}
		}
	}
	self.attack_state = AS_MISSILE;
	SUB_AttackFinished((LASERTARG_ON + (AS_SLIDING * random())));
	return (TRUE);
};

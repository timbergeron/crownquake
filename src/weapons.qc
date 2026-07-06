//Decompiled code. Please respect the original copyright.
void() player_run;
void() SuperDamageSound;
.float sight_out;

void() W_Precache =
{
	precache_sound("weapons/r_exp3.wav");
	precache_sound("weapons/rocket1i.wav");
	precache_sound("weapons/sgun1.wav");
	precache_sound("weapons/guncock.wav");
	precache_sound("weapons/ric1.wav");
	precache_sound("weapons/ric2.wav");
	precache_sound("weapons/ric3.wav");
	precache_sound("weapons/spike2.wav");
	precache_sound("weapons/tink1.wav");
	precache_sound("weapons/grenade.wav");
	precache_sound("weapons/bounce.wav");
	precache_sound("weapons/shotgn2.wav");
};

float() crandom =
{
	return ((H_MEGA * (random() - 0.5)));
};

void() W_FireAxe =
{
	local vector source;
	local vector org;

	makevectors(self.v_angle);
	source = (self.origin + '0 0 16');
	traceline(source, (source + (v_forward * IT_LIGHTNING)), FALSE, self);
	if ((trace_fraction == LASERTARG_ON))
	{
		return;
	}
	org = (trace_endpos - (v_forward * CF_SELECTED_PIECE));
	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = LASERTARG_ON;
		SpawnBlood(org, '0 0 0', 20);
		T_Damage(trace_ent, self, self, 20);
	}
	else
	{
		sound(self, CHAN_WEAPON, "player/axhit2.wav", LASERTARG_ON, ATTN_NORM);
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord(MSG_BROADCAST, org_x);
		WriteCoord(MSG_BROADCAST, org_y);
		WriteCoord(MSG_BROADCAST, org_z);
	}
};

vector() wall_velocity =
{
	local vector vel;

	vel = normalize(self.velocity);
	vel = normalize(((vel + (v_up * (random() - 0.5))) + (v_right * (random() - 0.5))));
	vel = (vel + (WEAPON_ROCKET * trace_plane_normal));
	vel = (vel * 200);
	return (vel);
};

void(vector org, vector vel) SpawnMeatSpray =
{
	local entity missile;
	local entity mpuff;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;
	makevectors(self.angles);
	missile.velocity = vel;
	missile.velocity_z = ((missile.velocity_z + 250) + (50 * random()));
	missile.avelocity = '3000 1000 2000';
	missile.nextthink = (time + LASERTARG_ON);
	missile.think = SUB_Remove;
	setmodel(missile, "progs/zom_gib.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, org);
};

void(vector org, vector vel, float damage) SpawnBlood =
{
	particle(org, (vel * 0.1), 73, (damage * WEAPON_ROCKET));
};

void(float damage) spawn_touchblood =
{
	local vector vel;

	vel = (wall_velocity() * 0.2);
	SpawnBlood((self.origin + (vel * 0.01)), vel, damage);
};

void(vector org, vector vel) SpawnChunk =
{
	particle(org, (vel * 0.02), MSG_BROADCAST, 10);
};
entity multi_ent;
float multi_damage;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = MSG_BROADCAST;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
	{
		return;
	}
	T_Damage(multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
	{
		return;
	}
	if ((hit != multi_ent))
	{
		ApplyMultiDamage();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
	{
		multi_damage = (multi_damage + damage);
	}
};

void(float damage, vector dir) TraceAttack =
{
	local vector vel;
	local vector org;

	vel = normalize(((dir + (v_up * crandom())) + (v_right * crandom())));
	vel = (vel + (WEAPON_ROCKET * trace_plane_normal));
	vel = (vel * 200);
	org = (trace_endpos - (dir * WEAPON_SPIKES));
	if (trace_ent.takedamage)
	{
		SpawnBlood(org, (vel * 0.2), damage);
		AddMultiDamage(trace_ent, damage);
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord(MSG_BROADCAST, org_x);
		WriteCoord(MSG_BROADCAST, org_y);
		WriteCoord(MSG_BROADCAST, org_z);
	}
};

void(float shotcount, vector dir, vector spread) FireBullets =
{
	local vector direction;
	local vector src;

	makevectors(self.v_angle);
	src = (self.origin + (v_forward * 10));
	src_z = (self.absmin_z + (self.size_z * 0.7));
	ClearMultiDamage();
	while ((shotcount > MSG_BROADCAST))
	{
		direction = ((dir + ((crandom() * spread_x) * v_right)) + ((crandom() * spread_y) * v_up));
		traceline(src, (src + (direction * IT_CELLS)), FALSE, self);
		if ((trace_fraction != 1))
		{
			TraceAttack(WEAPON_SPIKES, direction);
		}
		shotcount = (shotcount - 1);
	}
	ApplyMultiDamage();
};

void() W_FireShotgun =
{
	local vector dir;

	sound(self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;
	self.ammo_shells = (self.ammo_shells - 1);
	self.currentammo = (self.ammo_shells - 1);
	dir = aim(self, 100000);
	FireBullets(TE_LIGHTNING2, dir, '0.04 0.04 0');
};

void() W_FireSuperShotgun =
{
	local vector dir;

	if ((self.currentammo == 1))
	{
		W_FireShotgun();
		return;
	}
	sound(self, CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);
	self.punchangle_x = CONTENT_SLIME;
	self.ammo_shells = (self.ammo_shells - WEAPON_ROCKET);
	self.currentammo = (self.ammo_shells - WEAPON_ROCKET);
	dir = aim(self, 100000);
	FireBullets(14, dir, '0.14 0.08 0');
};

void() s_explode1 = [ 0, s_explode2 ]
{
};

void() s_explode2 = [ 1, s_explode3 ]
{
};

void() s_explode3 = [ 2, s_explode4 ]
{
};

void() s_explode4 = [ 3, s_explode5 ]
{
};

void() s_explode5 = [ 4, s_explode6 ]
{
};

void() s_explode6 = [ 5, SUB_Remove ]
{
};

void() BecomeExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel(self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1();
};

void() T_MissileTouch =
{
	local float damg;

	if ((other == self.owner))
	{
		return;
	}
	if ((other.chess_team == self.owner.chess_team))
	{
		if ((pointcontents(self.origin) == CONTENT_SKY))
		{
			remove(self);
			return;
		}
	}
	damg = (100 + (random() * 20));
	if (other.health)
	{
		if ((other.classname == "monster_shambler"))
		{
			damg = (damg * 0.5);
		}
		T_Damage(other, self, self.owner, damg);
	}
	T_RadiusDamage(self, self.owner, 120, other);
	self.origin = (self.origin - (WEAPON_BIG * normalize(self.velocity)));
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	BecomeExplosion();
};

void() W_FireRocket =
{
	local entity missile;
	local entity mpuff;

	self.ammo_rockets = (self.ammo_rockets - 1);
	self.currentammo = (self.ammo_rockets - 1);
	sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;
	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
	makevectors(self.v_angle);
	missile.velocity = aim(self, 1000);
	missile.velocity = (missile.velocity * 1000);
	missile.angles = vectoangles(missile.velocity);
	missile.touch = T_MissileTouch;
	missile.nextthink = (time + TE_LIGHTNING1);
	missile.think = SUB_Remove;
	setmodel(missile, "progs/missile.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, ((self.origin + (v_forward * WEAPON_BIG)) + '0 0 16'));
};

void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity e1;
	local entity e2;
	local vector f;

	f = (p2 - p1);
	normalize(f);
	f_x = (MSG_BROADCAST - f_y);
	f_y = f_x;
	f_z = MSG_BROADCAST;
	f = (f * CF_CHECK_NOTIFY);
	e2 = world;
	e1 = world;
	traceline(p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, (damage * WEAPON_SPIKES));
		T_Damage(trace_ent, from, from, damage);
		if ((self.classname == "player"))
		{
			if ((other.classname == "player"))
			{
				trace_ent.velocity_z = (trace_ent.velocity_z + 400);
			}
		}
	}
	e1 = trace_ent;
	traceline((p1 + f), (p2 + f), FALSE, self);
	if (((trace_ent != e1) && trace_ent.takedamage))
	{
		particle(trace_endpos, '0 0 100', 225, (damage * WEAPON_SPIKES));
		T_Damage(trace_ent, from, from, damage);
	}
	e2 = trace_ent;
	traceline((p1 - f), (p2 - f), FALSE, self);
	if ((((trace_ent != e1) && (trace_ent != e2)) && trace_ent.takedamage))
	{
		particle(trace_endpos, '0 0 100', 225, (damage * WEAPON_SPIKES));
		T_Damage(trace_ent, from, from, damage);
	}
};

void() W_FireLightning =
{
	local vector org;
	local float cells;

	if ((self.ammo_cells < 1))
	{
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		return;
	}
	if ((self.waterlevel > 1))
	{
		cells = self.ammo_cells;
		self.ammo_cells = MSG_BROADCAST;
		T_RadiusDamage(self, self, (35 * cells), world);
		W_SetCurrentAmmo();
		return;
	}
	if ((self.t_width < time))
	{
		sound(self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = (time + 0.6);
	}
	self.punchangle_x = -2;
	self.ammo_cells = (self.ammo_cells - 1);
	self.currentammo = (self.ammo_cells - 1);
	org = (self.origin + '0 0 16');
	traceline(org, (org + (v_forward * 600)), TRUE, self);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity(MSG_BROADCAST, self);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
	WriteCoord(MSG_BROADCAST, trace_endpos_x);
	WriteCoord(MSG_BROADCAST, trace_endpos_y);
	WriteCoord(MSG_BROADCAST, trace_endpos_z);
	LightningDamage(self.origin, (trace_endpos + (v_forward * WEAPON_SPIKES)), self, SVC_INTERMISSION);
};

void() GrenadeExplode =
{
	T_RadiusDamage(self, self.owner, 120, world);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	BecomeExplosion();
};

void() GrenadeTouch =
{
	if ((other == self.owner))
	{
		return;
	}
	if ((other.takedamage == DAMAGE_AIM))
	{
		GrenadeExplode();
		return;
	}
	sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
	if ((self.velocity == '0 0 0'))
	{
		self.avelocity = '0 0 0';
	}
};

void() W_FireGrenade =
{
	local entity missile;
	local entity mpuff;

	self.ammo_rockets = (self.ammo_rockets - 1);
	self.currentammo = (self.ammo_rockets - 1);
	sound(self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);
	self.punchangle_x = -2;
	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
	makevectors(self.v_angle);
	if (self.v_angle_x)
	{
		missile.velocity = ((((v_forward * 600) + (v_up * 200)) + ((crandom() * v_right) * 10)) + ((crandom() * v_up) * 10));
	}
	else
	{
		missile.velocity = aim(self, 10000);
		missile.velocity = (missile.velocity * 600);
		missile.velocity_z = 200;
	}
	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = GrenadeTouch;
	missile.nextthink = (time + 2.5);
	missile.think = GrenadeExplode;
	setmodel(missile, "progs/grenade.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, self.origin);
};
void() spike_touch;
void() superspike_touch;

void(vector org, vector dir) launch_spike =
{
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.angles = vectoangles(dir);
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = (time + TE_LIGHTNING2);
	setmodel(newmis, "progs/spike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);
	newmis.velocity = (dir * 1000);
};

void() W_FireSuperSpikes =
{
	local vector dir;
	local entity old;

	sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = (time + 0.2);
	self.ammo_nails = (self.ammo_nails - WEAPON_ROCKET);
	self.currentammo = (self.ammo_nails - WEAPON_ROCKET);
	dir = aim(self, 1000);
	launch_spike((self.origin + '0 0 16'), dir);
	newmis.touch = superspike_touch;
	setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');
	self.punchangle_x = -2;
};

void(float ox) W_FireSpikes =
{
	local vector dir;
	local entity old;

	makevectors(self.v_angle);
	if (((self.ammo_nails >= WEAPON_ROCKET) && (self.weapon == IT_SUPER_NAILGUN)))
	{
		W_FireSuperSpikes();
		return;
	}
	if ((self.ammo_nails < 1))
	{
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		return;
	}
	sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = (time + 0.2);
	self.ammo_nails = (self.ammo_nails - 1);
	self.currentammo = (self.ammo_nails - 1);
	dir = aim(self, 1000);
	launch_spike(((self.origin + '0 0 16') + (v_right * ox)), dir);
	self.punchangle_x = -2;
};
.float hit_z;

void() spike_touch =
{
	local float rand;

	if ((other == self.owner))
	{
		return;
	}
	if ((other.solid == SOLID_TRIGGER))
	{
		return;
	}
	if ((pointcontents(self.origin) == CONTENT_SKY))
	{
		remove(self);
		return;
	}
	if ((other == current_selected.enemy))
	{
		if (other.takedamage)
		{
			T_Damage(other, self, self.owner, TE_LIGHTNING3);
		}
		else
		{
			WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
			if ((self.classname == "wizspike"))
			{
				WriteByte(MSG_BROADCAST, TE_WIZSPIKE);
			}
			else
			{
				if ((self.classname == "knightspike"))
				{
					WriteByte(MSG_BROADCAST, TE_KNIGHTSPIKE);
				}
				else
				{
					WriteByte(MSG_BROADCAST, TE_SPIKE);
				}
			}
			WriteCoord(MSG_BROADCAST, self.origin_x);
			WriteCoord(MSG_BROADCAST, self.origin_y);
			WriteCoord(MSG_BROADCAST, self.origin_z);
		}
	}
	remove(self);
};

void() superspike_touch =
{
	local float rand;

	if ((other == self.owner))
	{
		return;
	}
	if ((other.solid == SOLID_TRIGGER))
	{
		return;
	}
	if ((pointcontents(self.origin) == CONTENT_SKY))
	{
		remove(self);
		return;
	}
	if (other.takedamage)
	{
		spawn_touchblood(18);
		T_Damage(other, self, self.owner, 18);
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord(MSG_BROADCAST, self.origin_x);
		WriteCoord(MSG_BROADCAST, self.origin_y);
		WriteCoord(MSG_BROADCAST, self.origin_z);
	}
	remove(self);
};

void() W_SetCurrentAmmo =
{
	player_run();
	self.items = (self.items - (self.items & (((IT_SHELLS | IT_NAILS) | IT_ROCKETS) | IT_CELLS)));
};

float() W_BestWeapon =
{
	local float it;

	it = self.items;
	if (((self.ammo_cells >= 1) && (it & IT_LIGHTNING)))
	{
		return (IT_LIGHTNING);
	}
	else
	{
		if (((self.ammo_nails >= WEAPON_ROCKET) && (it & IT_SUPER_NAILGUN)))
		{
			return (IT_SUPER_NAILGUN);
		}
		else
		{
			if (((self.ammo_shells >= WEAPON_ROCKET) && (it & IT_SUPER_SHOTGUN)))
			{
				return (IT_SUPER_SHOTGUN);
			}
			else
			{
				if (((self.ammo_nails >= 1) && (it & IT_NAILGUN)))
				{
					return (IT_NAILGUN);
				}
				else
				{
					if (((self.ammo_shells >= 1) && (it & IT_SHOTGUN)))
					{
						return (IT_SHOTGUN);
					}
				}
			}
		}
	}
	return (IT_AXE);
};

float() W_CheckNoAmmo =
{
	if ((self.currentammo > MSG_BROADCAST))
	{
		return (TRUE);
	}
	if ((self.weapon == IT_AXE))
	{
		return (TRUE);
	}
	self.weapon = W_BestWeapon();
	W_SetCurrentAmmo();
	return (FALSE);
};
void() player_axe1;
void() player_axeb1;
void() player_axec1;
void() player_axed1;
void() player_shot1;
void() player_nail1;
void() player_light1;
void() player_rocket1;

void() W_Attack =
{
	local float r;
	local vector dest_org;

	if (!W_CheckNoAmmo())
	{
		return;
	}
	return;
	makevectors(self.v_angle);
	self.show_hostile = (time + 1);
	if ((self.weapon == IT_AXE))
	{
		sound(self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		r = random();
		if ((r < 0.25))
		{
			player_axe1();
		}
		else
		{
			if ((r < 0.5))
			{
				player_axeb1();
			}
			else
			{
				if ((r < 0.75))
				{
					player_axec1();
				}
				else
				{
					player_axed1();
				}
			}
		}
		self.attack_finished = (time + 0.5);
	}
	else
	{
		if ((self.weapon == IT_SHOTGUN))
		{
			player_shot1();
			W_FireShotgun();
			self.attack_finished = (time + 0.5);
		}
		else
		{
			if ((self.weapon == IT_SUPER_SHOTGUN))
			{
				player_shot1();
				W_FireSuperShotgun();
				self.attack_finished = (time + 0.7);
			}
			else
			{
				if ((self.weapon == IT_NAILGUN))
				{
					player_nail1();
				}
				else
				{
					if ((self.weapon == IT_SUPER_NAILGUN))
					{
						player_nail1();
					}
					else
					{
						if ((self.weapon == IT_GRENADE_LAUNCHER))
						{
							player_rocket1();
							W_FireGrenade();
							self.attack_finished = (time + 0.6);
						}
						else
						{
							if ((self.weapon == IT_ROCKET_LAUNCHER))
							{
								player_rocket1();
								W_FireRocket();
								self.attack_finished = (time + 0.8);
							}
							else
							{
								if ((self.weapon == IT_LIGHTNING))
								{
									player_light1();
									self.attack_finished = (time + 0.1);
									sound(self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
								}
							}
						}
					}
				}
			}
		}
	}
};

void() W_ChangeWeapon =
{
	local float it;
	local float am;
	local float fl;

	it = self.items;
	am = MSG_BROADCAST;
	if ((self.impulse == 1))
	{
		fl = IT_AXE;
	}
	else
	{
		if ((self.impulse == WEAPON_ROCKET))
		{
			fl = IT_SHOTGUN;
			if ((self.ammo_shells < 1))
			{
				am = 1;
			}
		}
		else
		{
			if ((self.impulse == AS_MELEE))
			{
				fl = IT_SUPER_SHOTGUN;
				if ((self.ammo_shells < WEAPON_ROCKET))
				{
					am = 1;
				}
			}
			else
			{
				if ((self.impulse == WEAPON_SPIKES))
				{
					fl = IT_NAILGUN;
					if ((self.ammo_nails < 1))
					{
						am = 1;
					}
				}
				else
				{
					if ((self.impulse == TE_LIGHTNING1))
					{
						fl = IT_SUPER_NAILGUN;
						if ((self.ammo_nails < WEAPON_ROCKET))
						{
							am = 1;
						}
					}
					else
					{
						if ((self.impulse == TE_LIGHTNING2))
						{
							fl = IT_GRENADE_LAUNCHER;
							if ((self.ammo_rockets < 1))
							{
								am = 1;
							}
						}
						else
						{
							if ((self.impulse == TE_WIZSPIKE))
							{
								fl = IT_ROCKET_LAUNCHER;
								if ((self.ammo_rockets < 1))
								{
									am = 1;
								}
							}
							else
							{
								if ((self.impulse == WEAPON_BIG))
								{
									fl = IT_LIGHTNING;
									if ((self.ammo_cells < 1))
									{
										am = 1;
									}
								}
							}
						}
					}
				}
			}
		}
	}
	self.impulse = MSG_BROADCAST;
	if (!(self.items & fl))
	{
		sprint(self, "no weapon.\n");
		return;
	}
	if (am)
	{
		sprint(self, "not enough ammo.\n");
		return;
	}
	self.weapon = fl;
	W_SetCurrentAmmo();
};

void() CheatCommand =
{
	if ((deathmatch || coop))
	{
		return;
	}
	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 100;
	self.items = (((((((((self.items | IT_AXE) | IT_SHOTGUN) | IT_SUPER_SHOTGUN) | IT_NAILGUN) | IT_SUPER_NAILGUN) | IT_GRENADE_LAUNCHER) | IT_ROCKET_LAUNCHER) | IT_KEY1) | IT_KEY2);
	self.ammo_cells = 200;
	self.items = (self.items | IT_LIGHTNING);
	self.weapon = IT_ROCKET_LAUNCHER;
	self.impulse = MSG_BROADCAST;
	W_SetCurrentAmmo();
};

void() CycleWeaponCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = MSG_BROADCAST;
	while (1)
	{
		am = MSG_BROADCAST;
		if ((self.weapon == IT_LIGHTNING))
		{
			self.weapon = IT_AXE;
		}
		else
		{
			if ((self.weapon == IT_AXE))
			{
				self.weapon = IT_SHOTGUN;
				if ((self.ammo_shells < 1))
				{
					am = 1;
				}
			}
			else
			{
				if ((self.weapon == IT_SHOTGUN))
				{
					self.weapon = IT_SUPER_SHOTGUN;
					if ((self.ammo_shells < WEAPON_ROCKET))
					{
						am = 1;
					}
				}
				else
				{
					if ((self.weapon == IT_SUPER_SHOTGUN))
					{
						self.weapon = IT_NAILGUN;
						if ((self.ammo_nails < 1))
						{
							am = 1;
						}
					}
					else
					{
						if ((self.weapon == IT_NAILGUN))
						{
							self.weapon = IT_SUPER_NAILGUN;
							if ((self.ammo_nails < WEAPON_ROCKET))
							{
								am = 1;
							}
						}
						else
						{
							if ((self.weapon == IT_SUPER_NAILGUN))
							{
								self.weapon = IT_GRENADE_LAUNCHER;
								if ((self.ammo_rockets < 1))
								{
									am = 1;
								}
							}
							else
							{
								if ((self.weapon == IT_GRENADE_LAUNCHER))
								{
									self.weapon = IT_ROCKET_LAUNCHER;
									if ((self.ammo_rockets < 1))
									{
										am = 1;
									}
								}
								else
								{
									if ((self.weapon == IT_ROCKET_LAUNCHER))
									{
										self.weapon = IT_LIGHTNING;
										if ((self.ammo_cells < 1))
										{
											am = 1;
										}
									}
								}
							}
						}
					}
				}
			}
		}
		if (((it & self.weapon) && (am == MSG_BROADCAST)))
		{
			W_SetCurrentAmmo();
			return;
		}
	}
};

void() CycleWeaponReverseCommand =
{
	local float it;
	local float am;

	it = self.items;
	self.impulse = MSG_BROADCAST;
	while (1)
	{
		am = MSG_BROADCAST;
		if ((self.weapon == IT_LIGHTNING))
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if ((self.ammo_rockets < 1))
			{
				am = 1;
			}
		}
		else
		{
			if ((self.weapon == IT_ROCKET_LAUNCHER))
			{
				self.weapon = IT_GRENADE_LAUNCHER;
				if ((self.ammo_rockets < 1))
				{
					am = 1;
				}
			}
			else
			{
				if ((self.weapon == IT_GRENADE_LAUNCHER))
				{
					self.weapon = IT_SUPER_NAILGUN;
					if ((self.ammo_nails < WEAPON_ROCKET))
					{
						am = 1;
					}
				}
				else
				{
					if ((self.weapon == IT_SUPER_NAILGUN))
					{
						self.weapon = IT_NAILGUN;
						if ((self.ammo_nails < 1))
						{
							am = 1;
						}
					}
					else
					{
						if ((self.weapon == IT_NAILGUN))
						{
							self.weapon = IT_SUPER_SHOTGUN;
							if ((self.ammo_shells < WEAPON_ROCKET))
							{
								am = 1;
							}
						}
						else
						{
							if ((self.weapon == IT_SUPER_SHOTGUN))
							{
								self.weapon = IT_SHOTGUN;
								if ((self.ammo_shells < 1))
								{
									am = 1;
								}
							}
							else
							{
								if ((self.weapon == IT_SHOTGUN))
								{
									self.weapon = IT_AXE;
								}
								else
								{
									if ((self.weapon == IT_AXE))
									{
										self.weapon = IT_LIGHTNING;
										if ((self.ammo_cells < 1))
										{
											am = 1;
										}
									}
								}
							}
						}
					}
				}
			}
		}
		if (((it & self.weapon) && (am == MSG_BROADCAST)))
		{
			W_SetCurrentAmmo();
			return;
		}
	}
};

void() ServerflagsCommand =
{
	serverflags = ((serverflags * WEAPON_ROCKET) + 1);
};

void() QuadCheat =
{
	if ((deathmatch || coop))
	{
		return;
	}
	self.super_time = 1;
	self.super_damage_finished = (time + SVC_INTERMISSION);
	self.items = (self.items | IT_QUAD);
	dprint("quad cheat\n");
};

void() ImpulseCommands =
{
	local entity checklight;

	if (self.menu_screen)
	{
		Menu_Select(self.impulse);
		self.impulse = MSG_BROADCAST;
		return;
	}
	if ((self.impulse == 242))
	{
		Menu_Open(MENU_SCREEN_PAUSE);
		self.impulse = MSG_BROADCAST;
		return;
	}
	if ((self.impulse == 200))
	{
		Menu_Open(MENU_SCREEN_HELP);
		self.impulse = MSG_BROADCAST;
		return;
	}
	if (((self.impulse >= 1) && (self.impulse <= WEAPON_BIG)))
	{
		DoMarker(self.impulse);
	}
	else
	{
		if ((self.impulse == SVC_FINALE))
		{
			AddMarker();
		}
	}
	if ((self.impulse == 50))
	{
		if (!(self.flags & FL_FLY))
		{
			self.movetype = MOVETYPE_FLY;
			self.solid = SOLID_NOT;
			self.flags = (self.flags | FL_FLY);
			self.flags = (self.flags | FL_GODMODE);
			self.flags = (self.flags | FL_SWIM);
		}
		else
		{
			self.movetype = MOVETYPE_WALK;
			self.solid = SOLID_NOT;
			self.flags = (self.flags - (self.flags & FL_FLY));
			self.flags = (self.flags - (self.flags & FL_GODMODE));
		}
	}
	if ((self.impulse == 241))
	{
		ShowBoard();
	}
	if ((self.spectator != TRUE))
	{
		if (((((game_checkers && !gameover) && (current_turn != world)) && current_turn.is_bot) && (((self.impulse == 20) || (self.impulse == 60)) || (self.impulse == 100))))
		{
			centerprint(self, "Computer is thinking\n");
			self.impulse = MSG_BROADCAST;
			return;
		}
		if ((self.impulse == 20))
		{
			if ((!single_player && (self != current_turn)))
			{
				self.impulse = MSG_BROADCAST;
				return;
			}
			if ((Queening == 1))
			{
				if ((QueenTo == "chess_queen"))
				{
					QueenTo = "chess_rook";
					centerprint(self, "Promoting to: Rook\n");
				}
				else
				{
					if ((QueenTo == "chess_rook"))
					{
						QueenTo = "chess_knight";
						centerprint(self, "Promoting to: Knight\n");
					}
					else
					{
						if ((QueenTo == "chess_knight"))
						{
							QueenTo = "chess_bishop";
							centerprint(self, "Promoting to: Bishop\n");
						}
						else
						{
							if ((QueenTo == "chess_bishop"))
							{
								QueenTo = "chess_queen";
								centerprint(self, "Promoting to: Queen\n");
							}
						}
					}
				}
				self.impulse = MSG_BROADCAST;
				return;
			}
			if ((game_checkers && checkers_must_jump))
			{
				centerprint(self, "You must finish the jump\n");
				self.impulse = MSG_BROADCAST;
				return;
			}
			if ((current_turn.chess_flags & CF_SELECTED_PIECE))
			{
				current_turn.chess_flags = (current_turn.chess_flags - CF_SELECTED_PIECE);
				ClearSelectionEffect();
				mystuffcmd(self, "play effects/button.wav\n");
				mysprint(self, "Selection cleared\n");
				FindLocation();
				checklight = EntityAtLoc(current_dest_int);
				if (((last_highlight != world) && (checklight.owner != current_turn)))
				{
					setorigin(last_highlight, last_highlight.pos2);
					last_highlight.pos2 = last_highlight.pos1;
					last_highlight.pos1 = last_highlight.origin;
					last_highlight = world;
				}
				if (((checklight.owner == current_turn) && (checklight != current_selected)))
				{
					HighlightLocation(current_dest_int);
					current_selected = checklight;
				}
				else
				{
					current_selected = world;
				}
			}
		}
		else
		{
			if ((self.impulse == 60))
			{
				if ((!single_player && (current_turn != self)))
				{
					return;
				}
				if (!action_flag)
				{
					if (game_checkers)
					{
						if (checkers_must_jump)
						{
							mycentreprint(current_turn, "You must finish the jump");
						}
						else
						{
							mycentreprint(current_turn, "You must move");
						}
						self.impulse = MSG_BROADCAST;
						return;
					}
					mycentreprint(current_turn, "Turn passed\n");
					next_turn();
				}
			}
			else
			{
				if ((self.impulse == 100))
				{
					if ((Queening == 1))
					{
						MakeQueen();
					}
					else
					{
						ProcessSelection();
					}
				}
				else
				{
					if ((self.impulse == 199))
					{
						centerprint(self, self.last_message);
					}
				}
			}
		}
	}
	if ((self.impulse == 200))
	{
		sprint(self, "\nW         Toggle Mouse\n");
		sprint(self, "C         Toggle camera\n");
		sprint(self, "M         Place camera marker\n");
		sprint(self, "1-8       Go to camera marker\n");
		sprint(self, "F1        Display board in text\n");
		if (!self.spectator)
		{
			sprint(self, "R         Show last message\n");
			if (game_checkers)
			{
				sprint(self, "P         Pass disabled in checkers\n");
			}
			else
			{
				sprint(self, "P         Pass turn\n");
			}
			sprint(self, "Del       Unselect lighted piece\n");
		}
	}
	self.impulse = MSG_BROADCAST;
};

void() W_WeaponFrame =
{
	local float time_left;

	if (((self.menu_screen || (self.impulse == 242)) || (self.impulse == 200)))
	{
		if ((self.impulse > MSG_BROADCAST))
		{
			ImpulseCommands();
		}
		Menu_Render();
		return;
	}
	if (((time_per_turn > MSG_BROADCAST) && (current_turn != world)))
	{
		time_left = ceil((time_per_turn - (time - current_turn.turn_starttime)));
		if ((self.armorvalue != time_left))
		{
			self.armorvalue = time_left;
		}
	}
	else
	{
		if ((self.armorvalue != MSG_BROADCAST))
		{
			self.armorvalue = MSG_BROADCAST;
		}
	}
	if ((time < self.attack_finished))
	{
		return;
	}
	if ((self.impulse > MSG_BROADCAST))
	{
		ImpulseCommands();
	}
	if (self.button0)
	{
		SuperDamageSound();
		W_Attack();
	}
};

void() SuperDamageSound =
{
	if ((self.super_damage_finished > time))
	{
		if ((self.super_sound < time))
		{
			self.super_sound = (time + 1);
			sound(self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};

void() SDR_SightThink =
{
	local vector org;

	makevectors(self.owner.v_angle);
	org = (self.owner.origin + (v_forward * CF_TIME_NOTIFY));
	traceline(org, (org + (v_forward * 4048)), (current_selected != world), world);
	if ((trace_fraction == 1))
	{
		setmodel(self, "");
		return;
	}
	if (trace_ent.takedamage)
	{
		self.scale = 0.75;
	}
	else
	{
		self.scale = 0.5;
	}
	setmodel(self, "progs/s_light.spr");
	self.angles = vectoangles(v_forward);
	setorigin(self, trace_endpos);
	self.nextthink = (time + 0.05);
};

void() SDR_SightMake =
{
	local entity cross;

	self.sight_out = TRUE;
	cross = spawn();
	cross.owner = self;
	cross.movetype = MOVETYPE_NOCLIP;
	cross.solid = SOLID_NOT;
	setmodel(cross, "progs/s_bubble.spr");
	cross.classname = "laser_sight";
	setorigin(cross, self.origin);
	cross.think = SDR_SightThink;
	cross.nextthink = (time + 0.05);
};

void() LaserTargeterTrack =
{
	local vector dir;
	local vector src;

	makevectors(self.owner.v_angle);
	src = self.owner.origin;
	dir = v_forward;
	traceline(src, (src + (dir * 4048)), (current_selected != world), self);
	src = ((0.1 * src) + (0.9 * trace_endpos));
	setorigin(self, src);
	self.nextthink = (time + 0.1);
};

void(entity targ_owner) LaserTargeterToggle =
{
	local entity e;

	targ_owner.speed = (targ_owner.speed | LASERTARG_ON);
	e = spawn();
	e.owner = targ_owner;
	e.movetype = MOVETYPE_NONE;
	e.solid = SOLID_NOT;
	setmodel(e, "progs/s_light.spr");
	e.scale = 0.5;
	setsize(e, '0 0 0', '0 0 0');
	setorigin(e, e.owner.origin);
	targ_owner.pointer = e;
	e.nextthink = (time + 0.1);
	e.think = LaserTargeterTrack;
};

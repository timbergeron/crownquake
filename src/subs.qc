//Decompiled code. Please respect the original copyright.
void(vector tdest, float tspeed, void() func) SUB_CalcMove;
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt;
void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void() SUB_CalcMoveDone;
void() SUB_CalcAngleMoveDone;
void() SUB_UseTargets;
void() SUB_Remove;
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
float(entity e, float healamount, float ignore) T_Heal;
float(entity targ, entity inflictor) CanDamage;
entity LastMoved;
float LastMovedLocation;
float EntAtLocRunning;
.string ral_loc_str;
float movenum;
vector gborg;
void() GrabMe;
entity GetBody;
void(entity ent, string cmd) mysprint;
void() MakeQueen;
void() Q_Queen;
void() Q_Rook;
void() Q_Bishop;
void() Q_Knight;
void() Q_Stuff;
string QueenTo;
float Queening;
entity QueenEnt;
void() ShowBoard;
void() UndoResetStack;
void() UndoPushSnapshot;
void() UndoMove;
float() UndoAvailable;
float() UndoModeAllowed;
void() AddMarker;
void(float m_num) DoMarker;
.vector marker1;
.float marker1_x;
.float marker1_y;
.float marker1_z;
.vector marker2;
.float marker2_x;
.float marker2_y;
.float marker2_z;
.vector marker3;
.float marker3_x;
.float marker3_y;
.float marker3_z;
.vector marker4;
.float marker4_x;
.float marker4_y;
.float marker4_z;
.vector marker5;
.float marker5_x;
.float marker5_y;
.float marker5_z;
.vector marker6;
.float marker6_x;
.float marker6_y;
.float marker6_z;
.vector marker7;
.float marker7_x;
.float marker7_y;
.float marker7_z;
.vector marker8;
.float marker8_x;
.float marker8_y;
.float marker8_z;
.vector marker1a;
.float marker1a_x;
.float marker1a_y;
.float marker1a_z;
.vector marker2a;
.float marker2a_x;
.float marker2a_y;
.float marker2a_z;
.vector marker3a;
.float marker3a_x;
.float marker3a_y;
.float marker3a_z;
.vector marker4a;
.float marker4a_x;
.float marker4a_y;
.float marker4a_z;
.vector marker5a;
.float marker5a_x;
.float marker5a_y;
.float marker5a_z;
.vector marker6a;
.float marker6a_x;
.float marker6a_y;
.float marker6a_z;
.vector marker7a;
.float marker7a_x;
.float marker7a_y;
.float marker7a_z;
.vector marker8a;
.float marker8a_x;
.float marker8a_y;
.float marker8a_z;
.float lastmarked;
float ralcheckmate;
.float hasmoved;
.float spectator;
entity current_turn;
float action_flag;
entity current_selected;
entity current_enemy;
string current_destination;
float current_dest_int;
entity current_brush;
entity player1;
entity player2;
entity message_entity;
string message_text;
entity message_target;
entity castle_to_move;
float castle_destination;
float king_castle_move_flag;
float king_dead;
entity last_highlight;
float time_per_turn;
entity pawning_enemy;
entity ignore_canmove;
float secret_monsters;
float single_player;
entity light_ent;
entity selection_effect_piece;
entity move_hint_list;
entity move_hint_piece;
.entity move_hint_next;
entity dest_ent;
float en_passant_flag;
float game_checkers;
float checkers_board_spawned;
float checkers_must_jump;
float checkers_was_jump;
float checkers_invalid_notified;
entity checkers_capture_entity;
float checkers_capture_location;
entity checkers_bot_thinker;
entity checkers_bot_side;
entity checkers_bot_best_piece;
float checkers_bot_best_dest;
float checkers_bot_best_score;
float checkers_bot_search_depth;
float checkers_bot_work;
float checkers_bot_work_limit;
float checkers_bot_abort;
entity chess_file1;
entity chess_file2;
entity chess_file3;
entity chess_file4;
entity chess_file5;
entity chess_file6;
entity chess_file7;
entity chess_file8;
entity chess_bot_thinker;
entity chess_bot_side;
entity chess_bot_root_piece;
entity chess_bot_best_piece;
entity chess_bot_completed_piece;
float chess_bot_root_candidate;
float chess_bot_root_promotion;
float chess_bot_root_legal;
float chess_bot_root_pass;
float chess_bot_root_alpha;
float chess_bot_best_dest;
float chess_bot_best_promotion;
float chess_bot_best_score;
float chess_bot_completed_dest;
float chess_bot_completed_promotion;
float chess_bot_completed_score;
float chess_bot_iteration_depth;
float chess_bot_completed_depth;
float chess_bot_target_depth;
float chess_bot_nodes;
float chess_bot_work;
float chess_bot_work_limit;
float chess_bot_abort;
float chess_bot_searching;
float chess_bot_pending_promotion;
float chess_bot_checksum_before;
float chess_bot_player1_count_before;
float chess_bot_player2_count_before;
float chess_bot_player1_material_before;
float chess_bot_player2_material_before;
float chess_bot_en_passant_before;
float chess_bot_castle_flag_before;
entity chess_bot_castle_rook_before;
entity chess_bot_pawning_before;
float chess_bot_occupancy_before;
entity chess_bot_player1_last_before;
entity chess_bot_player2_last_before;
float chess_bot_player1_from_before;
float chess_bot_player1_to_before;
float chess_bot_player2_from_before;
float chess_bot_player2_to_before;
entity chess_bot_selected_before;
float chess_bot_dest_before;
entity chess_bot_ignore_before;
float chess_bot_castle_dest_before;
// Deferred "Computer thinking" notice: only announced if the computer is still on
// the clock past BOT_THINK_ANNOUNCE_DELAY, so quick replies stay silent.
float BOT_THINK_ANNOUNCE_DELAY = 3;
float bot_think_deadline;
float bot_think_announced;
entity chess_perft_thinker;
entity chess_perft_side;
entity chess_perft_root_piece;
float chess_perft_root_candidate;
float chess_perft_root_promotion;
float chess_perft_depth;
float chess_perft_total;
float chess_perft_running;
float chess_perft_expected;
float chess_perft_abort;
float chess_perft_work_limit;
float chess_perft_action_before;
float chess_perft_start_time;
float chess_perft_root_applied;
float chess_perft_root_to;
float chess_perft_root_move_promotion;
float chess_perft_root_old_loc;
float chess_perft_root_old_hasmoved;
string chess_perft_root_old_classname;
entity chess_perft_root_captured;
float chess_perft_root_captured_loc;
float chess_perft_root_captured_health;
float chess_perft_root_captured_ischecker;
entity chess_perft_root_rook;
float chess_perft_root_rook_loc;
float chess_perft_root_rook_hasmoved;
float chess_perft_root_rook_dest;
entity chess_perft_root_old_last_moved;
float chess_perft_root_old_last_from;
float chess_perft_root_old_last_to;
entity chess_perft_reply_piece;
float chess_perft_reply_candidate;
float chess_perft_reply_promotion;
float MENU_SCREEN_NONE;
float MENU_SCREEN_PAUSE = 1;
float MENU_SCREEN_HELP = 2;
float MENU_SCREEN_GAMEOVER = 3;
float MENU_SCREEN_NEWGAME = 4;
float MENU_SCREEN_GAMETYPE = 5;
float MENU_SCREEN_SIDE = 6;
float MENU_SCREEN_BOTLEVEL = 7;
float MENU_SCREEN_MAP = 8;
float menu_startup_shown;
float menu_startup_pending;
float menu_selected_checkers;
float menu_selected_bot_side;
.float chess_flags;
.string chess_team;
.float location;
.string location_str;
.float ischecker;
.float isking;
.float is_bot;
.float last_move_from;
.float last_move_to;
.entity occ1;
.entity occ2;
.entity occ3;
.entity occ4;
.entity occ5;
.entity occ6;
.entity occ7;
.entity occ8;
.float scale;
.float last_voice;
.entity last_voice_entity;
.float menu_screen;
.float menu_cursor;
.float menu_refresh;
.float menu_open_time;
.float menu_accept_time;
.float menu_return_screen;
.entity menu_winner;
.entity opponent;
.vector last_vel;
.float last_vel_x;
.float last_vel_y;
.float last_vel_z;
.vector orig_angle;
.float orig_angle_x;
.float orig_angle_y;
.float orig_angle_z;
.entity attack_missile;
.float last_color;
.float turn_starttime;
.string last_message;
.entity pointer;
.entity last_moved;
.vector movement;
.float movement_x;
.float movement_y;
.float movement_z;
float CF_SELECTED_PIECE    = 4;
float CF_HAS_MOVED    = 8;
float CF_CHECK_NOTIFY    = 16;
float CF_TIME_NOTIFY    = 32;
float LASERTARG_ON    = 1;
float SVC_SETVIEWANGLES    = 10;
float() TwoPlayersInGame;
void() FindSelection;
void(entity plyr) AllocateMonsters;
float() ComputerVsComputerGame;
void() FindLocation;
float(entity ent, float loc, entity at_loc, float actual_move) CheckValidMove;
float(entity ent, float loc, float actual_move) CanMove;
float(float loc) GetX;
float(float loc) GetY;
void() ProcessSelection;
void() ClearMoveHints;
void(entity piece) ShowMoveHints;
void() ClearSelectionEffect;
void(entity piece) ShowSelectionEffect;
void(entity client) WalkToDest;
void(vector org, vector vel, float damage) SpawnBlood;
entity(float loc) EntityAtLoc;
void() message_think;
void() welcome_mesg;
void() become_queen;
void(vector org) spawn_tfog;
vector(float loc) LocationToVector;
void() next_turn;
entity(entity monst) FindNewEnemy;
void(float loc) HighlightLocation;
void() CheckGameOver;
void() CheckersFinishMove;
void() CheckersClearTurnState;
void() SpawnCheckersBoard;
void() SpawnChessBoard;
void(float use_checkers) ResetGameToMode;
void() CheckersApplyBotCvars;
void() CheckersMaybeScheduleBotTurn;
void() CheckersCancelBotSearch;
void() ChessMaybeScheduleBotTurn;
void() ChessCancelBotSearch;
void() ChessBotPromotePawn;
void() ChessBotResetRepetition;
void(entity side) ChessBotRecordPosition;
void() ChessRebuildOccupancy;
entity(float loc) ChessOccupantAt;
entity(entity piece, float to_loc) ChessCapturedForMove;
float(entity side) ChessInCheck;
float(entity side) ChessHasLegalMove;
float(entity piece) ChessPieceHasLegalMove;
float(entity piece, float to_loc, float promotion) ChessMoveIsLegal;
float(entity piece) ChessCandidateCount;
float(entity piece, float candidate) ChessCandidateLocation;
void(entity piece, float to_loc) ChessExplainInvalidMove;
float(entity piece, float candidate, float to_loc) ChessCandidateEndsRay;
void(entity side_to_move, entity winner) ChessFinishNoLegalMoves;
void(entity requester) ChessPerftStart;
void() ChessPerftCancel;
float(entity ent) CheckersPieceCanJump;
float(entity ent, float loc) CheckersBotMoveIsJump;
float(entity side, entity forced_piece, entity piece, float loc) CheckersBotMoveAllowed;
float(entity side_owner) CheckersAnyCaptureAvailable;
float(entity side_owner) CheckersSideHasLegalMove;
void() CheckCheckersGameOver;
void(entity plyr) UpdateMonsterColors;
float(entity ent, entity ignore) CanDie;
entity(entity own) get_king;
void(entity ent, string msg) mycentreprint;
void(entity ent, string cmd) mystuffcmd;
void(float screen) Menu_Open;
void() Menu_Close;
void(float imp) Menu_Select;
float() Menu_Render;
void(entity winner) Menu_OpenGameOver;
void(entity loser) Menu_ResignSide;
void() Menu_OpenStartupModeSelect;
void(float use_checkers) Menu_StartNewGame;
float() Menu_ResumeRestartSelection;
void(entity client) Menu_EnablePregameFlyBinds;
void() Menu_RestoreGameBindsAll;
void() ClearLastHighlight;

void() SUB_Null =
{
};

void() SUB_Remove =
{
	remove(self);
};

void() SetMovedir =
{
	if ((self.angles == '0 -1 0'))
	{
		self.movedir = '0 0 1';
	}
	else
	{
		if ((self.angles == '0 -2 0'))
		{
			self.movedir = '0 0 -1';
		}
		else
		{
			makevectors(self.angles);
			self.movedir = v_forward;
		}
	}
	self.angles = '0 0 0';
};

void() InitTrigger =
{
	if ((self.angles != '0 0 0'))
	{
		SetMovedir();
	}
	self.solid = SOLID_TRIGGER;
	setmodel(self, self.model);
	self.movetype = MOVETYPE_NONE;
	self.modelindex = MSG_BROADCAST;
	self.model = "";
};

void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt =
{
	local entity stemp;

	stemp = self;
	self = ent;
	SUB_CalcMove(tdest, tspeed, func);
	self = stemp;
};

void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
	local vector vdestdelta;
	local float len;
	local float traveltime;

	if (!tspeed)
	{
		objerror("No speed is defined!");
	}
	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;
	if ((tdest == self.origin))
	{
		self.velocity = '0 0 0';
		self.nextthink = (self.ltime + 0.1);
		return;
	}
	vdestdelta = (tdest - self.origin);
	len = vlen(vdestdelta);
	traveltime = (len / tspeed);
	if ((traveltime < 0.1))
	{
		self.velocity = '0 0 0';
		self.nextthink = (self.ltime + 0.1);
		return;
	}
	self.nextthink = (self.ltime + traveltime);
	self.velocity = (vdestdelta * (LASERTARG_ON / traveltime));
};

void() SUB_CalcMoveDone =
{
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = CONTENT_EMPTY;
	if (self.think1)
	{
		self.think1();
	}
};

void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt =
{
	local entity stemp;

	stemp = self;
	self = ent;
	SUB_CalcAngleMove(destangle, tspeed, func);
	self = stemp;
};

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove =
{
	local vector destdelta;
	local float len;
	local float traveltime;

	if (!tspeed)
	{
		objerror("No speed is defined!");
	}
	destdelta = (destangle - self.angles);
	len = vlen(destdelta);
	traveltime = (len / tspeed);
	self.nextthink = (self.ltime + traveltime);
	self.avelocity = (destdelta * (LASERTARG_ON / traveltime));
	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;
};

void() SUB_CalcAngleMoveDone =
{
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.nextthink = CONTENT_EMPTY;
	if (self.think1)
	{
		self.think1();
	}
};

void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets();
	remove(self);
};

void() SUB_UseTargets =
{
	local entity t;
	local entity stemp;
	local entity otemp;
	local entity act;

	if (self.delay)
	{
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = (time + self.delay);
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		return;
	}
	if (((activator.classname == "player") && (self.message != "")))
	{
		centerprint(activator, self.message);
		if (!self.noise)
		{
			sound(activator, CHAN_VOICE, "misc/talk.wav", LASERTARG_ON, ATTN_NORM);
		}
	}
	if (self.killtarget)
	{
		t = world;
		do
		{
			t = find(t, targetname, self.killtarget);
			if (!t)
			{
				return;
			}
			remove(t);

		} while (LASERTARG_ON);
	}
	if (self.target)
	{
		act = activator;
		t = world;
		do
		{
			t = find(t, targetname, self.target);
			if (!t)
			{
				return;
			}
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if ((self.use != SUB_Null))
			{
				if (self.use)
				{
					self.use();
				}
			}
			self = stemp;
			other = otemp;
			activator = act;

		} while (LASERTARG_ON);
	}
};

void(float normal) SUB_AttackFinished =
{
	self.cnt = MSG_BROADCAST;
	if ((skill != AS_MELEE))
	{
		self.attack_finished = (time + normal);
	}
};
float(entity targ) visible;

void(void() thinkst) SUB_CheckRefire =
{
	if ((skill != AS_MELEE))
	{
		return;
	}
	if ((self.cnt == LASERTARG_ON))
	{
		return;
	}
	if (!visible(self.enemy))
	{
		return;
	}
	self.cnt = LASERTARG_ON;
	self.think = thinkst;
};

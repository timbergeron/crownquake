// Multi-level move undo / takeback.
//
// Approach: snapshot-and-rebuild. Before each turn a compact snapshot of the
// whole board position is pushed onto a stack. Undo tears the live board down
// (RemoveChessTeamPieces) and rebuilds it from a snapshot with the same spawn
// helpers the game uses at setup (SpawnChessPiece / SpawnCheckerMan). This
// avoids reviving monster corpses, reversing promotion/castling/en passant, or
// touching the live combat path. See src/undo.qc plan for details.
//
// Undo is offered only in single-player vs the computer and in local hotseat
// (human vs human); computer-vs-computer and spectators are excluded.

float UNDO_MAX = 12;         // plies of history retained; must match array sizes
float undo_count;            // snapshots currently on the stack

float undo_board[768];       // UNDO_MAX * 64: per-square encoded descriptor
float undo_side[12];         // side to move: 1 = white, 2 = black
float undo_movenum[12];
float undo_flags[12];        // bit0 gameover, bit1 king_dead, bit2 ralcheckmate
float undo_wfrags[12];       // white side .frags (capture count)
float undo_bfrags[12];       // black side .frags
float undo_epfrom[12];       // last mover's last_move_from (en-passant rights)
float undo_epto[12];         // last mover's last_move_to
float undo_checkers_no_progress[12];

// Multiplayer takeback request (hotseat human-vs-human): a player asks and the
// opponent must confirm, KTX-vote style. Unused in single-player vs the computer.
float UNDO_VOTE_TIMEOUT = 45;   // seconds a request stays open
entity undo_vote_by;            // side entity that requested, or world if none
float undo_vote_time;           // time() the request was made

void() UndoClearVote =
{
	undo_vote_by = world;
	undo_vote_time = MSG_BROADCAST;
};

void() UndoResetStack =
{
	undo_count = MSG_BROADCAST;
	UndoClearVote();
};

// A live, on-board piece in either mode (chess piece or checkers man).
float(entity piece) UndoPieceLive =
{
	if ((piece == world))
		return (FALSE);
	if ((piece.health <= MSG_BROADCAST))
		return (FALSE);
	if (!(piece.flags & FL_MONSTER))
		return (FALSE);
	if (!ChessLocOnBoard(piece.location))
		return (FALSE);
	return (TRUE);
};

string(float piece_type) UndoClassForType =
{
	if ((piece_type == CHESS_KNIGHT))
		return ("chess_knight");
	if ((piece_type == CHESS_BISHOP))
		return ("chess_bishop");
	if ((piece_type == CHESS_ROOK))
		return ("chess_rook");
	if ((piece_type == CHESS_QUEEN))
		return ("chess_queen");
	if ((piece_type == CHESS_KING))
		return ("chess_king");
	return ("chess_pawn");
};

// The two side entities are current_turn and its opponent.
entity(string team) UndoSideEntity =
{
	if ((current_turn == world))
		return (world);
	if ((current_turn.chess_team == team))
		return (current_turn);
	if (((current_turn.opponent != world) && (current_turn.opponent.chess_team == team)))
		return (current_turn.opponent);
	return (world);
};

entity(float side) UndoPlayerForSide =
{
	if ((side == 1))
		return (UndoSideEntity("white"));
	return (UndoSideEntity("black"));
};

void(float base) UndoEncodeBoard =
{
	local entity piece;
	local float piece_type;
	local float mag;
	local float idx;
	local float i;

	i = MSG_BROADCAST;
	while ((i < 64))
	{
		undo_board[(base + i)] = MSG_BROADCAST;
		i = (i + 1);
	}
	piece = find(world, chess_team, "white");
	while ((piece != world))
	{
		if (UndoPieceLive(piece))
		{
			idx = (((GetX(piece.location) - 1) * 8) + (GetY(piece.location) - 1));
			if (game_checkers)
				piece_type = 1;
			else
				piece_type = ChessPieceType(piece);
			mag = ((piece_type + (10 * piece.hasmoved)) + (20 * piece.isking));
			undo_board[(base + idx)] = mag;
		}
		piece = find(piece, chess_team, "white");
	}
	piece = find(world, chess_team, "black");
	while ((piece != world))
	{
		if (UndoPieceLive(piece))
		{
			idx = (((GetX(piece.location) - 1) * 8) + (GetY(piece.location) - 1));
			if (game_checkers)
				piece_type = 1;
			else
				piece_type = ChessPieceType(piece);
			mag = ((piece_type + (10 * piece.hasmoved)) + (20 * piece.isking));
			undo_board[(base + idx)] = (MSG_BROADCAST - mag);
		}
		piece = find(piece, chess_team, "black");
	}
};

void() UndoShiftDown =
{
	local float s;
	local float i;

	s = MSG_BROADCAST;
	while ((s < (UNDO_MAX - 1)))
	{
		i = MSG_BROADCAST;
		while ((i < 64))
		{
			undo_board[((s * 64) + i)] = undo_board[(((s + 1) * 64) + i)];
			i = (i + 1);
		}
		undo_side[s] = undo_side[(s + 1)];
		undo_movenum[s] = undo_movenum[(s + 1)];
		undo_flags[s] = undo_flags[(s + 1)];
		undo_wfrags[s] = undo_wfrags[(s + 1)];
		undo_bfrags[s] = undo_bfrags[(s + 1)];
		undo_epfrom[s] = undo_epfrom[(s + 1)];
		undo_epto[s] = undo_epto[(s + 1)];
		undo_checkers_no_progress[s] = undo_checkers_no_progress[(s + 1)];
		s = (s + 1);
	}
};

void() UndoPushSnapshot =
{
	local float slot;
	local entity wside;
	local entity bside;
	local entity mover;

	UndoClearVote();
	if ((current_turn == world))
		return;
	if ((undo_count >= UNDO_MAX))
	{
		UndoShiftDown();
		slot = (UNDO_MAX - 1);
	}
	else
	{
		slot = undo_count;
	}
	UndoEncodeBoard((slot * 64));
	if ((current_turn.chess_team == "white"))
		undo_side[slot] = 1;
	else
		undo_side[slot] = 2;
	undo_movenum[slot] = movenum;
	undo_flags[slot] = ((gameover + (2 * king_dead)) + (4 * ralcheckmate));
	undo_checkers_no_progress[slot] = checkers_no_progress_plies;
	wside = UndoSideEntity("white");
	bside = UndoSideEntity("black");
	if ((wside != world))
		undo_wfrags[slot] = wside.frags;
	else
		undo_wfrags[slot] = MSG_BROADCAST;
	if ((bside != world))
		undo_bfrags[slot] = bside.frags;
	else
		undo_bfrags[slot] = MSG_BROADCAST;
	// The side that just moved is current_turn's opponent; its last move is
	// what grants en-passant rights to the side now on move.
	mover = current_turn.opponent;
	if ((mover != world))
	{
		undo_epfrom[slot] = mover.last_move_from;
		undo_epto[slot] = mover.last_move_to;
	}
	else
	{
		undo_epfrom[slot] = MSG_BROADCAST;
		undo_epto[slot] = MSG_BROADCAST;
	}
	if ((undo_count < UNDO_MAX))
		undo_count = (undo_count + 1);
};

// Undo is meaningful only with exactly one computer opponent or no computers
// (hotseat).
float() UndoModeAllowed =
{
	local float bots;

	if ((current_turn == world))
		return (FALSE);
	if ((current_turn.opponent == world))
		return (FALSE);
	bots = MSG_BROADCAST;
	if (current_turn.is_bot)
		bots = (bots + 1);
	if (current_turn.opponent.is_bot)
		bots = (bots + 1);
	return ((bots <= 1));
};

// Index of the snapshot undo would restore, or -1 if none.
float() UndoTargetSlot =
{
	local float target;
	local entity side_ent;

	if ((undo_count < 2))
		return (0 - 1);
	target = (undo_count - 2);
	side_ent = UndoPlayerForSide(undo_side[target]);
	while (((target > MSG_BROADCAST) && ((side_ent != world) && side_ent.is_bot)))
	{
		target = (target - 1);
		side_ent = UndoPlayerForSide(undo_side[target]);
	}
	side_ent = UndoPlayerForSide(undo_side[target]);
	if (((side_ent != world) && side_ent.is_bot))
		return (0 - 1);
	return (target);
};

float() UndoAvailable =
{
	if (!UndoModeAllowed())
		return (FALSE);
	return ((UndoTargetSlot() >= MSG_BROADCAST));
};

void(float slot) UndoRestore =
{
	local float base;
	local float x;
	local float y;
	local float idx;
	local float loc;
	local float code;
	local float a;
	local float piece_type;
	local float king;
	local float moved;
	local string team;
	local entity piece;
	local entity wside;
	local entity bside;
	local entity opp;

	base = (slot * 64);
	RemoveChessTeamPieces("white");
	RemoveChessTeamPieces("black");
	if ((GetBody != world))
	{
		remove(GetBody);
		GetBody = world;
	}
	x = 1;
	while ((x <= 8))
	{
		y = 1;
		while ((y <= 8))
		{
			idx = (((x - 1) * 8) + (y - 1));
			code = undo_board[(base + idx)];
			if ((code != MSG_BROADCAST))
			{
				loc = ((x * 10) + y);
				if ((code > MSG_BROADCAST))
					team = "white";
				else
					team = "black";
				a = fabs(code);
				king = FALSE;
				moved = FALSE;
				if ((a >= 20))
				{
					king = TRUE;
					a = (a - 20);
				}
				if ((a >= 10))
				{
					moved = TRUE;
					a = (a - 10);
				}
				piece_type = a;
				if (game_checkers)
					SpawnCheckerMan(team, loc);
				else
					SpawnChessPiece(team, UndoClassForType(piece_type), loc);
				piece = EntityAtLoc(loc);
				if ((piece != world))
				{
					piece.hasmoved = moved;
					if ((game_checkers && king))
					{
						piece.isking = TRUE;
						piece.netname = "king";
						if ((cvar("pr_checkextension") && checkextension("DP_EF_BLUE")))
							piece.effects = (piece.effects | EF_BLUE);
						else
							piece.effects = (piece.effects | EF_BRIGHTLIGHT);
					}
				}
			}
			y = (y + 1);
		}
		x = (x + 1);
	}
	ChessRebuildOccupancy();

	movenum = undo_movenum[slot];
	if ((undo_flags[slot] & 1))
		gameover = TRUE;
	else
		gameover = FALSE;
	if ((undo_flags[slot] & 2))
		king_dead = TRUE;
	else
		king_dead = FALSE;
	if ((undo_flags[slot] & 4))
		ralcheckmate = TRUE;
	else
		ralcheckmate = FALSE;
	action_flag = FALSE;
	Queening = MSG_BROADCAST;
	QueenEnt = world;
	QueenTo = "";
	current_enemy = world;
	current_selected = world;
	current_dest_int = MSG_BROADCAST;

	wside = UndoSideEntity("white");
	bside = UndoSideEntity("black");
	if ((wside != world))
	{
		AllocateMonsters(wside);
		wside.frags = undo_wfrags[slot];
		wside.currentammo = undo_wfrags[slot];
		wside.skin = 1;
	}
	if ((bside != world))
	{
		AllocateMonsters(bside);
		bside.frags = undo_bfrags[slot];
		bside.currentammo = undo_bfrags[slot];
		bside.skin = 1;
	}

	current_turn = UndoPlayerForSide(undo_side[slot]);
	opp = current_turn.opponent;

	// Reset last-move bookkeeping, then restore the opponent's last move so
	// en-passant legality and last-move highlighting stay correct.
	if ((wside != world))
	{
		wside.last_moved = world;
		wside.last_move_from = MSG_BROADCAST;
		wside.last_move_to = MSG_BROADCAST;
	}
	if ((bside != world))
	{
		bside.last_moved = world;
		bside.last_move_from = MSG_BROADCAST;
		bside.last_move_to = MSG_BROADCAST;
	}
	LastMoved = world;
	LastMovedLocation = MSG_BROADCAST;
	if ((opp != world))
	{
		opp.last_move_from = undo_epfrom[slot];
		opp.last_move_to = undo_epto[slot];
		if ((undo_epto[slot] != MSG_BROADCAST))
		{
			opp.last_moved = EntityAtLoc(undo_epto[slot]);
			LastMoved = opp.last_moved;
			LastMovedLocation = undo_epto[slot];
		}
	}

	current_turn.chess_flags = (current_turn.chess_flags - (current_turn.chess_flags & CF_SELECTED_PIECE));
	current_turn.chess_flags = (current_turn.chess_flags - (current_turn.chess_flags & CF_TIME_NOTIFY));
	current_turn.chess_flags = (current_turn.chess_flags - (current_turn.chess_flags & CF_CHECK_NOTIFY));
	ClearSelectionEffect();
	ClearLastHighlight();
	ClearMoveHints();
	if (!single_player)
	{
		setmodel(current_turn.pointer, "progs/s_light.spr");
		current_turn.pointer.scale = 0.5;
	}
	current_turn.turn_starttime = time;
	if (game_checkers)
	{
		CheckersResetDrawState();
		checkers_no_progress_plies = undo_checkers_no_progress[slot];
	}
	else
	{
		ChessBotResetRepetition();
		ChessBotRecordPosition(current_turn);
	}
};

// Perform the takeback (no confirmation). Assumes UndoAvailable() already held.
void() UndoExecute =
{
	local float target;

	target = UndoTargetSlot();
	if ((target < MSG_BROADCAST))
		return;
	ChessPerftCancel();
	CheckersCancelBotSearch();
	ChessCancelBotSearch();
	UndoRestore(target);
	undo_count = (target + 1);
	UndoClearVote();
	bprint("** Move undone\n");
};

// Hotseat = live multiplayer, both sides human. Only then do we require the
// opponent to confirm a takeback; vs the computer, undo is immediate.
float() UndoIsVoteMode =
{
	if (single_player)
		return (FALSE);
	if ((current_turn == world))
		return (FALSE);
	if ((current_turn.opponent == world))
		return (FALSE);
	if ((current_turn.is_bot || current_turn.opponent.is_bot))
		return (FALSE);
	return (TRUE);
};

void(entity requester) UndoNotifyOpponent =
{
	local entity opp;

	opp = requester.opponent;
	if ((opp == world))
		return;
	mysprint(opp, strcat("** ", requester.netname, " requests a takeback. Press U to accept.\n"));
};

// Request / confirm / cancel a hotseat takeback. self is the invoking player.
void() UndoVoteInvoke =
{
	// Expire a stale request.
	if (((undo_vote_by != world) && ((time - undo_vote_time) > UNDO_VOTE_TIMEOUT)))
		UndoClearVote();

	if ((undo_vote_by == world))
	{
		if (action_flag)
		{
			mysprint(self, "Finish the current move first.\n");
			return;
		}
		if (!UndoAvailable())
		{
			mysprint(self, "Nothing to undo.\n");
			return;
		}
		undo_vote_by = self;
		undo_vote_time = time;
		bprint(strcat("** ", self.netname, " requests a takeback\n"));
		UndoNotifyOpponent(self);
		mysprint(self, "Takeback requested - waiting for opponent to accept.\n");
		return;
	}
	if ((self == undo_vote_by))
	{
		bprint(strcat("** ", self.netname, " cancels the takeback request\n"));
		UndoClearVote();
		return;
	}
	// A different player answered: this is the confirmation.
	if ((action_flag && !gameover))
	{
		mysprint(self, "Finish the current move first.\n");
		return;
	}
	if (!UndoAvailable())
	{
		mysprint(self, "Nothing to undo.\n");
		UndoClearVote();
		return;
	}
	bprint(strcat("** ", self.netname, " accepts the takeback\n"));
	UndoExecute();
};

// Public entry: called from the pause menu and impulse 61. self is the caller.
void() UndoMove =
{
	if (UndoIsVoteMode())
	{
		UndoVoteInvoke();
		return;
	}
	if ((action_flag && !gameover))
	{
		mysprint(self, "Finish the current move first.\n");
		return;
	}
	if (!UndoAvailable())
	{
		mysprint(self, "Nothing to undo.\n");
		return;
	}
	UndoExecute();
};

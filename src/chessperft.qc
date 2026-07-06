// Frame-sliced chess move-generation verification.
// Run with: set chessperft 3; impulse 243

float(float loc, string team_name, float piece_type) ChessPerftSquareIs =
{
	local entity piece;

	piece = ChessOccupantAt(loc);
	if ((piece == world))
		return (FALSE);
	if ((piece.chess_team != team_name))
		return (FALSE);
	if ((ChessPieceType(piece) != piece_type))
		return (FALSE);
	return (!piece.hasmoved);
};

float() ChessPerftStartingPosition =
{
	local float x;

	if (((ChessLivePieceCount(player1) != 16) || (ChessLivePieceCount(player2) != 16)))
		return (FALSE);
	if (((player1.last_moved != world) || (player2.last_moved != world)))
		return (FALSE);
	x = 1;
	while ((x <= 8))
	{
		if (!ChessPerftSquareIs(((x * 10) + 2), "white", CHESS_PAWN))
			return (FALSE);
		if (!ChessPerftSquareIs(((x * 10) + 7), "black", CHESS_PAWN))
			return (FALSE);
		x = (x + 1);
	}
	if ((!ChessPerftSquareIs(11, "white", CHESS_ROOK) || !ChessPerftSquareIs(81, "white", CHESS_ROOK))) return (FALSE);
	if ((!ChessPerftSquareIs(21, "white", CHESS_KNIGHT) || !ChessPerftSquareIs(71, "white", CHESS_KNIGHT))) return (FALSE);
	if ((!ChessPerftSquareIs(31, "white", CHESS_BISHOP) || !ChessPerftSquareIs(61, "white", CHESS_BISHOP))) return (FALSE);
	if ((!ChessPerftSquareIs(41, "white", CHESS_QUEEN) || !ChessPerftSquareIs(51, "white", CHESS_KING))) return (FALSE);
	if ((!ChessPerftSquareIs(18, "black", CHESS_ROOK) || !ChessPerftSquareIs(88, "black", CHESS_ROOK))) return (FALSE);
	if ((!ChessPerftSquareIs(28, "black", CHESS_KNIGHT) || !ChessPerftSquareIs(78, "black", CHESS_KNIGHT))) return (FALSE);
	if ((!ChessPerftSquareIs(38, "black", CHESS_BISHOP) || !ChessPerftSquareIs(68, "black", CHESS_BISHOP))) return (FALSE);
	if ((!ChessPerftSquareIs(48, "black", CHESS_QUEEN) || !ChessPerftSquareIs(58, "black", CHESS_KING))) return (FALSE);
	return (TRUE);
};

float(entity side) ChessPerftCountLegalMoves =
{
	local entity piece;
	local float candidate;
	local float candidate_count;
	local float to_loc;
	local float promotion;
	local float max_promotion;
	local float count;

	count = MSG_BROADCAST;
	piece = find(world, chess_team, side.chess_team);
	while ((piece != world))
	{
		if ((ChessPieceLive(piece) && (piece.owner == side)))
		{
			candidate_count = ChessCandidateCount(piece);
			candidate = 1;
			while ((candidate <= candidate_count))
			{
				to_loc = ChessCandidateLocation(piece, candidate);
				max_promotion = CHESS_PROMOTE_QUEEN;
				if (ChessWouldPromote(piece, to_loc))
					max_promotion = CHESS_PROMOTE_KNIGHT;
				promotion = CHESS_PROMOTE_QUEEN;
				while ((promotion <= max_promotion))
				{
					if (ChessMoveIsLegal(piece, to_loc, promotion))
						count = (count + 1);
					if ((chess_bot_work > chess_perft_work_limit))
					{
						chess_perft_abort = TRUE;
						return (MSG_BROADCAST);
					}
					promotion = (promotion + 1);
				}
				if (ChessCandidateEndsRay(piece, candidate, to_loc))
					candidate = (ceil((candidate / 7)) * 7);
				candidate = (candidate + 1);
			}
		}
		piece = find(piece, chess_team, side.chess_team);
	}
	return (count);
};

float(entity side, entity piece, float to_loc, float promotion) ChessPerftApplyAndCount =
{
	local entity captured;
	local entity rook;
	local entity old_last_moved;
	local float old_last_from;
	local float old_last_to;
	local float old_loc;
	local float old_hasmoved;
	local string old_classname;
	local float captured_loc;
	local float captured_health;
	local float rook_loc;
	local float rook_hasmoved;
	local float rook_dest;
	local float count;

	if (!ChessMoveIsLegal(piece, to_loc, promotion))
		return (-1);
	captured = ChessCapturedForMove(piece, to_loc);
	rook = ChessCastleRook(piece, to_loc);
	rook_dest = MSG_BROADCAST;
	if ((rook != world))
		rook_dest = ChessCastleRookDest(piece, to_loc);
	old_loc = piece.location;
	old_hasmoved = piece.hasmoved;
	old_classname = piece.classname;
	old_last_moved = side.last_moved;
	old_last_from = side.last_move_from;
	old_last_to = side.last_move_to;
	captured_loc = MSG_BROADCAST;
	captured_health = MSG_BROADCAST;
	rook_loc = MSG_BROADCAST;
	rook_hasmoved = FALSE;
	if ((captured != world))
	{
		captured_loc = captured.location;
		captured_health = captured.health;
		ChessSetOccupant(captured_loc, world);
		captured.location = MSG_BROADCAST;
		captured.health = -10;
	}
	ChessSetOccupant(old_loc, world);
	piece.location = to_loc;
	piece.hasmoved = TRUE;
	ChessSetOccupant(to_loc, piece);
	if (ChessWouldPromote(piece, to_loc))
		ChessSetPromotionClass(piece, promotion);
	if ((rook != world))
	{
		rook_loc = rook.location;
		rook_hasmoved = rook.hasmoved;
		ChessSetOccupant(rook_loc, world);
		rook.location = rook_dest;
		rook.hasmoved = TRUE;
		ChessSetOccupant(rook_dest, rook);
	}
	side.last_moved = piece;
	side.last_move_from = old_loc;
	side.last_move_to = to_loc;
	chess_bot_work = MSG_BROADCAST;
	count = ChessPerftCountLegalMoves(side.opponent);
	ChessSetOccupant(to_loc, world);
	piece.location = old_loc;
	piece.hasmoved = old_hasmoved;
	piece.classname = old_classname;
	ChessSetOccupant(old_loc, piece);
	if ((rook != world))
	{
		ChessSetOccupant(rook_dest, world);
		rook.location = rook_loc;
		rook.hasmoved = rook_hasmoved;
		ChessSetOccupant(rook_loc, rook);
	}
	if ((captured != world))
	{
		captured.location = captured_loc;
		captured.health = captured_health;
		ChessSetOccupant(captured_loc, captured);
	}
	side.last_moved = old_last_moved;
	side.last_move_from = old_last_from;
	side.last_move_to = old_last_to;
	return (count);
};

float(entity piece, float to_loc, float promotion) ChessPerftApplyRoot =
{
	if (!ChessMoveIsLegal(piece, to_loc, promotion))
		return (FALSE);
	chess_perft_root_captured = ChessCapturedForMove(piece, to_loc);
	chess_perft_root_rook = ChessCastleRook(piece, to_loc);
	chess_perft_root_rook_dest = MSG_BROADCAST;
	if ((chess_perft_root_rook != world))
		chess_perft_root_rook_dest = ChessCastleRookDest(piece, to_loc);
	chess_perft_root_old_loc = piece.location;
	chess_perft_root_old_hasmoved = piece.hasmoved;
	chess_perft_root_old_classname = piece.classname;
	chess_perft_root_old_last_moved = chess_perft_side.last_moved;
	chess_perft_root_old_last_from = chess_perft_side.last_move_from;
	chess_perft_root_old_last_to = chess_perft_side.last_move_to;
	chess_perft_root_captured_loc = MSG_BROADCAST;
	chess_perft_root_captured_health = MSG_BROADCAST;
	chess_perft_root_captured_ischecker = FALSE;
	chess_perft_root_rook_loc = MSG_BROADCAST;
	chess_perft_root_rook_hasmoved = FALSE;
	if ((chess_perft_root_captured != world))
	{
		chess_perft_root_captured_loc = chess_perft_root_captured.location;
		chess_perft_root_captured_health = chess_perft_root_captured.health;
		chess_perft_root_captured_ischecker = chess_perft_root_captured.ischecker;
		ChessSetOccupant(chess_perft_root_captured_loc, world);
		chess_perft_root_captured.location = MSG_BROADCAST;
		chess_perft_root_captured.ischecker = TRUE;
	}
	ChessSetOccupant(chess_perft_root_old_loc, world);
	piece.location = to_loc;
	piece.hasmoved = TRUE;
	ChessSetOccupant(to_loc, piece);
	if (ChessWouldPromote(piece, to_loc))
		ChessSetPromotionClass(piece, promotion);
	if ((chess_perft_root_rook != world))
	{
		chess_perft_root_rook_loc = chess_perft_root_rook.location;
		chess_perft_root_rook_hasmoved = chess_perft_root_rook.hasmoved;
		ChessSetOccupant(chess_perft_root_rook_loc, world);
		chess_perft_root_rook.location = chess_perft_root_rook_dest;
		chess_perft_root_rook.hasmoved = TRUE;
		ChessSetOccupant(chess_perft_root_rook_dest, chess_perft_root_rook);
	}
	chess_perft_side.last_moved = piece;
	chess_perft_side.last_move_from = chess_perft_root_old_loc;
	chess_perft_side.last_move_to = to_loc;
	chess_perft_root_to = to_loc;
	chess_perft_root_move_promotion = promotion;
	chess_perft_root_applied = TRUE;
	return (TRUE);
};

void() ChessPerftUndoRoot =
{
	if (!chess_perft_root_applied)
		return;
	ChessSetOccupant(chess_perft_root_to, world);
	chess_perft_root_piece.location = chess_perft_root_old_loc;
	chess_perft_root_piece.hasmoved = chess_perft_root_old_hasmoved;
	chess_perft_root_piece.classname = chess_perft_root_old_classname;
	ChessSetOccupant(chess_perft_root_old_loc, chess_perft_root_piece);
	if ((chess_perft_root_rook != world))
	{
		ChessSetOccupant(chess_perft_root_rook_dest, world);
		chess_perft_root_rook.location = chess_perft_root_rook_loc;
		chess_perft_root_rook.hasmoved = chess_perft_root_rook_hasmoved;
		ChessSetOccupant(chess_perft_root_rook_loc, chess_perft_root_rook);
	}
	if ((chess_perft_root_captured != world))
	{
		chess_perft_root_captured.location = chess_perft_root_captured_loc;
		chess_perft_root_captured.health = chess_perft_root_captured_health;
		chess_perft_root_captured.ischecker = chess_perft_root_captured_ischecker;
		ChessSetOccupant(chess_perft_root_captured_loc, chess_perft_root_captured);
	}
	chess_perft_side.last_moved = chess_perft_root_old_last_moved;
	chess_perft_side.last_move_from = chess_perft_root_old_last_from;
	chess_perft_side.last_move_to = chess_perft_root_old_last_to;
	chess_perft_root_applied = FALSE;
};

void(float root_cursor) ChessPerftAdvanceRoot =
{
	local float max_promotion;

	max_promotion = CHESS_PROMOTE_QUEEN;
	if (ChessWouldPromote(chess_perft_root_piece, chess_perft_root_to))
		max_promotion = CHESS_PROMOTE_KNIGHT;
	chess_perft_root_promotion = (chess_perft_root_promotion + 1);
	if ((chess_perft_root_promotion > max_promotion))
	{
		chess_perft_root_promotion = CHESS_PROMOTE_QUEEN;
		if (ChessCandidateEndsRay(chess_perft_root_piece, root_cursor, chess_perft_root_to))
			root_cursor = (ceil((root_cursor / 7)) * 7);
		chess_perft_root_candidate = (root_cursor + 1);
	}
};

void(float reply_cursor, float reply_to) ChessPerftAdvanceReply =
{
	local float max_promotion;

	max_promotion = CHESS_PROMOTE_QUEEN;
	if (ChessWouldPromote(chess_perft_reply_piece, reply_to))
		max_promotion = CHESS_PROMOTE_KNIGHT;
	chess_perft_reply_promotion = (chess_perft_reply_promotion + 1);
	if ((chess_perft_reply_promotion > max_promotion))
	{
		chess_perft_reply_promotion = CHESS_PROMOTE_QUEEN;
		if (ChessCandidateEndsRay(chess_perft_reply_piece, reply_cursor, reply_to))
			reply_cursor = (ceil((reply_cursor / 7)) * 7);
		chess_perft_reply_candidate = (reply_cursor + 1);
	}
};

float() ChessPerftStep =
{
	local float candidate_count;
	local float to_loc;
	local float count;

	if (!chess_perft_root_applied)
	{
		if ((chess_perft_root_piece == world))
			return (FALSE);
		candidate_count = ChessCandidateCount(chess_perft_root_piece);
		if ((chess_perft_root_candidate > candidate_count))
		{
			chess_perft_root_piece = ChessBotNextRootPiece(chess_perft_side, chess_perft_root_piece);
			chess_perft_root_candidate = 1;
			chess_perft_root_promotion = CHESS_PROMOTE_QUEEN;
			return (TRUE);
		}
		to_loc = ChessCandidateLocation(chess_perft_root_piece, chess_perft_root_candidate);
		chess_perft_root_to = to_loc;
		if (!ChessPerftApplyRoot(chess_perft_root_piece, to_loc, chess_perft_root_promotion))
		{
			ChessPerftAdvanceRoot(chess_perft_root_candidate);
			return (TRUE);
		}
		if ((chess_perft_depth == 1))
		{
			chess_perft_total = (chess_perft_total + 1);
			ChessPerftUndoRoot();
			ChessPerftAdvanceRoot(chess_perft_root_candidate);
			return (TRUE);
		}
		chess_perft_reply_piece = ChessBotNextRootPiece(chess_perft_side.opponent, world);
		chess_perft_reply_candidate = 1;
		chess_perft_reply_promotion = CHESS_PROMOTE_QUEEN;
		return (TRUE);
	}
	if ((chess_perft_reply_piece == world))
	{
		ChessPerftUndoRoot();
		ChessPerftAdvanceRoot(chess_perft_root_candidate);
		return (TRUE);
	}
	candidate_count = ChessCandidateCount(chess_perft_reply_piece);
	if ((chess_perft_reply_candidate > candidate_count))
	{
		chess_perft_reply_piece = ChessBotNextRootPiece(chess_perft_side.opponent, chess_perft_reply_piece);
		chess_perft_reply_candidate = 1;
		chess_perft_reply_promotion = CHESS_PROMOTE_QUEEN;
		return (TRUE);
	}
	to_loc = ChessCandidateLocation(chess_perft_reply_piece, chess_perft_reply_candidate);
	if ((chess_perft_depth == 2))
	{
		if (ChessMoveIsLegal(chess_perft_reply_piece, to_loc, chess_perft_reply_promotion))
			chess_perft_total = (chess_perft_total + 1);
	}
	else
	{
		count = ChessPerftApplyAndCount(chess_perft_side.opponent, chess_perft_reply_piece, to_loc, chess_perft_reply_promotion);
		if (chess_perft_abort)
			return (FALSE);
		if ((count >= MSG_BROADCAST))
			chess_perft_total = (chess_perft_total + count);
	}
	ChessPerftAdvanceReply(chess_perft_reply_candidate, to_loc);
	return (TRUE);
};

void() ChessPerftFinish =
{
	ChessPerftUndoRoot();
	bprint("** Chess perft depth ");
	bprint(ftos(chess_perft_depth));
	bprint(": ");
	bprint(ftos(chess_perft_total));
	if (chess_perft_abort)
	{
		bprint(" ABORTED (leaf work limit ");
		bprint(ftos(chess_perft_work_limit));
		bprint(")\n");
	}
	else if ((chess_perft_expected > MSG_BROADCAST))
	{
		if ((chess_perft_total == chess_perft_expected))
			bprint(" PASS\n");
		else
		{
			bprint(" FAIL (expected ");
			bprint(ftos(chess_perft_expected));
			bprint(")\n");
		}
	}
	else
		bprint("\n");
	if (!ChessBotInvariantsRestored())
		bprint("** CHESS PERFT ERROR: board state was not restored\n");
	if (((current_turn != world) && (time_per_turn > MSG_BROADCAST)))
		current_turn.turn_starttime = (current_turn.turn_starttime + (time - chess_perft_start_time));
	action_flag = chess_perft_action_before;
	chess_perft_running = FALSE;
	chess_perft_thinker = world;
	remove(self);
};

void() ChessPerftThink =
{
	local float batch;
	local float processed;
	local float status;

	if (!chess_perft_running)
	{
		chess_perft_thinker = world;
		remove(self);
		return;
	}
	batch = 16;
	if ((chess_perft_depth == 2))
		batch = 8;
	else if ((chess_perft_depth == 3))
		batch = 1;
	processed = MSG_BROADCAST;
	status = TRUE;
	while (((processed < batch) && status))
	{
		status = ChessPerftStep();
		processed = (processed + 1);
	}
	if (!status)
	{
		ChessPerftFinish();
		return;
	}
	self.nextthink = (time + 0.01);
};

void(entity requester) ChessPerftStart =
{
	local float standard_start;

	if (chess_perft_running)
	{
		mysprint(requester, "Chess perft is already running; impulse 243 cancels it\n");
		return;
	}
	if (((game_checkers || gameover) || (current_turn == world)))
	{
		mysprint(requester, "Chess perft requires an active chess position\n");
		return;
	}
	if ((requester.spectator || !((current_turn == requester) || (current_turn.owner == requester))))
	{
		mysprint(requester, "Only the current player can run chess perft\n");
		return;
	}
	if ((action_flag || current_turn.is_bot))
	{
		mysprint(requester, "Chess perft requires an idle human turn\n");
		return;
	}
	ChessCancelBotSearch();
	ChessRebuildOccupancy();
	if (!ChessOccupancyValid())
	{
		mysprint(requester, "Chess perft cannot run: invalid occupancy index\n");
		return;
	}
	chess_perft_depth = floor(cvar("chessperft"));
	if ((chess_perft_depth < 1)) chess_perft_depth = 1;
	if ((chess_perft_depth > 3)) chess_perft_depth = 3;
	chess_perft_work_limit = floor(cvar("chessperftwork"));
	if ((chess_perft_work_limit < 500)) chess_perft_work_limit = 500;
	if ((chess_perft_work_limit > 5000)) chess_perft_work_limit = 5000;
	chess_perft_abort = FALSE;
	standard_start = ChessPerftStartingPosition();
	chess_perft_expected = floor(cvar("chessperft_expected"));
	if ((standard_start && (chess_perft_expected <= MSG_BROADCAST)))
	{
		if ((chess_perft_depth == 1)) chess_perft_expected = 20;
		else if ((chess_perft_depth == 2)) chess_perft_expected = 400;
		else chess_perft_expected = 8902;
	}
	chess_perft_side = current_turn;
	chess_perft_total = MSG_BROADCAST;
	chess_perft_root_piece = ChessBotNextRootPiece(chess_perft_side, world);
	chess_perft_root_candidate = 1;
	chess_perft_root_promotion = CHESS_PROMOTE_QUEEN;
	chess_perft_root_applied = FALSE;
	chess_perft_action_before = action_flag;
	chess_perft_start_time = time;
	ChessBotRememberInvariants();
	action_flag = TRUE;
	chess_perft_running = TRUE;
	chess_perft_thinker = spawn();
	setmodel(chess_perft_thinker, "progs/null.mdl");
	chess_perft_thinker.think = ChessPerftThink;
	chess_perft_thinker.nextthink = (time + 0.01);
	bprint("** Chess perft started at depth ");
	bprint(ftos(chess_perft_depth));
	bprint("\n");
};

void() ChessPerftCancel =
{
	if (!chess_perft_running)
		return;
	ChessPerftUndoRoot();
	if (!ChessBotInvariantsRestored())
		bprint("** CHESS PERFT ERROR: board state was not restored after cancel\n");
	if (((current_turn != world) && (time_per_turn > MSG_BROADCAST)))
		current_turn.turn_starttime = (current_turn.turn_starttime + (time - chess_perft_start_time));
	action_flag = chess_perft_action_before;
	chess_perft_running = FALSE;
	if ((chess_perft_thinker != world))
	{
		remove(chess_perft_thinker);
		chess_perft_thinker = world;
	}
	bprint("** Chess perft cancelled\n");
};

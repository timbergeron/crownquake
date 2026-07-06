// Vanilla-compatible chess search and scheduling.

float CHESS_BOT_INVALID = -1234567;
float CHESS_BOT_MATE = 90000;

float(entity piece) ChessBotPositionalScore =
{
	local float piece_type;
	local float score;
	local float x;
	local float y;
	local float center;

	piece_type = ChessPieceType(piece);
	score = ChessMaterialValue(piece);
	x = GetX(piece.location);
	y = GetY(piece.location);
	center = (7 - (fabs(4.5 - x) + fabs(4.5 - y)));
	if ((center < MSG_BROADCAST))
		center = MSG_BROADCAST;
	if ((piece_type == CHESS_PAWN))
	{
		if ((piece.chess_team == "white"))
			score = (score + ((y - 2) * 5));
		else
			score = (score + ((7 - y) * 5));
		if (((x >= 3) && (x <= 6)))
			score = (score + 3);
	}
	else if ((piece_type == CHESS_KNIGHT))
		score = (score + (center * 6));
	else if ((piece_type == CHESS_BISHOP))
		score = (score + (center * 3));
	else if ((piece_type == CHESS_ROOK))
	{
		if ((((piece.chess_team == "white") && (y == 7)) || ((piece.chess_team == "black") && (y == 2))))
			score = (score + 12);
	}
	else if ((piece_type == CHESS_QUEEN))
		score = (score + center);
	else if ((piece_type == CHESS_KING))
	{
		if ((piece.hasmoved && ((x == 3) || (x == 7))))
			score = (score + 25);
	}
	return (score);
};

float(entity side) ChessBotSideScore =
{
	local entity piece;
	local float score;
	local float bishops;

	if ((side == world))
		return (MSG_BROADCAST);
	score = MSG_BROADCAST;
	bishops = MSG_BROADCAST;
	piece = find(world, chess_team, side.chess_team);
	while ((piece != world))
	{
		if ((ChessPieceLive(piece) && (piece.owner == side)))
		{
			score = (score + ChessBotPositionalScore(piece));
			if ((ChessPieceType(piece) == CHESS_BISHOP))
				bishops = (bishops + 1);
		}
		piece = find(piece, chess_team, side.chess_team);
	}
	if ((bishops >= 2))
		score = (score + 25);
	return (score);
};

float(entity side) ChessBotEvaluate =
{
	if (((side == world) || (side.opponent == world)))
		return (MSG_BROADCAST);
	return (ChessBotSideScore(side) - ChessBotSideScore(side.opponent));
};

float() ChessBotConfiguredLevel =
{
	local float level;

	level = floor(cvar("chessbotlevel"));
	if ((level < 1))
		level = floor(cvar("botdepth"));
	if ((level < 1))
		level = 3;
	if ((level > 5))
		level = 5;
	return (level);
};

float() ChessBotTargetDepth =
{
	local float level;

	level = ChessBotConfiguredLevel();
	if ((level == 1))
		return (1);
	if ((level <= 3))
		return (2);
	return (3);
};

float() ChessBotWorkLimit =
{
	local float configured;
	local float level;

	configured = floor(cvar("botwork"));
	if ((configured > MSG_BROADCAST))
	{
		if ((configured < 100))
			configured = 100;
		if ((configured > 5000))
			configured = 5000;
		return (configured);
	}
	level = ChessBotConfiguredLevel();
	if ((level == 1)) return (700);
	if ((level == 2)) return (1400);
	if ((level == 3)) return (2200);
	if ((level == 4)) return (3200);
	return (4500);
};

float() ChessBotBatchSize =
{
	local float batch;

	batch = floor(cvar("botbatch"));
	if ((batch <= MSG_BROADCAST))
		batch = 12;
	if ((batch < 1))
		batch = 1;
	if ((batch > 24))
		batch = 24;
	return (batch);
};

float(entity side, float depth, float alpha, float beta, float ply) ChessBotSearch;

float(entity side, entity piece, float to_loc, float promotion, float depth, float alpha, float beta, float ply) ChessBotScoreMove =
{
	local entity captured;
	local entity rook;
	local entity king;
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
	local float score;
	local float legal;

	score = CHESS_BOT_INVALID;
	chess_bot_work = (chess_bot_work + 1);
	if ((chess_bot_work > chess_bot_work_limit))
	{
		chess_bot_abort = TRUE;
		return (CHESS_BOT_INVALID);
	}
	if (!ChessPseudoLegalMove(piece, to_loc))
		return (CHESS_BOT_INVALID);
	if (((ChessPieceType(piece) == CHESS_KING) && (fabs(GetX(to_loc) - GetX(piece.location)) == 2)))
	{
		if (ChessSquareAttacked(piece.location, side.opponent))
			return (CHESS_BOT_INVALID);
		if (!ChessCastleTransitSafe(piece, to_loc))
			return (CHESS_BOT_INVALID);
	}
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
	king = get_king(side);
	legal = ((king != world) && !ChessSquareAttacked(king.location, side.opponent));
	if (legal)
	{
		chess_bot_nodes = (chess_bot_nodes + 1);
		if ((chess_bot_work > chess_bot_work_limit))
			chess_bot_abort = TRUE;
		if (!chess_bot_abort)
			score = -ChessBotSearch(side.opponent, (depth - 1), -beta, -alpha, (ply + 1));
	}
	else
		score = CHESS_BOT_INVALID;
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
	if (chess_bot_abort)
		return (CHESS_BOT_INVALID);
	return (score);
};

float(entity side, float depth, float alpha, float beta, float ply) ChessBotSearch =
{
	local entity piece;
	local entity captured;
	local float candidate;
	local float candidate_count;
	local float to_loc;
	local float promotion;
	local float max_promotion;
	local float pass_num;
	local float tactical;
	local float score;
	local float best;
	local float any_move;

	if (chess_bot_abort)
		return (MSG_BROADCAST);
	if ((depth <= MSG_BROADCAST))
		return (ChessBotEvaluate(side));
	best = -100000;
	any_move = FALSE;
	pass_num = 1;
	while (((pass_num <= 2) && !chess_bot_abort))
	{
		piece = find(world, chess_team, side.chess_team);
		while (((piece != world) && !chess_bot_abort))
		{
			if ((ChessPieceLive(piece) && (piece.owner == side)))
			{
				candidate_count = ChessCandidateCount(piece);
				candidate = 1;
				while (((candidate <= candidate_count) && !chess_bot_abort))
				{
					to_loc = ChessCandidateLocation(piece, candidate);
					captured = ChessCapturedForMove(piece, to_loc);
					tactical = ((captured != world) || ChessWouldPromote(piece, to_loc));
					if ((((pass_num == 1) && tactical) || ((pass_num == 2) && !tactical)))
					{
						max_promotion = CHESS_PROMOTE_QUEEN;
						if (ChessWouldPromote(piece, to_loc))
							max_promotion = CHESS_PROMOTE_KNIGHT;
						promotion = CHESS_PROMOTE_QUEEN;
						while (((promotion <= max_promotion) && !chess_bot_abort))
						{
							score = ChessBotScoreMove(side, piece, to_loc, promotion, depth, alpha, beta, ply);
							if ((score != CHESS_BOT_INVALID))
							{
								any_move = TRUE;
								if ((score > best))
									best = score;
								if ((score > alpha))
									alpha = score;
								if ((alpha >= beta))
									return (best);
							}
							promotion = (promotion + 1);
						}
					}
					if (ChessCandidateEndsRay(piece, candidate, to_loc))
						candidate = (ceil((candidate / 7)) * 7);
					candidate = (candidate + 1);
				}
			}
			piece = find(piece, chess_team, side.chess_team);
		}
		pass_num = (pass_num + 1);
	}
	if (chess_bot_abort)
		return (MSG_BROADCAST);
	if (!any_move)
	{
		if (ChessInCheck(side))
			return ((-CHESS_BOT_MATE) + ply);
		return (MSG_BROADCAST);
	}
	return (best);
};

void() ChessBotRememberInvariants =
{
	chess_bot_checksum_before = ChessPositionChecksum();
	chess_bot_player1_count_before = ChessLivePieceCount(player1);
	chess_bot_player2_count_before = ChessLivePieceCount(player2);
	chess_bot_player1_material_before = ChessMaterialTotal(player1);
	chess_bot_player2_material_before = ChessMaterialTotal(player2);
	chess_bot_en_passant_before = en_passant_flag;
	chess_bot_castle_flag_before = king_castle_move_flag;
	chess_bot_castle_rook_before = castle_to_move;
	chess_bot_pawning_before = pawning_enemy;
	chess_bot_occupancy_before = ChessOccupancyChecksum();
	chess_bot_player1_last_before = player1.last_moved;
	chess_bot_player2_last_before = player2.last_moved;
	chess_bot_player1_from_before = player1.last_move_from;
	chess_bot_player1_to_before = player1.last_move_to;
	chess_bot_player2_from_before = player2.last_move_from;
	chess_bot_player2_to_before = player2.last_move_to;
	chess_bot_selected_before = current_selected;
	chess_bot_dest_before = current_dest_int;
	chess_bot_ignore_before = ignore_canmove;
	chess_bot_castle_dest_before = castle_destination;
};

float() ChessBotInvariantsRestored =
{
	if ((ChessPositionChecksum() != chess_bot_checksum_before))
		return (FALSE);
	if ((ChessLivePieceCount(player1) != chess_bot_player1_count_before))
		return (FALSE);
	if ((ChessLivePieceCount(player2) != chess_bot_player2_count_before))
		return (FALSE);
	if ((ChessMaterialTotal(player1) != chess_bot_player1_material_before))
		return (FALSE);
	if ((ChessMaterialTotal(player2) != chess_bot_player2_material_before))
		return (FALSE);
	if ((en_passant_flag != chess_bot_en_passant_before))
		return (FALSE);
	if ((king_castle_move_flag != chess_bot_castle_flag_before))
		return (FALSE);
	if ((castle_to_move != chess_bot_castle_rook_before))
		return (FALSE);
	if ((pawning_enemy != chess_bot_pawning_before))
		return (FALSE);
	if ((ChessOccupancyChecksum() != chess_bot_occupancy_before))
		return (FALSE);
	if (!ChessOccupancyValid())
		return (FALSE);
	if ((player1.last_moved != chess_bot_player1_last_before))
		return (FALSE);
	if ((player2.last_moved != chess_bot_player2_last_before))
		return (FALSE);
	if ((player1.last_move_from != chess_bot_player1_from_before))
		return (FALSE);
	if ((player1.last_move_to != chess_bot_player1_to_before))
		return (FALSE);
	if ((player2.last_move_from != chess_bot_player2_from_before))
		return (FALSE);
	if ((player2.last_move_to != chess_bot_player2_to_before))
		return (FALSE);
	if ((current_selected != chess_bot_selected_before))
		return (FALSE);
	if ((current_dest_int != chess_bot_dest_before))
		return (FALSE);
	if ((ignore_canmove != chess_bot_ignore_before))
		return (FALSE);
	if ((castle_destination != chess_bot_castle_dest_before))
		return (FALSE);
	return (TRUE);
};

entity(entity side, entity after_piece) ChessBotNextRootPiece =
{
	local entity piece;

	piece = find(after_piece, chess_team, side.chess_team);
	while ((piece != world))
	{
		if ((ChessPieceLive(piece) && (piece.owner == side)))
			return (piece);
		piece = find(piece, chess_team, side.chess_team);
	}
	return (world);
};

void() ChessBotResetIteration =
{
	chess_bot_root_piece = ChessBotNextRootPiece(chess_bot_side, world);
	chess_bot_root_candidate = 1;
	chess_bot_root_promotion = CHESS_PROMOTE_QUEEN;
	chess_bot_root_legal = MSG_BROADCAST;
	chess_bot_root_pass = 1;
	if ((chess_bot_completed_piece != world))
		chess_bot_root_pass = MSG_BROADCAST;
	chess_bot_root_alpha = -100000;
	chess_bot_best_piece = world;
	chess_bot_best_dest = MSG_BROADCAST;
	chess_bot_best_promotion = CHESS_PROMOTE_QUEEN;
	chess_bot_best_score = -100000;
};

void() ChessBotStartSearch =
{
	ChessRebuildOccupancy();
	chess_bot_side = current_turn;
	chess_bot_target_depth = ChessBotTargetDepth();
	chess_bot_iteration_depth = 1;
	chess_bot_completed_depth = MSG_BROADCAST;
	chess_bot_completed_piece = world;
	chess_bot_completed_dest = MSG_BROADCAST;
	chess_bot_completed_promotion = CHESS_PROMOTE_QUEEN;
	chess_bot_completed_score = -100000;
	chess_bot_nodes = MSG_BROADCAST;
	chess_bot_work_limit = ChessBotWorkLimit();
	chess_bot_abort = FALSE;
	chess_bot_searching = TRUE;
	ChessBotRememberInvariants();
	ChessBotResetIteration();
};

void(string reason) ChessBotFailSafe =
{
	bprint("** CHESS BOT ERROR: ");
	bprint(reason);
	bprint("; continuing as a human player\n");
	chess_bot_searching = FALSE;
	chess_bot_abort = FALSE;
	current_selected = world;
	current_dest_int = MSG_BROADCAST;
	ignore_canmove = world;
	en_passant_flag = FALSE;
	king_castle_move_flag = FALSE;
	castle_to_move = world;
	pawning_enemy = world;
	action_flag = FALSE;
	cvar_set("bot", "0");
	CheckersApplyBotCvars();
	ChessRebuildOccupancy();
	ClearSelectionEffect();
	ClearLastHighlight();
};

void(float max_promotion, float to_loc) ChessBotAdvanceRoot =
{
	chess_bot_root_promotion = (chess_bot_root_promotion + 1);
	if ((chess_bot_root_promotion > max_promotion))
	{
		chess_bot_root_promotion = CHESS_PROMOTE_QUEEN;
		if (ChessCandidateEndsRay(chess_bot_root_piece, chess_bot_root_candidate, to_loc))
			chess_bot_root_candidate = (ceil((chess_bot_root_candidate / 7)) * 7);
		chess_bot_root_candidate = (chess_bot_root_candidate + 1);
	}
};

float() ChessBotProcessRootCandidate =
{
	local entity captured;
	local float candidate_count;
	local float to_loc;
	local float max_promotion;
	local float score;
	local float raw_score;
	local float level;
	local float tactical;

	if ((chess_bot_root_pass == MSG_BROADCAST))
	{
		chess_bot_root_piece = chess_bot_completed_piece;
		to_loc = chess_bot_completed_dest;
		chess_bot_root_promotion = chess_bot_completed_promotion;
		chess_bot_root_pass = 1;
		chess_bot_work = MSG_BROADCAST;
		chess_bot_abort = FALSE;
		score = ChessBotScoreMove(chess_bot_side, chess_bot_root_piece, to_loc, chess_bot_root_promotion, chess_bot_iteration_depth, chess_bot_root_alpha, 100000, MSG_BROADCAST);
		if (chess_bot_abort)
			return (-1);
		if ((score != CHESS_BOT_INVALID))
		{
			chess_bot_root_legal = (chess_bot_root_legal + 1);
			chess_bot_root_alpha = score;
			chess_bot_best_piece = chess_bot_root_piece;
			chess_bot_best_dest = to_loc;
			chess_bot_best_promotion = chess_bot_root_promotion;
			chess_bot_best_score = score;
		}
		chess_bot_root_piece = ChessBotNextRootPiece(chess_bot_side, world);
		chess_bot_root_candidate = 1;
		chess_bot_root_promotion = CHESS_PROMOTE_QUEEN;
		return (TRUE);
	}

	if ((chess_bot_root_piece == world))
	{
		if ((chess_bot_root_pass < 2))
		{
			chess_bot_root_pass = (chess_bot_root_pass + 1);
			chess_bot_root_piece = ChessBotNextRootPiece(chess_bot_side, world);
			chess_bot_root_candidate = 1;
			chess_bot_root_promotion = CHESS_PROMOTE_QUEEN;
			return (TRUE);
		}
		return (MSG_BROADCAST);
	}
	candidate_count = ChessCandidateCount(chess_bot_root_piece);
	if ((chess_bot_root_candidate > candidate_count))
	{
		chess_bot_root_piece = ChessBotNextRootPiece(chess_bot_side, chess_bot_root_piece);
		chess_bot_root_candidate = 1;
		chess_bot_root_promotion = CHESS_PROMOTE_QUEEN;
		if ((chess_bot_root_piece == world))
		{
			if ((chess_bot_root_pass < 2))
			{
				chess_bot_root_pass = (chess_bot_root_pass + 1);
				chess_bot_root_piece = ChessBotNextRootPiece(chess_bot_side, world);
				return (TRUE);
			}
			return (MSG_BROADCAST);
		}
		return (TRUE);
	}
	to_loc = ChessCandidateLocation(chess_bot_root_piece, chess_bot_root_candidate);
	max_promotion = CHESS_PROMOTE_QUEEN;
	if (ChessWouldPromote(chess_bot_root_piece, to_loc))
		max_promotion = CHESS_PROMOTE_KNIGHT;
	captured = ChessCapturedForMove(chess_bot_root_piece, to_loc);
	tactical = ((captured != world) || ChessWouldPromote(chess_bot_root_piece, to_loc));
	if ((((chess_bot_root_pass == 1) && !tactical) || ((chess_bot_root_pass == 2) && tactical)))
	{
		chess_bot_root_promotion = max_promotion;
		ChessBotAdvanceRoot(max_promotion, to_loc);
		return (TRUE);
	}
	if (((chess_bot_root_piece == chess_bot_completed_piece) && (to_loc == chess_bot_completed_dest)) && (chess_bot_root_promotion == chess_bot_completed_promotion))
	{
		ChessBotAdvanceRoot(max_promotion, to_loc);
		return (TRUE);
	}
	chess_bot_work = MSG_BROADCAST;
	chess_bot_abort = FALSE;
	score = ChessBotScoreMove(chess_bot_side, chess_bot_root_piece, to_loc, chess_bot_root_promotion, chess_bot_iteration_depth, chess_bot_root_alpha, 100000, MSG_BROADCAST);
	if (chess_bot_abort)
		return (-1);
	if ((score != CHESS_BOT_INVALID))
	{
		chess_bot_root_legal = (chess_bot_root_legal + 1);
		raw_score = score;
		if ((raw_score > chess_bot_root_alpha))
			chess_bot_root_alpha = raw_score;
		level = ChessBotConfiguredLevel();
		if ((level == 1))
			score = (score + (random() * 80));
		else
			score = (score + (random() * 0.01));
		if (((chess_bot_best_piece == world) || (score > chess_bot_best_score)) || ((score == chess_bot_best_score) && (random() < 0.5)))
		{
			chess_bot_best_piece = chess_bot_root_piece;
			chess_bot_best_dest = to_loc;
			chess_bot_best_promotion = chess_bot_root_promotion;
			chess_bot_best_score = score;
		}
	}
	ChessBotAdvanceRoot(max_promotion, to_loc);
	return (TRUE);
};

void() ChessBotPrintMove =
{
	bprint("** Chess bot: ");
	if ((ChessPieceType(chess_bot_completed_piece) == CHESS_PAWN)) bprint("Pawn ");
	else if ((ChessPieceType(chess_bot_completed_piece) == CHESS_KNIGHT)) bprint("Knight ");
	else if ((ChessPieceType(chess_bot_completed_piece) == CHESS_BISHOP)) bprint("Bishop ");
	else if ((ChessPieceType(chess_bot_completed_piece) == CHESS_ROOK)) bprint("Rook ");
	else if ((ChessPieceType(chess_bot_completed_piece) == CHESS_QUEEN)) bprint("Queen ");
	else if ((ChessPieceType(chess_bot_completed_piece) == CHESS_KING)) bprint("King ");
	bprint(ftos(chess_bot_completed_piece.location));
	if ((ChessCapturedForMove(chess_bot_completed_piece, chess_bot_completed_dest) != world))
		bprint(" x ");
	else
		bprint(" - ");
	bprint(ftos(chess_bot_completed_dest));
	bprint("\n");
	if (cvar("botdebug"))
	{
		bprint("** Chess bot depth ");
		bprint(ftos(chess_bot_completed_depth));
		bprint(", nodes ");
		bprint(ftos(chess_bot_nodes));
		bprint(", score ");
		bprint(ftos(chess_bot_completed_score));
		bprint("\n");
	}
};

float(entity actor, entity piece, float to_loc, float promotion) ChessBotExecuteMove =
{
	local vector dest_org;
	local float from_loc;

	if ((((actor == world) || (piece == world)) || game_checkers))
		return (FALSE);
	ChessRebuildOccupancy();
	if (!ChessOccupancyValid())
		return (FALSE);
	if (!ChessMoveIsLegal(piece, to_loc, promotion))
		return (FALSE);
	from_loc = piece.location;
	current_selected = piece;
	current_dest_int = to_loc;
	current_destination = ftos(to_loc);
	if (!CanMove(current_selected, current_dest_int, TRUE))
		return (FALSE);
	chess_bot_pending_promotion = promotion;
	action_flag = TRUE;
	ClearSelectionEffect();
	ClearLastHighlight();
	dest_org = LocationToVector(current_dest_int);
	setorigin(dest_ent, dest_org);
	mystuffcmd(actor, "play effects/button.wav\n");
	if ((current_selected.think != FoundTarget))
		WalkToDest(actor);
	current_turn.last_moved = current_selected;
	current_turn.last_move_from = from_loc;
	current_turn.last_move_to = current_dest_int;
	LastMoved = current_selected;
	LastMovedLocation = current_dest_int;
	current_selected.location = current_dest_int;
	current_selected.hasmoved = TRUE;
	current_turn.chess_flags = (current_turn.chess_flags - (current_turn.chess_flags & CF_SELECTED_PIECE));
	return (TRUE);
};

void() ChessBotFinishNoMove =
{
	ChessFinishNoLegalMoves(current_turn, current_turn.opponent);
};

void() ChessBotFinishSearch =
{
	if (!ChessBotInvariantsRestored())
	{
		ChessBotFailSafe("search state was not restored");
		return;
	}
	if ((chess_bot_completed_piece == world))
	{
		ChessBotFinishNoMove();
		chess_bot_searching = FALSE;
		return;
	}
	ChessBotPrintMove();
	if (!ChessBotExecuteMove(current_turn, chess_bot_completed_piece, chess_bot_completed_dest, chess_bot_completed_promotion))
	{
		ChessBotFailSafe("live validation rejected selected move");
		return;
	}
	chess_bot_searching = FALSE;
};

void() ChessBotThink =
{
	local float batch;
	local float processed;
	local float status;

	if (((game_checkers || gameover) || (current_turn == world)))
	{
		chess_bot_thinker = world;
		chess_bot_searching = FALSE;
		remove(self);
		return;
	}
	if (!current_turn.is_bot)
	{
		chess_bot_thinker = world;
		chess_bot_searching = FALSE;
		remove(self);
		return;
	}
	if (action_flag)
	{
		self.nextthink = (time + 0.05);
		return;
	}
	if (((current_turn.owner != world) && current_turn.owner.menu_screen))
	{
		self.nextthink = (time + 0.1);
		return;
	}
	if (!chess_bot_searching)
	{
		ChessBotStartSearch();
		if (!ChessOccupancyValid())
		{
			ChessBotFailSafe("invalid board occupancy");
			chess_bot_thinker = world;
			remove(self);
			return;
		}
	}
	batch = ChessBotBatchSize();
	if ((chess_bot_iteration_depth > 1))
		batch = 2;
	processed = MSG_BROADCAST;
	status = TRUE;
	while (((processed < batch) && (status == TRUE)))
	{
		status = ChessBotProcessRootCandidate();
		processed = (processed + 1);
	}
	if ((status == -1))
	{
		if (cvar("botdebug"))
		{
			bprint("** Chess bot depth ");
			bprint(ftos(chess_bot_iteration_depth));
			bprint(" exceeded work budget ");
			bprint(ftos(chess_bot_work_limit));
			bprint("; using completed depth ");
			bprint(ftos(chess_bot_completed_depth));
			bprint("\n");
		}
		if ((chess_bot_completed_piece == world))
		{
			ChessBotFailSafe("vanilla work budget too small for depth one");
		}
		else
			ChessBotFinishSearch();
		chess_bot_thinker = world;
		remove(self);
		return;
	}
	if ((status == MSG_BROADCAST))
	{
		if (cvar("botdebug"))
		{
			bprint("** Chess bot completed depth ");
			bprint(ftos(chess_bot_iteration_depth));
			bprint(" with ");
			bprint(ftos(chess_bot_root_legal));
			bprint(" legal root moves\n");
		}
		if ((chess_bot_best_piece != world))
		{
			chess_bot_completed_piece = chess_bot_best_piece;
			chess_bot_completed_dest = chess_bot_best_dest;
			chess_bot_completed_promotion = chess_bot_best_promotion;
			chess_bot_completed_score = chess_bot_best_score;
			chess_bot_completed_depth = chess_bot_iteration_depth;
		}
		if (((chess_bot_best_piece != world) && (chess_bot_iteration_depth < chess_bot_target_depth)))
		{
			chess_bot_iteration_depth = (chess_bot_iteration_depth + 1);
			ChessBotResetIteration();
			self.nextthink = (time + 0.01);
			return;
		}
		ChessBotFinishSearch();
		chess_bot_thinker = world;
		remove(self);
		return;
	}
	self.nextthink = (time + 0.01);
};

void() ChessCancelBotSearch =
{
	if ((chess_bot_thinker != world))
	{
		remove(chess_bot_thinker);
		chess_bot_thinker = world;
	}
	chess_bot_searching = FALSE;
	chess_bot_side = world;
};

void() ChessMaybeScheduleBotTurn =
{
	ChessCancelBotSearch();
	if (((game_checkers || gameover) || (current_turn == world)))
		return;
	if (!current_turn.is_bot)
		return;
	if (action_flag)
		return;
	chess_bot_thinker = spawn();
	setmodel(chess_bot_thinker, "progs/null.mdl");
	chess_bot_thinker.think = ChessBotThink;
	chess_bot_thinker.nextthink = (time + CheckersBotDelay());
	mysprint(current_turn, "Computer thinking\n");
};

void() ChessBotPromotePawn =
{
	if ((chess_bot_pending_promotion == CHESS_PROMOTE_ROOK))
		QueenTo = "chess_rook";
	else if ((chess_bot_pending_promotion == CHESS_PROMOTE_BISHOP))
		QueenTo = "chess_bishop";
	else if ((chess_bot_pending_promotion == CHESS_PROMOTE_KNIGHT))
		QueenTo = "chess_knight";
	else
		QueenTo = "chess_queen";
	chess_bot_pending_promotion = CHESS_PROMOTE_QUEEN;
	MakeQueen();
};

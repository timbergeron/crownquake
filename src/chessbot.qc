// Vanilla-compatible chess search and scheduling.

float CHESS_BOT_INVALID = -1234567;
float CHESS_BOT_MATE = 90000;
float chess_bot_eval_endgame;
float chess_bot_white_pawns[9];
float chess_bot_black_pawns[9];
float chess_bot_white_pawn_min[9];
float chess_bot_black_pawn_max[9];
float chess_bot_killer1_from[8];
float chess_bot_killer1_to[8];
float chess_bot_killer1_promotion[8];
float chess_bot_killer2_from[8];
float chess_bot_killer2_to[8];
float chess_bot_killer2_promotion[8];
float chess_bot_history[768];
float chess_bot_pv_from[64];
float chess_bot_pv_to[64];
float chess_bot_pv_promotion[64];
float chess_bot_previous_pv_from[8];
float chess_bot_previous_pv_to[8];
float chess_bot_previous_pv_promotion[8];
float chess_bot_repetition_key1[64];
float chess_bot_repetition_key2[64];
float chess_bot_repetition_count;
float chess_bot_line_key1[8];
float chess_bot_line_key2[8];
float chess_bot_position_key1;
float chess_bot_position_key2;

float() ChessBotQuiescenceDepth =
{
	local float depth;

	depth = floor(cvar("botqdepth"));
	if ((depth < MSG_BROADCAST))
		depth = MSG_BROADCAST;
	if ((depth > 4))
		depth = 4;
	return (depth);
};

void(entity side) ChessBotBuildPositionKey =
{
	local entity piece;
	local entity mover;
	local float x;
	local float y;
	local float code;
	local float en_passant_loc;

	chess_bot_position_key1 = 17;
	chess_bot_position_key2 = 29;
	x = 1;
	while ((x <= 8))
	{
		y = 1;
		while ((y <= 8))
		{
			piece = ChessOccupantAt(((x * 10) + y));
			code = MSG_BROADCAST;
			if ((piece != world))
			{
				code = ChessPieceType(piece);
				if ((piece.chess_team == "black"))
					code = (code + 6);
				if (piece.hasmoved)
					code = (code + 13);
			}
			chess_bot_position_key1 = ((chess_bot_position_key1 * 7) + code + 1);
			chess_bot_position_key1 = (chess_bot_position_key1 - (floor((chess_bot_position_key1 / 1000003)) * 1000003));
			chess_bot_position_key2 = ((chess_bot_position_key2 * 11) + code + 3);
			chess_bot_position_key2 = (chess_bot_position_key2 - (floor((chess_bot_position_key2 / 999983)) * 999983));
			y = (y + 1);
		}
		x = (x + 1);
	}
	code = 1;
	if (((side != world) && (side.chess_team == "black")))
		code = 2;
	en_passant_loc = MSG_BROADCAST;
	if ((side != world))
	{
		mover = side.opponent;
		if ((((mover != world) && (mover.last_moved != world)) && (ChessPieceType(mover.last_moved) == CHESS_PAWN)))
		{
			if ((fabs(GetY(mover.last_move_to) - GetY(mover.last_move_from)) == 2))
				en_passant_loc = mover.last_move_to;
		}
	}
	chess_bot_position_key1 = (((chess_bot_position_key1 * 7) + code) + en_passant_loc);
	chess_bot_position_key1 = (chess_bot_position_key1 - (floor((chess_bot_position_key1 / 1000003)) * 1000003));
	chess_bot_position_key2 = (((chess_bot_position_key2 * 11) + code) + (en_passant_loc * 3));
	chess_bot_position_key2 = (chess_bot_position_key2 - (floor((chess_bot_position_key2 / 999983)) * 999983));
};

void() ChessBotResetRepetition =
{
	chess_bot_repetition_count = MSG_BROADCAST;
};

void(entity side) ChessBotRecordPosition =
{
	local float i;

	if (((game_checkers || (side == world)) || !ChessOccupancyValid()))
		return;
	ChessBotBuildPositionKey(side);
	if ((chess_bot_repetition_count >= 64))
	{
		i = 1;
		while ((i < 64))
		{
			chess_bot_repetition_key1[(i - 1)] = chess_bot_repetition_key1[i];
			chess_bot_repetition_key2[(i - 1)] = chess_bot_repetition_key2[i];
			i = (i + 1);
		}
		chess_bot_repetition_count = 63;
	}
	chess_bot_repetition_key1[chess_bot_repetition_count] = chess_bot_position_key1;
	chess_bot_repetition_key2[chess_bot_repetition_count] = chess_bot_position_key2;
	chess_bot_repetition_count = (chess_bot_repetition_count + 1);
};

float(entity side) ChessBotGamePositionOccurrences =
{
	local float i;
	local float count;

	ChessBotBuildPositionKey(side);
	count = MSG_BROADCAST;
	i = MSG_BROADCAST;
	while ((i < chess_bot_repetition_count))
	{
		if (((chess_bot_repetition_key1[i] == chess_bot_position_key1) && (chess_bot_repetition_key2[i] == chess_bot_position_key2)))
			count = (count + 1);
		i = (i + 1);
	}
	return (count);
};

float(entity side, float ply) ChessBotSearchPositionRepeated =
{
	local float i;
	local float count;
	local float row;

	ChessBotBuildPositionKey(side);
	count = MSG_BROADCAST;
	i = MSG_BROADCAST;
	while ((i < chess_bot_repetition_count))
	{
		if (((chess_bot_repetition_key1[i] == chess_bot_position_key1) && (chess_bot_repetition_key2[i] == chess_bot_position_key2)))
			count = (count + 1);
		i = (i + 1);
	}
	row = floor(ply);
	i = 1;
	while (((i < row) && (i < 8)))
	{
		if (((chess_bot_line_key1[i] == chess_bot_position_key1) && (chess_bot_line_key2[i] == chess_bot_position_key2)))
			count = (count + 1);
		i = (i + 1);
	}
	if (((row >= 1) && (row < 8)))
	{
		chess_bot_line_key1[row] = chess_bot_position_key1;
		chess_bot_line_key2[row] = chess_bot_position_key2;
	}
	return (count >= 2);
};

void() ChessBotPrepareEvaluation =
{
	local entity piece;
	local float material;
	local float piece_type;
	local float file_num;
	local float rank_num;

	file_num = 1;
	while ((file_num <= 8))
	{
		chess_bot_white_pawns[file_num] = MSG_BROADCAST;
		chess_bot_black_pawns[file_num] = MSG_BROADCAST;
		chess_bot_white_pawn_min[file_num] = 9;
		chess_bot_black_pawn_max[file_num] = MSG_BROADCAST;
		file_num = (file_num + 1);
	}
	material = MSG_BROADCAST;
	piece = find(world, chess_team, "white");
	while ((piece != world))
	{
		if (ChessPieceLive(piece))
		{
			piece_type = ChessPieceType(piece);
			if ((piece_type == CHESS_PAWN))
			{
				file_num = GetX(piece.location);
				rank_num = GetY(piece.location);
				chess_bot_white_pawns[file_num] = (chess_bot_white_pawns[file_num] + 1);
				if ((rank_num < chess_bot_white_pawn_min[file_num]))
					chess_bot_white_pawn_min[file_num] = rank_num;
			}
			else if ((piece_type != CHESS_KING))
				material = (material + ChessMaterialValue(piece));
		}
		piece = find(piece, chess_team, "white");
	}
	piece = find(world, chess_team, "black");
	while ((piece != world))
	{
		if (ChessPieceLive(piece))
		{
			piece_type = ChessPieceType(piece);
			if ((piece_type == CHESS_PAWN))
			{
				file_num = GetX(piece.location);
				rank_num = GetY(piece.location);
				chess_bot_black_pawns[file_num] = (chess_bot_black_pawns[file_num] + 1);
				if ((rank_num > chess_bot_black_pawn_max[file_num]))
					chess_bot_black_pawn_max[file_num] = rank_num;
			}
			else if ((piece_type != CHESS_KING))
				material = (material + ChessMaterialValue(piece));
		}
		piece = find(piece, chess_team, "black");
	}
	chess_bot_eval_endgame = (material <= 2600);
};

float(entity pawn) ChessBotPawnStructureScore =
{
	local float score;
	local float x;
	local float y;
	local float file_num;
	local float advance;
	local float adjacent_pawn;
	local float passed;

	score = MSG_BROADCAST;
	x = GetX(pawn.location);
	y = GetY(pawn.location);
	advance = (y - 2);
	if ((pawn.chess_team == "black"))
		advance = (7 - y);
	// Doubled pawns obstruct one another and are harder to defend.
	if ((pawn.chess_team == "white"))
		score = (score - ((chess_bot_white_pawns[x] - 1) * 8));
	else
		score = (score - ((chess_bot_black_pawns[x] - 1) * 8));
	// A pawn is isolated when neither neighboring file contains a friendly pawn.
	adjacent_pawn = FALSE;
	file_num = (x - 1);
	while ((file_num <= (x + 1)))
	{
		if ((((file_num >= 1) && (file_num <= 8)) && (file_num != x)))
		{
			if (((pawn.chess_team == "white") && (chess_bot_white_pawns[file_num] > MSG_BROADCAST)))
				adjacent_pawn = TRUE;
			if (((pawn.chess_team == "black") && (chess_bot_black_pawns[file_num] > MSG_BROADCAST)))
				adjacent_pawn = TRUE;
		}
		file_num = (file_num + 1);
	}
	if (!adjacent_pawn)
		score = (score - 10);
	// Passed pawns have no opposing pawn ahead on their own or adjacent files.
	passed = TRUE;
	file_num = (x - 1);
	while ((file_num <= (x + 1)))
	{
		if (((file_num >= 1) && (file_num <= 8)))
		{
			if (((pawn.chess_team == "white") && (chess_bot_black_pawn_max[file_num] > y)))
				passed = FALSE;
			if (((pawn.chess_team == "black") && (chess_bot_white_pawn_min[file_num] < y)))
				passed = FALSE;
		}
		file_num = (file_num + 1);
	}
	if (passed)
		score = (score + 15 + (advance * 8));
	return (score);
};

float(entity rook) ChessBotRookFileScore =
{
	local float x;
	local float own_pawn;
	local float any_pawn;
	local float score;

	x = GetX(rook.location);
	if ((rook.chess_team == "white"))
	{
		own_pawn = (chess_bot_white_pawns[x] > MSG_BROADCAST);
		any_pawn = ((chess_bot_white_pawns[x] + chess_bot_black_pawns[x]) > MSG_BROADCAST);
	}
	else
	{
		own_pawn = (chess_bot_black_pawns[x] > MSG_BROADCAST);
		any_pawn = ((chess_bot_white_pawns[x] + chess_bot_black_pawns[x]) > MSG_BROADCAST);
	}
	score = MSG_BROADCAST;
	if (!own_pawn)
		score = (score + 8);
	if (!any_pawn)
		score = (score + 8);
	return (score);
};

float(entity king, float center) ChessBotKingSafetyScore =
{
	local entity occupant;
	local float direction;
	local float file_num;
	local float shield_rank;
	local float score;

	direction = 1;
	if ((king.chess_team == "black"))
		direction = -1;
	shield_rank = (GetY(king.location) + direction);
	score = MSG_BROADCAST;
	if (((shield_rank >= 1) && (shield_rank <= 8)))
	{
		file_num = (GetX(king.location) - 1);
		while ((file_num <= (GetX(king.location) + 1)))
		{
			if (((file_num >= 1) && (file_num <= 8)))
			{
				occupant = ChessOccupantAt(((file_num * 10) + shield_rank));
				if ((((occupant != world) && (occupant.owner == king.owner)) && (ChessPieceType(occupant) == CHESS_PAWN)))
					score = (score + 6);
			}
			file_num = (file_num + 1);
		}
	}
	if ((king.hasmoved && ((GetX(king.location) == 3) || (GetX(king.location) == 7))))
		score = (score + 25);
	if (chess_bot_eval_endgame)
		score = (score + (center * 4));
	else
		score = (score - (center * 4));
	return (score);
};

// Cheap mobility deliberately ignores pins and attacked king squares. Full
// legal generation here would dominate leaf evaluation cost; occupancy-based
// reach still identifies trapped and active pieces well enough for scoring.
float(entity piece) ChessBotPseudoMobility =
{
	local entity occupant;
	local float piece_type;
	local float candidate;
	local float candidate_count;
	local float to_loc;
	local float mobility;

	piece_type = ChessPieceType(piece);
	candidate_count = ChessCandidateCount(piece);
	candidate = 1;
	mobility = MSG_BROADCAST;
	while ((candidate <= candidate_count))
	{
		to_loc = ChessCandidateLocation(piece, candidate);
		if (ChessLocOnBoard(to_loc))
		{
			occupant = ChessOccupantAt(to_loc);
			if ((piece_type == CHESS_PAWN))
			{
				if (ChessPseudoLegalMove(piece, to_loc))
					mobility = (mobility + 1);
			}
			else if (!((piece_type == CHESS_KING) && (candidate > 8)))
			{
				if (((occupant == world) || (occupant.owner != piece.owner)))
					mobility = (mobility + 1);
			}
		}
		if (ChessCandidateEndsRay(piece, candidate, to_loc))
			candidate = (ceil((candidate / 7)) * 7);
		candidate = (candidate + 1);
	}
	return (mobility);
};

float(entity piece) ChessBotPositionalScore =
{
	local float piece_type;
	local float score;
	local float x;
	local float y;
	local float center;
	local float mobility;

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
		score = (score + ChessBotPawnStructureScore(piece));
	}
	else if ((piece_type == CHESS_KNIGHT))
		score = (score + (center * 6));
	else if ((piece_type == CHESS_BISHOP))
		score = (score + (center * 3));
	else if ((piece_type == CHESS_ROOK))
	{
		if ((((piece.chess_team == "white") && (y == 7)) || ((piece.chess_team == "black") && (y == 2))))
			score = (score + 12);
		score = (score + ChessBotRookFileScore(piece));
	}
	else if ((piece_type == CHESS_QUEEN))
		score = (score + center);
	else if ((piece_type == CHESS_KING))
		score = (score + ChessBotKingSafetyScore(piece, center));
	mobility = ChessBotPseudoMobility(piece);
	if (((piece_type == CHESS_KNIGHT) || (piece_type == CHESS_BISHOP)))
		score = (score + (mobility * 3));
	else if ((piece_type == CHESS_ROOK))
		score = (score + (mobility * 2));
	else if (((piece_type == CHESS_QUEEN) || (piece_type == CHESS_KING)))
		score = (score + mobility);
	else if ((piece_type == CHESS_PAWN))
		score = (score + (mobility * 2));
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
	ChessBotPrepareEvaluation();
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
float(entity side, float alpha, float beta, float ply, float qdepth) ChessBotQuiescence;

float(float loc) ChessBotSquareIndex =
{
	return ((((GetX(loc) - 1) * 8) + (GetY(loc) - 1)));
};

float(entity side, entity piece, float to_loc) ChessBotHistoryIndex =
{
	local float side_offset;
	local float piece_offset;

	side_offset = MSG_BROADCAST;
	if ((side.chess_team == "black"))
		side_offset = 384;
	piece_offset = ((ChessPieceType(piece) - 1) * 64);
	return ((side_offset + piece_offset) + ChessBotSquareIndex(to_loc));
};

float(entity side, entity piece, float to_loc) ChessBotHistoryScore =
{
	return (chess_bot_history[ChessBotHistoryIndex(side, piece, to_loc)]);
};

void() ChessBotResetOrdering =
{
	local float i;

	i = MSG_BROADCAST;
	while ((i < 8))
	{
		chess_bot_killer1_from[i] = MSG_BROADCAST;
		chess_bot_killer1_to[i] = MSG_BROADCAST;
		chess_bot_killer1_promotion[i] = MSG_BROADCAST;
		chess_bot_killer2_from[i] = MSG_BROADCAST;
		chess_bot_killer2_to[i] = MSG_BROADCAST;
		chess_bot_killer2_promotion[i] = MSG_BROADCAST;
		chess_bot_previous_pv_from[i] = MSG_BROADCAST;
		chess_bot_previous_pv_to[i] = MSG_BROADCAST;
		chess_bot_previous_pv_promotion[i] = MSG_BROADCAST;
		chess_bot_line_key1[i] = MSG_BROADCAST;
		chess_bot_line_key2[i] = MSG_BROADCAST;
		i = (i + 1);
	}
	// Keep history across turns, but decay it so recent cutoffs dominate.
	i = MSG_BROADCAST;
	while ((i < 768))
	{
		chess_bot_history[i] = floor((chess_bot_history[i] * 0.5));
		i = (i + 1);
	}
};

void(float ply) ChessBotClearPVRow =
{
	local float row;
	local float i;

	row = floor(ply);
	if (((row < MSG_BROADCAST) || (row > 7)))
		return;
	i = row;
	while ((i < 8))
	{
		chess_bot_pv_from[((row * 8) + i)] = MSG_BROADCAST;
		chess_bot_pv_to[((row * 8) + i)] = MSG_BROADCAST;
		chess_bot_pv_promotion[((row * 8) + i)] = MSG_BROADCAST;
		i = (i + 1);
	}
};

void(float ply, float from_loc, float to_loc, float promotion) ChessBotSetPV =
{
	local float row;
	local float child_row;
	local float i;

	row = floor(ply);
	if (((row < MSG_BROADCAST) || (row > 7)))
		return;
	chess_bot_pv_from[((row * 8) + row)] = from_loc;
	chess_bot_pv_to[((row * 8) + row)] = to_loc;
	chess_bot_pv_promotion[((row * 8) + row)] = promotion;
	child_row = (row + 1);
	i = child_row;
	while ((i < 8))
	{
		if ((child_row <= 7))
		{
			chess_bot_pv_from[((row * 8) + i)] = chess_bot_pv_from[((child_row * 8) + i)];
			chess_bot_pv_to[((row * 8) + i)] = chess_bot_pv_to[((child_row * 8) + i)];
			chess_bot_pv_promotion[((row * 8) + i)] = chess_bot_pv_promotion[((child_row * 8) + i)];
		}
		i = (i + 1);
	}
};

void() ChessBotCommitPV =
{
	local float i;

	i = MSG_BROADCAST;
	while ((i < 8))
	{
		chess_bot_previous_pv_from[i] = chess_bot_pv_from[i];
		chess_bot_previous_pv_to[i] = chess_bot_pv_to[i];
		chess_bot_previous_pv_promotion[i] = chess_bot_pv_promotion[i];
		i = (i + 1);
	}
};

float(float ply, float from_loc, float to_loc, float promotion) ChessBotIsPreviousPVMove =
{
	local float row;

	row = floor(ply);
	if (((row < MSG_BROADCAST) || (row > 7)))
		return (FALSE);
	return ((((chess_bot_previous_pv_from[row] == from_loc) && (chess_bot_previous_pv_to[row] == to_loc)) && (chess_bot_previous_pv_promotion[row] == promotion)));
};

float(float ply, float from_loc, float to_loc, float promotion) ChessBotIsKillerMove =
{
	local float row;

	row = floor(ply);
	if (((row < MSG_BROADCAST) || (row > 7)))
		return (FALSE);
	if ((((chess_bot_killer1_from[row] == from_loc) && (chess_bot_killer1_to[row] == to_loc)) && (chess_bot_killer1_promotion[row] == promotion)))
		return (TRUE);
	return ((((chess_bot_killer2_from[row] == from_loc) && (chess_bot_killer2_to[row] == to_loc)) && (chess_bot_killer2_promotion[row] == promotion)));
};

void(entity side, entity piece, float to_loc, float promotion, float ply, float depth) ChessBotRecordQuietCutoff =
{
	local float row;
	local float from_loc;
	local float history_index;
	local float bonus;

	row = floor(ply);
	from_loc = piece.location;
	if (((row >= MSG_BROADCAST) && (row <= 7)))
	{
		if (!(((chess_bot_killer1_from[row] == from_loc) && (chess_bot_killer1_to[row] == to_loc)) && (chess_bot_killer1_promotion[row] == promotion)))
		{
			chess_bot_killer2_from[row] = chess_bot_killer1_from[row];
			chess_bot_killer2_to[row] = chess_bot_killer1_to[row];
			chess_bot_killer2_promotion[row] = chess_bot_killer1_promotion[row];
			chess_bot_killer1_from[row] = from_loc;
			chess_bot_killer1_to[row] = to_loc;
			chess_bot_killer1_promotion[row] = promotion;
		}
	}
	history_index = ChessBotHistoryIndex(side, piece, to_loc);
	bonus = ((depth * depth) * 4);
	if ((bonus < 1))
		bonus = 1;
	chess_bot_history[history_index] = (chess_bot_history[history_index] + bonus);
	if ((chess_bot_history[history_index] > 10000))
		chess_bot_history[history_index] = 10000;
};

// Lower values are searched first. Promotions and favorable captures usually
// produce the strongest alpha-beta cutoffs; losing captures follow them. When
// the king is in check, quiet evasions form the final class.
float(entity piece, entity captured, float to_loc, float in_check) ChessBotMoveOrderClass =
{
	local float exchange_score;

	if (ChessWouldPromote(piece, to_loc))
		return (1);
	if ((captured != world))
	{
		exchange_score = ((ChessMaterialValue(captured) * 10) - ChessMaterialValue(piece));
		if ((exchange_score >= 7000))
			return (1);
		if ((exchange_score >= 3500))
			return (2);
		if ((exchange_score >= 1500))
			return (3);
		return (4);
	}
	if (in_check)
		return (5);
	return (MSG_BROADCAST);
};

float(entity side, entity piece, entity captured, float to_loc, float promotion, float ply) ChessBotSearchOrderClass =
{
	local float tactical_class;

	if (ChessBotIsPreviousPVMove(ply, piece.location, to_loc, promotion))
		return (1);
	tactical_class = ChessBotMoveOrderClass(piece, captured, to_loc, FALSE);
	if ((tactical_class > MSG_BROADCAST))
		return (tactical_class + 1);
	if (ChessBotIsKillerMove(ply, piece.location, to_loc, promotion))
		return (6);
	if ((ChessBotHistoryScore(side, piece, to_loc) > MSG_BROADCAST))
		return (7);
	return (8);
};

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
	local float repetition_occurrences;

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
	repetition_occurrences = MSG_BROADCAST;
	if ((ply == MSG_BROADCAST))
		repetition_occurrences = ChessBotGamePositionOccurrences(side.opponent);
	king = get_king(side);
	legal = ((king != world) && !ChessSquareAttacked(king.location, side.opponent));
	if (legal)
	{
		chess_bot_nodes = (chess_bot_nodes + 1);
		if ((chess_bot_work > chess_bot_work_limit))
			chess_bot_abort = TRUE;
		if (!chess_bot_abort)
		{
			if ((depth > MSG_BROADCAST))
				score = -ChessBotSearch(side.opponent, (depth - 1), -beta, -alpha, (ply + 1));
			else
				score = -ChessBotQuiescence(side.opponent, -beta, -alpha, (ply + 1), ((MSG_BROADCAST - depth) - 1));
			if (((repetition_occurrences > MSG_BROADCAST) && (fabs(score) < (CHESS_BOT_MATE - 1000))))
				score = (score - (repetition_occurrences * 30));
		}
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

// Continue unstable leaf positions through captures, promotions, and all
// legal check evasions. This prevents the fixed-depth search from stopping in
// the middle of an exchange and valuing a temporarily won piece as permanent.
float(entity side, float alpha, float beta, float ply, float qdepth) ChessBotQuiescence =
{
	local entity piece;
	local entity captured;
	local float candidate;
	local float candidate_count;
	local float to_loc;
	local float promotion;
	local float max_promotion;
	local float in_check;
	local float order_class;
	local float wanted_class;
	local float max_class;
	local float score;
	local float best;
	local float any_move;

	if (chess_bot_abort)
		return (MSG_BROADCAST);
	if (ChessBotSearchPositionRepeated(side, ply))
		return (MSG_BROADCAST);
	in_check = ChessInCheck(side);
	best = -100000;
	if (!in_check)
	{
		best = ChessBotEvaluate(side);
		if ((best >= beta))
			return (best);
		if ((best > alpha))
			alpha = best;
	}
	if ((qdepth <= MSG_BROADCAST))
	{
		if (in_check)
			return (ChessBotEvaluate(side));
		return (best);
	}
	any_move = FALSE;
	max_class = 4;
	if (in_check)
		max_class = 5;
	wanted_class = 1;
	while (((wanted_class <= max_class) && !chess_bot_abort))
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
					order_class = ChessBotMoveOrderClass(piece, captured, to_loc, in_check);
					if ((order_class == wanted_class))
					{
						max_promotion = CHESS_PROMOTE_QUEEN;
						if (ChessWouldPromote(piece, to_loc))
							max_promotion = CHESS_PROMOTE_KNIGHT;
						promotion = CHESS_PROMOTE_QUEEN;
						while (((promotion <= max_promotion) && !chess_bot_abort))
						{
							score = ChessBotScoreMove(side, piece, to_loc, promotion, (MSG_BROADCAST - qdepth), alpha, beta, ply);
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
		wanted_class = (wanted_class + 1);
	}
	if (chess_bot_abort)
		return (MSG_BROADCAST);
	if ((in_check && !any_move))
		return ((-CHESS_BOT_MATE) + ply);
	return (best);
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
	local float order_class;
	local float from_loc;
	local float score;
	local float best;
	local float any_move;

	if (chess_bot_abort)
		return (MSG_BROADCAST);
	if (ChessBotSearchPositionRepeated(side, ply))
		return (MSG_BROADCAST);
	ChessBotClearPVRow(ply);
	if ((depth <= MSG_BROADCAST))
		return (ChessBotQuiescence(side, alpha, beta, ply, ChessBotQuiescenceDepth()));
	best = -100000;
	any_move = FALSE;
	pass_num = 1;
	while (((pass_num <= 8) && !chess_bot_abort))
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
					max_promotion = CHESS_PROMOTE_QUEEN;
					if (ChessWouldPromote(piece, to_loc))
						max_promotion = CHESS_PROMOTE_KNIGHT;
					promotion = CHESS_PROMOTE_QUEEN;
					while (((promotion <= max_promotion) && !chess_bot_abort))
					{
						order_class = ChessBotSearchOrderClass(side, piece, captured, to_loc, promotion, ply);
						if ((order_class == pass_num))
						{
							from_loc = piece.location;
							score = ChessBotScoreMove(side, piece, to_loc, promotion, depth, alpha, beta, ply);
							if ((score != CHESS_BOT_INVALID))
							{
								any_move = TRUE;
								if ((score > best))
								{
									best = score;
									ChessBotSetPV(ply, from_loc, to_loc, promotion);
								}
								if ((score > alpha))
									alpha = score;
								if ((alpha >= beta))
								{
									if (((captured == world) && !ChessWouldPromote(piece, to_loc)))
										ChessBotRecordQuietCutoff(side, piece, to_loc, promotion, ply, depth);
									return (best);
								}
							}
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
	ChessBotResetOrdering();
	ChessBotClearPVRow(MSG_BROADCAST);
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
	local float order_class;

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
			ChessBotSetPV(MSG_BROADCAST, chess_bot_root_piece.location, to_loc, chess_bot_root_promotion);
		}
		chess_bot_root_piece = ChessBotNextRootPiece(chess_bot_side, world);
		chess_bot_root_candidate = 1;
		chess_bot_root_promotion = CHESS_PROMOTE_QUEEN;
		return (TRUE);
	}

	if ((chess_bot_root_piece == world))
	{
		if ((chess_bot_root_pass < 6))
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
			if ((chess_bot_root_pass < 6))
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
	if (tactical)
		order_class = ChessBotMoveOrderClass(chess_bot_root_piece, captured, to_loc, FALSE);
	else if ((ChessBotHistoryScore(chess_bot_side, chess_bot_root_piece, to_loc) > MSG_BROADCAST))
		order_class = 5;
	else
		order_class = 6;
	if ((chess_bot_root_pass != order_class))
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
			ChessBotSetPV(MSG_BROADCAST, chess_bot_root_piece.location, to_loc, chess_bot_root_promotion);
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
			ChessBotCommitPV();
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

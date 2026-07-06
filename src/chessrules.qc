// Vanilla-compatible logical chess board and rules used by the chess bot.
// Search code must not call the live, side-effecting CanMove path.

float CHESS_PAWN = 1;
float CHESS_KNIGHT = 2;
float CHESS_BISHOP = 3;
float CHESS_ROOK = 4;
float CHESS_QUEEN = 5;
float CHESS_KING = 6;

float CHESS_PROMOTE_QUEEN = 1;
float CHESS_PROMOTE_ROOK = 2;
float CHESS_PROMOTE_BISHOP = 3;
float CHESS_PROMOTE_KNIGHT = 4;

void(entity file_ent) ChessClearFile =
{
	file_ent.occ1 = world;
	file_ent.occ2 = world;
	file_ent.occ3 = world;
	file_ent.occ4 = world;
	file_ent.occ5 = world;
	file_ent.occ6 = world;
	file_ent.occ7 = world;
	file_ent.occ8 = world;
};

entity(float file_num) ChessFileEntity =
{
	if ((file_num == 1))
		return (chess_file1);
	if ((file_num == 2))
		return (chess_file2);
	if ((file_num == 3))
		return (chess_file3);
	if ((file_num == 4))
		return (chess_file4);
	if ((file_num == 5))
		return (chess_file5);
	if ((file_num == 6))
		return (chess_file6);
	if ((file_num == 7))
		return (chess_file7);
	if ((file_num == 8))
		return (chess_file8);
	return (world);
};

void() ChessEnsureOccupancy =
{
	if ((chess_file1 == world))
	{
		chess_file1 = spawn();
		chess_file1.classname = "chess_file_index";
	}
	if ((chess_file2 == world))
	{
		chess_file2 = spawn();
		chess_file2.classname = "chess_file_index";
	}
	if ((chess_file3 == world))
	{
		chess_file3 = spawn();
		chess_file3.classname = "chess_file_index";
	}
	if ((chess_file4 == world))
	{
		chess_file4 = spawn();
		chess_file4.classname = "chess_file_index";
	}
	if ((chess_file5 == world))
	{
		chess_file5 = spawn();
		chess_file5.classname = "chess_file_index";
	}
	if ((chess_file6 == world))
	{
		chess_file6 = spawn();
		chess_file6.classname = "chess_file_index";
	}
	if ((chess_file7 == world))
	{
		chess_file7 = spawn();
		chess_file7.classname = "chess_file_index";
	}
	if ((chess_file8 == world))
	{
		chess_file8 = spawn();
		chess_file8.classname = "chess_file_index";
	}
};

void() ChessClearOccupancy =
{
	ChessEnsureOccupancy();
	ChessClearFile(chess_file1);
	ChessClearFile(chess_file2);
	ChessClearFile(chess_file3);
	ChessClearFile(chess_file4);
	ChessClearFile(chess_file5);
	ChessClearFile(chess_file6);
	ChessClearFile(chess_file7);
	ChessClearFile(chess_file8);
};

entity(float loc) ChessOccupantAt =
{
	local entity file_ent;
	local float rank_num;

	file_ent = ChessFileEntity(GetX(loc));
	if ((file_ent == world))
		return (world);
	rank_num = GetY(loc);
	if ((rank_num == 1))
		return (file_ent.occ1);
	if ((rank_num == 2))
		return (file_ent.occ2);
	if ((rank_num == 3))
		return (file_ent.occ3);
	if ((rank_num == 4))
		return (file_ent.occ4);
	if ((rank_num == 5))
		return (file_ent.occ5);
	if ((rank_num == 6))
		return (file_ent.occ6);
	if ((rank_num == 7))
		return (file_ent.occ7);
	if ((rank_num == 8))
		return (file_ent.occ8);
	return (world);
};

void(float loc, entity occupant) ChessSetOccupant =
{
	local entity file_ent;
	local float rank_num;

	file_ent = ChessFileEntity(GetX(loc));
	if ((file_ent == world))
		return;
	rank_num = GetY(loc);
	if ((rank_num == 1))
		file_ent.occ1 = occupant;
	else if ((rank_num == 2))
		file_ent.occ2 = occupant;
	else if ((rank_num == 3))
		file_ent.occ3 = occupant;
	else if ((rank_num == 4))
		file_ent.occ4 = occupant;
	else if ((rank_num == 5))
		file_ent.occ5 = occupant;
	else if ((rank_num == 6))
		file_ent.occ6 = occupant;
	else if ((rank_num == 7))
		file_ent.occ7 = occupant;
	else if ((rank_num == 8))
		file_ent.occ8 = occupant;
};

float(entity piece) ChessPieceType =
{
	if ((piece == world))
		return (MSG_BROADCAST);
	if ((piece.classname == "chess_pawn"))
		return (CHESS_PAWN);
	if ((piece.classname == "chess_knight"))
		return (CHESS_KNIGHT);
	if ((piece.classname == "chess_bishop"))
		return (CHESS_BISHOP);
	if ((piece.classname == "chess_rook"))
		return (CHESS_ROOK);
	if ((piece.classname == "chess_queen"))
		return (CHESS_QUEEN);
	if ((piece.classname == "chess_king"))
		return (CHESS_KING);
	return (MSG_BROADCAST);
};

float(entity piece) ChessPieceLive =
{
	if ((piece == world))
		return (FALSE);
	if ((piece.health <= MSG_BROADCAST))
		return (FALSE);
	if (!(piece.flags & FL_MONSTER))
		return (FALSE);
	if (piece.ischecker)
		return (FALSE);
	return (ChessPieceType(piece) != MSG_BROADCAST);
};

float(float loc) ChessLocOnBoard =
{
	local float x;
	local float y;

	x = GetX(loc);
	y = GetY(loc);
	return ((((x >= 1) && (x <= 8)) && (y >= 1)) && (y <= 8));
};

void() ChessRebuildOccupancy =
{
	local entity piece;

	ChessClearOccupancy();
	piece = find(world, chess_team, "white");
	while ((piece != world))
	{
		if ((ChessPieceLive(piece) && ChessLocOnBoard(piece.location)))
			ChessSetOccupant(piece.location, piece);
		piece = find(piece, chess_team, "white");
	}
	piece = find(world, chess_team, "black");
	while ((piece != world))
	{
		if ((ChessPieceLive(piece) && ChessLocOnBoard(piece.location)))
			ChessSetOccupant(piece.location, piece);
		piece = find(piece, chess_team, "black");
	}
};

float() ChessOccupancyValid =
{
	local entity piece;
	local float x;
	local float y;
	local float loc;

	x = 1;
	while ((x <= 8))
	{
		y = 1;
		while ((y <= 8))
		{
			loc = ((x * 10) + y);
			piece = ChessOccupantAt(loc);
			if ((piece != world))
			{
				if (!ChessPieceLive(piece))
					return (FALSE);
				if ((piece.location != loc))
					return (FALSE);
			}
			y = (y + 1);
		}
		x = (x + 1);
	}
	piece = find(world, chess_team, "white");
	while ((piece != world))
	{
		if (ChessPieceLive(piece))
		{
			if (((piece.owner == world) || (piece.owner.chess_team != "white")))
				return (FALSE);
			if (!ChessLocOnBoard(piece.location))
				return (FALSE);
			if ((ChessOccupantAt(piece.location) != piece))
				return (FALSE);
		}
		piece = find(piece, chess_team, "white");
	}
	piece = find(world, chess_team, "black");
	while ((piece != world))
	{
		if (ChessPieceLive(piece))
		{
			if (((piece.owner == world) || (piece.owner.chess_team != "black")))
				return (FALSE);
			if (!ChessLocOnBoard(piece.location))
				return (FALSE);
			if ((ChessOccupantAt(piece.location) != piece))
				return (FALSE);
		}
		piece = find(piece, chess_team, "black");
	}
	return (TRUE);
};

float(float from_loc, float to_loc) ChessPathClear =
{
	local float from_x;
	local float from_y;
	local float to_x;
	local float to_y;
	local float step_x;
	local float step_y;
	local float x;
	local float y;
	local float guard;

	from_x = GetX(from_loc);
	from_y = GetY(from_loc);
	to_x = GetX(to_loc);
	to_y = GetY(to_loc);
	step_x = MSG_BROADCAST;
	step_y = MSG_BROADCAST;
	if ((to_x > from_x))
		step_x = 1;
	else if ((to_x < from_x))
		step_x = -1;
	if ((to_y > from_y))
		step_y = 1;
	else if ((to_y < from_y))
		step_y = -1;
	x = (from_x + step_x);
	y = (from_y + step_y);
	guard = MSG_BROADCAST;
	while ((((x != to_x) || (y != to_y)) && (guard < 8)))
	{
		chess_bot_work = (chess_bot_work + 1);
		if ((ChessOccupantAt(((x * 10) + y)) != world))
			return (FALSE);
		x = (x + step_x);
		y = (y + step_y);
		guard = (guard + 1);
	}
	return ((x == to_x) && (y == to_y));
};

entity(entity piece, float to_loc) ChessEnPassantCaptured =
{
	local entity captured;
	local entity opponent_side;
	local float capture_loc;
	local float old_x;
	local float old_y;
	local float new_x;
	local float new_y;

	if ((ChessPieceType(piece) != CHESS_PAWN))
		return (world);
	if ((ChessOccupantAt(to_loc) != world))
		return (world);
	old_x = GetX(piece.location);
	old_y = GetY(piece.location);
	new_x = GetX(to_loc);
	new_y = GetY(to_loc);
	if ((fabs(new_x - old_x) != 1))
		return (world);
	if ((fabs(new_y - old_y) != 1))
		return (world);
	capture_loc = ((new_x * 10) + old_y);
	captured = ChessOccupantAt(capture_loc);
	if ((captured == world))
		return (world);
	if ((ChessPieceType(captured) != CHESS_PAWN))
		return (world);
	if ((captured.owner == piece.owner))
		return (world);
	opponent_side = piece.owner.opponent;
	if ((opponent_side == world))
		return (world);
	if ((opponent_side.last_moved != captured))
		return (world);
	if ((opponent_side.last_move_to != captured.location))
		return (world);
	if ((fabs(GetY(opponent_side.last_move_to) - GetY(opponent_side.last_move_from)) != 2))
		return (world);
	return (captured);
};

entity(entity piece, float to_loc) ChessCapturedForMove =
{
	local entity captured;

	captured = ChessOccupantAt(to_loc);
	if ((captured != world))
		return (captured);
	return (ChessEnPassantCaptured(piece, to_loc));
};

entity(entity king, float to_loc) ChessCastleRook =
{
	local float old_x;
	local float new_x;
	local float rank_num;

	if ((ChessPieceType(king) != CHESS_KING))
		return (world);
	old_x = GetX(king.location);
	new_x = GetX(to_loc);
	rank_num = GetY(king.location);
	if ((fabs(new_x - old_x) != 2))
		return (world);
	if ((new_x < old_x))
		return (ChessOccupantAt((10 + rank_num)));
	return (ChessOccupantAt((80 + rank_num)));
};

float(entity king, float to_loc) ChessCastleRookDest =
{
	local float old_x;
	local float new_x;
	local float rank_num;

	old_x = GetX(king.location);
	new_x = GetX(to_loc);
	rank_num = GetY(king.location);
	if ((new_x < old_x))
		return ((((old_x - 1) * 10) + rank_num));
	return ((((old_x + 1) * 10) + rank_num));
};

float(entity piece, float to_loc) ChessWouldPromote =
{
	if ((ChessPieceType(piece) != CHESS_PAWN))
		return (FALSE);
	if (((piece.chess_team == "white") && (GetY(to_loc) == 8)))
		return (TRUE);
	if (((piece.chess_team == "black") && (GetY(to_loc) == 1)))
		return (TRUE);
	return (FALSE);
};

void(entity piece, float promotion) ChessSetPromotionClass =
{
	if ((promotion == CHESS_PROMOTE_ROOK))
		piece.classname = "chess_rook";
	else if ((promotion == CHESS_PROMOTE_BISHOP))
		piece.classname = "chess_bishop";
	else if ((promotion == CHESS_PROMOTE_KNIGHT))
		piece.classname = "chess_knight";
	else
		piece.classname = "chess_queen";
};

float(entity piece, float to_loc) ChessPseudoLegalMove =
{
	local entity target;
	local entity rook;
	local float piece_type;
	local float old_x;
	local float old_y;
	local float new_x;
	local float new_y;
	local float dx;
	local float dy;
	local float direction;
	local float start_rank;

	if (!ChessPieceLive(piece))
		return (FALSE);
	if (!ChessLocOnBoard(to_loc))
		return (FALSE);
	if ((piece.location == to_loc))
		return (FALSE);
	target = ChessOccupantAt(to_loc);
	if (((target != world) && (target.owner == piece.owner)))
		return (FALSE);
	if (((target != world) && (ChessPieceType(target) == CHESS_KING)))
		return (FALSE);
	piece_type = ChessPieceType(piece);
	old_x = GetX(piece.location);
	old_y = GetY(piece.location);
	new_x = GetX(to_loc);
	new_y = GetY(to_loc);
	dx = (new_x - old_x);
	dy = (new_y - old_y);

	if ((piece_type == CHESS_PAWN))
	{
		direction = 1;
		start_rank = 2;
		if ((piece.chess_team == "black"))
		{
			direction = -1;
			start_rank = 7;
		}
		if ((dx == MSG_BROADCAST))
		{
			if (((dy == direction) && (target == world)))
				return (TRUE);
			if (((((dy == (direction * 2)) && (old_y == start_rank)) && !piece.hasmoved) && (target == world)))
				return (ChessOccupantAt(((old_x * 10) + (old_y + direction))) == world);
			return (FALSE);
		}
		if (((fabs(dx) == 1) && (dy == direction)))
		{
			if (((target != world) && (target.owner != piece.owner)))
				return (TRUE);
			return (ChessEnPassantCaptured(piece, to_loc) != world);
		}
		return (FALSE);
	}
	if ((piece_type == CHESS_KNIGHT))
		return ((((fabs(dx) == 2) && (fabs(dy) == 1)) || ((fabs(dx) == 1) && (fabs(dy) == 2))));
	if ((piece_type == CHESS_BISHOP))
	{
		if ((fabs(dx) != fabs(dy)))
			return (FALSE);
		return (ChessPathClear(piece.location, to_loc));
	}
	if ((piece_type == CHESS_ROOK))
	{
		if (((dx != MSG_BROADCAST) && (dy != MSG_BROADCAST)))
			return (FALSE);
		return (ChessPathClear(piece.location, to_loc));
	}
	if ((piece_type == CHESS_QUEEN))
	{
		if (!(((fabs(dx) == fabs(dy)) || (dx == MSG_BROADCAST)) || (dy == MSG_BROADCAST)))
			return (FALSE);
		return (ChessPathClear(piece.location, to_loc));
	}
	if ((piece_type == CHESS_KING))
	{
		if (((fabs(dx) <= 1) && (fabs(dy) <= 1)))
			return (TRUE);
		if (((((dy == MSG_BROADCAST) && (fabs(dx) == 2)) && !piece.hasmoved) && (old_x == 5)))
		{
			if ((((piece.chess_team == "white") && (old_y != 1)) || ((piece.chess_team == "black") && (old_y != 8))))
				return (FALSE);
			rook = ChessCastleRook(piece, to_loc);
			if ((((rook == world) || !ChessPieceLive(rook)) || (ChessPieceType(rook) != CHESS_ROOK)))
				return (FALSE);
			if (((rook.owner != piece.owner) || rook.hasmoved))
				return (FALSE);
			return (ChessPathClear(piece.location, rook.location));
		}
	}
	return (FALSE);
};

float(float square, entity attacking_side) ChessSquareAttacked =
{
	local entity piece;
	local float piece_type;
	local float dx;
	local float dy;
	local float direction;

	if ((attacking_side == world))
		return (FALSE);
	piece = find(world, chess_team, attacking_side.chess_team);
	while ((piece != world))
	{
		if ((ChessPieceLive(piece) && (piece.owner == attacking_side)))
		{
			chess_bot_work = (chess_bot_work + 1);
			piece_type = ChessPieceType(piece);
			dx = (GetX(square) - GetX(piece.location));
			dy = (GetY(square) - GetY(piece.location));
			if ((piece_type == CHESS_PAWN))
			{
				direction = 1;
				if ((piece.chess_team == "black"))
					direction = -1;
				if (((fabs(dx) == 1) && (dy == direction)))
					return (TRUE);
			}
			else if ((piece_type == CHESS_KNIGHT))
			{
				if ((((fabs(dx) == 2) && (fabs(dy) == 1)) || ((fabs(dx) == 1) && (fabs(dy) == 2))))
					return (TRUE);
			}
			else if ((piece_type == CHESS_BISHOP))
			{
				if (((fabs(dx) == fabs(dy)) && ChessPathClear(piece.location, square)))
					return (TRUE);
			}
			else if ((piece_type == CHESS_ROOK))
			{
				if ((((dx == MSG_BROADCAST) || (dy == MSG_BROADCAST)) && ChessPathClear(piece.location, square)))
					return (TRUE);
			}
			else if ((piece_type == CHESS_QUEEN))
			{
				if (((((fabs(dx) == fabs(dy)) || (dx == MSG_BROADCAST)) || (dy == MSG_BROADCAST)) && ChessPathClear(piece.location, square)))
					return (TRUE);
			}
			else if ((piece_type == CHESS_KING))
			{
				if (((fabs(dx) <= 1) && (fabs(dy) <= 1)))
					return (TRUE);
			}
		}
		piece = find(piece, chess_team, attacking_side.chess_team);
	}
	return (FALSE);
};

float(entity side) ChessInCheck =
{
	local entity king;

	if ((side == world))
		return (FALSE);
	king = get_king(side);
	if ((king == world))
		return (TRUE);
	return (ChessSquareAttacked(king.location, side.opponent));
};

float(entity piece) ChessCandidateCount =
{
	local float piece_type;

	piece_type = ChessPieceType(piece);
	if ((piece_type == CHESS_PAWN))
		return (4);
	if ((piece_type == CHESS_KNIGHT))
		return (8);
	if ((piece_type == CHESS_BISHOP))
		return (28);
	if ((piece_type == CHESS_ROOK))
		return (28);
	if ((piece_type == CHESS_QUEEN))
		return (56);
	if ((piece_type == CHESS_KING))
		return (10);
	return (MSG_BROADCAST);
};

float(entity piece, float candidate) ChessCandidateLocation =
{
	local float piece_type;
	local float x;
	local float y;
	local float direction;
	local float direction_index;
	local float step;
	local float dx;
	local float dy;

	piece_type = ChessPieceType(piece);
	x = GetX(piece.location);
	y = GetY(piece.location);
	if ((piece_type == CHESS_PAWN))
	{
		direction = 1;
		if ((piece.chess_team == "black"))
			direction = -1;
		if ((candidate == 1))
			return ((x * 10) + y + direction);
		if ((candidate == 2))
			return ((x * 10) + y + (direction * 2));
		if ((candidate == 3))
			return (((x - 1) * 10) + y + direction);
		if ((candidate == 4))
			return (((x + 1) * 10) + y + direction);
	}
	if ((piece_type == CHESS_KNIGHT))
	{
		if ((candidate == 1)) return (((x + 2) * 10) + y + 1);
		if ((candidate == 2)) return (((x + 2) * 10) + y - 1);
		if ((candidate == 3)) return (((x - 2) * 10) + y + 1);
		if ((candidate == 4)) return (((x - 2) * 10) + y - 1);
		if ((candidate == 5)) return (((x + 1) * 10) + y + 2);
		if ((candidate == 6)) return (((x + 1) * 10) + y - 2);
		if ((candidate == 7)) return (((x - 1) * 10) + y + 2);
		if ((candidate == 8)) return (((x - 1) * 10) + y - 2);
	}
	if ((piece_type == CHESS_KING))
	{
		if ((candidate == 1)) return (((x + 1) * 10) + y);
		if ((candidate == 2)) return (((x - 1) * 10) + y);
		if ((candidate == 3)) return ((x * 10) + y + 1);
		if ((candidate == 4)) return ((x * 10) + y - 1);
		if ((candidate == 5)) return (((x + 1) * 10) + y + 1);
		if ((candidate == 6)) return (((x + 1) * 10) + y - 1);
		if ((candidate == 7)) return (((x - 1) * 10) + y + 1);
		if ((candidate == 8)) return (((x - 1) * 10) + y - 1);
		if ((candidate == 9)) return (((x - 2) * 10) + y);
		if ((candidate == 10)) return (((x + 2) * 10) + y);
	}
	if (((piece_type == CHESS_BISHOP) || (piece_type == CHESS_ROOK)) || (piece_type == CHESS_QUEEN))
	{
		direction_index = floor(((candidate - 1) / 7));
		step = (candidate - (direction_index * 7));
		dx = MSG_BROADCAST;
		dy = MSG_BROADCAST;
		if ((piece_type == CHESS_BISHOP))
			direction_index = (direction_index + 4);
		if ((direction_index == 0)) dx = 1;
		else if ((direction_index == 1)) dx = -1;
		else if ((direction_index == 2)) dy = 1;
		else if ((direction_index == 3)) dy = -1;
		else if ((direction_index == 4)) { dx = 1; dy = 1; }
		else if ((direction_index == 5)) { dx = 1; dy = -1; }
		else if ((direction_index == 6)) { dx = -1; dy = 1; }
		else if ((direction_index == 7)) { dx = -1; dy = -1; }
		return ((((x + (dx * step)) * 10) + y + (dy * step)));
	}
	return (MSG_BROADCAST);
};

float(entity piece, float candidate, float to_loc) ChessCandidateEndsRay =
{
	local float piece_type;

	piece_type = ChessPieceType(piece);
	if (!(((piece_type == CHESS_BISHOP) || (piece_type == CHESS_ROOK)) || (piece_type == CHESS_QUEEN)))
		return (FALSE);
	if (!ChessLocOnBoard(to_loc))
		return (TRUE);
	return (ChessOccupantAt(to_loc) != world);
};

float(entity piece, float to_loc) ChessCastleTransit =
{
	local float old_x;
	local float new_x;
	local float rank_num;

	old_x = GetX(piece.location);
	new_x = GetX(to_loc);
	rank_num = GetY(piece.location);
	if ((new_x < old_x))
		return ((((old_x - 1) * 10) + rank_num));
	return ((((old_x + 1) * 10) + rank_num));
};

float(entity piece, float to_loc) ChessCastleTransitSafe =
{
	local float old_loc;
	local float transit_loc;
	local float safe;

	old_loc = piece.location;
	transit_loc = ChessCastleTransit(piece, to_loc);
	ChessSetOccupant(old_loc, world);
	piece.location = transit_loc;
	ChessSetOccupant(transit_loc, piece);
	safe = !ChessSquareAttacked(transit_loc, piece.owner.opponent);
	ChessSetOccupant(transit_loc, world);
	piece.location = old_loc;
	ChessSetOccupant(old_loc, piece);
	return (safe);
};

float(entity piece, float to_loc, float promotion) ChessMoveIsLegal =
{
	local entity side;
	local entity captured;
	local entity rook;
	local entity king;
	local float old_loc;
	local float old_hasmoved;
	local string old_classname;
	local float captured_loc;
	local float captured_health;
	local float rook_loc;
	local float rook_hasmoved;
	local float rook_dest;
	local float legal;

	if (!ChessPseudoLegalMove(piece, to_loc))
		return (FALSE);
	side = piece.owner;
	if ((side == world))
		return (FALSE);
	if (((ChessPieceType(piece) == CHESS_KING) && (fabs(GetX(to_loc) - GetX(piece.location)) == 2)))
	{
		if (ChessSquareAttacked(piece.location, side.opponent))
			return (FALSE);
		if (!ChessCastleTransitSafe(piece, to_loc))
			return (FALSE);
	}
	captured = ChessCapturedForMove(piece, to_loc);
	rook = ChessCastleRook(piece, to_loc);
	rook_dest = MSG_BROADCAST;
	if ((rook != world))
		rook_dest = ChessCastleRookDest(piece, to_loc);
	old_loc = piece.location;
	old_hasmoved = piece.hasmoved;
	old_classname = piece.classname;
	captured_loc = MSG_BROADCAST;
	captured_health = MSG_BROADCAST;
	rook_loc = MSG_BROADCAST;
	rook_hasmoved = FALSE;
	if ((captured != world))
	{
		captured_loc = captured.location;
		captured_health = captured.health;
		ChessSetOccupant(captured.location, world);
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
	king = get_king(side);
	legal = ((king != world) && !ChessSquareAttacked(king.location, side.opponent));
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
	return (legal);
};

void(entity piece, float to_loc) ChessExplainInvalidMove =
{
	local entity target;
	local entity rook;
	local float piece_type;
	local float old_x;
	local float old_y;
	local float new_x;
	local float new_y;
	local float dx;
	local float dy;

	if ((piece == world))
		return;
	if (!ChessLocOnBoard(to_loc))
	{
		mysprint(piece.owner, "Invalid move: the destination is outside the board.\n");
		return;
	}
	target = ChessOccupantAt(to_loc);
	if (((target != world) && (target.owner == piece.owner)))
	{
		mysprint(piece.owner, "Invalid move: that square is occupied by one of your pieces.\n");
		return;
	}
	if (((target != world) && (ChessPieceType(target) == CHESS_KING)))
	{
		mysprint(piece.owner, "Invalid move: the king is checkmated, not captured.\n");
		return;
	}
	piece_type = ChessPieceType(piece);
	old_x = GetX(piece.location);
	old_y = GetY(piece.location);
	new_x = GetX(to_loc);
	new_y = GetY(to_loc);
	dx = (new_x - old_x);
	dy = (new_y - old_y);

	if ((ChessPseudoLegalMove(piece, to_loc) && !(((piece_type == CHESS_KING) && (dy == MSG_BROADCAST)) && (fabs(dx) == 2))))
	{
		if ((piece_type == CHESS_KING))
			mysprint(piece.owner, "Invalid king move: the king cannot move into check.\n");
		else
			mysprint(piece.owner, "Invalid move: that would leave your king in check.\n");
		return;
	}
	if ((piece_type == CHESS_PAWN))
	{
		if (((dx == MSG_BROADCAST) && (target != world)))
			mysprint(piece.owner, "Invalid pawn move: pawns cannot move forward into an occupied square.\n");
		else if (((fabs(dx) == 1) && (target == world)))
			mysprint(piece.owner, "Invalid pawn move: pawns capture one square diagonally only when an enemy is present, except en passant.\n");
		else
			mysprint(piece.owner, "Invalid pawn move: pawns move one square forward, or two from their starting square, and capture one square diagonally.\n");
		return;
	}
	if ((piece_type == CHESS_KNIGHT))
	{
		mysprint(piece.owner, "Invalid knight move: knights move in an L shape, two squares in one direction and one sideways.\n");
		return;
	}
	if ((piece_type == CHESS_BISHOP))
	{
		if ((fabs(dx) == fabs(dy)))
			mysprint(piece.owner, "Invalid bishop move: bishops move diagonally, but another piece is blocking this path.\n");
		else
			mysprint(piece.owner, "Invalid bishop move: bishops can only move diagonally.\n");
		return;
	}
	if ((piece_type == CHESS_ROOK))
	{
		if (((dx == MSG_BROADCAST) || (dy == MSG_BROADCAST)))
			mysprint(piece.owner, "Invalid rook move: rooks move in straight lines, but another piece is blocking this path.\n");
		else
			mysprint(piece.owner, "Invalid rook move: rooks can only move horizontally or vertically.\n");
		return;
	}
	if ((piece_type == CHESS_QUEEN))
	{
		if ((((fabs(dx) == fabs(dy)) || (dx == MSG_BROADCAST)) || (dy == MSG_BROADCAST)))
			mysprint(piece.owner, "Invalid queen move: queens move in straight lines or diagonally, but another piece is blocking this path.\n");
		else
			mysprint(piece.owner, "Invalid queen move: queens can only move in straight lines or diagonally.\n");
		return;
	}
	if ((piece_type == CHESS_KING))
	{
		if (((dy == MSG_BROADCAST) && (fabs(dx) == 2)))
		{
			if (piece.hasmoved)
				mysprint(piece.owner, "Invalid castle: the king cannot castle after it has moved.\n");
			else if (!((old_x == 5) && (((piece.chess_team == "white") && (old_y == 1)) || ((piece.chess_team == "black") && (old_y == 8)))))
				mysprint(piece.owner, "Invalid castle: the king must be on its original square.\n");
			else
			{
				rook = ChessCastleRook(piece, to_loc);
				if ((((rook == world) || (ChessPieceType(rook) != CHESS_ROOK)) || (rook.owner != piece.owner)))
					mysprint(piece.owner, "Invalid castle: the required rook is not on its original square.\n");
				else if (rook.hasmoved)
					mysprint(piece.owner, "Invalid castle: the rook cannot castle after it has moved.\n");
				else if (!ChessPathClear(piece.location, rook.location))
					mysprint(piece.owner, "Invalid castle: every square between the king and rook must be empty.\n");
				else if (ChessSquareAttacked(piece.location, piece.owner.opponent))
					mysprint(piece.owner, "Invalid castle: the king cannot castle out of check.\n");
				else if (!ChessCastleTransitSafe(piece, to_loc))
					mysprint(piece.owner, "Invalid castle: the king cannot castle through an attacked square.\n");
				else
					mysprint(piece.owner, "Invalid castle: the king cannot castle into check.\n");
			}
		}
		else
			mysprint(piece.owner, "Invalid king move: kings move one square in any direction, except when castling.\n");
		return;
	}
	mysprint(piece.owner, "Invalid move: the selected entity is not a chess piece.\n");
};

float(entity piece) ChessPieceHasLegalMove =
{
	local float candidate;
	local float candidate_count;
	local float to_loc;
	local float promotion;

	if (!ChessPieceLive(piece))
		return (FALSE);
	candidate_count = ChessCandidateCount(piece);
	candidate = 1;
	while ((candidate <= candidate_count))
	{
		to_loc = ChessCandidateLocation(piece, candidate);
		promotion = CHESS_PROMOTE_QUEEN;
		while ((promotion <= CHESS_PROMOTE_KNIGHT))
		{
			if (ChessMoveIsLegal(piece, to_loc, promotion))
				return (TRUE);
			if (!ChessWouldPromote(piece, to_loc))
				promotion = CHESS_PROMOTE_KNIGHT;
			promotion = (promotion + 1);
		}
		if (ChessCandidateEndsRay(piece, candidate, to_loc))
			candidate = (ceil((candidate / 7)) * 7);
		candidate = (candidate + 1);
	}
	return (FALSE);
};

float(entity side) ChessHasLegalMove =
{
	local entity piece;

	if ((side == world))
		return (FALSE);
	piece = find(world, chess_team, side.chess_team);
	while ((piece != world))
	{
		if ((ChessPieceLive(piece) && (piece.owner == side)))
		{
			if (ChessPieceHasLegalMove(piece))
				return (TRUE);
		}
		piece = find(piece, chess_team, side.chess_team);
	}
	return (FALSE);
};

float(entity piece) ChessMaterialValue =
{
	local float piece_type;

	piece_type = ChessPieceType(piece);
	if ((piece_type == CHESS_PAWN)) return (100);
	if ((piece_type == CHESS_KNIGHT)) return (320);
	if ((piece_type == CHESS_BISHOP)) return (330);
	if ((piece_type == CHESS_ROOK)) return (500);
	if ((piece_type == CHESS_QUEEN)) return (900);
	if ((piece_type == CHESS_KING)) return (20000);
	return (MSG_BROADCAST);
};

float() ChessPositionChecksum =
{
	local entity piece;
	local float checksum;

	checksum = MSG_BROADCAST;
	piece = find(world, chess_team, "white");
	while ((piece != world))
	{
		if (ChessPieceLive(piece))
			checksum = (checksum + (piece.location * (ChessPieceType(piece) + 11)) + ChessMaterialValue(piece) + (piece.hasmoved * 101));
		piece = find(piece, chess_team, "white");
	}
	piece = find(world, chess_team, "black");
	while ((piece != world))
	{
		if (ChessPieceLive(piece))
			checksum = (checksum + (piece.location * (ChessPieceType(piece) + 29)) + ChessMaterialValue(piece) + (piece.hasmoved * 211));
		piece = find(piece, chess_team, "black");
	}
	return (checksum);
};

float() ChessOccupancyChecksum =
{
	local entity piece;
	local float x;
	local float y;
	local float loc;
	local float checksum;

	checksum = MSG_BROADCAST;
	x = 1;
	while ((x <= 8))
	{
		y = 1;
		while ((y <= 8))
		{
			loc = ((x * 10) + y);
			piece = ChessOccupantAt(loc);
			if ((piece != world))
				checksum = (checksum + (loc * (ChessPieceType(piece) + 43)));
			y = (y + 1);
		}
		x = (x + 1);
	}
	return (checksum);
};

float(entity side) ChessLivePieceCount =
{
	local entity piece;
	local float count;

	count = MSG_BROADCAST;
	piece = find(world, chess_team, side.chess_team);
	while ((piece != world))
	{
		if (ChessPieceLive(piece))
			count = (count + 1);
		piece = find(piece, chess_team, side.chess_team);
	}
	return (count);
};

float(entity side) ChessMaterialTotal =
{
	local entity piece;
	local float total;

	total = MSG_BROADCAST;
	piece = find(world, chess_team, side.chess_team);
	while ((piece != world))
	{
		if (ChessPieceLive(piece))
			total = (total + ChessMaterialValue(piece));
		piece = find(piece, chess_team, side.chess_team);
	}
	return (total);
};

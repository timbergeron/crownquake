void(entity client, string event, float imp) Menu_DebugState =
{
	if (!cvar("cq_debug"))
	{
		return;
	}
	bprint("** MENU DEBUG: ");
	bprint(event);
	bprint(" screen=");
	bprint(ftos(client.menu_screen));
	bprint(" impulse=");
	bprint(ftos(imp));
	bprint(" selected_checkers=");
	bprint(ftos(menu_selected_checkers));
	bprint(" single_player=");
	bprint(ftos(single_player));
	bprint(" teamplay=");
	bprint(ftos(cvar("teamplay")));
	bprint(" game_checkers=");
	bprint(ftos(game_checkers));
	bprint(" checkers=");
	bprint(ftos(cvar("checkers")));
	bprint(" bot=");
	bprint(ftos(cvar("bot")));
	bprint(" restart=");
	bprint(ftos(cvar("cq_menustart")));
	bprint("\n");
};

string(float digit) Menu_GoldNumber =
{
	return (chr2str((18 + digit)));
};

string(float digit, string label) Menu_Row =
{
	return (strcat("  ", Menu_GoldNumber(digit), "  ", label, "\n"));
};

entity(entity side) Menu_ClientForSide =
{
	if ((side == world))
	{
		return (world);
	}
	if ((side.flags & FL_CLIENT))
	{
		return (side);
	}
	if ((side.owner != world))
	{
		return (side.owner);
	}
	return (world);
};

void(entity client, float screen) Menu_OpenForClient =
{
	if ((client == world))
	{
		return;
	}
	if (!client.menu_screen)
	{
		client.menu_open_time = time;
	}
	if ((client.menu_screen != screen))
	{
		client.menu_accept_time = (time + 0.25);
	}
	client.menu_screen = screen;
	client.menu_cursor = 1;
	client.menu_refresh = MSG_BROADCAST;
};

void(entity client) Menu_ClearClient =
{
	if ((client == world))
	{
		return;
	}
	client.menu_screen = MENU_SCREEN_NONE;
	client.menu_cursor = MSG_BROADCAST;
	client.menu_refresh = MSG_BROADCAST;
	client.menu_open_time = MSG_BROADCAST;
	client.menu_accept_time = MSG_BROADCAST;
	client.menu_return_screen = MENU_SCREEN_NONE;
	client.menu_winner = world;
	centerprint(client, "");
};

void() Menu_ClearAllClients =
{
	local entity client1;
	local entity client2;

	client1 = Menu_ClientForSide(player1);
	client2 = Menu_ClientForSide(player2);
	Menu_ClearClient(client1);
	if ((client2 != client1))
	{
		Menu_ClearClient(client2);
	}
};

void(float screen) Menu_Open =
{
	Menu_OpenForClient(self, screen);
};

void(entity client) Menu_EnablePregameFlyBinds =
{
	if ((client == world))
	{
		return;
	}
	stuffcmd(client, "bind space +jump\n");
};

void(entity client) Menu_RestoreGameBinds =
{
	if ((client == world))
	{
		return;
	}
	stuffcmd(client, "-jump\n");
	stuffcmd(client, "bind space \"impulse 100\"\n");
};

void() Menu_RestoreGameBindsAll =
{
	local entity client1;
	local entity client2;

	client1 = Menu_ClientForSide(player1);
	client2 = Menu_ClientForSide(player2);
	Menu_RestoreGameBinds(client1);
	if ((client2 != client1))
	{
		Menu_RestoreGameBinds(client2);
	}
};

void() Menu_Close =
{
	if (((self.menu_open_time > MSG_BROADCAST) && (time_per_turn > MSG_BROADCAST)) && (((current_turn == self) || (single_player && (current_turn.owner == self)))))
	{
		current_turn.turn_starttime = (current_turn.turn_starttime + (time - self.menu_open_time));
	}
	self.menu_screen = MENU_SCREEN_NONE;
	self.menu_cursor = MSG_BROADCAST;
	self.menu_refresh = MSG_BROADCAST;
	self.menu_open_time = MSG_BROADCAST;
	self.menu_accept_time = MSG_BROADCAST;
	self.menu_return_screen = MENU_SCREEN_NONE;
	centerprint(self, "");
};

void() Menu_OpenStartupModeSelect =
{
	local entity client;

	if (menu_startup_shown)
	{
		return;
	}
	if ((current_turn != world))
	{
		client = Menu_ClientForSide(current_turn);
	}
	else
	{
		client = Menu_ClientForSide(player1);
	}
	if ((client == world))
	{
		return;
	}
	menu_startup_shown = TRUE;
	menu_startup_pending = TRUE;
	client.menu_return_screen = MENU_SCREEN_NONE;
	Menu_OpenForClient(client, MENU_SCREEN_NEWGAME);
	Menu_EnablePregameFlyBinds(client);
	Menu_DebugState(client, "open startup", MSG_BROADCAST);
};

void(float use_checkers) Menu_StartWaitingForSecondPlayer =
{
	ChessPerftCancel();
	CheckersCancelBotSearch();
	ChessCancelBotSearch();
	ClearSelectionEffect();
	menu_startup_pending = FALSE;
	Menu_ClearAllClients();
	game_checkers = use_checkers;
	gameover = FALSE;
	action_flag = TRUE;
	king_dead = FALSE;
	ralcheckmate = FALSE;
	Queening = MSG_BROADCAST;
	QueenEnt = world;
	QueenTo = "";
	current_enemy = world;
	current_turn = world;
	current_selected = world;
	current_dest_int = MSG_BROADCAST;
	LastMoved = world;
	LastMovedLocation = MSG_BROADCAST;
	movenum = MSG_BROADCAST;
	ClearLastHighlight();
	if (game_checkers)
	{
		checkers_board_spawned = FALSE;
		SpawnCheckersBoard();
	}
	else
	{
		SpawnChessBoard();
	}
	if ((player1 != world))
	{
		player1.frags = MSG_BROADCAST;
		player1.currentammo = MSG_BROADCAST;
		player1.chess_flags = MSG_BROADCAST;
		player1.skin = 1;
		player1.last_moved = world;
		player1.last_move_from = MSG_BROADCAST;
		player1.last_move_to = MSG_BROADCAST;
		AllocateMonsters(player1);
		message_target = Menu_ClientForSide(player1);
		if ((message_entity == world))
		{
			message_entity = spawn();
		}
		message_text = "Waiting for other player..";
		message_entity.think = message_think;
		message_entity.nextthink = (time + 0.1);
		Menu_EnablePregameFlyBinds(message_target);
	}
};

void(float use_checkers) Menu_StartNewGame =
{
	Menu_DebugState(self, "start new game", use_checkers);
	if ((!single_player && (player2 == world)))
	{
		Menu_StartWaitingForSecondPlayer(use_checkers);
		return;
	}
	menu_startup_pending = FALSE;
	Menu_RestoreGameBindsAll();
	Menu_ClearAllClients();
	ResetGameToMode(use_checkers);
};

float() Menu_ResumeRestartSelection =
{
	local float selection;

	selection = floor(cvar("cq_menustart"));
	Menu_DebugState(self, "resume restart", selection);
	if (!selection)
	{
		return (FALSE);
	}
	if (((single_player && ((selection == 1) || (selection == 2))) || (!single_player && ((selection == 3) || (selection == 4)))))
	{
		cvar_set("cq_menustart", "0");
		localcmd("set cq_menustart 0\n");
		menu_startup_shown = TRUE;
		Menu_StartNewGame(((selection == 2) || (selection == 4)));
		return (TRUE);
	}
	cvar_set("cq_menustart", "0");
	localcmd("set cq_menustart 0\n");
	return (FALSE);
};

void(float want_single_player) Menu_StartSelectedGame =
{
	local float restart_selection;

	Menu_DebugState(self, "start selected game", want_single_player);
	cvar_set("bot", "0");
	cvar_set("checkers", ftos(menu_selected_checkers));
	if (((want_single_player && single_player) || (!want_single_player && !single_player)))
	{
		Menu_StartNewGame(menu_selected_checkers);
		return;
	}
	if ((want_single_player && (player2 != world)))
	{
		centerprint(self, "Disconnect the other player first\n");
		self.menu_refresh = (time + 1);
		return;
	}
	if (want_single_player)
	{
		cvar_set("teamplay", "0");
		restart_selection = (1 + menu_selected_checkers);
	}
	else
	{
		cvar_set("teamplay", "1");
		restart_selection = (3 + menu_selected_checkers);
	}
	cvar_set("cq_menustart", ftos(restart_selection));
	localcmd("set bot 0\n");
	if (menu_selected_checkers)
	{
		localcmd("set checkers 1\n");
	}
	else
	{
		localcmd("set checkers 0\n");
	}
	if (want_single_player)
	{
		localcmd("set teamplay 0\n");
		if (menu_selected_checkers)
		{
			localcmd("set cq_menustart 2\n");
		}
		else
		{
			localcmd("set cq_menustart 1\n");
		}
	}
	else
	{
		localcmd("set teamplay 1\n");
		if (menu_selected_checkers)
		{
			localcmd("set cq_menustart 4\n");
		}
		else
		{
			localcmd("set cq_menustart 3\n");
		}
	}
	Menu_DebugState(self, "queue player-mode restart", restart_selection);
	centerprint(self, "Changing player mode...\n");
	localcmd("restart\n");
};

void(float bot_side) Menu_StartCheckersBotGame =
{
	Menu_DebugState(self, "start bot game", bot_side);
	if ((!single_player && (player2 != world)))
	{
		self.menu_refresh = MSG_BROADCAST;
		return;
	}
	cvar_set("bot", ftos(bot_side));
	if (single_player)
	{
		Menu_StartNewGame(menu_selected_checkers);
		return;
	}
	cvar_set("checkers", ftos(menu_selected_checkers));
	cvar_set("teamplay", "0");
	if ((bot_side == 1))
	{
		localcmd("set bot 1\n");
	}
	else if ((bot_side == 3))
	{
		localcmd("set bot 3\n");
	}
	else
	{
		localcmd("set bot 2\n");
	}
	if (menu_selected_checkers)
		localcmd("set checkers 1\n");
	else
		localcmd("set checkers 0\n");
	localcmd("set teamplay 0\n");
	Menu_DebugState(self, "queue bot restart", bot_side);
	centerprint(self, "Starting single-player game...\n");
	localcmd("restart\n");
};

void(float depth) Menu_SetCheckersBotDepth =
{
	if ((depth < 1))
	{
		depth = 3;
	}
	if ((depth > 5))
	{
		depth = 5;
	}
	if (menu_selected_checkers)
	{
		cvar_set("checkersbotdepth", ftos(depth));
		localcmd(strcat("set checkersbotdepth ", ftos(depth), "\n"));
	}
	else
	{
		cvar_set("chessbotlevel", ftos(depth));
		localcmd(strcat("set chessbotlevel ", ftos(depth), "\n"));
	}
};

void(float bot_side, float return_screen) Menu_OpenCheckersBotLevel =
{
	if ((return_screen == MENU_SCREEN_PAUSE))
		menu_selected_checkers = game_checkers;
	menu_selected_bot_side = bot_side;
	self.menu_return_screen = return_screen;
	Menu_Open(MENU_SCREEN_BOTLEVEL);
};

void(entity winner) Menu_OpenGameOver =
{
	local entity client;

	client = Menu_ClientForSide(player1);
	if ((client != world))
	{
		client.menu_winner = winner;
		Menu_OpenForClient(client, MENU_SCREEN_GAMEOVER);
	}
	client = Menu_ClientForSide(player2);
	if (((client != world) && (client != Menu_ClientForSide(player1))))
	{
		client.menu_winner = winner;
		Menu_OpenForClient(client, MENU_SCREEN_GAMEOVER);
	}
};

void(entity loser) Menu_ResignSide =
{
	local entity winner;

	if ((loser == world))
	{
		return;
	}
	if (gameover)
	{
		return;
	}
	winner = loser.opponent;
	ChessPerftCancel();
	CheckersCancelBotSearch();
	ChessCancelBotSearch();
	gameover = TRUE;
	action_flag = TRUE;
	ClearSelectionEffect();
	if (game_checkers)
	{
		CheckersClearTurnState();
	}
	current_selected = world;
	ClearLastHighlight();
	if ((winner != world))
	{
		mycentreprint(winner, "YOU HAVE WON!");
		winner.skin = SPAWN_CRUCIFIED;
	}
	mycentreprint(loser, "You have resigned.");
	loser.skin = MSG_BROADCAST;
	bprint("** ");
	if ((loser.netname != ""))
	{
		bprint(loser.netname);
	}
	else
	{
		bprint("Player");
	}
	bprint(" resigns");
	if ((winner != world))
	{
		bprint("; ");
		bprint(winner.netname);
		bprint(" wins");
	}
	bprint("\n");
	Menu_OpenGameOver(winner);
};

void(float bot_side) Menu_SetCheckersBot =
{
	if (!single_player)
	{
		self.menu_refresh = MSG_BROADCAST;
		return;
	}
	cvar_set("bot", ftos(bot_side));
	CheckersApplyBotCvars();
	CheckersMaybeScheduleBotTurn();
	ChessMaybeScheduleBotTurn();
	Menu_Close();
};

void() Menu_SelectPause =
{
	local entity loser;

	if ((self.impulse == 1))
	{
		Menu_Close();
		return;
	}
	if ((self.impulse == 2))
	{
		self.menu_return_screen = MENU_SCREEN_PAUSE;
		Menu_Open(MENU_SCREEN_HELP);
		return;
	}
	if ((self.impulse == 3))
	{
		if (self.spectator)
		{
			self.menu_refresh = MSG_BROADCAST;
			return;
		}
		if (single_player)
		{
			if (current_turn.is_bot)
				loser = current_turn.opponent;
			else
				loser = current_turn;
		}
		else
		{
			loser = self;
		}
		Menu_ResignSide(loser);
		return;
	}
	if ((self.impulse == 4))
	{
		self.menu_return_screen = MENU_SCREEN_PAUSE;
		Menu_Open(MENU_SCREEN_NEWGAME);
		return;
	}
	if ((((single_player || (player2 == world)) && (self.impulse == 5))))
	{
		if (single_player)
		{
			Menu_SetCheckersBot(MSG_BROADCAST);
		}
		else
		{
			cvar_set("bot", "0");
			Menu_Close();
		}
		return;
	}
	if ((((single_player || (player2 == world)) && (self.impulse == 6))))
	{
		if (game_checkers)
			Menu_OpenCheckersBotLevel(1, MENU_SCREEN_PAUSE);
		else
			Menu_OpenCheckersBotLevel(2, MENU_SCREEN_PAUSE);
		return;
	}
	if ((((single_player || (player2 == world)) && (self.impulse == 7))))
	{
		if (game_checkers)
			Menu_OpenCheckersBotLevel(2, MENU_SCREEN_PAUSE);
		else
			Menu_OpenCheckersBotLevel(1, MENU_SCREEN_PAUSE);
		return;
	}
	if (((self.impulse == 20) || (self.impulse == 100)) || (self.impulse == 242))
	{
		Menu_Close();
		return;
	}
	self.menu_refresh = MSG_BROADCAST;
};

void() Menu_SelectHelp =
{
	if ((self.impulse == 1))
	{
		if (self.menu_return_screen)
		{
			Menu_Open(self.menu_return_screen);
			self.menu_return_screen = MENU_SCREEN_NONE;
		}
		else
		{
			Menu_Close();
		}
		return;
	}
	if (((self.impulse == 2) || (self.impulse == 20)) || (self.impulse == 200))
	{
		Menu_Close();
		return;
	}
	self.menu_refresh = MSG_BROADCAST;
};

void() Menu_SelectGameOver =
{
	if ((self.impulse == 1))
	{
		Menu_StartNewGame(game_checkers);
		return;
	}
	if ((self.impulse == 2))
	{
		self.menu_return_screen = MENU_SCREEN_GAMEOVER;
		Menu_Open(MENU_SCREEN_NEWGAME);
		return;
	}
	if ((self.impulse == 3))
	{
		self.menu_return_screen = MENU_SCREEN_GAMEOVER;
		Menu_Open(MENU_SCREEN_HELP);
		return;
	}
	if (((self.impulse == 4) || (self.impulse == 20)) || (self.impulse == 242))
	{
		Menu_Close();
		return;
	}
	self.menu_refresh = MSG_BROADCAST;
};

void() Menu_SelectNewGame =
{
	if ((self.impulse == 1))
	{
		menu_selected_checkers = TRUE;
		Menu_Open(MENU_SCREEN_GAMETYPE);
		return;
	}
	if ((self.impulse == 2))
	{
		menu_selected_checkers = FALSE;
		Menu_Open(MENU_SCREEN_GAMETYPE);
		return;
	}
	if ((self.impulse == 3))
	{
		Menu_Open(MENU_SCREEN_MAP);
		return;
	}
	if ((self.impulse == 4))
	{
		if (menu_startup_pending)
		{
			self.menu_refresh = MSG_BROADCAST;
			return;
		}
		if (self.menu_return_screen)
		{
			Menu_Open(self.menu_return_screen);
			self.menu_return_screen = MENU_SCREEN_NONE;
		}
		else
		{
			Menu_Close();
		}
		return;
	}
	self.menu_refresh = MSG_BROADCAST;
};

void() Menu_SelectMap =
{
	if (((self.impulse < 1) || (self.impulse > 4)))
	{
		self.menu_refresh = MSG_BROADCAST;
		return;
	}
	if ((self.impulse == 4))
	{
		Menu_Open(MENU_SCREEN_NEWGAME);
		return;
	}
	ChessPerftCancel();
	CheckersCancelBotSearch();
	ChessCancelBotSearch();
	cvar_set("bot", "0");
	cvar_set("cq_menustart", "0");
	localcmd("set bot 0\n");
	localcmd("set cq_menustart 0\n");
	centerprint(self, "Loading board map...\n");
	if ((self.impulse == 1))
		localcmd("map quess1\n");
	else if ((self.impulse == 2))
		localcmd("map quess2\n");
	else
		localcmd("map quess3\n");
};

void() Menu_SelectGameType =
{
	if ((self.impulse == 1))
	{
		Menu_Open(MENU_SCREEN_SIDE);
		return;
	}
	if ((self.impulse == 2))
	{
		Menu_StartSelectedGame(FALSE);
		return;
	}
	if ((self.impulse == 3))
	{
		Menu_OpenCheckersBotLevel(3, MENU_SCREEN_GAMETYPE);
		return;
	}
	if ((self.impulse == 4))
	{
		Menu_Open(MENU_SCREEN_NEWGAME);
		return;
	}
	self.menu_refresh = MSG_BROADCAST;
};

void() Menu_SelectSide =
{
	if ((self.impulse == 1))
	{
		if (menu_selected_checkers)
			Menu_OpenCheckersBotLevel(2, MENU_SCREEN_SIDE);
		else
			Menu_OpenCheckersBotLevel(1, MENU_SCREEN_SIDE);
		return;
	}
	if ((self.impulse == 2))
	{
		if (menu_selected_checkers)
			Menu_OpenCheckersBotLevel(1, MENU_SCREEN_SIDE);
		else
			Menu_OpenCheckersBotLevel(2, MENU_SCREEN_SIDE);
		return;
	}
	if ((self.impulse == 3))
	{
		Menu_Open(MENU_SCREEN_GAMETYPE);
		return;
	}
	self.menu_refresh = MSG_BROADCAST;
};

void() Menu_SelectBotLevel =
{
	local float return_screen;

	if (((self.impulse >= 1) && (self.impulse <= 5)))
	{
		Menu_SetCheckersBotDepth(self.impulse);
		return_screen = self.menu_return_screen;
		self.menu_return_screen = MENU_SCREEN_NONE;
		Menu_StartCheckersBotGame(menu_selected_bot_side);
		return;
	}
	if ((self.impulse == 6))
	{
		return_screen = self.menu_return_screen;
		self.menu_return_screen = MENU_SCREEN_NONE;
		if (return_screen)
		{
			Menu_Open(return_screen);
		}
		else
		{
			Menu_Open(MENU_SCREEN_SIDE);
		}
		return;
	}
	self.menu_refresh = MSG_BROADCAST;
};

void(float imp) Menu_Select =
{
	Menu_DebugState(self, "select", imp);
	if ((time < self.menu_accept_time))
	{
		Menu_DebugState(self, "ignored repeated input", imp);
		self.impulse = MSG_BROADCAST;
		return;
	}
	self.impulse = imp;
	if ((self.menu_screen == MENU_SCREEN_PAUSE))
	{
		Menu_SelectPause();
		return;
	}
	if ((self.menu_screen == MENU_SCREEN_HELP))
	{
		Menu_SelectHelp();
		return;
	}
	if ((self.menu_screen == MENU_SCREEN_GAMEOVER))
	{
		Menu_SelectGameOver();
		return;
	}
	if ((self.menu_screen == MENU_SCREEN_NEWGAME))
	{
		Menu_SelectNewGame();
		return;
	}
	if ((self.menu_screen == MENU_SCREEN_GAMETYPE))
	{
		Menu_SelectGameType();
		return;
	}
	if ((self.menu_screen == MENU_SCREEN_SIDE))
	{
		Menu_SelectSide();
		return;
	}
	if ((self.menu_screen == MENU_SCREEN_BOTLEVEL))
	{
		Menu_SelectBotLevel();
		return;
	}
	if ((self.menu_screen == MENU_SCREEN_MAP))
	{
		Menu_SelectMap();
		return;
	}
};

void() Menu_RenderPause =
{
	local string text;

	if (self.spectator)
	{
		centerprint(self,
			"\n"
			"\xC3\xD2\xCF\xD7\xCE\xD1\xD5\xC1\xCB\xC5 \xCD\xC5\xCE\xD5\n\n"
			"  ", Menu_GoldNumber(1), "  Resume           \n"
			"  ", Menu_GoldNumber(2), "  Help             \n");
		return;
	}
	if ((single_player || (player2 == world)))
	{
		text = strcat("\n", "\xC3\xD2\xCF\xD7\xCE\xD1\xD5\xC1\xCB\xC5 \xCD\xC5\xCE\xD5", "\n\n");
		text = strcat(text, Menu_Row(1, "Resume           "), Menu_Row(2, "Help             "), Menu_Row(3, "Resign           "), Menu_Row(4, "New Game         "));
		if (game_checkers)
			text = strcat(text, Menu_Row(5, "Bot Off          "), Menu_Row(6, "Bot Plays Red    "), Menu_Row(7, "Bot Plays Black  "));
		else
			text = strcat(text, Menu_Row(5, "Bot Off          "), Menu_Row(6, "Bot Plays White  "), Menu_Row(7, "Bot Plays Black  "));
		centerprint(self, text);
		return;
	}
	text = strcat("\n", "\xC3\xD2\xCF\xD7\xCE\xD1\xD5\xC1\xCB\xC5 \xCD\xC5\xCE\xD5", "\n\n");
	text = strcat(text, Menu_Row(1, "Resume           "), Menu_Row(2, "Help             "), Menu_Row(3, "Resign           "), Menu_Row(4, "New Game         "));
	centerprint(self, text);
};

void() Menu_RenderHelp =
{
	if (game_checkers)
	{
		centerprint(self,
			"\n"
			"\xC3\xC8\xC5\xC3\xCB\xC5\xD2\xD3 \xC8\xC5\xCC\xD0\n\n"
			"  Space/LMB  select or move \n"
			"  Del        unselect piece \n"
			"  F1         text board     \n"
			"  F2         game menu      \n"
			"  H          this help      \n\n"
			"Captures are mandatory.\n"
			"Multi-jumps must be finished.\n"
			"Passing is disabled.\n\n"
			"  ", Menu_GoldNumber(1), "  Back              \n"
			"  ", Menu_GoldNumber(2), "  Close             \n");
		return;
	}
	centerprint(self,
		"\n"
		"\xC3\xC8\xC5\xD3\xD3 \xC8\xC5\xCC\xD0\n\n"
		"  Space/LMB  select or move \n"
		"  Del        unselect piece \n"
		"  P          pass turn      \n"
		"  F1         text board     \n"
		"  F2         game menu      \n"
		"  H          this help      \n\n"
		"  ", Menu_GoldNumber(1), "  Back              \n"
		"  ", Menu_GoldNumber(2), "  Close             \n");
};

void() Menu_RenderGameOver =
{
	local string text;

	if ((self.menu_winner == world))
		text = strcat("\n", "\xC7\xC1\xCD\xC5 \xCF\xD6\xC5\xD2", "\n\nDraw by stalemate\n\n");
	else
		text = strcat("\n", "\xC7\xC1\xCD\xC5 \xCF\xD6\xC5\xD2", "\n\nWinner: ", self.menu_winner.netname, "\n\n");
	text = strcat(text, Menu_Row(1, "Rematch          "), Menu_Row(2, "New Game         "), Menu_Row(3, "Help             "), Menu_Row(4, "Close            "));
	centerprint(self, text);
};

void() Menu_RenderNewGame =
{
	local string text;

	if (menu_startup_pending)
	{
		text = strcat("\n", "\xD3\xC5\xCC\xC5\xC3\xD4 \xCD\xCF\xC4\xC5", "\n\n");
		text = strcat(text, Menu_Row(1, "Checkers            "), Menu_Row(2, "Chess               "), Menu_Row(3, "Select Map          "));
		centerprint(self, text);
		return;
	}
	text = strcat("\n", "\xCE\xC5\xD7 \xC7\xC1\xCD\xC5", "\n\n");
	text = strcat(text, Menu_Row(1, "Checkers            "), Menu_Row(2, "Chess               "), Menu_Row(3, "Select Map          "));
	text = strcat(text, Menu_Row(4, "Back                "));
	centerprint(self, text);
};

void() Menu_RenderMap =
{
	local string text;

	text = strcat("\n", "\xD3\xC5\xCC\xC5\xC3\xD4 \xCD\xC1\xD0", "\n\n");
	text = strcat(text, Menu_Row(1, "The Dark Church     "), Menu_Row(2, "Blood Sky Castle    "), Menu_Row(3, "The Hall of Kings   "));
	text = strcat(text, Menu_Row(4, "Back                "));
	centerprint(self, text);
};

void() Menu_RenderGameType =
{
	local string text;

	text = strcat("\n", "\xD3\xC5\xCC\xC5\xC3\xD4 \xD0\xCC\xC1\xD9\xC5\xD2\xD3", "\n\n");
	if (menu_selected_checkers)
	{
		text = strcat(text, Menu_Row(1, "Vs Computer        "), Menu_Row(2, "Two Players        "), Menu_Row(3, "Computer vs Computer"));
		text = strcat(text, Menu_Row(4, "Back               "));
		centerprint(self, text);
		return;
	}
	text = strcat(text, Menu_Row(1, "Single Player       "), Menu_Row(2, "Multiplayer         "), Menu_Row(3, "Computer vs Computer"));
	text = strcat(text, Menu_Row(4, "Back                "));
	centerprint(self, text);
};

void() Menu_RenderSide =
{
	if (!menu_selected_checkers)
	{
		centerprint(self,
			"\n"
			"\xD3\xC5\xCC\xC5\xC3\xD4 \xD3\xC9\xC4\xC5\n\n"
			"  ", Menu_GoldNumber(1), "  Play White            \n"
			"  ", Menu_GoldNumber(2), "  Play Black            \n"
			"  ", Menu_GoldNumber(3), "  Back                  \n");
		return;
	}
	centerprint(self,
		"\n"
		"\xD3\xC5\xCC\xC5\xC3\xD4 \xD3\xC9\xC4\xC5\n\n"
		"  ", Menu_GoldNumber(1), "  Play Red              \n"
		"  ", Menu_GoldNumber(2), "  Play Black            \n"
		"  ", Menu_GoldNumber(3), "  Back                  \n");
};

void() Menu_RenderBotLevel =
{
	local string text;

	if (menu_selected_checkers)
		text = strcat("\n", "\xC3\xC8\xC5\xC3\xCB\xC5\xD2\xD3 \xC2\xCF\xD4 \xCC\xC5\xD6\xC5\xCC", "\n\n");
	else
		text = strcat("\n", "\xC3\xC8\xC5\xD3\xD3 \xC2\xCF\xD4 \xCC\xC5\xD6\xC5\xCC", "\n\n");
	text = strcat(text, Menu_Row(1, "Novice              "), Menu_Row(2, "Easy                "), Menu_Row(3, "Normal              "));
	text = strcat(text, Menu_Row(4, "Hard                "), Menu_Row(5, "Expert              "), Menu_Row(6, "Back                "));
	centerprint(self, text);
};

float() Menu_Render =
{
	if (!self.menu_screen)
	{
		return (FALSE);
	}
	if ((self.menu_refresh > time))
	{
		return (TRUE);
	}
	self.menu_refresh = (time + 0.5);
	if ((self.menu_screen == MENU_SCREEN_PAUSE))
	{
		Menu_RenderPause();
		return (TRUE);
	}
	if ((self.menu_screen == MENU_SCREEN_HELP))
	{
		Menu_RenderHelp();
		return (TRUE);
	}
	if ((self.menu_screen == MENU_SCREEN_GAMEOVER))
	{
		Menu_RenderGameOver();
		return (TRUE);
	}
	if ((self.menu_screen == MENU_SCREEN_NEWGAME))
	{
		Menu_RenderNewGame();
		return (TRUE);
	}
	if ((self.menu_screen == MENU_SCREEN_GAMETYPE))
	{
		Menu_RenderGameType();
		return (TRUE);
	}
	if ((self.menu_screen == MENU_SCREEN_SIDE))
	{
		Menu_RenderSide();
		return (TRUE);
	}
	if ((self.menu_screen == MENU_SCREEN_BOTLEVEL))
	{
		Menu_RenderBotLevel();
		return (TRUE);
	}
	if ((self.menu_screen == MENU_SCREEN_MAP))
	{
		Menu_RenderMap();
		return (TRUE);
	}
	return (TRUE);
};

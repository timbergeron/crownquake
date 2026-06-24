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
	local entity oldself;

	if ((client == world))
	{
		return;
	}
	if (!client.menu_screen)
	{
		client.menu_open_time = time;
	}
	client.menu_screen = screen;
	client.menu_cursor = 1;
	client.menu_refresh = MSG_BROADCAST;
	oldself = self;
	self = client;
	Menu_Render();
	self = oldself;
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
	if ((current_turn == world))
	{
		return;
	}
	client = Menu_ClientForSide(current_turn);
	if ((client == world))
	{
		return;
	}
	menu_startup_shown = TRUE;
	client.menu_return_screen = MENU_SCREEN_NONE;
	Menu_OpenForClient(client, MENU_SCREEN_NEWGAME);
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
	gameover = TRUE;
	action_flag = TRUE;
	if (game_checkers)
	{
		CheckersClearTurnState();
	}
	current_selected = world;
	if ((light_ent != world))
	{
		light_ent.effects = MSG_BROADCAST;
	}
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

void(float use_checkers) Menu_StartNewGame =
{
	Menu_ClearAllClients();
	ResetGameToMode(use_checkers);
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
		Menu_StartNewGame(FALSE);
		return;
	}
	if ((self.impulse == 2))
	{
		Menu_StartNewGame(TRUE);
		return;
	}
	if ((self.impulse == 3))
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
	self.menu_refresh = MSG_BROADCAST;
};

void(float imp) Menu_Select =
{
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
};

void() Menu_RenderPause =
{
	if (self.spectator)
	{
		centerprint(self,
			"\n"
			"==============================\n"
			"        CROWNQUAKE MENU       \n"
			"==============================\n\n"
			"  1  Resume\n"
			"  2  Help\n\n"
			"Press a number key.\n");
		return;
	}
	centerprint(self,
		"\n"
		"==============================\n"
		"        CROWNQUAKE MENU       \n"
		"==============================\n\n"
		"  1  Resume\n"
		"  2  Help\n"
		"  3  Resign\n"
		"  4  New Game\n\n"
		"Press a number key.\n");
};

void() Menu_RenderHelp =
{
	if (game_checkers)
	{
		centerprint(self,
			"\n"
			"==============================\n"
			"        CHECKERS HELP         \n"
			"==============================\n\n"
			"  Space/LMB  select or move\n"
			"  Del        unselect piece\n"
			"  F1         text board\n"
			"  F2         game menu\n"
			"  H          this help\n\n"
			"Captures are mandatory.\n"
			"Multi-jumps must be finished.\n"
			"Passing is disabled.\n\n"
			"  1  Back\n"
			"  2  Close\n");
		return;
	}
	centerprint(self,
		"\n"
		"==============================\n"
		"          CHESS HELP          \n"
		"==============================\n\n"
		"  Space/LMB  select or move\n"
		"  Del        unselect piece\n"
		"  P          pass turn\n"
		"  F1         text board\n"
		"  F2         game menu\n"
		"  H          this help\n\n"
		"  1  Back\n"
		"  2  Close\n");
};

void() Menu_RenderGameOver =
{
	if (((self.menu_winner != world) && (self.menu_winner.netname != "")))
	{
		centerprint(self,
			"\n"
			"==============================\n"
			"          GAME OVER           \n"
			"==============================\n\n"
			"Winner: ",
			self.menu_winner.netname,
			"\n\n"
			"  1  Rematch\n"
			"  2  New Game\n"
			"  3  Help\n"
			"  4  Close\n");
		return;
	}
	centerprint(self,
		"\n"
		"==============================\n"
		"          GAME OVER           \n"
		"==============================\n\n"
		"Winner: Unknown\n\n"
		"  1  Rematch\n"
		"  2  New Game\n"
		"  3  Help\n"
		"  4  Close\n");
};

void() Menu_RenderNewGame =
{
	centerprint(self,
		"\n"
		"==============================\n"
		"          NEW GAME            \n"
		"==============================\n\n"
		"  1  Chess\n"
		"  2  Checkers\n"
		"  3  Back\n\n"
		"Press a number key.\n");
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
	return (TRUE);
};

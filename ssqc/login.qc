void (entity player, string login, string secret) performLogin = {
	string data = strcat("login=", login);
	data = strcat(data,"&secret=");
	data = strcat(data,secret);	
	uri_get(loginUrl, BR_LOGIN_REQUEST, "application/x-www-form-urlencoded", data);
	self.login_in_progress = 1;
	dprint(infokey(self,"name"));
	dprint(" [");
	dprint(infokey(self,"ip"));
	dprint("]");
	dprint(" trying to login as ");
	dprint(login);
	dprint("\n");
}

void (entity player, string token) performFoLogin = {
	local string uri = sprintf("%s/results/api/v1/fo_login", backend_address);
	uri_get(uri, FO_LOGIN_REQUEST, "application/json", sprintf("{ \"auth_token\": \"%s\" }", token));
	dprint(sprintf("%s [%s] logging in\n", infokey(player, "name"), infokey(player, "ip")));
}

void(float reqid, float responsecode, string resourcebody, int resourcebytes) URI_Get_Callback = {
	local float success = !responsecode;

	switch(reqid) {
		case FO_QUAD_STARTED_REQUEST:
			local string msg;

			if (success && resourcebody) {
				match_id = resourcebody;
				msg = sprintf("Quad start successfully logged. ID: %s\n", match_id);
				bprint(PRINT_HIGH, msg);
				dprint(msg);
			} else {
				msg = sprintf("Quad start failed to log. Response code: %d\n", responsecode);
				bprint(PRINT_HIGH, msg);
				dprint(msg);
			}

			break;
		case FO_QUAD_FINISHED_REQUEST:
			local string msg;

			if (success && resourcebody == match_id) {
				msg = sprintf("Quad result successfully logged. ID: %s\n", match_id);
				bprint(PRINT_HIGH, msg);
				dprint(msg);
			} else {
				msg = sprintf("Quad result failed to log. Response code: %d\n", responsecode);
				bprint(PRINT_HIGH, msg);
				dprint(msg);
			}

			break;
		case FO_LOGIN_REQUEST:
			local string msg;

			if (!responsecode) {
				self.fo_login = resourcebody;
				CenterPrint(self, sprintf("You have logged in as %s\n", self.fo_login));
				msg = sprintf("%s logged in as %s\n", infokey(self, "name"), self.fo_login);
				bprint(PRINT_HIGH, msg);
				dprint(msg);
			} else {
				CenterPrint(self, "Login failed\n");
				msg = (sprintf("%s login failed. Response code: %d\n", infokey(self, "name"), responsecode));
				sprint(self, PRINT_HIGH, msg);
				dprint(msg);
			}

			break;
		case BR_LOGIN_REQUEST:
			local float got_one = 0;
			self.login_in_progress = 0;	
			local float csqcactive = infokeyf(self, INFOKEY_P_CSQCACTIVE);
			if (!responsecode) {		
				float num_args = tokenizebyseparator(resourcebody,";");
				self.login = argv(0);
				forceinfokey(self,"*login", self.login);
				bprint(2, infokey(self,"name"));
				bprint(2, " has logged in as \s");
				bprint(2, self.login);
				bprint(2, "\s\n");
				dprint(infokey(self,"name"));
				dprint(" logged in as ");
				dprint(self.login);
				dprint("\n");
				CenterPrint3(self, "You have logged in as ", self.login, "\n");
				if (num_args > 1) {
					if (argv(1) == "true") {
						self.is_admin = TRUE;
						forceinfokey(self,"*admin", ftos(self.is_admin));
						Admin_Aliases ();
						bprint(2, self.netname, " \sgains full admin status!\s\n");
						//				bprint (3, "\n");
						sprint(self, 2, "Type \scommands\s for admin commands.\n");
					}
				}
				if(self.team_no == 0 && !intermission_running) {
					if (clanbattle && (self.has_disconnected != 1)) {
						if (self.tf_id != 0) {
							got_one = RejoinWithTfId();
							ResetAndRespawnPlayer(self);
						}
						if (!got_one) {
							CreateTfIdAndJoin();
						}
					}
					if (!got_one) {
						if (csqcactive)
							Menu_Team(0);
						else
							Menu_Team(1);
					}
				}
			} else {
				dprint(infokey(self,"name"));
				dprint(" login failed: ");
				dprint(self.login);
				dprint("\n");
				CenterPrint3(self, ftos(responsecode), " - Login FAILED, invalid Login/Secret", "\n");
			}
			break;
	}
}

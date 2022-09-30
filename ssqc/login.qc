void (entity player, string login, string secret) performLogin = {
	string data = strcat("login=", login);
	data = strcat(data,"&secret=");
	data = strcat(data,secret);	
	uri_get(loginUrl, 10, "application/x-www-form-urlencoded", data);
	self.login_in_progress = 1;
	dprint(infokey(self,"name"));
	dprint(" [");
	dprint(infokey(self,"ip"));
	dprint("]");
	dprint(" trying to login as ");
	dprint(login);
	dprint("\n");
}

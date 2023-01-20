string ClassToString(float num)
{
    if (num == 1) return "Scout";
    if (num == 2) return "Sniper";
    if (num == 3) return "Soldier";
    if (num == 4) return "Demoman";
    if (num == 5) return "Medic";
    if (num == 6) return "HWGuy";
    if (num == 7) return "Pyro";
    if (num == 8) return "Spy";
    if (num == 9) return "Engineer";
    if (num == 11) return "Civilian";
    if (num == 13) return "Sentry Gun";
    if (num == 14) return "Goal Item";
    return "";
}

string TeamToString(float num)
{
    if (num == 1) return "Blue";
    if (num == 2) return "Red";
    if (num == 3) return "Yellow";
    if (num == 4) return "Green";
    return " ";
}
float Bitfield_Add (float bf, float b) =
{
	bf = bf | b;
	return bf;
};

float Bitfield_Remove (float bf, float b) =
{
	bf = bf - (bf & b);
	return bf;
};

float Bitfield_Contains (float bf, float b) =
{
	if (bf & b)
		return  1;
	else 	
		return 0;

};										
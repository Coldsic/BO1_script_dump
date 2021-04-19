
shouldSaveOnStartup()
{
	gt = GetDvar( #"g_gametype");
	
	switch(gt)
	{
		case "vs":
			return false;
		default:
			break;
	}
	return true;
}
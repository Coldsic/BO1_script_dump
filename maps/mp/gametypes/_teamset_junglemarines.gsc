register(teamset)
{
	game["allies_teamset"][teamset] = ::allies;
	game["axis_teamset"][teamset] = ::axis;
	cac_init();
}
level_init()
{
	game["allies"] = "marines";
	game["axis"] = "nva";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["allies_soldiertype"] = "junglemarines";
	game["axis_soldiertype"] = "junglemarines";
	
	game["entity_headicon_allies"] = "faction_128_marines";
	game["entity_headicon_axis"] = "faction_128_nva";
	game["headicon_allies"] = "faction_128_marines";
	game["headicon_axis"] = "faction_128_nva";
	
	game["cac_faction_allies"] = "usa_sog";
	game["cac_faction_axis"] = "vtn_nva";
	
	level.teamPrefix["allies"] = "vox_sog";
	level.teamPostfix["allies"] = "us";
	level.teamPrefix["axis"] = "vox_nva";
	level.teamPostfix["axis"] = "ja";
	
	SetDvar("g_TeamName_Allies", &"MPUI_MARINE_SHORT");
	SetDvar("g_TeamColor_Allies", ".5 .5 .5");
	SetDvar("g_ScoresColor_Allies", "0 0 0");
	SetDvar("g_FactionName_Allies", "usa_sog" );
	SetDvar("g_TeamName_Axis", &"MPUI_NVA_SHORT");
	SetDvar("g_TeamColor_Axis", "0.52 0.28 0.28");		
	SetDvar("g_ScoresColor_Axis", "0.52 0.28 0.28");
	SetDvar("g_FactionName_Axis", "vtn_nva" );
	
	
	game["strings"]["allies_win"] = &"MP_MARINE_WIN_MATCH";
	game["strings"]["allies_win_round"] = &"MP_MARINE_WIN_ROUND";
	game["strings"]["allies_mission_accomplished"] = &"MP_MARINE_MISSION_ACCOMPLISHED";
	game["strings"]["allies_eliminated"] = &"MP_MARINE_ELIMINATED";
	game["strings"]["allies_forfeited"] = &"MP_MARINE_FORFEITED";
	game["strings"]["allies_name"] = &"MP_MARINE_NAME";
	
	game["music"]["spawn_allies"] = "SPAWN_SOG";
	game["music"]["victory_allies"] = "mus_victory_usa";
	game["icons"]["allies"] = "faction_128_marines";
	game["colors"]["allies"] = (0.6,0.64,0.69);
	game["voice"]["allies"] = "vox_sog_";
	SetDvar( "scr_allies", "marines" );
	game["strings"]["axis_win"] = &"MP_NVA_WIN_MATCH";
	game["strings"]["axis_win_round"] = &"MP_NVA_WIN_ROUND";
	game["strings"]["axis_mission_accomplished"] = &"MP_NVA_MISSION_ACCOMPLISHED";
	game["strings"]["axis_eliminated"] = &"MP_NVA_ELIMINATED";
	game["strings"]["axis_forfeited"] = &"MP_NVA_FORFEITED";
	game["strings"]["axis_name"] = &"MP_NVA_NAME";
	
	game["music"]["spawn_axis"] = "SPAWN_NVA";
	game["music"]["victory_axis"] = "mus_victory_japanese";
	game["icons"]["axis"] = "faction_128_nva";
	game["colors"]["axis"] = (0.52,0.28,0.28);
	game["voice"]["axis"] = "vox_nva_";
	setDvar( "scr_axis", "nva" );
	precacheShader( "faction_128_marines" );
	precacheShader( "faction_128_nva" );
	
	level.heli_vo["allies"]["approach"] = "vox_sog_2_kls_attackheli_approach";
	level.heli_vo["allies"]["door"] = "vox_sog_2_kls_attackheli_door";
	level.heli_vo["allies"]["down"] = "vox_sog_2_kls_attackheli_down";
	level.heli_vo["allies"]["hit"] = "vox_sog_2_kls_attackheli_hit";
	level.heli_vo["allies"]["kill"] = "vox_sog_2_kls_attackheli_kill";
	level.heli_vo["allies"]["ready"] = "vox_sog_2_kls_attackheli_ready";
	level.heli_vo["allies"]["shoot"] = "vox_sog_2_kls_attackheli_shoot";
	level.heli_vo["axis"]["approach"] = "vox_nva_1_kls_attackheli_approach";
	level.heli_vo["axis"]["door"] = "vox_nva_1_kls_attackheli_door";
	level.heli_vo["axis"]["down"] = "vox_nva_1_kls_attackheli_down";
	level.heli_vo["axis"]["hit"] = "vox_nva_1_kls_attackheli_hit";
	level.heli_vo["axis"]["kill"] = "vox_nva_1_kls_attackheli_kill";
	level.heli_vo["axis"]["ready"] = "vox_nva_1_kls_attackheli_ready";
	level.heli_vo["axis"]["shoot"] = "vox_nva_1_kls_attackheli_shoot";
}
cac_init()
{
	mpbody\ordnance_disposal_mp::main();
	mpbody\camo_mp::main();
	mpbody\hardened_mp::main();
	mpbody\standard_mp::main();
	mpbody\utility_mp::main();
	mphead\head_armor_mp::main();
	mphead\head_flak_mp::main();
	mphead\head_camo_mp::main();
	mphead\head_standard_mp::main();
	mphead\head_utility_mp::main();
}
allies()
{
	keys = GetArrayKeys( level.cac_functions[ "precache" ] );
	for( i = 0; i < keys.size; i++ )
	{
		content_type = keys[i];
		[[level.cac_functions[ "precache" ][content_type]]]( "usa_sog" );
	}
}
axis()
{
	keys = GetArrayKeys( level.cac_functions[ "precache" ] );
	for( i = 0; i < keys.size; i++ )
	{
		content_type = keys[i];
		[[level.cac_functions[ "precache" ][content_type]]]( "vtn_nva" );
	}
}
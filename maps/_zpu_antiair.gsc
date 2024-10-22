// _zpu_antiair.gsc
/*
	Sets up the behavior for the zpu antiair vehicle
*/

#include maps\_vehicle;

main()
{
	build_aianims(::setanims);
	build_unload_groups(::unload_groups);
}

// Animation set up for AI
#using_animtree ("generic_human");
setanims()
{
	// TODO: put in animations
}

unload_groups()
{
	unload_groups = [];
	unload_groups[ "all" ] = [];


	group = "all";
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;


	unload_groups[ "default" ] = unload_groups[ "all" ];

	return unload_groups;
}

 
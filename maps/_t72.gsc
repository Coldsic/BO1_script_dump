#include maps\_vehicle;
#using_animtree( "vehicles" );
main()
{
	
	
}
set_vehicle_anims( positions )
{
	
	return positions;
}
#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	for( i=0;i<11;i++ )
		positions[ i ] = spawnstruct();
	positions[ 0 ].getout_delete = true;
	return positions;
}  

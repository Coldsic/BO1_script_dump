#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#using_animtree( "generic_human" );
main()
{
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	level.scr_anim[ "generic" ][ "Cover Crouch" ][ 0 ]	 = %covercrouch_hide_idle;
	level.scr_anim[ "generic" ][ "Cover Crouch" ][ 1 ]	 = %covercrouch_twitch_1;
	level.scr_anim[ "generic" ][ "Cover Crouch" ][ 2 ]	 = %covercrouch_hide_2_aim;
	level.scr_anim[ "generic" ][ "Cover Crouch" ][ 3 ]	 = %covercrouch_hide_2_aim;
	level.scr_anim[ "generic" ][ "Cover Crouch" ][ 4 ]	 = %covercrouch_hide_2_aim;
	level.scr_anim[ "generic" ][ "Cover Crouch" ][ 5 ]	 = %covercrouch_hide_look;
	
	
	
	
	
	
	
	
	
	
	
	level.node_offset = [];
	level.node_offset[ "Cover Left" ] = ( 0, 90, 0 );
	level.node_offset[ "Cover Right" ] = ( 0, -90, 0 );
	
	wait 5;
	
	spawners = getspawnerarray();
	spawner = undefined;
	
	for( i=0; i<spawners.size; i++ )
	{
		if( spawners[i].count != 0 )
		{
			spawner = spawners[i];
			break;
		}
	}	
	
	
	
	thread node_debug_render();
	thread scriptstruct_debug_render();
}
scriptstruct_debug_render()
{
	while( 1 )
	{
		level waittill( "obstacle", selected_struct );
		
		if( isdefined(selected_struct) )
		{
			level thread render_struct( selected_struct );
		}
		else
		{
			level notify( "stop_struct_render" );
		}
	}
}
render_struct( selected_struct )
{
	self endon( "stop_struct_render" );
	
	while( isdefined( selected_struct ) )
	{
		Box( selected_struct.origin, (-16, -16, -16), (16, 16, 16), 0, (1, 0.4, 0.4) );
		wait 0.05;
	}
}
node_debug_render()
{
	while( 1 )
	{
		level waittill( "node_not_safe", node );
		
		if( isdefined(node) )
		{
			
			
			spawn_johnny_node_chaser( node );
		}
		else
		{
			
			
			
			if( isdefined( level.johnny_node_chaser ) )
			{
				level.johnny_node_chaser thread delete_timer();
			}
		}
	}
}
delete_timer()
{
	self endon("stop_delete_timer");
	self endon("death");
	
	time = 5;
	while( time > 0.01 )
	{
		Print3d( self.origin, time, (1,1,1), 1, 0.8, 4 );
		wait 0.2;
		time -= 0.2;
	}
	
	self delete();
}
animate_at_node( node )
{
	if ( !node_has_animations( node ) || !isdefined( level.nodedrone ) )
		return;
		
	level.nodedrone thread animate_nodedrone_at_node( node );
}
spawn_johnny_node_chaser( node )
{
	if( !isdefined(level.johnny_node_chaser) )
	{
		if( !isdefined(level.enemy_spawner) )
			maps\_debug::dynamic_ai_spawner_init();
		
		if( !isdefined(level.enemy_spawner) )
			return;
			
		spawner = level.enemy_spawner;
		
		old_origin = spawner.origin;
		old_angles = spawner.angles;
		
		spawner.origin = node.origin;
		spawner.angles = node.angles;
		
		spawner.count = 50;
		spawn = spawner spawn_ai();
		
		spawner.origin = old_origin;
		spawner.angles = old_angles;
		
		if ( spawn_failed( spawn ) )
		{
			return;
		}
		
		level.johnny_node_chaser = spawn;
	}
	
	if( isdefined(level.johnny_node_chaser) )
	{
		if( !FindPath( level.johnny_node_chaser.origin, node.origin ) )
		{
			level.johnny_node_chaser forceteleport( node.origin, node.angles );
		}
		level.johnny_node_chaser.script_accuracy = 0;
		level.johnny_node_chaser notify("stop_delete_timer");
		level.johnny_node_chaser.goalradius = 16;
		level.johnny_node_chaser thread keepupwithnode( node );
	}
}
keepupwithnode( node )
{
	self endon("stop_delete_timer");
	self endon( "death" );
	
	prev_org = (0,0,0);
	prev_ang = (0,0,0);
	
	while( 1 )
	{
		if( !vector_compare( prev_org, node.origin) || !vector_compare( prev_ang, node.angles ) )
		{
			prev_org = node.origin;
			prev_ang = node.angles;
			
			self setgoalnode( node );	
			
		}
		
		wait 1.0;
		
		
		
		
		
		
		
		
		
		
	}
}
animate_nodedrone_at_node( node )
{
	angles = node.angles;
	if( isdefined( level.node_offset[ node.type ] ) )
		angles = angles + level.node_offset[ node.type ];
	
	self.origin = node.origin;
	self.angles = angles;
	self dontinterpolate();
	self show();
	
	self thread stay_animated_at_node( node );
}
stay_animated_at_node( node )
{
	self.currentnode = node;
	
	prev_org = (0,0,0);
	prev_ang = (0,0,0);
	
	while( isdefined( self.currentnode ) )
	{
		if( !vector_compare( prev_org, node.origin) || !vector_compare( prev_ang, node.angles ) )
		{
			prev_org = node.origin;
			prev_ang = node.angles;
		
			angles = node.angles;
			if( isdefined( level.node_offset[ self.currentnode.type ] ) )
				angles = angles + level.node_offset[ self.currentnode.type ];
			
			self.origin = node.origin;
			self.angles = angles;
				
			self notify( "stop_loop" );
			if( node_has_animations( node ) )
				self anim_generic_loop( self, node.type, "stop_loop" );
			else
				prev_org = (0,0,0);
		}
		
		wait 0.05;
	}
}
node_has_animations( node )
{
	if ( isdefined( level.scr_anim[ "generic" ][ node.type ] ) )
		return true;
	return false;
} 
  


anim_get_dvar_int( dvar, def )
{
	return int( anim_get_dvar( dvar, def ) );
}
anim_get_dvar( dvar, def )
{
	if ( getdvar( dvar ) != "" )
		return getdvarfloat( dvar );
	else
	{
		setdvar( dvar, def );
		return def;
	}
}
set_orient_mode( mode, val1 )
{
	
	if ( isdefined( val1 ) )
		self OrientMode( mode, val1 );
	else
		self OrientMode( mode );
}
debug_anim_print( text )
{
}
debug_turn_print( text, line )
{
}
debug_allow_movement()
{
	return true;
}
debug_allow_combat()
{
	return true;
}
current_yaw_line_debug( duration )
{
}
getAnimDirection( damageyaw )
{
	if( ( damageyaw > 135 ) ||( damageyaw <= -135 ) )	
	{
		return "front";
	}
	else if( ( damageyaw > 45 ) &&( damageyaw <= 135 ) )		
	{
		return "right";
	}
	else if( ( damageyaw > -45 ) &&( damageyaw <= 45 ) )		
	{
		return "back";
	}
	else
	{															
		return "left";
	}
	return "front";
}
setFootstepEffect(name, fx)
{
	assertEx(isdefined(name), "Need to define the footstep surface type.");
	assertEx(isdefined(fx), "Need to define the mud footstep effect.");
	if (!isdefined(anim.optionalStepEffects))
		anim.optionalStepEffects = [];
	anim.optionalStepEffects[anim.optionalStepEffects.size] = name;
	level._effect["step_" + name] = fx;
}  

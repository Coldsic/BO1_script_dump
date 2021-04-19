
#include common_scripts\utility; 
#include maps\mp\_utility; 
main()
{
	if( !IsDefined( level.dofDefault ) )
	{
		level.dofDefault["nearStart"] = 0; 
		level.dofDefault["nearEnd"] = 1; 
		level.dofDefault["farStart"] = 8000; 
		level.dofDefault["farEnd"] = 10000; 
		level.dofDefault["nearBlur"] = 6; 
		level.dofDefault["farBlur"] = 0; 
	}
	level.curDoF = ( level.dofDefault["farStart"] - level.dofDefault["nearEnd"] ) / 2; 
	
	
	if( !IsDefined( level.script ) )
	{
		level.script = tolower( GetDvar( "mapname" ) ); 
	}
	
	
}
artfxprintln( file, string )
{
	
	if( file == -1 )
	{
		return; 
	}
	fprintln( file, string ); 
}
strtok_loc( string, par1 )
{
	stringlist = []; 
	indexstring = ""; 
	for( i = 0 ; i < string.size ; i ++ )
	{
		if( string[i] == " " )
		{
			stringlist[stringlist.size] = indexstring; 
			indexstring = ""; 
		}
		else
		{
			indexstring = indexstring+string[i]; 
		}
	}
	if( indexstring.size )
	{
		stringlist[stringlist.size] = indexstring; 
	}
	return stringlist; 
}
setfogsliders()
{
	
	fogall = strtok_loc( getDvar( #"g_fogColorReadOnly" ), " " ) ;
	red = fogall[ 0 ];
	green = fogall[ 1 ];
	blue = fogall[ 2 ];
	halfplane = getDvar( #"g_fogHalfDistReadOnly" );
	nearplane = getDvar( #"g_fogStartDistReadOnly" );
		
	if ( !isdefined( red )
		 || !isdefined( green )
		 || !isdefined( blue )
		 || !isdefined( halfplane )
		 )
	{
		red = 1;
		green = 1;
		blue = 1;
		halfplane = 10000001;
		nearplane = 10000000;
	}
	setdvar("scr_fog_exp_halfplane",halfplane);
	setdvar("scr_fog_nearplane",nearplane);
	setdvar("scr_fog_color",red+" "+green+" "+blue);
}
tweakart()
{
	  
}         
fovslidercheck()
{
	
	if( level.dofDefault["nearStart"] >= level.dofDefault["nearEnd"] )
	{
		level.dofDefault["nearStart"] = level.dofDefault["nearEnd"] - 1; 
		SetDvar( "scr_dof_nearStart", level.dofDefault["nearStart"] ); 
	}
	if( level.dofDefault["nearEnd"] <= level.dofDefault["nearStart"] )
	{
		level.dofDefault["nearEnd"] = level.dofDefault["nearStart"] + 1; 
		SetDvar( "scr_dof_nearEnd", level.dofDefault["nearEnd"] ); 
	}
	if( level.dofDefault["farStart"] >= level.dofDefault["farEnd"] )
	{
		level.dofDefault["farStart"] = level.dofDefault["farEnd"] - 1; 
		SetDvar( "scr_dof_farStart", level.dofDefault["farStart"] ); 
	}
	if( level.dofDefault["farEnd"] <= level.dofDefault["farStart"] )
	{
		level.dofDefault["farEnd"] = level.dofDefault["farStart"] + 1; 
		SetDvar( "scr_dof_farEnd", level.dofDefault["farEnd"] ); 
	}
	if( level.dofDefault["farBlur"] >= level.dofDefault["nearBlur"] )
	{
		level.dofDefault["farBlur"] = level.dofDefault["nearBlur"] - .1; 
		SetDvar( "scr_dof_farBlur", level.dofDefault["farBlur"] ); 
	}
	if( level.dofDefault["farStart"] <= level.dofDefault["nearEnd"] )
	{
		level.dofDefault["farStart"] = level.dofDefault["nearEnd"] + 1; 
		SetDvar( "scr_dof_farStart", level.dofDefault["farStart"] ); 
	}
} 
dumpsettings()
{
	  
}
debug_reflection()
{
}
remove_reflection_objects()
{
}
create_reflection_objects()
{
}
create_reflection_object()
{
	
}
debug_reflection_buttons()
{
} 
 
  

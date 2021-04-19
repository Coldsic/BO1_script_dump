
#using_animtree( "generic_human" );
force_grenade_toss( pos, grenade_weapon, explode_time, anime, throw_tag )
{
	self endon( "death" );
	og_grenadeweapon = undefined;
	
	if( IsDefined( grenade_weapon ) )
	{
		og_grenadeweapon = self.grenadeWeapon;
		self.grenadeWeapon = grenade_weapon;
	}
	self.grenadeammo++;
	if( !IsDefined( explode_time ) )
	{
		explode_time = 4;
	}
	if( !IsDefined( throw_tag ) )
	{
		throw_tag = "tag_inhand";
	}
	
	
	angles = VectorToAngles( pos - self.origin );
	self OrientMode( "face angle", angles[1] );
	
	
	if( DistanceSquared( self.origin, pos ) < 200 * 200 )
	{
		return false;
	}
	
	self.force_grenade_throw_tag = throw_tag;
	self.force_grenade_pos = pos;
	self.force_grenade_explod_time = explode_time;
	if( !IsDefined( anime ) )
	{
		anime = "force_grenade_throw";
		
		if( !IsDefined( self.animname ) )
		{
			self.animname = "force_grenader";
		}
	
		
		if( !IsDefined( level.scr_anim[self.animname] ) || !IsDefined( level.scr_anim[self.animname][anime] ) )
		{
			switch( self.a.special )
			{
				case "cover_crouch":
				case "none":
					if (self.a.pose == "stand")
					{
						throw_anim = %stand_grenade_throw;
					}
					else 
					{
						throw_anim = %crouch_grenade_throw;
					}
		
					gun_hand = "left";
					break;
				default: 
					throw_anim = %stand_grenade_throw;
					gun_hand = "left";
					break;
			}
			
			level.scr_anim[self.animname][anime] = throw_anim;
			maps\_anim::addNotetrack_attach( self.animname, "grenade_right", GetWeaponModel( self.grenadeweapon ), self.force_grenade_throw_tag, anime );
			maps\_anim::addNotetrack_detach( self.animname, "fire", GetWeaponModel( self.grenadeweapon ), self.force_grenade_throw_tag, anime );
		}
	}
	
	
	function = ::force_grenade_toss_internal;
	if( !maps\_anim::notetrack_customfunction_exists( self.animname, "fire", function, anime ) )
	{
		maps\_anim::addNotetrack_customFunction( self.animname, "fire", function, anime );
	}
	
	if( !IsDefined( level.scr_sound[self.animname] ) || !IsDefined( level.scr_sound[self.animname][anime] ) )
	{
		self animscripts\battleChatter_ai::evaluateAttackEvent("grenade");
	}
	
	self maps\_anim::anim_single( self, anime );
	
	if( self.animname == "force_grenader" )
	{
		self.animname = undefined;
	}
	if( IsDefined( og_grenadeweapon ) )
	{
		self.grenadeWeapon = og_grenadeweapon;
	}
	self notify( "forced_grenade_thrown" );
	return true;
}
force_grenade_toss_internal( guy )
{
	guy MagicGrenade( guy GetTagOrigin( guy.force_grenade_throw_tag ), guy.force_grenade_pos, guy.force_grenade_explod_time );
	
	guy.grenadeammo--;	
	guy.force_grenade_pos = undefined;
	guy.force_grenade_explod_time = undefined;
	guy.force_grenade_throw_tag = undefined;
}
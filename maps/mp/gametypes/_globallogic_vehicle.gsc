#include maps\mp\_utility;
Callback_VehicleDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, damageFromUnderneath, modelIndex, partName )
{
	
	if ( !(level.iDFLAGS_RADIUS & iDFlags) )
	{
		
		iDamage = maps\mp\gametypes\_class::cac_modified_vehicle_damage( self, eAttacker, iDamage, sMeansOfDeath, sWeapon, eInflictor );
	}
	
	self.iDFlags = iDFlags;
	self.iDFlagsTime = getTime();
	
	if ( game["state"] == "postgame" )
		return;
	
	if ( isDefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( eAttacker.canDoCombat ) && !eAttacker.canDoCombat )
		return;
	
	
	
	if( !isDefined( vDir ) )
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;
	
	friendly = false;
	if ( ( IsDefined( self.maxhealth ) && (self.health == self.maxhealth)) || !isDefined( self.attackers ) )
	{
		self.attackers = [];
		self.attackerData = [];
		self.attackerDamage = [];
	}
	
	if ( sWeapon == "none" && isDefined( eInflictor ) )
	{
		if ( isDefined( eInflictor.targetname ) && eInflictor.targetname == "explodable_barrel" )
			sWeapon = "explodable_barrel_mp";
		else if ( isDefined( eInflictor.destructible_type ) && isSubStr( eInflictor.destructible_type, "vehicle_" ) )
			sWeapon = "destructible_car_mp";
	}
	
	if( !(iDFlags & level.iDFLAGS_NO_PROTECTION) )
	{
	  if ( self IsVehicleImmuneToDamage( iDFlags, sMeansOfDeath, sWeapon ) )
	  {
	  	return;
	  }
		if ( sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET" )
		{
		}
		
		else if ( sMeansOfDeath == "MOD_PROJECTILE" || sMeansOfDeath == "MOD_GRENADE" )
		{
			iDamage *= GetVehicleProjectileScalar( sWeapon );
			iDamage = int(iDamage);
			
			if ( iDamage == 0 )
			{
				return;
			}
		}
		
		else if ( sMeansOfDeath == "MOD_GRENADE_SPLASH" )
		{
			iDamage *= GetVehicleUnderneathSplashScalar( sWeapon );
			iDamage = int(iDamage);
			
			if ( iDamage == 0 )
			{
				return;
			}
		}
	
		iDamage *= level.vehicleDamageScalar;
		iDamage = int(iDamage);
		
		if ( isPlayer( eAttacker ) )
			eAttacker.pers["participation"]++;
		
		prevHealthRatio = self.health / self.maxhealth;
		
		if ( IsDefined( self.owner ) && IsPlayer(self.owner) )
		{
			team = self.owner.pers["team"];
		}
		else
		{
			team = self maps\mp\_vehicles::vehicle_get_occupant_team();
		}
		
		if ( level.teamBased && isPlayer( eAttacker ) && (team == eAttacker.pers["team"]) )
		{
			if ( level.friendlyfire == 0 ) 
			{
				if( !AllowFriendlyFireDamage( eInflictor, eAttacker, sMeansOfDeath, sWeapon ) )
						return;
				
				if ( iDamage < 1 )
					iDamage = 1;
				
				self.lastDamageWasFromEnemy = false;
				
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, damageFromUnderneath, modelIndex, partName, true);
			}
			else if ( level.friendlyfire == 1 ) 
			{
				
				if ( iDamage < 1 )
					iDamage = 1;
				
				self.lastDamageWasFromEnemy = false;
				
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, damageFromUnderneath, modelIndex, partName, false);
			}
			else if ( level.friendlyfire == 2 ) 
			{
				if( !AllowFriendlyFireDamage( eInflictor, eAttacker, sMeansOfDeath, sWeapon ) )
					return;
				
				if ( iDamage < 1 )
					iDamage = 1;
				
				self.lastDamageWasFromEnemy = false;
				
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, damageFromUnderneath, modelIndex, partName, true);
			}
			else if ( level.friendlyfire == 3 ) 
			{
				iDamage = int(iDamage * .5);
				
				if ( iDamage < 1 )
					iDamage = 1;
				
				self.lastDamageWasFromEnemy = false;
				
				self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, damageFromUnderneath, modelIndex, partName, false);
			}
			
			friendly = true;
		}
		else
		{
			if ( !level.teamBased && IsDefined( self.targetname ) && self.targetname == "rcbomb" )
			{
				
			}
			else if ( IsDefined( self.owner ) && self.owner == eAttacker ) 
				return;
			
			if(iDamage < 1)
				iDamage = 1;
				
			if ( IsDefined( self.owner ) && self.owner == eAttacker ) 
				return;
				
			if ( isdefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( sWeapon ) )
				eAttacker thread maps\mp\gametypes\_weapons::checkHit( sWeapon );
			if ( issubstr( sMeansOfDeath, "MOD_GRENADE" ) && isDefined( eInflictor.isCooked ) )
				self.wasCooked = getTime();
			else
				self.wasCooked = undefined;
			
			attacker_seat = undefined;
			if ( IsDefined( eAttacker ) )
				attacker_seat = self GetOccupantSeat( eAttacker );
	
			self.lastDamageWasFromEnemy = (isDefined( eAttacker ) && !isdefined(attacker_seat));
			
			self finishVehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, damageFromUnderneath, modelIndex, partName, false);
		}
		if ( isdefined(eAttacker) && eAttacker != self )
		{
			if( maps\mp\gametypes\_globallogic_player::doDamageFeedback( sWeapon, eInflictor ) )
			{
				hasBodyArmor = false;
				if ( iDamage > 0 )
					eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( hasBodyArmor, sMeansOfDeath );
			}
		}
	}
	
	if(GetDvarInt( #"g_debugDamage"))
		println("actor:" + self getEntityNumber() + " health:" + self.health + " attacker:" + eAttacker.clientid + " inflictor is player:" + isPlayer(eInflictor) + " damage:" + iDamage + " hitLoc:" + sHitLoc);
	if(1) 
	{
		lpselfnum = self getEntityNumber();
		lpselfteam = "";
		lpattackerteam = "";
		if(isPlayer(eAttacker))
		{
			lpattacknum = eAttacker getEntityNumber();
			lpattackGuid = eAttacker getGuid();
			lpattackname = eAttacker.name;
			lpattackerteam = eAttacker.pers["team"];
		}
		else
		{
			lpattacknum = -1;
			lpattackGuid = "";
			lpattackname = "";
			lpattackerteam = "world";
		}
		logPrint("VD;" + lpselfnum + ";" + lpselfteam + ";" + lpattackGuid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");
	}
	
}
Callback_VehicleRadiusDamage( eInflictor, eAttacker, iDamage, fInnerDamage, fOuterDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, fRadius, fConeAngleCos, vConeDir, psOffsetTime )
{
	
	iDamage = maps\mp\gametypes\_class::cac_modified_vehicle_damage( self, eAttacker, iDamage, sMeansOfDeath, sWeapon, eInflictor );
	fInnerDamage = maps\mp\gametypes\_class::cac_modified_vehicle_damage( self, eAttacker, fInnerDamage, sMeansOfDeath, sWeapon, eInflictor );
	fOuterDamage = maps\mp\gametypes\_class::cac_modified_vehicle_damage( self, eAttacker, fOuterDamage, sMeansOfDeath, sWeapon, eInflictor );
	self.iDFlags = iDFlags;
	self.iDFlagsTime = getTime();
	
	if ( game["state"] == "postgame" )
		return;
	
	if ( isDefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( eAttacker.canDoCombat ) && !eAttacker.canDoCombat )
		return;
	
	friendly = false;
	
	if( !(iDFlags & level.iDFLAGS_NO_PROTECTION) )
	{
	  if ( self IsVehicleImmuneToDamage( iDFlags, sMeansOfDeath, sWeapon ) )
	  {
	  	return;
	  }
	  
		
		if ( sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_GRENADE_SPLASH" || sMeansOfDeath == "MOD_EXPLOSIVE" )
		{
			
			scalar = GetVehicleProjectileSplashScalar( sWeapon );		
			iDamage = int(iDamage * scalar);
			fInnerDamage = (fInnerDamage * scalar);
			fOuterDamage = (fOuterDamage * scalar);
			
			if ( fInnerDamage == 0 )
			{
				return;
			}
			if ( iDamage < 1 )
			{
				iDamage = 1;
			}
		}
		
		occupant_team = self maps\mp\_vehicles::vehicle_get_occupant_team();
			
		if ( level.teamBased && isPlayer( eAttacker ) && (occupant_team == eAttacker.pers["team"]) )
		{
			if ( level.friendlyfire == 0 ) 
			{
				if( !AllowFriendlyFireDamage( eInflictor, eAttacker, sMeansOfDeath, sWeapon ) )
					return;
				
				if ( iDamage < 1 )
					iDamage = 1;
				
				self.lastDamageWasFromEnemy = false;
				
				self finishVehicleRadiusDamage(eInflictor, eAttacker, iDamage, fInnerDamage, fOuterDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, fRadius, fConeAngleCos, vConeDir, psOffsetTime);
			}
			else if ( level.friendlyfire == 1 ) 
			{
				
				if ( iDamage < 1 )
					iDamage = 1;
				
				self.lastDamageWasFromEnemy = false;
				
				self finishVehicleRadiusDamage(eInflictor, eAttacker, iDamage, fInnerDamage, fOuterDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, fRadius, fConeAngleCos, vConeDir, psOffsetTime);
			}
			else if ( level.friendlyfire == 2 ) 
			{
				if( !AllowFriendlyFireDamage( eInflictor, eAttacker, sMeansOfDeath, sWeapon ) )
					return;
				
				if ( iDamage < 1 )
					iDamage = 1;
				
				self.lastDamageWasFromEnemy = false;
				
				self finishVehicleRadiusDamage(eInflictor, eAttacker, iDamage, fInnerDamage, fOuterDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, fRadius, fConeAngleCos, vConeDir, psOffsetTime);
			}
			else if ( level.friendlyfire == 3 ) 
			{
				iDamage = int(iDamage * .5);
				
				if ( iDamage < 1 )
					iDamage = 1;
				
				self.lastDamageWasFromEnemy = false;
				
				self finishVehicleRadiusDamage(eInflictor, eAttacker, iDamage, fInnerDamage, fOuterDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, fRadius, fConeAngleCos, vConeDir, psOffsetTime);
			}
			
			friendly = true;
		}
		else
		{
			
			if(iDamage < 1)
				iDamage = 1;
		
			self finishVehicleRadiusDamage(eInflictor, eAttacker, iDamage, fInnerDamage, fOuterDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, fRadius, fConeAngleCos, vConeDir, psOffsetTime);
		}
	}
}
clearLastTankAttacker()
{
	self endon( "disconnect" );
	self notify( "clearLastTankAttacker" );
	self endon( "clearLastTankAttacker" );
	count = 1;
	wait( 3 ); 
	while ( self.health < 99 && count < 10 )
	{
		wait ( 1 );
		count++;
	}	
	self.lastTankThatAttacked = undefined;
}
vehicleCrush()
{
	self endon("disconnect");
	
	if(IsDefined( level._effect ) && IsDefined( level._effect["tanksquish"] ) )
	{
		PlayFX( level._effect["tanksquish"], self.origin + (0, 0, 30));
	}
	self playsound( "chr_crunch" );
}
GetVehicleProjectileScalar( sWeapon )
{
	if ( sWeapon == "satchel_charge_mp" ) 
	{
		scale = 2.75;
	}
	else if ( sWeapon == "sticky_grenade_mp" ) 
	{
		scale = 2.25;
	}
	else if ( sWeapon == "claymore_mp" ) 
	{
		scale = 1;
	}
	else if ( issubstr(sWeapon,"bazooka") ) 
	{
		scale = 2.5;
	}
	else if ( sWeapon == "artillery_mp" ) 
	{
		scale = 2.75;
	}
	
	else if ( issubstr(sWeapon,"gl_") ) 
	{
		scale = 1.5;
	}
	
	else if ( issubstr(sWeapon,"turret_mp") ) 
	{
		scale = 2;
	}
	
	else if ( issubstr(sWeapon,"grenade") ) 
	{
		scale = .5;
	}
	else 
	{
		scale = 1;
	}
	
	return scale;
}
GetVehicleProjectileSplashScalar( sWeapon )
{
	if ( sWeapon == "satchel_charge_mp" ) 
	{
		scale = 0.5;
	}
	else if ( sWeapon == "sticky_grenade_mp" ) 
	{
		scale = 0.5;
	}
	else if ( sWeapon == "claymore_mp" ) 
	{
		scale = 0.1;
	}
	else if ( issubstr(sWeapon,"bazooka") ) 
	{
		scale = 0.1;
	}
	else if ( sWeapon == "artillery_mp" ) 
	{
		scale = 0.6;
	}
	
	else if ( issubstr(sWeapon,"gl_") ) 
	{
		scale = 0.1;
	}
	
	else if ( issubstr(sWeapon,"turrent_mp") ) 
	{
		scale = 0.1;
	}
	
	else if ( issubstr(sWeapon,"grenade") ) 
	{
		scale = 0.1;
	}
	else 
	{
		scale = 0.1;
	}
	
	return scale;
}
GetVehicleUnderneathSplashScalar( sWeapon )
{
	if ( sWeapon == "satchel_charge_mp" ) 
	{
		
		scale = 10.0;
		
		
		scale *= 3.0;
	}
	else 
	{
		scale = 1.0;
	}
	
	return scale;
}
GetVehicleBulletDamage( sWeapon )
{
	if( issubstr( sWeapon, "ptrs41_" ) )
	{
		iDamage = 25;
	}
	else if ( isSubStr( sWeapon, "gunner" ) )
	{
		iDamage = 5;
	}
	else if( issubstr(sWeapon,"mg42_bipod") || issubstr(sWeapon,"30cal_bipod") )  
	{
		iDamage = 5;
	}
	else
	{
		iDamage = 1;
	}
	return iDamage;
}
AllowFriendlyFireDamage( eInflictor, eAttacker, sMeansOfDeath, sWeapon )
{
	if (IsDefined( self.allowFriendlyFireDamageOverride ) )
	{
		return [[self.allowFriendlyFireDamageOverride]](eInflictor, eAttacker, sMeansOfDeath, sWeapon );
	}
	
	
	if ( sWeapon != "artillery_mp" )
		return false;
	vehicle = eAttacker GetVehicleOccupied();
	if( (isDefined( vehicle ) && vehicle == self) || ( IsDefined( self.owner ) && self.owner == eAttacker )  )
	{
		return true;
	}
	
	return false;
}
//	Callback Setup
//	This script provides the hooks from code into script for the gametype callback functions.

//=============================================================================
// Code Callback functions

/*================
Called by code after the level's main script function has run.
================*/
CodeCallback_StartGameType()
{
	// If the gametype has not beed started, run the startup
	if(!isDefined(level.gametypestarted) || !level.gametypestarted)
	{
		[[level.callbackStartGameType]]();

		level.gametypestarted = true; // so we know that the gametype has been started up
	}
}

/*================
Called when a player begins connecting to the server.
Called again for every map change or tournement restart.

Return undefined if the client should be allowed, otherwise return
a string with the reason for denial.

Otherwise, the client will be sent the current gamestate
and will eventually get to ClientBegin.

firstTime will be qtrue the very first time a client connects
to the server machine, but qfalse on map changes and tournement
restarts.
================*/
CodeCallback_PlayerConnect()
{
	self endon("disconnect");
	//TUEY:  we can axe this if we need to----didn't know of a better place to put it.  This is for 
	//the new Bump and Step trigger system.
	self thread maps\mp\_audio::monitor_player_sprint();
	[[level.callbackPlayerConnect]]();
}

/*================
Called when a player drops from the server.
Will not be called between levels.
self is the player that is disconnecting.
================*/
CodeCallback_PlayerDisconnect()
{
	self notify("disconnect");
	
	// CODER_MOD - DSL - 03/24/08
	// Tidy up ambient triggers.

	client_num = self getentitynumber();

	[[level.callbackPlayerDisconnect]]();
}


/*================
Called when a host migration has occurred
================*/
CodeCallback_HostMigration()
{
	PrintLn("****CodeCallback_HostMigration****");
	[[level.callbackHostMigration]]();
}


/*================
Called when a host migration save has occurred
================*/
CodeCallback_HostMigrationSave()
{
	PrintLn("****CodeCallback_HostMigrationSave****");
	[[level.callbackHostMigrationSave]]();
}


/*================
Called when a player migration has occurred
================*/
CodeCallback_PlayerMigrated()
{
	PrintLn("****CodeCallback_PlayerMigrated****");
	[[level.callbackPlayerMigrated]]();
}


/*================
Called when a player has taken damage.
self is the player that took damage.
================*/
CodeCallback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	self endon("disconnect");
	[[level.callbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}

/*================
Called when a player has been killed.
self is the player that was killed.
================*/
CodeCallback_PlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	self endon("disconnect");
	[[level.callbackPlayerKilled]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
}

/*================
Called when a player has been killed, but has last stand perk.
self is the player that was killed.
================*/
CodeCallback_PlayerLastStand(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration )
{
	self endon("disconnect");
	[[level.callbackPlayerLastStand]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
}

/*================
Called when a actor has taken damage.
self is the actor that took damage.
================*/
CodeCallback_ActorDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	[[level.callbackActorDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}

/*================
Called when a actor has been killed.
self is the actor that was killed.
================*/
CodeCallback_ActorKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset)
{
	[[level.callbackActorKilled]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset);
}


/*================
Called when a vehicle has taken damage.
self is the vehicl that took damage.
================*/
CodeCallback_VehicleDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName)
{
	[[level.callbackVehicleDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset, damageFromUnderneath, modelIndex, partName);
}


/*================
Called when a vehicle has taken damage.
self is the vehicl that took damage.
================*/
CodeCallback_VehicleRadiusDamage(eInflictor, eAttacker, iDamage, fInnerDamage, fOuterDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, fRadius, fConeAngleCos, vConeDir, timeOffset)
{
	[[level.callbackVehicleRadiusDamage]](eInflictor, eAttacker, iDamage, fInnerDamage, fOuterDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, fRadius, fConeAngleCos, vConeDir, timeOffset);
}

// CODER_MOD - GMJ - 05/19/08 - Generic mechanism to notify level from code.
/*================
Called from code to send a notification to the level object.
================*/
CodeCallback_LevelNotify(level_notify, param1, param2)
{
	level thread Callback_DoLevelNotify( level_notify, param1, param2 );
}

Callback_DoLevelNotify( level_notify, param1, param2 )
{
	wait ( 0.05 );

	if ( isdefined( param1 ) && isdefined( param2 ) )
	{
		level notify( level_notify, param1, param2 );
	}
	else if( isdefined( param1 ) )
	{
		level notify( level_notify, param1 );
	}
	else
	{
		level notify ( level_notify );
	}
}

// CODER_MOD - LDS - 06/02/10 - Callback to inform facial animation system of new event
CodeCallback_FaceEventNotify( notify_msg, ent )
{
	if( IsDefined( ent ) && IsDefined( ent.do_face_anims ) && ent.do_face_anims )
	{
		if( IsDefined( level.face_event_handler ) && IsDefined( level.face_event_handler.events[notify_msg] ) )
		{
			ent SendFaceEvent( level.face_event_handler.events[notify_msg] );
		}
	}
}

//=============================================================================

/*================
Setup any misc callbacks stuff like defines and default callbacks
================*/
SetupCallbacks()
{
	SetDefaultCallbacks();
	
	// Set defined for damage flags used in the playerDamage callback
	level.iDFLAGS_RADIUS			= 1;
	level.iDFLAGS_NO_ARMOR			= 2;
	level.iDFLAGS_NO_KNOCKBACK		= 4;
	level.iDFLAGS_PENETRATION		= 8;
	level.iDFLAGS_NO_TEAM_PROTECTION = 16;
	level.iDFLAGS_NO_PROTECTION		= 32;
	level.iDFLAGS_PASSTHRU			= 64;
}

/*================
Called from the gametype script to store off the default callback functions.
This allows the callbacks to be overridden by level script, but not lost.
================*/
SetDefaultCallbacks()
{
	level.callbackStartGameType = maps\mp\gametypes\_globallogic::Callback_StartGameType;
	level.callbackPlayerConnect = maps\mp\gametypes\_globallogic_player::Callback_PlayerConnect;
	level.callbackPlayerDisconnect = maps\mp\gametypes\_globallogic_player::Callback_PlayerDisconnect;
	level.callbackPlayerDamage = maps\mp\gametypes\_globallogic_player::Callback_PlayerDamage;
	level.callbackPlayerKilled = maps\mp\gametypes\_globallogic_player::Callback_PlayerKilled;
	level.callbackPlayerLastStand = maps\mp\gametypes\_globallogic_player::Callback_PlayerLastStand;
	level.callbackActorDamage = maps\mp\gametypes\_globallogic_actor::Callback_ActorDamage;
	level.callbackActorKilled = maps\mp\gametypes\_globallogic_actor::Callback_ActorKilled;
	level.callbackVehicleDamage = maps\mp\gametypes\_globallogic_vehicle::Callback_VehicleDamage;
	level.callbackVehicleRadiusDamage = maps\mp\gametypes\_globallogic_vehicle::Callback_VehicleRadiusDamage;
	level.callbackPlayerMigrated = maps\mp\gametypes\_globallogic_player::Callback_PlayerMigrated;
	level.callbackHostMigration = maps\mp\gametypes\_hostmigration::Callback_HostMigration;
	level.callbackHostMigrationSave = maps\mp\gametypes\_hostmigration::Callback_HostMigrationSave;
}

/*================
Called when a gametype is not supported.
================*/
AbortLevel()
{
	println("Aborting level - gametype is not supported");

	level.callbackStartGameType = ::callbackVoid;
	level.callbackPlayerConnect = ::callbackVoid;
	level.callbackPlayerDisconnect = ::callbackVoid;
	level.callbackPlayerDamage = ::callbackVoid;
	level.callbackPlayerKilled = ::callbackVoid;
	level.callbackPlayerLastStand = ::callbackVoid;
	level.callbackActorDamage = ::callbackVoid;
	level.callbackActorKilled = ::callbackVoid;
	level.callbackVehicleDamage = ::callbackVoid;

	setdvar("g_gametype", "dm");

	exitLevel(false);
}

CodeCallback_GlassSmash(pos, dir)
{
	level notify("glass_smash", pos, dir);
}

/*================
================*/
callbackVoid()
{
}

 
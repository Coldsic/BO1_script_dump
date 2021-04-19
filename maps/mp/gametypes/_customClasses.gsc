#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
isCustomGame()
{
	return ( !level.onlineGame || GetDvarInt( #"xblive_privatematch" ) ) && GetDvarInt( #"customgamemode" );
}
isUsingCustomGameModeClasses()
{
	return isCustomGame() && GetDvarInt( #"custom_class_mode" ) == 1;
}
shouldGiveLeaderBonus()
{
	return isPlayer( self ) && ( ( level.gameType == "tdm" && level.placement[ self.team ][0] == self ) || ( level.gameType == "dm" && level.placement[ "all" ][0] == self ) );
}
setMovementSpeedModifier()
{
	speed = 1.0;
	if( isDefined( self.class_num ) && isDefined( self.custom_class[ self.class_num ][ "movementSpeed" ] ) )
	{
		switch( self.custom_class[ self.class_num ][ "movementSpeed" ] )
		{
		case 1:
			speed = 0.5;
			break;
		case 2:
			speed = 0.8;
			break;
		case 4:
			speed = 1.2;
			break;
		case 5:
			speed = 1.75;
			break;
		}
	}
	self setMoveSpeedScale( speed );
}
getModifiedHealth()
{
	if( isDefined( self.class_num ) && isDefined( self.custom_class[ self.class_num ][ "health" ] ) )
	{
		return self.custom_class[ self.class_num ][ "health" ];
	}
	return 100.0;
}
getHealthRegenModifier()
{
	regen = 0.1;
	if( isDefined( self.class_num ) && isDefined( self.custom_class[ self.class_num ][ "healthRegeneration" ] ) )
	{
		switch( self.custom_class[ self.class_num ][ "healthRegeneration" ] )
		{
		case 1:
			regen = 0.0;
			break;
		case 2:
			regen = 0.01;
			break;
		case 3:
			regen = 0.05;
			break;
		case 5:
			regen = 0.2;
			break;
		case 6:
			regen = 0.4;
			break;
		}
	}
	return regen;
}
getHealthRegenTime()
{
	regenTime = level.playerHealth_RegularRegenDelay;
	if( isDefined( self.class_num ) && isDefined( self.custom_class[ self.class_num ][ "healthRegeneration" ] ) )
	{
		switch( self.custom_class[ self.class_num ][ "healthRegeneration" ] )
		{
		case 2: 
			regenTime += 3000;
			break;
		case 3: 
			regenTime += 2000;
			break;
		case 5: 
			regenTime -= 2000;
			break;
		case 6: 
			regenTime -= 3000;
			break;
		}
	}
	return regenTime;
}
getHealthVampirismModifier()
{
	vampirism = 0.0;
	if( isDefined( self.class_num ) && isDefined( self.custom_class[ self.class_num ][ "healthVampirism" ] ) )
	{
		vampirism = self.custom_class[ self.class_num ][ "healthVampirism" ] / 100.0;
	}
	return vampirism;
}
getDamageModifier()
{
	damage = 1.0;
	if( isDefined( self.class_num ) && isDefined( self.custom_class[ self.class_num ][ "damage" ] ) )
	{
		switch( self.custom_class[ self.class_num ][ "damage" ] )
		{
		case 1:
			damage = 0.25;
			break;
		case 3:
			damage = 1.5;
			break;
		case 4:
			damage = 2.0;
			break;
		case 5:
			damage = 4.0;
			break;
		}
	}
	return damage;
}
getExplosiveDamageModifier()
{
	damageExplosive = 1.0;
	if( isDefined( self.class_num ) && isDefined( self.custom_class[ self.class_num ][ "damageExplosive" ] ) )
	{
		switch( self.custom_class[ self.class_num ][ "damageExplosive" ] )
		{
		case 1:
			damageExplosive = 0.25;
			break;
		case 3:
			damageExplosive = 1.5;
			break;
		case 4:
			damageExplosive = 2.0;
			break;
		case 5:
			damageExplosive = 4.0;
			break;
		}
	}
	return damageExplosive;
}
sprintSpeedModifier()
{
	self endon("disconnect");
	
	while(1)
	{
		self waittill( "sprint_begin" );
		if( isDefined( self.class_num ) && isDefined( self.custom_class[ self.class_num ][ "movementSprintSpeed" ] ) )
		{
			sprintModifier = 1.0;
			switch( self.custom_class[ self.class_num ][ "movementSprintSpeed" ] )
			{
			case 2:
				sprintModifier = 1.25;
				break;
			case 3:
				sprintModifier = 1.5;
				break;
			}
			oldMoveSpeedScale = self getMoveSpeedScale();
			self setMoveSpeedScale( oldMoveSpeedScale * sprintModifier );
			self waittill( "sprint_end" );
			self setMoveSpeedScale( oldMoveSpeedScale );
		}
	}
} 

#include maps\_vehicle;
#include maps\_utility;


#using_animtree ("vehicles");
main()
{
	
	if(IsDefined(self.script_string) && self.script_string == "sink_me")
	{
		level._effect["sink_fx"+ self.vehicletype] = LoadFX("vehicle/vexplosion/fx_vexp_sampan_machinegun");
		level._effect["explo_fx"+ self.vehicletype] = LoadFX("vehicle/vexplosion/fx_vexp_sampan");
		level.vehicle_death_thread[self.vehicletype] = ::delete_and_sink_fx;
	}
}

delete_and_sink_fx()
{
	self notify( "nodeath_thread" );
	
	if(!IsDefined(self.weapon_last_damage))
	{
		self.weapon_last_damage = "hind_rockets";
	}
	
	if(self.weapon_last_damage == "hind_rockets")
	{
		PlayFX(level._effect["explo_fx"+ self.vehicletype], self.origin, AnglesToForward(self.angles));
		
		//SOUND - Shawn J
		//iprintlnbold ( "Sampan Explo");
		self PlaySound("evt_sampan_explo");
	}
	else // if(self.weapon_last_damage == "hind_minigun_pilot")
	{
		PlayFX(level._effect["sink_fx"+ self.vehicletype], self.origin, AnglesToForward(self.angles));
		
		//SOUND - Shawn J
		//iprintlnbold ( "Sampan Sink");
		self PlaySound("evt_sampan_sink");
	}
	
	waittillframeend;
	self Delete();
} 
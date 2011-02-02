/**
 * File: War3Source_CryptLord.sp
 * Description: The Crypt Lord race for War3Source.
 * Author(s): Anthony Iacono & Ownage | Ownz (DarkEnergy)
 */
 
#pragma semicolon 1

#include <sourcemod>
#include "W3SIncs/War3Source_Interface"
#include <sdktools>
#include <sdktools_functions>
#include <sdktools_tempents>
#include <sdktools_tempents_stocks>

new thisRaceID;

new SKILL_IMPALE,SKILL_SPIKE,SKILL_BEETLES,ULT_LOCUST;

//skill 1
new Float:ImpaleChanceArr[]={0.0,0.05,0.09,0.12,0.15}; 

//skill 2
new Float:SpikeDamageRecieve[]={1.0,0.95,0.9,0.85,0.8};
new Float:SpikeArmorGainArr[]={0.0,0.1,0.20,0.3,0.40}; 
new Float:SpikeReturnDmgArr[]={0.0,0.05,0.10,0.15,0.2}; 

//skill 3
new const BeetleDamage=15;
new Float:BeetleChanceArr[]={0.0,0.05,0.1,0.15,0.2};

//ultimate
new Handle:ultCooldownCvar;
new Handle:ultRangeCvar;
new Float:LocustDamagePercent[]={0.0,0.1,0.2,0.3,0.4};

new String:ultimateSound[]="war3source/locustswarmloop.wav";


public Plugin:myinfo = 
{
	name = "War3Source Race - Crypt Lord",
	author = "PimpinJuice & Ownz (DarkEnergy)",
	description = "The Crypt Lord race for War3Source.",
	version = "1.0.0.0",
	url = "http://Www.OwnageClan.Com"
};

public OnPluginStart()
{
	
	ultCooldownCvar=CreateConVar("war3_crypt_locust_cooldown","20","Cooldown between ultimate usage");
	ultRangeCvar=CreateConVar("war3_crypt_locust_range","800","Range of locust ultimate");
	
	LoadTranslations("w3s.race.crypt.phrases");
}

public OnWar3LoadRaceOrItemOrdered(num)
{
	if(num==80)
	{

								
		thisRaceID=War3_CreateNewRaceT("crypt");
		SKILL_IMPALE=War3_AddRaceSkillT(thisRaceID,"Impale",false,4);
		SKILL_SPIKE=War3_AddRaceSkillT(thisRaceID,War3_GetGame()==Game_CS?"SpikedCarapaceCS":"SpikedCarapaceTF",false,4);
		SKILL_BEETLES=War3_AddRaceSkillT(thisRaceID,"CarrionBeetles",false,4);
		ULT_LOCUST=War3_AddRaceSkillT(thisRaceID,"LocustSwarm",true,4); 
		War3_CreateRaceEnd(thisRaceID);	
	}

}

public OnMapStart()
{
	
	War3_PrecacheSound(ultimateSound);
}

public OnWar3PlayerAuthed(client)
{
	
}

public OnRaceSelected(client,race)
{
	if(race!=thisRaceID)
	{
	}
}


public OnUltimateCommand(client,race,bool:pressed)
{

	if(race==thisRaceID && pressed && ValidPlayer(client,true) )
	{
		new ult_level=War3_GetSkillLevel(client,race,ULT_LOCUST);
		if(ult_level>0)
		{
			
			if(!Silenced(client)&&War3_SkillNotInCooldown(client,thisRaceID,ULT_LOCUST,true))
			{
				new Float:posVec[3];
				GetClientAbsOrigin(client,posVec);
				new Float:otherVec[3];
				new Float:bestTargetDistance=999999.0; 
				new team = GetClientTeam(client);
				new bestTarget=0;
				
				new Float:ultmaxdistance=GetConVarFloat(ultRangeCvar);
				for(new i=1;i<=MaxClients;i++)
				{
					if(ValidPlayer(i,true)&&GetClientTeam(i)!=team&&!W3HasImmunity(i,Immunity_Ultimates))
					{
						GetClientAbsOrigin(i,otherVec);
						new Float:dist=GetVectorDistance(posVec,otherVec);
						if(dist<bestTargetDistance&&dist<ultmaxdistance)
						{
							bestTarget=i;
							bestTargetDistance=GetVectorDistance(posVec,otherVec);
							
						}
					}
				}
				if(bestTarget==0)
				{
					W3MsgNoTargetFound(client,ultmaxdistance);
				}
				else
				{
					new damage=RoundFloat(float(War3_GetMaxHP(bestTarget))*LocustDamagePercent[ult_level]);
					if(damage>0)
					{
						
						if(War3_DealDamage(bestTarget,damage,client,DMG_BULLET,"locust")) //default magic
						{
							W3PrintSkillDmgHintConsole(bestTarget,client,War3_GetWar3DamageDealt(),"Locust");
							W3FlashScreen(bestTarget,RGBA_COLOR_RED);
							
							EmitSoundToAll(ultimateSound,client);
							War3_CooldownMGR(client,GetConVarFloat(ultCooldownCvar),thisRaceID,ULT_LOCUST,false,false,_,"Locust");
						}
					}
				}
			}
		}
		else
		{
			W3MsgUltNotLeveled(client);
		}
	}
}




public OnW3TakeDmgBullet(victim,attacker,Float:damage){
	if(ValidPlayer(victim,true)&&ValidPlayer(attacker,true)&&GetClientTeam(victim)!=GetClientTeam(attacker))
	{
		if(War3_GetRace(victim)==thisRaceID)
		{
			new skill_level=War3_GetSkillLevel(victim,thisRaceID,SKILL_SPIKE);
			if(skill_level>0&&!Hexed(victim,false))
			{
				War3_DamageModPercent(SpikeDamageRecieve[skill_level]);  
			}
		}	
	}
}
public OnWar3EventPostHurt(victim,attacker,damage)
{

	if(W3GetDamageIsBullet()&&ValidPlayer(victim,true)&&ValidPlayer(attacker,true)&&GetClientTeam(victim)!=GetClientTeam(attacker))
	{
		
		if(War3_GetRace(victim)==thisRaceID)
		{
			new skill_level=War3_GetSkillLevel(victim,thisRaceID,SKILL_SPIKE);
			if(skill_level>0&&!Hexed(victim,false))
			{
				if(!W3HasImmunity(attacker,Immunity_Skills)){
					if(War3_GetGame()==Game_CS)
					{
						new armor=War3_GetCSArmor(victim);
						new armor_add=RoundFloat(damage*SpikeArmorGainArr[skill_level]);
						if(armor_add>20) armor_add=20;
						War3_SetCSArmor(victim,armor+armor_add);
						
						
					}
					new returndmg=RoundFloat(FloatMul(SpikeReturnDmgArr[skill_level],float(damage)));
					returndmg=returndmg<40?returndmg:40;
					War3_DealDamage(attacker,returndmg,victim,_,"spiked_carapace",W3DMGORIGIN_SKILL,W3DMGTYPE_PHYSICAL);
					PrintToConsole(victim,"%T","Returned {amount} damage to {player}",victim,War3_GetWar3DamageDealt(),attacker);
					PrintToConsole(attacker,"%T","Received {amount} damage from Spiked Carapace from {player}",attacker,War3_GetWar3DamageDealt(),victim);
				}
			}
			
			
			skill_level = War3_GetSkillLevel(attacker,thisRaceID,SKILL_IMPALE);
			if(skill_level>0&&!Hexed(victim,false)&&GetRandomFloat(0.0,1.0)<=ImpaleChanceArr[skill_level])
			{
				if(W3HasImmunity(attacker,Immunity_Skills))
				{
					PrintHintText(attacker,"%T","Blocked Impale",attacker);
					PrintHintText(victim,"%T","Enemy Blocked Impale",victim);
				}
				else
				{
					War3_ShakeScreen(attacker,2.0,50.0,40.0);
					PrintHintText(victim,"%T","Impaled enemy",victim);
					PrintHintText(attacker,"%T","You got impaled by enemy",attacker);
					W3FlashScreen(attacker,{0,0,128,80});
				}
			}	
		}
		if(War3_GetRace(attacker)==thisRaceID)
		{
			new skill_level = War3_GetSkillLevel(attacker,thisRaceID,SKILL_BEETLES);
			if(!Hexed(attacker,false)&&GetRandomFloat(0.0,1.0)<=BeetleChanceArr[skill_level])
			{
				if(W3HasImmunity(victim,Immunity_Skills))
				{
					PrintHintText(victim,"%T","You blocked beetles attack",victim);
					PrintHintText(attacker,"%T","Beetles attack was blocked",attacker);
				}
				else
				{
					
					War3_DealDamage(victim,BeetleDamage,attacker,DMG_BULLET,"beetles");
					W3PrintSkillDmgHintConsole(victim,attacker,War3_GetWar3DamageDealt(),"beetles");
					W3FlashScreen(victim,RGBA_COLOR_RED);
					
				}
			}
			skill_level = War3_GetSkillLevel(attacker,thisRaceID,SKILL_IMPALE);
			if(skill_level>0&&!Hexed(attacker,false)&&GetRandomFloat(0.0,1.0)<=ImpaleChanceArr[skill_level]) //spike always activates except chancemod reduction
			{
				if(W3HasImmunity(attacker,Immunity_Skills)){
					PrintHintText(victim,"%T","Blocked Impale",victim);
					PrintHintText(attacker,"%T","Enemy Blocked Impale",attacker);
				}
				else
				{
					War3_ShakeScreen(victim,2.0,50.0,40.0);
					PrintHintText(victim,"%T","You got impaled by enemy",victim);
					PrintHintText(attacker,"%T","Impaled enemy",attacker);
					W3FlashScreen(victim,{0,0,128,80});
				}
			}
		}
	}
}


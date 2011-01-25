

#include <sourcemod>
#include "W3SIncs/War3Source_Interface"



public Plugin:myinfo= 
{
	name="War3Source Admin Console",
	author="Ownz (DarkEnergy)",
	description="War3Source Core Plugins",
	version="1.0",
	url="http://war3source.com/"
};



public APLRes:AskPluginLoad2(Handle:myself,bool:late,String:error[],err_max)
{
	if(!InitNativesForwards())
	{
		LogError("[War3Source] There was a failure in creating the native / forwards based functions, definately halting.");
		return APLRes_Failure;
	}
	return APLRes_Success;
}

public OnPluginStart()
{
	
	RegAdminCmd("war3_setxp",War3Source_CMDSetXP,ADMFLAG_RCON,"Set a player's XP");
	RegAdminCmd("war3_givexp",War3Source_CMD_GiveXP,ADMFLAG_RCON,"Give a player XP");
	RegAdminCmd("war3_removexp",War3Source_CMD_RemoveXP,ADMFLAG_RCON,"Remove some XP from a player");
	RegConsoleCmd("war3_setlevel",War3Source_CMD_War3_SetLevel,"Set a player's level");
	RegAdminCmd("war3_givelevel",War3Source_CMD_GiveLevel,ADMFLAG_RCON,"Give a player a single level");
	RegAdminCmd("war3_removelevel",War3Source_CMD_RemoveLevel,ADMFLAG_RCON,"Remove a single level from a player");
	RegAdminCmd("war3_setgold",War3Source_CMD_War3_SetGold,ADMFLAG_RCON,"Set a player's gold count");
	RegAdminCmd("war3_givegold",War3Source_CMD_GiveGold,ADMFLAG_RCON,"Give a player gold");
	RegAdminCmd("war3_removegold",War3Source_CMD_RemoveGold,ADMFLAG_RCON,"Remove some gold from a player");

}

bool:InitNativesForwards()
{
	return true;
}


public War3Source_PlayerParse(String:matchstr[],playerlist[])
{
	new i=0;
	if(StrEqual(matchstr,"@all",false))
	{
		// All?
		
		for(new x=1;x<=MaxClients;x++)
		{
			if(ValidPlayer(x))
			{
				playerlist[i++]=x;
			}
		}
	}
	else
	{
		// Team?
		if(StrEqual(matchstr,"@ct",false))
		{
			for(new x=1;x<=MaxClients;x++)
			{
				if(ValidPlayer(x))
				{	
					if(GetClientTeam(x)==3){
						playerlist[i++]=x;
					}
				}
			}
		}
		else if(StrEqual(matchstr,"@t",false))
		{
			for(new x=1;x<=MaxClients;x++)
			{
				if(ValidPlayer(x))
				{	
					if(GetClientTeam(x)==2){
						playerlist[i++]=x;
					}
				}
			}
		}
		else
		{
			// Userid?
			if(matchstr[0]=='@')
			{
				new uid=StringToInt(matchstr[1]); //startign from index 1
				for(new x=1;x<=MaxClients;x++)
				{
					if(ValidPlayer(x))
					{	
						if(GetClientUserId(x)==uid){
							playerlist[i++]=x;
							break;
						}
					}
				}
			}
			else
			{
				// Player name?
				for(new x=1;x<=MaxClients;x++)
				{
					if(ValidPlayer(x))
					{	
						new String:name[64];
						GetClientName(x,name,sizeof(name));
						if(StrContains(name,matchstr,false)!=-1)
						{
							playerlist[i++]=x;
							break;
						}
					}
				}
			}
		}
	}
	return i;
}

public Action:War3Source_CMDSetXP(client,args)
{
	if(args!=2)
		PrintToConsole(client,"%T","[War3Source] The syntax of the command is: war3_setxp <player> <xp>",client);
	else
	{
		decl String:match[64];
		GetCmdArg(1,match,sizeof(match));
		decl String:buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		new String:adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		new xp=StringToInt(buf);
		if(xp<0)
			xp=0;
		new playerlist[66];
		new results=War3Source_PlayerParse(match,playerlist);
		for(new x=0;x<results;x++)
		{
			decl String:name[64];	
			GetClientName(playerlist[x],name,sizeof(name));
			
			new race=War3_GetRace(playerlist[x]);
			if(race>0)
			{
				War3_SetXP(playerlist[x],race,xp);
				PrintToConsole(client,"%T","[War3Source] You just set {player} XP to {amount}",client,name,xp);
				War3_ChatMessage(playerlist[x],"%T","Admin {player} set your XP to {amount}",playerlist[x],adminname,xp);
				W3DoLevelCheck(playerlist[x]);
			}
		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source] No players matched your query",client);
	}
	return Plugin_Handled;
}

public Action:War3Source_CMD_GiveXP(client,args)
{
	if(args!=2)
		PrintToConsole(client,"%T","[War3Source] The syntax of the command is: war3_givexp <player> <xp>",client);
	else
	{

		decl String:match[64];
		GetCmdArg(1,match,sizeof(match));
		decl String:buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		new String:adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		new xp=StringToInt(buf);
		if(xp<0)
			xp=0;
		
		
		new playerlist[66];
		new results=War3Source_PlayerParse(match,playerlist);
		for(new x=0;x<results;x++)
		{
			
			decl String:name[64];
			GetClientName(playerlist[x],name,sizeof(name));
			new race=War3_GetRace(playerlist[x]);
			if(race>0)
			{
				
				new oldxp=War3_GetXP(playerlist[x],race);
				War3_SetXP(playerlist[x],race,oldxp+xp);
				PrintToConsole(client,"%T","[War3Source] You just gave {amount} XP to {player}",client,xp,name);
				War3_ChatMessage(playerlist[x],"%T","Admin {player} gave you {amount} XP",playerlist[x],adminname,xp);
				W3DoLevelCheck(playerlist[x]);
				
			}
			
		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source] No players matched your query",client);
	}
	return Plugin_Handled;
}

public Action:War3Source_CMD_RemoveXP(client,args)
{
	if(args!=2)
		PrintToConsole(client,"%T","[War3Source] The syntax of the command is: war3_removexp <player> <xp>",client);
	else
	{
		decl String:match[64];
		GetCmdArg(1,match,sizeof(match));
		decl String:buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		new String:adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		new xp=StringToInt(buf);
		if(xp<0)
			xp=0;
		new playerlist[66];
		new results=War3Source_PlayerParse(match,playerlist);
		for(new x=0;x<results;x++)
		{
			decl String:name[64];
			GetClientName(playerlist[x],name,sizeof(name));
			
			new race=War3_GetRace(playerlist[x]);
			if(race>0)
			{
				new newxp=War3_GetXP(playerlist[x],race)-xp;
				if(newxp<0)
					newxp=0;
				War3_SetXP(playerlist[x],race,newxp);
				PrintToConsole(client,"%T","[War3Source] You just removed {amount} XP from {player}",client,xp,name);
				War3_ChatMessage(playerlist[x],"%T","Admin {player} removed {amount} XP from you",playerlist[x],adminname,xp);
				W3DoLevelCheck(playerlist[x]);
			}
		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source] No players matched your query",client);
	}
	return Plugin_Handled;
}

public Action:War3Source_CMD_War3_SetLevel(client,args)
{
	if(client!=0&&!HasSMAccess(client,ADMFLAG_CUSTOM6)){
		ReplyToCommand(client,"No Access");
	}
	else if(args!=2)
		PrintToConsole(client,"%T","[War3Source] The syntax of the command is: war3_War3_SetLevel <player> <level>",client);
	else
	{
		decl String:match[64];
		GetCmdArg(1,match,sizeof(match));
		decl String:buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		new String:adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		new level=StringToInt(buf);
		if(level<0)
			level=0;
		
		new playerlist[66];
		new results=War3Source_PlayerParse(match,playerlist);
		for(new x=0;x<results;x++)
		{
			decl String:name[64];
			GetClientName(playerlist[x],name,sizeof(name));
			
			new race=War3_GetRace(playerlist[x]);
			if(race>0)
			{
				new oldlevel=War3_GetLevel(playerlist[x],race);
				if(oldlevel>level)
					War3_SetXP(playerlist[x],race,0);
				
				
				W3ClearSkillLevels(playerlist[x],race);
				
				if(level>W3GetRaceMaxLevel(race)){
					level=W3GetRaceMaxLevel(race);
				}
				War3_SetLevel(playerlist[x],race,level);
				PrintToConsole(client,"%T","[War3Source] You just set player {player} level to {amount}",client,name,level);
				War3_ChatMessage(playerlist[x],"%T","Admin {player} set your level to {amount}, re-pick your skills",playerlist[x],adminname,level);
				
			
				
				W3DoLevelCheck(playerlist[x]);
				
			}
		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source] No players matched your query",client);
		
	}
	return Plugin_Handled;
}

public Action:War3Source_CMD_GiveLevel(client,args)
{
	if(args!=1)
		PrintToConsole(client,"%T","[War3Source] The syntax of the command is: war3_givelevel <player>",client);
	else
	{
		decl String:match[64];
		GetCmdArg(1,match,sizeof(match));
		new String:adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		
		new playerlist[66];
		new results=War3Source_PlayerParse(match,playerlist);
		for(new x=0;x<results;x++)
		{
			decl String:name[64];
			GetClientName(playerlist[x],name,sizeof(name));
			
			
			new race=War3_GetRace(playerlist[x]);
			if(race>0)
			{
				new newlevel=War3_GetLevel(playerlist[x],race)+1;
				if(newlevel>W3GetRaceMaxLevel(race))
					PrintToConsole(client,"%T","[War3Source] Player {player} is already at their max level",client,name);
				else
				{
					War3_SetLevel(playerlist[x],race,newlevel);
					PrintToConsole(client,"%T","[War3Source] You just gave player {player} a level",client,name);
					War3_ChatMessage(playerlist[x],"%T","Admin {player} gave you a level",playerlist[x],adminname);
					W3DoLevelCheck(playerlist[x]);
				}
			}
			
		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source] No players matched your query",client);
		
	}
	return Plugin_Handled;
	
}

public Action:War3Source_CMD_RemoveLevel(client,args)
{
	if(args!=1)
		PrintToConsole(client,"%T","[War3Source] The syntax of the command is: war3_removelevel <player>",client);
	else
	{
		decl String:match[64];
		GetCmdArg(1,match,sizeof(match));
		new String:adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		
		
		new playerlist[66];
		new results=War3Source_PlayerParse(match,playerlist);
		for(new x=0;x<results;x++)
		{
			decl String:name[64];
			GetClientName(playerlist[x],name,sizeof(name));
			
			new race=War3_GetRace(playerlist[x]);
			if(race>0)
			{
				new newlevel=War3_GetLevel(playerlist[x],race)-1;
				if(newlevel<0)
					PrintToConsole(client,"%T","[War3Source] Player {player} is already at level 0",client,name);
				else
				{
					W3ClearSkillLevels(playerlist[x],race);
					
					War3_SetLevel(playerlist[x],race,newlevel);
					PrintToConsole(client,"%T","[War3Source] You just removed a level from player {player}",client,name);
					War3_ChatMessage(playerlist[x],"%T","Admin {player} removed a level from you, re-pick your skills",playerlist[x],adminname);
					W3DoLevelCheck(playerlist[x]);
				}
			}
			
		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source] No players matched your query",client);
		
	}
	return Plugin_Handled;
}

public Action:War3Source_CMD_War3_SetGold(client,args)
{
	if(args!=2)
		PrintToConsole(client,"%T","[War3Source] The syntax of the command is: war3_War3_SetGold <player> <gold>",client);
	else
	{
		decl String:match[64];
		GetCmdArg(1,match,sizeof(match));
		decl String:buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		new maxgold=W3GetMaxGold();
		new String:adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		new gold=StringToInt(buf);
		if(gold<0)
			gold=0;
		if(gold>maxgold)
			gold=maxgold;
		
		new playerlist[66];
		new results=War3Source_PlayerParse(match,playerlist);
		for(new x=0;x<results;x++)
		{
			decl String:name[64];
			GetClientName(playerlist[x],name,sizeof(name));
			
			
			War3_SetGold(playerlist[x],gold);
			PrintToConsole(client,"%T","[War3Source] You just set player {player} gold to {amount}",client,name,gold);
			War3_ChatMessage(playerlist[x],"%T","Admin {player} set your gold to {amount}",playerlist[x],adminname,gold);
		
		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source] No players matched your query",client);

	}
	return Plugin_Handled;
}

public Action:War3Source_CMD_GiveGold(client,args)
{
	if(args!=2)
		PrintToConsole(client,"%T","[War3Source] The syntax of the command is: war3_givegold <player> <gold>",client);
	else
	{
		decl String:match[64];
		GetCmdArg(1,match,sizeof(match));
		decl String:buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		new String:adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		new gold=StringToInt(buf);
		if(gold<0)
			gold=0;
		
		new maxgold=W3GetMaxGold();
		
		new playerlist[66];
		new results=War3Source_PlayerParse(match,playerlist);
		for(new x=0;x<results;x++)
		{
			decl String:name[64];
			GetClientName(playerlist[x],name,sizeof(name));
			
			
			new newgold=War3_GetGold(playerlist[x])+gold;
			if(newgold<0)
				newgold=0;
			if(newgold>maxgold)
				newgold=maxgold;
			War3_SetGold(playerlist[x],newgold);
			PrintToConsole(client,"%T","[War3Source] You just gave player {player} {amount} gold",client,name,gold);
			War3_ChatMessage(playerlist[x],"%T","Admin {player} give you {amount} gold",playerlist[x],adminname,gold);
		
		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source] No players matched your query",client);

	}
	return Plugin_Handled;
}

public Action:War3Source_CMD_RemoveGold(client,args)
{
	if(args!=2)
		PrintToConsole(client,"%T","[War3Source] The syntax of the command is: war3_givegold <player> <gold>",client);
	else
	{
		decl String:match[64];
		GetCmdArg(1,match,sizeof(match));
		decl String:buf[32];
		GetCmdArg(2,buf,sizeof(buf));
		new String:adminname[64];
		if(client!=0)
			GetClientName(client,adminname,sizeof(adminname));
		else
			adminname="Console";
		new gold=StringToInt(buf);
		if(gold<0)
			gold=0;
		
		new maxgold=W3GetMaxGold();
		
		new playerlist[66];
		new results=War3Source_PlayerParse(match,playerlist);
		for(new x=0;x<results;x++)
		{
			decl String:name[64];
			GetClientName(playerlist[x],name,sizeof(name));
			
			new newcreds=War3_GetGold(playerlist[x])-gold;
			if(newcreds<0)
				newcreds=0;
			if(newcreds>maxgold)
				newcreds=maxgold;
			War3_SetGold(playerlist[x],newcreds);
			PrintToConsole(client,"%T","[War3Source] You just removed {amount} gold from player {player}",client,gold,name);
			War3_ChatMessage(playerlist[x],"%T","Admin {player} removed {amount} gold from you",playerlist[x],adminname,gold);
		
		}
		if(results==0)
			PrintToConsole(client,"%T","[War3Source] No players matched your query",client);
	}
	return Plugin_Handled;
}

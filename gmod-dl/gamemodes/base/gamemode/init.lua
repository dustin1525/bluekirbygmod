
include( 'shared.lua' )
include( 'player.lua' )
include( 'npc.lua' )
--I'm a n00b so I is cewter with no skillz.
WarmUpTime = CreateConVar( "bw_warmup_time", "30", {SERVER_CAN_EXECUTE} )
WarmUpTimeA = WarmUpTime:GetInt()

/*---------------------------------------------------------
   Name: gamemode:Initialize( )
   Desc: Called immediately after starting the gamemode 
---------------------------------------------------------*/
function GM:Initialize( )
	--LOLOLOLOL
	//timer.Create( "WarmUpTimer", 1, WarmUpTime:GetInt(), function() WarmUpTimeA = WarmUpTimeA - 1 print(WarmUpTimeA) end)
end

/*---------------------------------------------------------
   Name: gamemode:InitPostEntity( )
   Desc: Called as soon as all map entities have been spawned
---------------------------------------------------------*/
function GM:InitPostEntity( )	
end


/*---------------------------------------------------------
   Name: gamemode:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
function GM:Think( )
end


/*---------------------------------------------------------
   Name: gamemode:ShutDown( )
   Desc: Called when the Lua system is about to shut down
---------------------------------------------------------*/
function GM:ShutDown( )
end

/*---------------------------------------------------------
   Name: gamemode:DoPlayerDeath( )
   Desc: Carries out actions when the player dies 		 
---------------------------------------------------------*/
function GM:DoPlayerDeath( ply, attacker, dmginfo )

	ply:CreateRagdoll()
	
	ply:AddDeaths( 1 )
	
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
	
		if ( attacker == ply ) then
			attacker:AddFrags( -1 )
		else
			attacker:AddFrags( 1 )
		end
		
	end
	
end


/*---------------------------------------------------------
   Name: gamemode:EntityTakeDamage( entity, inflictor, attacker, amount, dmginfo )
   Desc: The entity has received damage	 
---------------------------------------------------------*/
function GM:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )
	if ent:IsPlayer() then
		amount = 0
	end
end


/*---------------------------------------------------------
   Name: gamemode:CreateEntityRagdoll( entity, ragdoll )
   Desc: A ragdoll of an entity has been created
---------------------------------------------------------*/
function GM:CreateEntityRagdoll( entity, ragdoll )
end


// Set the ServerName every 30 seconds in case it changes..
// This is for backwards compatibility only - client can now use GetHostName()
local function HostnameThink()

	SetGlobalString( "ServerName", GetHostName() )

end

timer.Create( "HostnameThink", 30, 0, HostnameThink )

/*---------------------------------------------------------
	Show the default team selection screen
---------------------------------------------------------*/
function GM:ShowTeam( ply )

	if (!GAMEMODE.TeamBased) then return end
	
	local TimeBetweenSwitches = GAMEMODE.SecondsBetweenTeamSwitches or 10
	if ( ply.LastTeamSwitch && RealTime()-ply.LastTeamSwitch < TimeBetweenSwitches ) then
		ply.LastTeamSwitch = ply.LastTeamSwitch + 1;
		ply:ChatPrint( Format( "Please wait %i more seconds before trying to change team again", (TimeBetweenSwitches - (RealTime()-ply.LastTeamSwitch)) + 1 ) )
		return false
	end
	
	// For clientside see cl_pickteam.lua
	ply:SendLua( "GAMEMODE:ShowTeam()" )

end

/*---------------------------------------------------------
	
---------------------------------------------------------*/
function GM:CanToyboxSaveMap( ply )

	// No saving unless we're in sandbox!

	return false

end


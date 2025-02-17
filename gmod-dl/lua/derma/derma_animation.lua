/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

*/

local DermaAnimation = {}
DermaAnimation.__index = DermaAnimation

function DermaAnimation:Run()

	if ( !self.Running ) then return end
	
	local CurTime = SysTime()
	local delta = (CurTime - self.StartTime) / self.Length
	
	// If we have ended we run once more with the Finished member set
	// This allows us to clean up in the same function..
	if ( CurTime > self.EndTime ) then
	
		self.Finished = true
		self.Running = nil
		delta = 1
	
	end
		
	self.Func( self.Panel, self, delta, self.Data )
	self.Started = nil

end


function DermaAnimation:Start( Length, Data )

	if ( self.Length == 0 ) then return end

	self.Running = true
	self.Started = true
	self.Finished = nil
	self.Length = Length
	self.StartTime = SysTime()
	self.EndTime = SysTime() + Length
	
	self.Data = Data

end

function DermaAnimation:Stop()

	if ( !self.Running ) then return end
	
	self.Finished = true
	self.Running = nil
	delta = 1

end

function DermaAnimation:Active()

	return self.Running

end

function Derma_Anim( name, panel, func )

	local anim = {}
	anim.Name = name
	anim.Panel = panel
	anim.Func = func
	
	setmetatable( anim, DermaAnimation )
	
	return anim

end

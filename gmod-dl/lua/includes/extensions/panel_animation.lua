//
//  ___  ___   _   _   _    __   _   ___ ___ __ __
// |_ _|| __| / \ | \_/ |  / _| / \ | o \ o \\ V /
//  | | | _| | o || \_/ | ( |_n| o ||   /   / \ / 
//  |_| |___||_n_||_| |_|  \__/|_n_||_|\\_|\\ |_|  2007
//										 
//


local meta = FindMetaTable( "Panel" )
if (!meta) then return end

/*---------------------------------------------------------
   Name:	SetTerm
   Desc:	Kill the panel at this time
---------------------------------------------------------*/  
function meta:SetTerm( term )

	self.Term = SysTime() + term
	self:SetAnimationEnabled( true )

end

/*---------------------------------------------------------
   Name:	AnimationThinkInternal
   Desc:	anim
---------------------------------------------------------*/  
function meta:AnimationThinkInternal()

	if ( self.Term && self.Term <= SysTime() ) then self:Remove() return end
	if ( !self.m_AnimList ) then return end // This can happen if we only have term

	for k, anim in pairs( self.m_AnimList ) do
	
		if ( SysTime() >= anim.StartTime ) then
		
			local Fraction = math.TimeFraction( anim.StartTime, anim.EndTime, SysTime() )
			Fraction = math.Clamp( Fraction, 0, 1 )
			
			if ( anim.Think ) then
				anim:Think( self, Fraction ^ anim.Ease )
			end
			
			if ( Fraction == 1 ) then
				self.m_AnimList[k] = nil				
			end
			
		end

	end
	
end

/*---------------------------------------------------------
   Name:	SetAnimationEnabled
   Desc:	anim
---------------------------------------------------------*/  
function meta:SetAnimationEnabled( b )

	if (!b) then
		self.AnimationThink = nil
		return
	end
	
	if ( self.AnimationThink ) then return end
	
	self.AnimationThink = self.AnimationThinkInternal

end

/*---------------------------------------------------------
   Name:	NewAnimation
   Desc:	anim
---------------------------------------------------------*/  
function meta:NewAnimation( length, delay, ease )

	if ( delay == nil ) then delay = 0 end
	if ( ease == nil ) then ease = 1 end
	
	local anim = { EndTime = SysTime() + delay + length, 
					StartTime = SysTime() + delay,
					Ease = ease }
					
	self:SetAnimationEnabled( true )
	if (self.m_AnimList == nil) then self.m_AnimList = {} end
	
	table.insert( self.m_AnimList, anim )
	
	return anim

end

local function MoveThink( anim, panel, fraction )

	if ( !anim.StartPos ) then anim.StartPos = Vector( panel.x, panel.y, 0 ) end
	local pos = LerpVector( fraction, anim.StartPos, anim.Pos )
	panel:SetPos( pos.x, pos.y )
	
end

/*---------------------------------------------------------
   Name:	MoveTo
---------------------------------------------------------*/  
function meta:MoveTo( x, y, length, delay, ease )

	local anim = self:NewAnimation( length, delay, ease )
	anim.Pos = Vector( x, y, 0 )
	anim.Think = MoveThink

end

local function SizeThink( anim, panel, fraction )

	if ( !anim.StartSize ) then local w, h = panel:GetSize() anim.StartSize = Vector( w, h, 0 ) end
	local size = LerpVector( fraction, anim.StartSize, anim.Size )
	panel:SetSize( size.x, size.y )
	
end

/*---------------------------------------------------------
   Name:	SizeTo
---------------------------------------------------------*/  
function meta:SizeTo( w, h, length, delay, ease )

	local anim = self:NewAnimation( length, delay, ease )
	anim.Size = Vector( w, h, 0 )
	anim.Think = SizeThink

end

local function ColorThink( anim, panel, fraction )

	if ( !anim.StartColor ) then anim.StartColor = panel:GetColor() end
	
	panel:SetColor( Color( Lerp( fraction, anim.StartColor.r, anim.Color.r ),
					Lerp( fraction, anim.StartColor.g, anim.Color.g ),
					Lerp( fraction, anim.StartColor.b, anim.Color.b ),
					Lerp( fraction, anim.StartColor.a, anim.Color.a ) ) )
	
end

/*---------------------------------------------------------
   Name:	ColorTo
---------------------------------------------------------*/  
function meta:ColorTo( col, length, delay )

	// We can only use this on specific panel types!
	if ( !self.SetColor ) then return end
	if ( !self.GetColor ) then return end

	local anim = self:NewAnimation( length, delay )
	anim.Color = col
	anim.Think = ColorThink

end

local function AlphaThink( anim, panel, fraction )

	if ( !anim.StartAlpha ) then anim.StartAlpha = panel:GetAlpha() end
	
	panel:SetAlpha( Lerp( fraction, anim.StartAlpha, anim.Alpha ) )
	
end

/*---------------------------------------------------------
   Name:	AlphaTo
---------------------------------------------------------*/  
function meta:AlphaTo( alpha, length, delay )

	local anim = self:NewAnimation( length, delay )
	anim.Alpha = alpha
	anim.Think = AlphaThink

end


local function MoveByThink( anim, panel, fraction )

	if ( !anim.StartPos ) then 
		anim.StartPos = Vector( panel.x, panel.y, 0 ) 
		anim.Pos = anim.StartPos + anim.Pos
	end
	
	local pos = LerpVector( fraction, anim.StartPos, anim.Pos )
	panel:SetPos( pos.x, pos.y )
	
end

/*---------------------------------------------------------
   Name:	MoveBy
---------------------------------------------------------*/  
function meta:MoveBy( x, y, length, delay, ease )

	local anim = self:NewAnimation( length, delay, ease )
	anim.Pos = Vector( x, y, 0 )
	anim.Think = MoveByThink

end


local function LerpPositions( anim, panel )

	if ( !panel.TargetPos ) then return end
	
	local Speed = FrameTime() * 100 * anim.Speed
	local Pos = Vector( panel.x, panel.y, 0 )
	local Distance = panel.TargetPos - Pos
	local Length = Distance:Length()
	
	if ( anim.UseGravity && Length > 1 ) then
		Speed = Speed * (Length * 0.1)
	end
		
	if ( Length < Speed ) then
		panel:SetPosReal( panel.TargetPos.x, panel.TargetPos.y )
		panel.TargetPos = nil
		return
	end
	
	Distance:Normalize()
	Distance = Pos + (Distance * Speed)
	
	panel:SetPosReal( Distance.x, Distance.y )
	
end

local function NewSetPos( self, x, y )

	self.TargetPos = Vector( x, y )

end

/*---------------------------------------------------------
   Name:	LerpPositions
---------------------------------------------------------*/  
function meta:LerpPositions( speed, usegravity )

	if ( self.SetPosReal ) then return end
	
	self.SetPosReal = self.SetPos
	self.SetPos = NewSetPos

	self.LerpAnim = self:NewAnimation( 60 * 60 * 24 )
	self.LerpAnim.Speed = speed
	self.LerpAnim.UseGravity = usegravity
	self.LerpAnim.Think = LerpPositions

end

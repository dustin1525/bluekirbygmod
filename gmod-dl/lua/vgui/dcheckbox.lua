/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DNumberWang

*/

local PANEL = {}

AccessorFunc( PANEL, "m_bChecked", 		"Checked", 		FORCE_BOOL )

Derma_Hook( PANEL, "Paint", "Paint", "CheckBox" )
Derma_Hook( PANEL, "ApplySchemeSettings", "Scheme", "CheckBox" )
Derma_Hook( PANEL, "PerformLayout", "Layout", "CheckBox" )

Derma_Install_Convar_Functions( PANEL )

/*---------------------------------------------------------
	
---------------------------------------------------------*/
function PANEL:Init()

	self:SetType( "none" )
	
	self:SetSize( 13, 13 )

end


/*---------------------------------------------------------
   Name: SetValue
---------------------------------------------------------*/
function PANEL:SetValue( val )

	val = tobool( val )

	self:SetChecked( val )
	
	if ( !val ) then self:SetType( "none" ) else self:SetType( "tick" ) end

	self.m_bValue = val
	
	self:OnChange( val )
	
	if ( val ) then val = "1" else val = "0" end	
	self:ConVarChanged( val )
	

end

/*---------------------------------------------------------
   Name: DoClick
---------------------------------------------------------*/
function PANEL:DoClick()

	self:Toggle()

end

/*---------------------------------------------------------
   Name: Toggle
---------------------------------------------------------*/
function PANEL:Toggle()

	if ( self:GetChecked() == nil || !self:GetChecked() ) then
		self:SetValue( true )
	else
		self:SetValue( false )
	end

end

/*---------------------------------------------------------
   Name: OnChange
---------------------------------------------------------*/
function PANEL:OnChange( bVal )

	// For override

end

/*---------------------------------------------------------
	Think
---------------------------------------------------------*/
function PANEL:Think()

	self:ConVarStringThink()

end

derma.DefineControl( "DCheckBox", "Simple Checkbox", PANEL, "DSysButton" )


local PANEL = {}
AccessorFunc( PANEL, "m_iIndent", 		"Indent" )

/*---------------------------------------------------------
	
---------------------------------------------------------*/
function PANEL:Init()

	self:SetTall( 16 )
	self.Button = vgui.Create( "DCheckBox", self )
	
	function self.Button.OnChange( _, val ) self:OnChange( val ) end

end

/*---------------------------------------------------------
   Name: SetConVar
---------------------------------------------------------*/
function PANEL:SetConVar( cvar )
	self.Button:SetConVar( cvar )
end

/*---------------------------------------------------------
   Name: SetValue
---------------------------------------------------------*/
function PANEL:SetValue( val )
	self.Button:SetValue( val )
end

/*---------------------------------------------------------
   Name: SetChecked
---------------------------------------------------------*/
function PANEL:SetChecked( val )
	self.Button:SetChecked( val )
end

/*---------------------------------------------------------
   Name: GetChecked
---------------------------------------------------------*/
function PANEL:GetChecked( val )
	return self.Button:GetChecked()
end

/*---------------------------------------------------------
   Name: SetValue
---------------------------------------------------------*/
function PANEL:Toggle()
	self.Button:Toggle()
end


/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	local x = self.m_iIndent or 0

	self.Button:SetSize( 14, 14 )
	self.Button:SetPos( x, 0 )
	
	if ( self.Label ) then
		self.Label:SizeToContents()
		self.Label:SetPos( x + 14 + 10, 0 )
	end

end

/*---------------------------------------------------------
   Name: SetTextColor
---------------------------------------------------------*/
function PANEL:SetTextColor( color )

	self.Label:SetTextColor( color )

end


/*---------------------------------------------------------
	SizeToContents
---------------------------------------------------------*/
function PANEL:SizeToContents()
	self:PerformLayout( true )
	self:SetWide( self.Label.x + self.Label:GetWide() )
	self:SetTall( self.Button:GetTall() )
end

/*---------------------------------------------------------
   Name: SetConVar
---------------------------------------------------------*/
function PANEL:SetText( text )

	if ( !self.Label ) then
		self.Label = vgui.Create( "DLabel", self )
		self.Label:SetMouseInputEnabled( true )
		self.Label.OnMouseReleased = function() self:Toggle() end
	end
	
	self.Label:SetText( text )
	self:InvalidateLayout()

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()
end

/*---------------------------------------------------------
   Name: OnChange
---------------------------------------------------------*/
function PANEL:OnChange( bVal )

	// For override

end

/*---------------------------------------------------------
   Name: GenerateExample
---------------------------------------------------------*/
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
		ctrl:SetText( "CheckBox" )
		ctrl:SetWide( 200 )
	
	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "DCheckBoxLabel", "Simple Checkbox", PANEL, "DPanel" )
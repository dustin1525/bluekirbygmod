/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DMenu

*/

PANEL = {}

AccessorFunc( PANEL, "m_bBorder", 			"DrawBorder" )
AccessorFunc( PANEL, "m_bBackground", 		"DrawBackground" )
AccessorFunc( PANEL, "m_bDeleteSelf", 		"DeleteSelf" )
AccessorFunc( PANEL, "m_iMinimumWidth", 	"MinimumWidth" )
AccessorFunc( PANEL, "m_iMaxHeight", 		"MaxHeight" )

AccessorFunc( PANEL, "m_pOpenSubMenu", 		"OpenSubMenu" )


/*---------------------------------------------------------
	Init
---------------------------------------------------------*/
function PANEL:Init()

	self:SetDrawBorder( true )
	self:SetDrawBackground( true )
	self:SetMinimumWidth( 100 )
	self:SetDrawOnTop( true )
	self:SetMaxHeight( ScrH() * 0.9 )
		
	self:EnableVerticalScrollbar()
	self:SetPadding( 1 )
	
	// Automatically remove this panel when menus are to be closed
	RegisterDermaMenuForClose( self )
	
	self.animOpen = Derma_Anim( "Open", self, self.OpenAnim )

end

/*---------------------------------------------------------
	OpenAnim
---------------------------------------------------------*/
function PANEL:OpenAnim( anim, delta, data )

	if ( anim.Finished ) then
	
		self:SetSize( data.Width, data.Height )
		self:SetAlpha( 255 )
	
	return end

	//delta = delta ^ 0.85
	//self:SetSize( data.Width, data.Height * delta )
	self:SetAlpha( delta * 255 )

end

/*---------------------------------------------------------
	OpenAnim
---------------------------------------------------------*/
function PANEL:Think()

	self.animOpen:Run()

end

/*---------------------------------------------------------
	AddPanel
---------------------------------------------------------*/
function PANEL:AddPanel( pnl )

	self:AddItem( pnl )
	pnl.ParentMenu = self
	
end

/*---------------------------------------------------------
	AddOption
---------------------------------------------------------*/
function PANEL:AddOption( strText, funcFunction )

	local pnl = vgui.Create( "DMenuOption", self )
	pnl:SetText( strText )
	if ( funcFunction ) then pnl.DoClick = funcFunction end
	
	self:AddPanel( pnl )
	
	return true

end

/*---------------------------------------------------------
	AddSpacer
---------------------------------------------------------*/
function PANEL:AddSpacer( strText, funcFunction )

	local pnl = vgui.Create( "DBevel", self )
	pnl:SetTall( 2 )
	pnl:SetAlpha( 100 )
	
	self:AddPanel( pnl )
	
	return true

end

/*---------------------------------------------------------
	AddSubMenu
---------------------------------------------------------*/
function PANEL:AddSubMenu( strText, funcFunction )

	local SubMenu = DermaMenu( self )
	SubMenu:SetVisible( false )
	SubMenu:SetParent( self )

	local pnl = vgui.Create( "DMenuOption", self )
	pnl:SetSubMenu( SubMenu )
	pnl:SetText( strText )
	if ( funcFunction ) then pnl.DoClick = funcFunction end
	
	self:AddPanel( pnl )
	
	return SubMenu

end

/*---------------------------------------------------------
	Hide
---------------------------------------------------------*/
function PANEL:Hide()

	local openmenu = self:GetOpenSubMenu()
	if ( openmenu ) then
		openmenu:Hide()
	end
	
	self:SetVisible( false )
	self:SetOpenSubMenu( nil )
	
end

/*---------------------------------------------------------
	OpenSubMenu
---------------------------------------------------------*/
function PANEL:OpenSubMenu( item, menu )

	// Do we already have a menu open?
	local openmenu = self:GetOpenSubMenu()
	if ( openmenu ) then
	
		// Don't open it again!
		if ( menu && openmenu == menu ) then return end
	
		// Close it!
		self:CloseSubMenu( openmenu )
	
	end
	
	if ( !menu ) then return end

	local x, y = item:LocalToScreen( self:GetWide(), 0 )
	menu:Open( x-3, y, false, item )
	
	self:SetOpenSubMenu( menu )

end


/*---------------------------------------------------------
	CloseSubMenu
---------------------------------------------------------*/
function PANEL:CloseSubMenu( menu )

	menu:Hide()
	self:SetOpenSubMenu( nil )

end

/*---------------------------------------------------------
	Paint
---------------------------------------------------------*/
function PANEL:Paint()

	derma.SkinHook( "Paint", "Menu", self )
	return true

end

/*---------------------------------------------------------
	PaintOver
---------------------------------------------------------*/
function PANEL:PaintOver()

	derma.SkinHook( "PaintOver", "Menu", self )
	return true

end

/*---------------------------------------------------------
	PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	if ( self.animOpen.Running ) then return end
	
	local w = self:GetMinimumWidth()
	
	// Find the widest one
	for k, pnl in pairs( self.Items ) do
	
		pnl:PerformLayout()
		w = math.max( w, pnl:GetWide() )
	
	end

	self:SetWide( w )
	
	local y = 0 // for padding
	
	for k, pnl in pairs( self.Items ) do
	
		pnl:SetWide( w )
		pnl:SetPos( 0, y )
		pnl:InvalidateLayout( true )
		
		y = y + pnl:GetTall()
	
	end
	
	y = math.min( y, self:GetMaxHeight() )
	
	self:SetTall( y + 1 ) // 1 here is for padding

	derma.SkinHook( "Layout", "Menu", self )
	
	DScrollPanel.PerformLayout( self )

end


/*---------------------------------------------------------
	Open - Opens the menu. 
	x and y are optional, if they're not provided the menu 
		will appear at the cursor.
---------------------------------------------------------*/
function PANEL:Open( x, y, skipanimation, ownerpanel )

	x = x or gui.MouseX()
	y = y or gui.MouseY()
	
	local OwnerHeight = 0
	local OwnerWidth = 0
	
	if ( ownerpanel ) then
		OwnerWidth, OwnerHeight = ownerpanel:GetSize()
	end
		
	self:PerformLayout()
		
	local w = self:GetWide()
	local h = self:GetTall()
	
	self:SetSize( w, h )
	
	
	if ( y + h > ScrH() ) then y = y - h - OwnerHeight end
	if ( x + w > ScrW() ) then x = x - w end
	if ( y < 1 ) then y = 1 end
	if ( x < 1 ) then x = 1 end
	
	self:SetPos( x, y )
	
	// Popup!
	self:MakePopup()
	
	// Make sure it's visible!
	self:SetVisible( true )
	
	// Keep the mouse active while the menu is visible.
	self:SetKeyboardInputEnabled( false )
	
	// Animate the opening
	if ( !skipanimation ) then
		self.animOpen:Start( 0.2, { Width = w, Height = h } )
	end
	
end

/*---------------------------------------------------------
   Name: GenerateExample
---------------------------------------------------------*/
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local MenuItemSelected = function()
		Derma_Message( "Choosing a menu item worked!" )
	end

	local ctrl = vgui.Create( "Button" )
		ctrl:SetText( "Test Me!" )
		ctrl.DoClick = function() 
						local menu = DermaMenu()
						
							menu:AddOption( "Option One", MenuItemSelected )
							menu:AddOption( "Option 2", MenuItemSelected )
							local submenu = menu:AddSubMenu( "Option Free" )
								submenu:AddOption( "Submenu 1", MenuItemSelected )
								submenu:AddOption( "Submenu 2", MenuItemSelected )
							menu:AddOption( "Option For", MenuItemSelected )
							
						menu:Open()
		
						end
		
	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "DMenu", "A Menu", PANEL, "DScrollPanel" )

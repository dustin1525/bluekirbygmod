//=============================================================================//
//  ___  ___   _   _   _    __   _   ___ ___ __ __
// |_ _|| __| / \ | \_/ |  / _| / \ | o \ o \\ V /
//  | | | _| | o || \_/ | ( |_n| o ||   /   / \ / 
//  |_| |___||_n_||_| |_|  \__/|_n_||_|\\_|\\ |_|  2007
//										 
//=============================================================================//


local PANEL = {}

AccessorFunc( PANEL, "m_pController", 			"Controller" )

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Init()

	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( false )
	
	self.List = vgui.Create( "DListView", self )
	
	self.List:AddColumn( "Map Name" )
	self.List:AddColumn( "Category" )
	
	self.List:SetDataHeight( 17 )
	
	self.List.OnRowSelected = function( list, itemid, line ) self:DoClick( itemid, line ) end
	self.List.DoDoubleClick = function( list, itemid, line ) self:DoDoubleClick( itemid, line ) end
	
	self.List:SetMultiSelect( false )
										
	self:BuildMaps()
	
end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:BuildMaps()

	for k, v in pairs( g_MapList ) do
	
		local item = self.List:AddLine( v.Name, v.Category )
		item.MapName = v.Name
							
	end
	
	self.List:SortByColumn( 1, true )

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Reload()

	self.List:Clear()
	self:BuildMaps()

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:PerformLayout()

	self.List:SetPos( 0, 0 )
	self.List:SetSize( self:GetWide(), self:GetTall() )
	
end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:DoClick( itemid, line )

	self:GetController():SetMap( line.MapName )
	
end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:DoDoubleClick( itemid )

	// No need to set the map, it should be set 
	// by the first click..
	
	self:GetController():LaunchGame()
	
end




vgui.Register( "MapListList", PANEL )
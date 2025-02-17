/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DPanelList
	
	A window.

*/

local PANEL = {}

AccessorFunc( PANEL, "m_pMother", 		"Mother" )
AccessorFunc( PANEL, "m_bSelected", 	"Selected", 		FORCE_BOOL )

Derma_Hook( PANEL, "Paint", "Paint", "ComboBoxItem" )
Derma_Hook( PANEL, "ApplySchemeSettings", "Scheme", "ComboBoxItem" )
Derma_Hook( PANEL, "PerformLayout", "Layout", "ComboBoxItem" )

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self:SetMouseInputEnabled( true )
	self:SetTextInset( 5 )
	self:SetTall( 19 )

end

/*---------------------------------------------------------
   Name: OnCursorMoved
---------------------------------------------------------*/
function PANEL:OnMousePressed( mcode )

	if ( mcode == MOUSE_LEFT ) then
		self:Select( true )
	end

	self:SetTextColor( Color( 0, 0, 0, 255 ) )
end

/*---------------------------------------------------------
   Name: OnCursorMoved
---------------------------------------------------------*/
function PANEL:OnCursorMoved( x, y )

	if ( input.IsMouseDown( MOUSE_LEFT ) ) then
		self:Select( false )
	end

end


/*---------------------------------------------------------
   Name: Select
---------------------------------------------------------*/
function PANEL:Select( bOnlyMe )

	self.m_pMother:SelectItem( self, bOnlyMe )
	
	self:DoClick()

end

/*---------------------------------------------------------
   Name: DoClick
---------------------------------------------------------*/
function PANEL:DoClick()

	// For override

end


derma.DefineControl( "DComboBoxItem", "", PANEL, "DLabel" )


local PANEL = {}

AccessorFunc( PANEL, "m_bSelectMultiple", 		"Multiple", 		FORCE_BOOL )
AccessorFunc( PANEL, "m_pSelected", 			"Selected", 		FORCE_BOOL ) 		// Last selected, not multiple
AccessorFunc( PANEL, "SelectedItems", 			"SelectedItems" ) 	// All selected in a table

Derma_Hook( PANEL, "Paint", "Paint", "ComboBox" )

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self:SetMultiple( true )
	self:EnableHorizontal( false )
	self:EnableVerticalScrollbar( true )
	
	self:SetPadding( 1 )
	
	self.SelectedItems = {}

end

/*---------------------------------------------------------
   Name: Clear
---------------------------------------------------------*/
function PANEL:Clear()

	self.SelectedItems = {}
	DPanelList.Clear( self, true )

end

/*---------------------------------------------------------
   Name: AddItem
---------------------------------------------------------*/
function PANEL:AddItem( strLabel )

	local item = vgui.Create( "DComboBoxItem", self )
	item:SetMother( self )
	item:SetText( strLabel )

	DPanelList.AddItem( self, item )
	
	return item

end

/*---------------------------------------------------------
   Name: Rebuild
---------------------------------------------------------*/
function PANEL:Rebuild()

	local Offset = 0
	
	local x, y = self.Padding, self.Padding;
	for k, panel in pairs( self.Items ) do
	
		local w = panel:GetWide()
		local h = panel:GetTall()
		
		

		panel:SetPos( self.Padding, y )
		panel:SetWide( self:GetCanvas():GetWide() - self.Padding * 2 )
		
		x = x + w + self.Spacing
		
		y = y + h + self.Spacing
		
		Offset = y + h + self.Spacing
	
	end
		
	self:GetCanvas():SetTall( Offset + (self.Padding * 2) - self.Spacing ) 

end

/*---------------------------------------------------------
   Name: SelectItem
---------------------------------------------------------*/
function PANEL:SelectItem( item, onlyme )

	if ( !onlyme && item:GetSelected() ) then return end
	
	// Unselect old items
	if ( onlyme || !self.m_bSelectMultiple ) then
	
		for k, v in pairs( self.SelectedItems ) do
			v:SetSelected( false )
		end
		
		self.SelectedItems = {}
		self.m_pSelected = nil
		
	end
	
	
	self.m_pSelected = item
	item:SetSelected( true )
	table.insert( self.SelectedItems, item )

end

/*---------------------------------------------------------
   Name: SelectByName
---------------------------------------------------------*/
function PANEL:SelectByName( strName )

	for k, panel in pairs( self.Items ) do
	
		if ( panel:GetValue() == strName ) then
			self:SelectItem( panel, true )
		return end
	
	end

end

/*---------------------------------------------------------
   Name: GetSelectedValues
---------------------------------------------------------*/
function PANEL:GetSelectedValues() 
 
    local items = self:GetSelectedItems();  
	
    if ( #items > 1 ) then
	
        local ret = {};  
        for _, v in pairs( items ) do table.insert( ret, v:GetValue() ) end  
        return ret;  
		
    else  
	
        return items[1]:GetValue()  
		
    end  
	
end  

/*---------------------------------------------------------
   Name: GenerateExample
---------------------------------------------------------*/
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
		ctrl:AddItem( "Bread" )
		ctrl:AddItem( "Carrots" )
		ctrl:AddItem( "Toilet Paper" )
		ctrl:AddItem( "Air Freshner" )
		ctrl:AddItem( "Shovel" )
		ctrl:SetSize( 100, 300 )
		
	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "DComboBox", "", PANEL, "DPanelList" )

/*---------------------------------------------------------
   Name: scripted_ents
   Desc: Scripted Entity factory
---------------------------------------------------------*/
module( "scripted_ents", package.seeall )

local SEntList = {}

local BaseClasses = {}
BaseClasses['anim'] 	= 'base_anim'
BaseClasses['point'] 	= 'base_point'
BaseClasses['brush'] 	= 'base_brush'
BaseClasses['vehicle'] 	= 'base_vehicle'

/*---------------------------------------------------------
   Name: TableInherit( t, base )
   Desc: Copies any missing data from base to t
---------------------------------------------------------*/
local function TableInherit( t, base )

	for k, v in pairs( base ) do 
		
		if ( t[k] == nil ) then	
			t[k] = v 
		elseif ( type(t[k]) == "table" ) then
			TableInherit( t[k], v )
		end
		
	end
	
	t["BaseClass"] = base
	
	return t

end


/*---------------------------------------------------------
   Name: Register( table, string, bool )
---------------------------------------------------------*/
function Register( t, name, reload )

	// Don't load it twice unless we're reloading
	if (!reload && SEntList[ name ] != nil ) then
		return
	end
	
	if ( t.Type == nil ) then
		PrintTable( t )
		Msg("Couldn't register Scripted Entity "..name.." - the Type field is empty!\n")
		return
	end
	
	local Base = t.Base
	
	if ( !Base ) then
		Base = BaseClasses[ t.Type ]
	end
	
	SEntList[ name ] = {}
	SEntList[ name ].type 			= t.Type
	SEntList[ name ].t 				= t
	SEntList[ name ].isBaseType 	= true
	SEntList[ name ].Base 			= Base
	
	if (!Base) then
		Msg("WARNING: Scripted entity "..name.." has an invalid base entity!\n" )
	end
	
	t.Classname = name
	t.ClassName = name
	
end

/*---------------------------------------------------------
   Name: Get( string )
---------------------------------------------------------*/
function Get( name )

	if (SEntList[ name ] == nil) then return nil end

	// Create/copy a new table
	local retval = {}
	for k, v in pairs( SEntList[ name ].t ) do 
		retval[k] = v
	end
	
	// Derive from base class
	if ( name != SEntList[ name ].Base ) then
	
		if (!Get( SEntList[ name ].Base )) then
		
			Msg("ERROR: Trying to derive entity "..tostring(name).." from non existant entity "..tostring(SEntList[ name ].Base).."!\n" )
		
		else
	
			retval = TableInherit( retval, Get( SEntList[ name ].Base ) )
		
		end
		
	end

	return retval
end


/*---------------------------------------------------------
   Name: GetType( string )
---------------------------------------------------------*/
function GetType( name )

	if (SEntList[ name ] == nil) then return nil end
	return SEntList[ name ].type
	
end

/*---------------------------------------------------------
   Name: GetStored( string )
   Desc: Gets the REAL sent table, not a copy
---------------------------------------------------------*/
function GetStored( name )
	return SEntList[ name ]
end

/*---------------------------------------------------------
   Name: GetList( string )
   Desc: Get a list of all the registered SENTs
---------------------------------------------------------*/
function GetList()
	local result = {}
	
	for k,v in pairs(SEntList) do
		result[ k ] = v
	end
	
	return result
end

/*---------------------------------------------------------
   Name: GetSpawnable
---------------------------------------------------------*/
function GetSpawnable()

	local result = {}
	
	for k,v in pairs( SEntList ) do
		
		local v = Get( k )
		if ( v && (v.Spawnable || v.AdminSpawnable) ) then
			result[ k ] = v
		end
		
	end
	
	return result
	
end


// Backwards compatibility
tablex = table

/*---------------------------------------------------------
   Name: Inherit( t, base )
   Desc: Copies any missing data from base to t
---------------------------------------------------------*/
function table.Inherit( t, base )

	for k, v in pairs( base ) do 
		if ( t[k] == nil ) then	t[k] = v end
	end
	
	t["BaseClass"] = base
	
	return t

end


/*---------------------------------------------------------
    Name: Copy(t, lookup_table)
    Desc: Taken straight from http://lua-users.org/wiki/PitLibTablestuff
          and modified to the new Lua 5.1 code by me.
          Original function by PeterPrade!
---------------------------------------------------------*/
function table.Copy(t, lookup_table)
	if (t == nil) then return nil end
	
	local copy = {}
	setmetatable(copy, getmetatable(t))
	for i,v in pairs(t) do
		if type(v) ~= "table" then
			copy[i] = v
		else
			lookup_table = lookup_table or {}
			lookup_table[t] = copy
			if lookup_table[v] then
				copy[i] = lookup_table[v] -- we already copied this table. reuse the copy.
			else
				copy[i] = table.Copy(v,lookup_table) -- not yet copied. copy it.
			end
		end
	end
	return copy
end

/*---------------------------------------------------------
    Name: Empty( tab )
    Desc: Empty a table
---------------------------------------------------------*/
function table.Empty( tab )

	for k, v in pairs( tab ) do
		tab[k] = nil
	end

end

/*---------------------------------------------------------
    Name: CopyFromTo( FROM, TO )
    Desc: Make TO exactly the same as FROM - but still the same table.
---------------------------------------------------------*/
function table.CopyFromTo( FROM, TO )

	// Erase values from table TO
	table.Empty( TO )
	
	// Copy values over
	table.Merge( TO, FROM )
	
end


/*---------------------------------------------------------
   Name: xx
   Desc: xx
---------------------------------------------------------*/
function table.Merge(dest, source)

	for k,v in pairs(source) do
	
		if ( type(v) == 'table' && type(dest[k]) == 'table' ) then
			-- don't overwrite one table with another;
			-- instead merge them recurisvely
			table.Merge(dest[k], v)
		else
			dest[k] = v
		end
	end
	
	return dest
	
end


/*---------------------------------------------------------
   Name: xx
   Desc: xx
---------------------------------------------------------*/
function table.HasValue( t, val )
	for k,v in pairs(t) do
		if (v == val ) then return true end
	end
	return false
end

table.InTable = HasValue


/*---------------------------------------------------------
   Name: table.Add( dest, source )
   Desc: Unlike merge this adds the two tables together and discards keys.
---------------------------------------------------------*/
function table.Add( dest, source )

	// At least one of them needs to be a table or this whole thing will fall on its ass
	if (type(source)!='table') then return dest end
	
	if (type(dest)!='table') then dest = {} end

	for k,v in pairs(source) do
		table.insert( dest, v )
	end
	
	return dest
end

/*---------------------------------------------------------
   Name: table.sortdesc( table )
   Desc: Like Lua's default sort, but descending
---------------------------------------------------------*/
function table.sortdesc( Table )

	return table.sort( Table, function(a, b) return a > b end )
end

/*---------------------------------------------------------
   Name: table.SortByKey( table )
   Desc: Returns a table sorted numerically by Key value
---------------------------------------------------------*/

function table.SortByKey( Table, Desc )

	local temp = {}

	for key, _ in pairs(Table) do table.insert(temp, key) end
	if ( Desc ) then
		table.sort(temp, function(a, b) return Table[a] < Table[b] end)
	else
		table.sort(temp, function(a, b) return Table[a] > Table[b] end)
	end

	return temp
end

/*---------------------------------------------------------
   Name: table.Count( table )
   Desc: Returns the number of keys in a table
---------------------------------------------------------*/

function table.Count (t)
  local i = 0
  for k in pairs(t) do i = i + 1 end
  return i
end


/*---------------------------------------------------------
   Name: table.Random( table )
   Desc: Return a random key
---------------------------------------------------------*/

function table.Random (t)
  
  local rk = math.random( 1, table.Count( t ) )
  local i = 1
  for k, v in pairs(t) do 
	if ( i == rk ) then return v end
	i = i + 1 
  end

end


/*----------------------------------------------------------------------
   Name: table.IsSequential( table )
   Desc: Returns true if the tables 
	 keys are sequential
-----------------------------------------------------------------------*/

function table.IsSequential(t)
	local i = 1
	for key, value in pairs (t) do
		if not tonumber(i) or key ~= i then return false end
		i = i + 1
	end
	return true
end


/*---------------------------------------------------------
   Name: table.ToString( table,name,nice )
   Desc: Convert a simple table to a string
		table = the table you want to convert (table)
		name  = the name of the table (string)
		nice  = whether to add line breaks and indents (bool)
---------------------------------------------------------*/

function table.ToString(t,n,nice)
	local 		nl,tab  = "",  ""
	if nice then 	nl,tab = "\n", "\t"	end

	local function MakeTable ( t, nice, indent, done)
		local str = ""
		local done = done or {}
		local indent = indent or 0
		local idt = ""
		if nice then idt = string.rep ("\t", indent) end

		local sequential = table.IsSequential(t)

		for key, value in pairs (t) do

			str = str .. idt .. tab .. tab

			if not sequential then
				if type(key) == "number" or type(key) == "boolean" then 
					key ='['..tostring(key)..']' ..tab..'='
				else
					key = tostring(key) ..tab..'='
				end
			else
				key = ""
			end

			if type (value) == "table" and not done [value] then

				done [value] = true
				str = str .. key .. tab .. '{' .. nl
				.. MakeTable (value, nice, indent + 1, done)
				str = str .. idt .. tab .. tab ..tab .. tab .."},".. nl

			else
				
				if 	type(value) == "string" then 
					value = '"'..tostring(value)..'"'
				elseif  type(value) == "Vector" then
					value = 'Vector('..value.x..','..value.y..','..value.z..')'
				elseif  type(value) == "Angle" then
					value = 'Angle('..value.pitch..','..value.yaw..','..value.roll..')'
				else
					value = tostring(value)
				end
				
				str = str .. key .. tab .. value .. ",".. nl

			end

		end
		return str
	end
	local str = ""
	if n then str = n.. tab .."=" .. tab end
	str = str .."{" .. nl .. MakeTable ( t, nice) .. "}"
	return str
end

/*---------------------------------------------------------
   Name: table.Sanitise( table )
   Desc: Converts a table containing vectors, angles, bools so it can be converted to and from keyvalues
---------------------------------------------------------*/
function table.Sanitise( t, done )

	local done = done or {}
	local tbl = {}

	for k, v in pairs ( t ) do
	
		if ( type( v ) == "table" and !done[ v ] ) then

			done[ v ] = true
			tbl[ k ] = table.Sanitise ( v, done )

		else

			if ( type(v) == "Vector" ) then

				local x, y, z = v.x, v.y, v.z
				if y == 0 then y = nil end
				if z == 0 then z = nil end
				tbl[k] = { __type = "Vector", x = x, y = y, z = z }

			elseif ( type(v) == "Angle" ) then

				local p,y,r = v.pitch, v.yaw, v.roll
				if p == 0 then p = nil end
				if y == 0 then y = nil end
				if r == 0 then r = nil end
				tbl[k] = { __type = "Angle", p = p, y = y, r = r }

			elseif ( type(v) == "boolean" ) then
			
				tbl[k] = { __type = "Bool", tostring( v ) }

			else
			
				tbl[k] = tostring(v)

			end
			
			
		end
		
		
	end
	
	return tbl
	
end


/*---------------------------------------------------------
   Name: table.DeSanitise( table )
   Desc: Converts a Sanitised table back
---------------------------------------------------------*/
function table.DeSanitise( t, done )

	local done = done or {}
	local tbl = {}

	for k, v in pairs ( t ) do
	
		if ( type( v ) == "table" and !done[ v ] ) then
		
			done[ v ] = true

			if ( v.__type ) then
			
				if ( v.__type == "Vector" ) then
				
					tbl[ k ] = Vector( v.x, v.y, v.z )
				
				elseif ( v.__type == "Angle" ) then
				
					tbl[ k ] = Angle( v.p, v.y, v.r )
					
				elseif ( v.__type == "Bool" ) then
					
					tbl[ k ] = ( v[1] == "true" )
					
				end
			
			else
			
				tbl[ k ] = table.DeSanitise( v, done )
				
			end
			
		else
		
			tbl[ k ] = v
			
		end
		
	end
	
	return tbl
	
end

function table.ForceInsert( t, v )

	if ( t == nil ) then t = {} end
	
	table.insert( t, v )
	
	return t
	
end


/*---------------------------------------------------------
   Name: table.SortByMember( table )
   Desc: Sorts table by named member
---------------------------------------------------------*/
function table.SortByMember( Table, MemberName, bAsc )

	local TableMemberSort = function( a, b, MemberName, bReverse ) 
	
		//
		// All this error checking kind of sucks, but really is needed
		//
		if ( type(a) != "table" ) then return !bReverse end
		if ( type(b) != "table" ) then return bReverse end
		if ( !a[MemberName] ) then return !bReverse end
		if ( !b[MemberName] ) then return bReverse end
	
		if ( bReverse ) then
			return a[MemberName] < b[MemberName]
		else
			return a[MemberName] > b[MemberName]
		end
		
	end

	table.sort( Table, function(a, b) return TableMemberSort( a, b, MemberName, bAsc or false ) end )
	
end


/*---------------------------------------------------------
   Name: table.LowerKeyNames( table )
   Desc: Lowercase the keynames of all tables
---------------------------------------------------------*/
function table.LowerKeyNames( Table )

	local OutTable = {}

	for k, v in pairs( Table ) do
	
		// Recurse
		if ( type( v ) == "table" ) then
			v = table.LowerKeyNames( v )
		end
		
		OutTable[ k ] = v
		
		if ( type( k ) == "string" ) then
	
			OutTable[ k ]  = nil
			OutTable[ string.lower( k ) ] = v
		
		end		
	
	end
	
	return OutTable
	
end


/*---------------------------------------------------------
   Name: table.LowerKeyNames( table )
   Desc: Lowercase the keynames of all tables
---------------------------------------------------------*/
function table.CollapseKeyValue( Table )

	local OutTable = {}
	
	for k, v in pairs( Table ) do
	
		local Val = v.Value
	
		if ( type( Val ) == "table" ) then
			Val = table.CollapseKeyValue( Val )
		end
		
		OutTable[ v.Key ] = Val
	
	end
	
	return OutTable

end

/*---------------------------------------------------------
   Name: table.ClearKeys( table, bSaveKey )
   Desc: Clears the keys, converting to a numbered format
---------------------------------------------------------*/
function table.ClearKeys( Table, bSaveKey )

	local OutTable = {}
	
	for k, v in pairs( Table ) do
		if ( bSaveKey ) then
			v.__key = k
		end
		table.insert( OutTable, v )	
	end
	
	return OutTable

end



local function fnPairsSorted( pTable, Index )

	if ( Index == nil ) then
	
		Index = 1
	
	else
	
		for k, v in pairs( pTable.__SortedIndex ) do
			if ( v == Index ) then
				Index = k + 1
				break
			end
		end
		
	end
	
	local Key = pTable.__SortedIndex[ Index ]
	if ( !Key ) then
		pTable.__SortedIndex = nil
		return
	end
	
	Index = Index + 1
	
	return Key, pTable[ Key ]

end

/*---------------------------------------------------------
   A Pairs function

		Sorted by TABLE KEY
		
---------------------------------------------------------*/
function SortedPairs( pTable, Desc )

	pTable = table.Copy( pTable )
	
	local SortedIndex = {}
	for k, v in pairs( pTable ) do
		table.insert( SortedIndex, k )
	end
	
	if ( Desc ) then
		table.sort( SortedIndex, function(a,b) return a>b end )
	else
		table.sort( SortedIndex )
	end
	pTable.__SortedIndex = SortedIndex

	return fnPairsSorted, pTable, nil
	
end

/*---------------------------------------------------------
   A Pairs function

		Sorted by VALUE
		
---------------------------------------------------------*/
function SortedPairsByValue( pTable, Desc )

	pTable = table.ClearKeys( pTable )
	
	if ( Desc ) then
		table.sort( pTable, function(a,b) return a>b end )
	else
		table.sort( pTable )
	end

	return ipairs( pTable )
	
end

/*---------------------------------------------------------
   A Pairs function

		Sorted by Member Value (All table entries must be a table!)
		
---------------------------------------------------------*/
function SortedPairsByMemberValue( pTable, pValueName, Desc )

	Desc = Desc or false
	
	local pSortedTable = table.ClearKeys( pTable, true )
	
	table.SortByMember( pSortedTable, pValueName, !Desc )
	
	local SortedIndex = {}
	for k, v in ipairs( pSortedTable ) do
		table.insert( SortedIndex, v.__key )
	end
	
	pTable.__SortedIndex = SortedIndex

	return fnPairsSorted, pTable, nil
	
end

/*---------------------------------------------------------
   A Pairs function		
---------------------------------------------------------*/
function RandomPairs( pTable, Desc )

	local Count = table.Count( pTable )
	pTable = table.Copy( pTable )
	
	local SortedIndex = {}
	for k, v in pairs( pTable ) do
		table.insert( SortedIndex, { key = k, val = math.random( 1, 1000 ) } )
	end
	
	if ( Desc ) then
		table.sort( SortedIndex, function(a,b) return a.val>b.val end )
	else
		table.sort( SortedIndex, function(a,b) return a.val<b.val end )
	end
	
	for k, v in pairs( SortedIndex ) do
		SortedIndex[ k ] = v.key;
	end
	
	pTable.__SortedIndex = SortedIndex

	return fnPairsSorted, pTable, nil
	
end

/*---------------------------------------------------------
	GetFirstKey
---------------------------------------------------------*/
function table.GetFirstKey( t )

	local k, v = next( t )
	return k
	
end

function table.GetFirstValue( t )

	local k, v = next( t )
	return v
	
end

function table.GetLastKey( t )

	local k, v = next( t, table.Count(t) )
	return k
	
end

function table.GetLastValue( t )

	local k, v = next( t, table.Count(t) )
	return v
	
end

function table.FindNext( tab, val )
	
	local bfound = false
	for k, v in pairs( tab ) do
		if ( bfound ) then return v end
		if ( val == v ) then bfound = true end
	end
	
	return table.GetFirstValue( tab )	
	
end

function table.FindPrev( tab, val )
	
	local last = table.GetLastValue( tab )
	for k, v in pairs( tab ) do
		if ( val == v ) then return last end
		last = v
	end
	
	return last
	
end

function table.GetWinningKey( tab )
	
	local highest = -10000
	local winner = nil
	
	for k, v in pairs( tab ) do
		if ( v > highest ) then 
			winner = k
			highest = v
		end
	end
	
	return winner
	
end

function table.KeyFromValue( tbl, val )
	for key, value in pairs( tbl ) do
		if ( value == val ) then return key end
	end
end

function table.KeysFromValue( tbl, val )
	local res = {}
	for key, value in pairs( tbl ) do
		if ( value == val ) then table.insert( res, key ) end
	end
	return res
end
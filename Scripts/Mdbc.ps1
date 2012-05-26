
<#
.Synopsis
	Connects to a database and adds interactive helpers.

.Description
	Use it only as the example and base for your own interactive helpers. This
	script reflects personal preferences, its features may not be suitable for
	all scenarios and they may change at any time.

	The script imports the Mdbc module, connects to the server and database,
	and installs helper aliases and variables designed for interactive use.

	Global aliases:
		amd - Add-MdbcData
		gmd - Get-MdbcData
		rmd - Remove-MdbcData
		umd - Update-MdbcData
		nmd - New-MdbcData
		nmq - New-MdbcQuery
		nmu - New-MdbcUpdate

	Global variables:
		$Server     - connected server
		$Database   - connected database
		$Collection - connected collection
		$m<name>    - collection <name> (for each collection)
		$<operator> - operator shortcuts for JSON-like expressions

	With a large number of collections their names are not displayed. Command
	Get-Variable m*..* is useful for finding a collection by its name pattern.

.Parameter ConnectionString
		Connection string (see the C# driver manual for details).
		The default is "." which stands for "mongodb://localhost".

.Parameter DatabaseName
		Database name or wildcard pattern. If it is not resolved to an existing
		database name then the script prints all database names and exits. The
		default name is 'test'.

.Parameter CollectionName
		The name of a collection to be connected, that is stored as $Collection.
		The default is 'test', not necessarily existing.
#>

param
(
	[Parameter()]
	$ConnectionString = '.',
	$DatabaseName = 'test',
	$CollectionName = 'test'
)

Import-Module Mdbc

# Aliases
Set-Alias -Scope global -Name amd -Value Add-MdbcData
Set-Alias -Scope global -Name gmd -Value Get-MdbcData
Set-Alias -Scope global -Name rmd -Value Remove-MdbcData
Set-Alias -Scope global -Name umd -Value Update-MdbcData
Set-Alias -Scope global -Name nmd -Value New-MdbcData
Set-Alias -Scope global -Name nmq -Value New-MdbcQuery
Set-Alias -Scope global -Name nmu -Value New-MdbcUpdate

# Query operators
$global:all = '$all'
$global:and = '$and'
$global:elemMatch = '$elemMatch'
$global:exists = '$exists'
$global:gt = '$gt'
$global:gte = '$gte'
$global:in = '$in'
$global:lt = '$lt'
$global:lte = '$lte'
$global:mod = '$mod'
$global:ne = '$ne'
$global:nin = '$nin'
$global:nor = '$nor'
$global:not = '$not'
$global:options = '$options'
$global:or = '$or'
$global:regex = '$regex'
$global:size = '$size'
$global:type = '$type'

# Update operators
$global:addToSet = '$addToSet'
$global:bit = '$bit'
$global:each = '$each'
$global:inc = '$inc'
$global:pop = '$pop'
$global:pull = '$pull'
$global:pullAll = '$pullAll'
$global:push = '$push'
$global:pushAll = '$pushAll'
$global:rename = '$rename'
$global:set = '$set'
$global:unset = '$unset'

# Server variable
Connect-Mdbc $ConnectionString
$global:Server = $Server
Write-Host "Server `$Server $($Server.Settings.Server)"

# Database variable
$name = @($Server.GetDatabaseNames() -like $DatabaseName)
if ($name.Count -ne 1) {
	Write-Host "Server databases: $($Server.GetDatabaseNames())"
	return
}
Write-Host "Database `$Database $name"
$global:Database = $Server.GetDatabase($name)

# Collection variables
$global:Collection = $Database.GetCollection($CollectionName)
$collections = @($Database.GetCollectionNames())
Write-Host "$($collections.Count) collections"
$global:MaximumVariableCount = 32kb
foreach($name in $collections) {
	if (!$name.StartsWith('system.')) {
		if ($collections.Count -lt 50) { Write-Host "Collection `$m$name" }
		New-Variable -Scope global -Name "m$name" -Value $Database.GetCollection($name) -ErrorAction Continue -Force
	}
}

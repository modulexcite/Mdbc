
<#
.Synopsis
	Tests Get-MdbcData -As with ad-hoc strongly typed helpers.
#>

Import-Module Mdbc

# strongly typed helpers
Add-Type @'
using System;
public class TestGetMdbcDataAs1 {
	public int _id;
	public int data;
	public DateTime time;
}
public class TestGetMdbcDataAs2 {
	public int _id;
	public int data;
}
public class TestGetMdbcDataAs3 {
	public object _id;
	public int data;
	public DateTime time;
}
'@

Connect-Mdbc . test test -NewCollection

# add data with custom _id
1..5 | %{@{_id = $_; data = $_ % 2; time = Get-Date}} | Add-MdbcData

# get full data
Get-MdbcData -As ([TestGetMdbcDataAs1]) -First 1

# get subset of fields
Get-MdbcData -Property data -As ([TestGetMdbcDataAs2]) -First 1

$null = $Collection.Drop()

# add data with default _id
1..5 | %{@{data = $_}} | Add-MdbcData

# get data, the extra field `time` is not an issue
Get-MdbcData -As ([TestGetMdbcDataAs3]) -First 1

# get strongly typed data using a cursor
Get-MdbcData -As ([TestGetMdbcDataAs3]) -Cursor -Skip 3

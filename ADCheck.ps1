#import-module activedirectory
get-module ActiveDirectory
Import-Module ActiveDirectory

#clear screen on each run
Cls

# init counters
$NotFound = 0
$Found = 0
$Total = 0
$Error = 0 

# Get a list of users from CSV file 
 $CSVUsers = Import-Csv -Path "C:\Temp\ToolLicenseEval\userlist_input.csv" 
 
# [System.Collections.ArrayList] $CSVNotFound = [PSCustomObject]@()
$CSVNotFound = New-Object System.Collections.ArrayList
$CSVFound = New-Object System.Collections.ArrayList

Write-Output "Checking if user exists"


foreach($WWID in $CSVUsers){
	Try
	{
	    # Count total # of records.   Use for progress reporting after moved to collecting 
		# the results instead of  just output to screen
	    $Total++
		if ( -Not ($Total % 500)) {Write-Host "$Total Records Processed" -BackgroundColor "Green" -ForegroundColor "Black"}
		$User = Get-ADUser $WWID.wwid
	   # user account exists
	   # Collect not found exception records
	    [void]$CSVFound.Add($WWID)
 		$Found++
		
	}
	Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
	{
		# Collect not found exception records
	    [void]$CSVNotFound.Add($WWID) 
	   $NotFound++
	}
	Catch
	{
	   # All other errors: e.g. Domain controller not found, domain unreachable, authentication failure etc 
	   Write-Host "AD Error: Domain controller not found, domain unreachable, authentication failure or another error occurred"
	   write-Host "$WWID.wwid - causing Error" 
	   $Error++
		if ( $Error >  10) {Exit}
	} 
}
# Report the totals 
 Write-host "$Found users found"
 Write-host "$NotFound users Not found"
 Write-host "$Total rows in input file" 
 
#save the collections to new CSV files. 
  $CSVNotFound | Export-Csv -Path "C:\Temp\ToolLicenseEval\NoUserlist.csv"  -NoTypeInformation
  $CSVFound | Export-Csv -Path "C:\Temp\ToolLicenseEval\FoundUserlist.csv"  -NoTypeInformation 
 # Doesn't work:    Format-Table $CSVNotFound 

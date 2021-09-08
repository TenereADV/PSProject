﻿#Script that allows the user to install windows features on a remote machine#

#Import-Module ActiveDirectory

Function Install-Menu
{
    Param (
    )
    Write-Host ""
    Write-Host "1: Domain Services (AD DS)"
    Write-Host "2: Federation Services (AD FS)"
    Write-Host "3: Certificate Services (AD CS)"
    Write-Host "4: Dynamic Host Control Protocol (DHCP)"
    Write-Host "5: Domain Name System (DNS)"
    Write-Host "6: Web Server (IIS)"
    Write-Host "7: All of the above"
    Write-Host ""    
    Write-Host "0: Finished. Reboot machine"
    Write-Host "Q: Exits the installation"
    }

<#This is the first time I am using nested Do-While loops.  The top one that checks if the server is valid took me some time 
to figure out the syntax.  I was trying to use only Ifs and ElseIfs, but then remembered that since $allcomp has multiple
objects in the array, I needed to use a ForEach loop to check each one.  Once I was able to match the user's input with the
valid computers in the domain, i updated the While statement to exit the loop.#>

<#Asks the user to enter a machine name and checks if it is on the domain.  If it is, it checks if it is running a version of
Windows Server #>
Do{
    Do{
    write-host ""
    $server = Read-Host "Which server would you like to setup? Type 'help' for a list of all machines. Type 'quit' to exit the script.";""
    If($server -eq 'help'){
        get-adcomputer -filter * -properties Name | Select-Object -expandproperty Name | write-host -ForegroundColor yellow
        } 
    If($server -eq "quit"){
       return}

    $allcomp = get-adcomputer -filter * | select name
        ForEach ($a in $allcomp){
        If($a.name -eq $server){
        break}
        }
               
    }While($a.name -ne $server)

    $testcomp = Invoke-Command {Get-WmiObject Win32_OperatingSystem -ComputerName $server| select caption}
    
    If($testcomp.caption -notlike "*server*"){
        $t = $testcomp.caption
        write-host "";"You can only use this script on Windows Server operating systems. You have chosen a machine running $t.";""}
    
  }While($testcomp.caption -notlike "*server*")
  
#Asks the user what they want to install and installs it on the server selected above. 
#Repeats until the user quits or finishes.

################### CREATE A WAY THAT LETS THE USER KNOW WHAT HAS BEEN INSTALLED. STRIKETHROUGH? ###########################

Do{

Do{
Install-Menu
$repeat = $false 
        Write-Host ""   
    $Selection = Read-Host "What would you like to install?"
        Write-Host ""

    switch ($Selection)
    {
        '1'{'Installing AD DS.'}
        '2'{'Installing AD FS.'}
        '3'{'Installing AD CS.'}
        '4'{'Installing DHCP.'}
        '5'{'Installing DNS.'}
        '6'{'Installing IIS.'}
        '7'{'Installing all features. (This may take a few momemnts)'}
        '0'{'Rebooting machine.'}
        'Q'{'User quit the installation.'}
        
        Default {"Please enter a valid selection";$repeat = $true}
    }
}While ($repeat -eq $true)


If($Selection -eq "1"){
    Invoke-Command {Install-WindowsFeature -name ad-domain-services -IncludeManagementTools -ComputerName $server -whatif}
    #$chosen = "INSTALLED" -ForegroundColor yellow
}ElseIf($Selection -eq "2"){
    Invoke-Command {Install-WindowsFeature -name adfs-Federation -IncludeManagementTools -ComputerName $server -WhatIf}
}ElseIf($Selection -eq "3"){
    Invoke-Command {Install-WindowsFeature -name ad-certificate -IncludeManagementTools -ComputerName $server -WhatIf} 
    $chosen = 6>$null
}ElseIf($Selection -eq "4"){
    Invoke-Command {Install-WindowsFeature -name dhcp -IncludeManagementTools -ComputerName $server -WhatIf} 
}ElseIf($Selection -eq "5"){
    Invoke-Command {Install-WindowsFeature -name dns -IncludeManagementTools -ComputerName $server -WhatIf} 
}ElseIf($Selection -eq "6"){
    Invoke-Command {Install-WindowsFeature -name web-server -IncludeManagementTools -ComputerName $server -WhatIf} 
}ElseIf($Selection -eq "7"){
    Invoke-Command {Install-WindowsFeature -name ad-domain-services,adfs-Federation,ad-certificate,dhcp,dns,web-server -IncludeManagementTools -ComputerName $server -WhatIf} 
}ElseIf($Selection -eq "0"){
    Invoke-Command {Restart-Computer -ComputerName $server -WhatIf}
}ElseIf($Selection -eq "q"){return}

}While ($selection -ne "0" -and $selection -ne "q")

Clear-Variable chosen







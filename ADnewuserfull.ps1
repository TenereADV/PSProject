##Prompts the user for the new employee's information to populate AD fields.##

Do{
$version = Read-Host "Would you like to create a simple or detailed account?"

If($version -eq "simple"){
$repeat2 = $false
#Function used to allow assignment of a department.
Function Dept-Menu
{
    Param (
    )
    Write-Host ""
    Write-Host "1: Development"
    Write-Host "2: IT"
    Write-Host "3: Managers"
    Write-Host "4: Research"
    Write-Host "5: Sales"
}

$First = Read-Host "Enter the employee's first name"
$Last = Read-Host "Enter the employees's last name"
$Name = $First + " " + $Last
$Dname = $Name
$SamName = $First

#Switch used to assign a department. 
Do{
Dept-Menu
$repeat = $false 
    $Selection = Read-Host "Choose the employee's department"
        Write-Host ""

    switch ($Selection)
    {
        '1'{'Employee will be assigned to the Development department.'}
        '2'{'Employee will be assigned to the IT department.'}
        '3'{'Employee will be assigned to the Managers department.'}
        '4'{'Employee will be assigned to the Research department.'}
        '5'{'Employee will be assigned to the Sales department.'}
        Default {"Please enter a valid selection";$repeat = $true}
    }
}
While ($repeat -eq $true)

#If statement to change the user's selection to a department
If($Selection -eq "1"){
    $Dept = "Development"}
Elseif ($selection -eq "2"){
    $Dept = "IT"}
Elseif ($selection -eq "3"){
    $Dept = "Managers"}
Elseif ($selection -eq "4"){
    $Dept = "Research"}
Elseif ($selection -eq "5"){
    $Dept = "Sales"}

#Assigns department to the employee's path
$Path = "ou=$Dept,dc=adatum,dc=com"

#Inserts blank line for formatting.
Write-Host ""

#Asks user to enable account. Checks for invalid choice.
Do{ 
$Enabled = Read-Host "Would you like to enable this account now?"
If($Enabled -eq "y" -or $enabled -eq "yes"){
    $Enabled = 1}
ElseIf($Enabled -eq "n" -or $Enabled -eq "no"){
    $Enabled = 0}
Else{
    Write-Host "Please enter a valid selection."}
} Until ($enabled -eq 0 -or $enabled -eq 1)

#Converts temp password to secure
$PW = ConvertTo-SecureString "Pa55w.rd" -AsPlainText -Force

#Creates the new ADUser
new-aduser -GivenName $First -Surname $Last -name $name -DisplayName $Dname -SamAccountName $SamName -Path $Path -Department $Dept -Enabled $Enabled -AccountPassword $PW -ChangePasswordAtLogon $true

Write-Host "";"Temporary password is 'Pa55w.rd'.  The employee will be forced to change it upon first login."


Get-ADUser -Identity $SamName -Properties department

#End of simple/detailed If statement. 
######### Start of detailed ADUser details #########

}ElseIf($version -eq 'detailed'){

$attributes = @{
    
}

$First = Read-Host "Enter the employee's first name"
$Last = Read-Host "Enter the employees's last name"
$Name = $First + " " + $Last
$Dname = $Name
$SamName = $First

#Switch used to assign a department. 
Do{
Dept-Menu
$repeat = $false 
    $Selection = Read-Host "Choose the employee's department"
        Write-Host ""

    switch ($Selection)
    {
        '1'{'Employee will be assigned to the Development department.'}
        '2'{'Employee will be assigned to the IT department.'}
        '3'{'Employee will be assigned to the Managers department.'}
        '4'{'Employee will be assigned to the Research department.'}
        '5'{'Employee will be assigned to the Sales department.'}
        Default {"Please enter a valid selection";$repeat = $true}
    }
}
While ($repeat -eq $true)

#If statement to change the user's selection to a department
If($Selection -eq "1"){
    $Dept = "Development"}
Elseif ($selection -eq "2"){
    $Dept = "IT"}
Elseif ($selection -eq "3"){
    $Dept = "Managers"}
Elseif ($selection -eq "4"){
    $Dept = "Research"}
Elseif ($selection -eq "5"){
    $Dept = "Sales"}

#Assigns department to the employee's path
$Path = "ou=$Dept,dc=adatum,dc=com"

#Inserts blank line for formatting.
Write-Host ""

#Asks user to enable account. Checks for invalid choice.
Do{ 
$Enabled = Read-Host "Would you like to enable this account now?"
If($Enabled -eq "y" -or $enabled -eq "yes"){
    $Enabled = 1}
ElseIf($Enabled -eq "n" -or $Enabled -eq "no"){
    $Enabled = 0}
Else{
    Write-Host "Please enter a valid selection."}
} Until ($enabled -eq 0 -or $enabled -eq 1)

#Converts temp password to secure
$PW = ConvertTo-SecureString "Pa55w.rd" -AsPlainText -Force

#Creates the new ADUser
new-aduser -GivenName $First -Surname $Last -name $name -DisplayName $Dname -SamAccountName $SamName -Path $Path -Department $Dept -Enabled $Enabled -AccountPassword $PW -ChangePasswordAtLogon $true

Write-Host "";"Temporary password is 'Pa55w.rd'.  The employee will be forced to change it upon first login."

$repeat2 = $false

Get-ADUser -Identity $SamName -Properties department,enabled






#Invalid selection from the simple/detailed input
}Else{
    Write-Host "Please enter a valid selection.";
    $repeat2 = $true
    }
#End of Do statement from beginning
 }While ($repeat2 -eq $true)

#Remove-ADUser -Identity test




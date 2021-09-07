#Prompts the user for the new user's information to populate AD fields.

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


$First = Read-Host "Enter the employees's first name"
$Last = Read-Host "Enter the employees's last name"
$Name = $First + " " + $Last
$Dname = $Name
$SamName = $First
$PW = Read-Host -AsSecureString "Enter a temporary password. User will change it on their first login"

#Switch used to assign a department
Dept-Menu
    $Selection = Read-Host "Choose the employee's department"
        Write-Host ""

    switch ($Selection)
    {
        '1'{'Employee will be assigned to the Development department.'}
        '2'{'Employee will be assigned to the IT department.'}
        '3'{'Employee will be assigned to the Managers department.'}
        '4'{'Employee will be assigned to the Research department.'}
        '5'{'Employee will be assigned to the Sales department.'}
    }

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

$Path = "ou=$Dept,dc=adatum,dc=com"

new-aduser -GivenName $First -Surname $Last -name $name -DisplayName $Dname -SamAccountName $SamName -Path $Path -Department $Dept


get-aduser -filter "name -like '*test*'" -Properties *
#Remove-ADUser -Identity test




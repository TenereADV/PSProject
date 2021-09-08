﻿##Prompts the user for the new employee's information to populate AD fields.##
##Some simple error handling included.  This script assumes the user will try to enter correct data.##

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
################################## Start of detailed ADUser details ###################################

}ElseIf($version -eq 'detailed'){

$newuser = @{}

#Default attributes
$newuser.givenname = Read-Host "Enter the employee's first name"
$newuser.surname = Read-Host "Enter the employees's last name"
$newuser.name = $First + " " + $Last
$newuser.displayname = $Name
$newuser.samaccountname = $First

#Displays a dialog box for the user to select the attributes to add
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'New User Attributes'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Hold CTRL and click which attributes to add:'
$form.Controls.Add($label)
$listBox = New-Object System.Windows.Forms.Listbox
$listBox.Location = New-Object System.Drawing.Point(10,50)
$listBox.Size = New-Object System.Drawing.Size(260,50)

$listBox.SelectionMode = 'MultiExtended'

[void] $listBox.Items.Add('City')
[void] $listBox.Items.Add('Company')
[void] $listBox.Items.Add('Country')
[void] $listBox.Items.Add('Description')
[void] $listBox.Items.Add('Division')
[void] $listBox.Items.Add('Email')
[void] $listBox.Items.Add('Employee ID')
[void] $listBox.Items.Add('Employee Number')
[void] $listBox.Items.Add('Home Phone Number')
[void] $listBox.Items.Add('Initials')
[void] $listBox.Items.Add('Manager')
[void] $listBox.Items.Add('Mobile Phone Number')
[void] $listBox.Items.Add('PO Box')
[void] $listBox.Items.Add('Postal Code')
[void] $listBox.Items.Add('State')
[void] $listBox.Items.Add('Street Address')
[void] $listBox.Items.Add('Title')

$listBox.Height = 70
$form.Controls.Add($listBox)
$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $listBox.SelectedItems
}
        
if($x -contains "city"){
    $newuser.city = Read-Host "Enter employee's city"
}If($x -contains "company"){
    $newuser.company = Read-Host "Enter employee's company"
<#Country requires a two-letter country code to work.  Need to either show user the options or search based on their input.
I'm going to try the search their input method first#>
}If($x -contains "country"){
    $newuser.country = Read-Host "Enter employee's country"
}If($x -contains "description"){
    $newuser.description = Read-Host "Enter a short employee description"
}If($x -contains "division"){
    $newuser.division = Read-Host "Enter employee's division"
}If($x -contains "email"){
    $newuser.emailaddress = Read-Host "Enter employee's email"
}If($x -contains "employee id"){
    $newuser.employeeid = Read-Host "Enter employee's ID"
}If($x -contains "employee number"){
    $newuser.employeenumber = Read-Host "Enter employee number"
}If($x -contains "initials"){
    $newuser.initials = Read-Host "Enter employee's initials"
#Asks the user for the manager's name and checks if it is valid or specific.
<#This script gave me some trouble trying to include error checks. I first realized that if you didn't enter a specific enough 
name, it would populate multiple users in the variable. So i just used an If statement to make sure there was only one object in 
the variable. Incorrect users was straight-forward: it wouldn't put an object in the array, so I had it count the number and if 
it was zero, it means it was an incorrect choice. I was convinced that I needed to use a Do-Until, but it kept
kicking me out of the loop.  I then changed the Until to a While, and it worked like a charm. #>
}If($x -contains "manager"){
    Do{
    $confirm = "n"
    $user = Read-Host "Enter the manager's first and last name"
    $manager = Get-ADUser -Filter "name -like '*$user*'"
    If($manager.Count -gt "1"){
        Write-Host "Please enter a more specific name."}
    elseIf($manager.count -eq "0"){
        Write-Host "Please enter a correct name."}
    Else{
        $mname = $manager.Name
        #Need to add error handling#
        $confirm = Read-Host "You have chosen $mname as the manager.  Is this correct?" 
    }$newuser.manager = $manager
        }while ($confirm -eq "n")
}If($x -contains "mobile"){
    $newuser.mobilephone = Read-Host "Enter employee's mobile phone number"
}If($x -contains "home phone"){
    $newuser.homephone = Read-Host "Enter employee's home phone number"
}If($x -contains "PO Box"){
    $newuser.pobox = Read-Host "Enter employee's PO Box number"
}If($x -contains "postal code"){
    $newuser.postalcode = Read-Host "Enter employee's postal/zip code"
}If($x -contains "state"){
    $newuser.state = Read-Host "Enter employee's state"
}If($x -contains "street address"){
    $newuser.street = Read-Host "Enter employee's street"
}If($x -contains "title"){
    $newuser.title = Read-Host "Enter employee's title"
}

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

#Creates the new ADUser using a hashtable populated by the user's choices
New-ADUser @newuser


Write-Host "";"Temporary password is 'Pa55w.rd'.  The employee will be forced to change it upon first login."

$repeat2 = $false

Get-ADUser -Identity $SamName -Properties *






#Invalid selection from the simple/detailed input
}Else{
    Write-Host "Please enter a valid selection.";
    $repeat2 = $true
    }
#End of Do statement from beginning
 }While ($repeat2 -eq $true)

#Clears the NewUser hashtable for the next use
$newuser.clear()




#Remove-ADUser -Identity test
#get-aduser -filter "givenname -like 'test'" | remove-aduser




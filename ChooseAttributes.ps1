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
        $x
        }


if($x -contains "city"){
    $city = Read-Host "Enter employee's city"
}If($x -contains "company"){
    $phone = Read-Host "Enter employee's company"
}If($x -contains "country"){
    $country = Read-Host "Enter employee's country"
}If($x -contains "description"){
    $descrip = Read-Host "Enter a short employee description"
}If($x -contains "division"){
    $div = Read-Host "Enter employee's division"
}If($x -contains "email"){
    $email = Read-Host "Enter employee's email"
}If($x -contains "employee id"){
    $empid = Read-Host "Enter employee's ID"
}If($x -contains "employee number"){
    $empnum = Read-Host "Enter employee number"
}If($x -contains "initials"){
    $init = Read-Host "Enter employee's initials"
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
        $confirm = Read-Host "You have chosen $mname as the manager.  Is this correct?" 
    }
        }while ($confirm -eq "n")
}If($x -contains "mobile"){
    $mobile = Read-Host "Enter employee's mobile phone number"
}If($x -contains "PO Box"){
    $pobox = Read-Host "Enter employee's PO Box number"
}If($x -contains "postal code"){
    $postal = Read-Host "Enter employee's postal/zip code"
}If($x -contains "state"){
    $state = Read-Host "Enter employee's state"
}If($x -contains "street address"){
    $street = Read-Host "Enter employee's street"
}If($x -contains "title"){
    $title = Read-Host "Enter employee's title"
}

<#Now I need to figure out how to select only the variable/arrays that were chosen by the user and add them to the
New-Aduser command #>    




<#
remove-Variable -Name  'city'
remove-Variable -Name  'country'
remove-Variable -Name  'city country'
#>
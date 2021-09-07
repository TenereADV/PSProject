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
$listBox.Size = New-Object System.Drawing.Size(260,20)

$listBox.SelectionMode = 'MultiExtended'

[void] $listBox.Items.Add('City')
[void] $listBox.Items.Add('State')
[void] $listBox.Items.Add('Country')
[void] $listBox.Items.Add('E-Mail')
[void] $listBox.Items.Add('Phone Number')
[void] $listBox.Items.Add('Phone Number2')


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
}If($x -contains "country"){
    $country = Read-Host "Enter employee'scountry"
}If($x -contains "phone number"){
    $phone = Read-Host "Enter employee's phone number"
}If($x -contains "phone number"){
    $phone = Read-Host "Enter employee's phone number"
}If($x -contains "phone number"){
    $phone = Read-Host "Enter employee's phone number"
}If($x -contains "phone number"){
    $phone = Read-Host "Enter employee's phone number"
}If($x -contains "phone number"){
    $phone = Read-Host "Enter employee's phone number"
}If($x -contains "phone number"){
    $phone = Read-Host "Enter employee's phone number"
}If($x -contains "phone number"){
    $phone = Read-Host "Enter employee's phone number"
}


<#
foreach ($t in $x){
    New-Variable -Name "$t" -value $t
    $t
}


for ($i=1; $i -le $x.Count; $i++)
{
    New-Variable -Name "$x" -value $x
    #Get-Variable -Name "$i" -valueonly
}
}
remove-Variable -Name  'city'
remove-Variable -Name  'country'
remove-Variable -Name  'city country'
#>
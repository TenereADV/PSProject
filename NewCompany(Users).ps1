##Script used for new AD environments. Populates OUs, users, and security groups. 
##Some simple error handling included.  This script assumes the user will try to enter correct data.##

#Creates departments/OUs#
<#So this is my first Try-Catch scenario.  I was convinced that the Catch needed a specific error to handle, but if left 
blank, it will catch any error.  The most common issue I see with this is if the user encounters an error other than a 
duplicate OU; it still tells the user its a duplicate. #>

#Needs error handling for non-integers
#ProtectedFromAccidentalDeletion for testing purposes only
Clear-Host

#Function used to allow assignment of a department. Displays department and number based on how many OUs exist.


Function Dept-Menu
{
    Param (
    )
    $dept = Get-ADOrganizationalUnit -filter * -Properties name | select -ExpandProperty name
    $deptlist = New-Object -TypeName "System.Collections.ArrayList"
    
    $i = 0
    ForEach($d in $dept){
        $i++;        ;
        Write-Host $i "- "-NoNewline ;$d
        $deptlist += $d}
}

Do{
$input = Read-Host "Would you like to create any departments/OUs? [Y/N]`n(Type 'list' to display current OUs)"
If($input -eq 'list'){
    Write-Host ""
    Get-ADOrganizationalUnit -filter * -Properties name | select -ExpandProperty name
    }
    Write-Host ""
If($input -eq 'y' -or $input -eq 'yes'){
    $deptnum = Read-Host "How many?"
    Write-Host ""

    For($i=1;$i -le $deptnum;$i++){
    
        $d = Read-Host "Department name? (Type 'back' to go back)"
        If($d -eq 'b' -or $d -eq 'back'){
            Write-Host ""
            break}
        Try{
        New-ADOrganizationalUnit -Name $d -path "DC=Adatum,DC=com" -ProtectedFromAccidentalDeletion $false 
        } Catch {
        Write-host "";"duplicate";""
        $i--}
    }
}ElseIf($input -eq 'n' -or $input -eq 'no'){
}
}Until ($input -eq 'n' -or $input -eq 'no')
   
Write-Host "The following departments/OUs are now active:";""

Get-ADOrganizationalUnit -filter * -Properties name | select -ExpandProperty name
Write-Host  ""

#Creates groups to assign users later
#NEEDS ERROR HANDLING FOR GROUPCATEGORY,GROUPSCOPE
$msg = "Do you want to create any groups (security or distribution)? [Y/N]"
Do {
    $response = Read-Host -Prompt $msg
    if ($response -eq 'y') {
        $newgroup = @{}
        $newgroup.name = Read-Host "Name of the new group?"
        $newgroup.samaccountname = $newgroup.name
        $newgroup.groupcategory = Read-Host "Security or Distribution?"
        $newgroup.groupscope = Read-Host "DomainLocal, Global, or Universal?"
        
        New-ADGroup @newgroup 
        get-adgroup -filter * | where name -eq $newgroup.name
        Remove-ADGroup -Identity $newgroup.name
    }
} until ($response -eq 'n')


##Prompts the user for the new employee's information to populate AD fields.##

<#This user creation section is different from the previous becuase the departments are no long hard-coded; the user created them
earlier in the script. I need to figure out how to display them to the user and assign them accordingly#>
Do{
Write-Host ""
$version = Read-Host "Would you like to create a simple or detailed user account?"

################################## Start of simple ADUser ###################################

If($version -eq "simple"){
$repeat2 = $false

<#This script was similar to the Manager script I made earlier.  It checks if the employee name that is entered matches a current employee
and lets the user know either way.  Since I resued the Manager script, troubleshooting was much easier this time around.#>

Do{
Write-Host ""
$First = Read-Host "Enter the employee's first name"
$Last = Read-Host "Enter the employees's last name"
$Name = $First + " " + $Last
$Dname = $Name
$SamName = $First
$confirm = "n"
    
    $testname = Get-ADUser -Filter "name -like '*$name*'"
    If($testname.name -eq $Name){
        Write-Host "";"User already exists. Please check your spelling and try again.";""
        $confirm = "n"}
    Else{$testname.count -eq "0" | Out-Null
        Write-Host "";"User is not in the database. Proceed.";""
        $confirm = "y"}

}while ($confirm -eq "n")
   
#Switch used to assign a department.
<#This now dynamically displays the OUs available and allows the user to select which OU they would like to assign the employee.
It also reduced the amount of code I used because I now don't need an IF statement for every possible OU available.  Since the 
user just created the OUs, there is no way to know ahead of time how many IFs you would need.#>

Dept-Menu

    [int]$Selection = Read-Host "Choose the employee's department"
    $selection--
    $Department = $deptlist[$Selection]

#Assigns department to the employee's path
$Path = "ou=$Department,dc=adatum,dc=com"

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
new-aduser -GivenName $First -Surname $Last -name $name -DisplayName $Dname -SamAccountName $SamName -Path $Path -Department $Department -Enabled $Enabled -AccountPassword $PW -ChangePasswordAtLogon $true

Write-Host "";"Temporary password is 'Pa55w.rd'.  The employee will be forced to change it upon first login."

#Displays new employee's info
Get-ADUser -Identity $SamName -Properties department

#Assigns the new user to a group


########################Removes test user. Used for testing only.
get-aduser -filter "samaccountname -like '$samname'" | remove-aduser





#End of simple or detailed If statement. 
################################## Start of detailed ADUser ###################################

}ElseIf($version -eq 'detailed'){

#Function used to allow assignment of a department.

$newuser = @{}

#Default attributes and checks if user is already in the database.

Do{
Write-Host ""
$newuser.givenname = Read-Host "Enter the employee's first name"
$newuser.surname = Read-Host "Enter the employees's last name"
$newuser.name = $newuser.givenname + " " + $newuser.surname
$newuser.displayname = $newuser.name
$newuser.samaccountname = $newuser.givenname
$confirm = "n"
$checkname = $newuser.name   
    $testname = Get-ADUser -Filter "name -like '*$checkname*'"
    If($testname.name -eq $newuser.name){
        Write-Host "";"User already exists. Please check your spelling and try again."
        $confirm = "n"}
    Else{$testname.count -eq "0" | Out-Null
        Write-Host "";"User is not in the database. Proceed."
        $confirm = "y"}

}while ($confirm -eq "n")
  
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
I'm going to try the search their input method first.  This one was a more compilcated than I thought it was going to be.
New-ADUser requires the country to be inserted in XX format, not just as a typical string (ex. FR for France).  
First I created a hashtable with all available XX as the keys and the spelled out countries as the values.  I then used a
Do-While loop until the .ContainsValue came back true.  Error handling asks the user to repeat until a correct country
is added.  User can also display a full list for reference.  Had a Do-While loop that keept looping when it wasn't supposed to.
Kept getting an error that I was missing a curly bracket; I thought it was after the Do, but it was actually the ending curly bracket
associated with the If statement for City.#>
}If($x -contains "country"){
$CountryLookup = @{
    "AD"="ANDORRA"
    "AE"="UNITED ARAB EMIRATES"
    "AF"="AFGHANISTAN"
    "AG"="ANTIGUA AND BARBUDA"
    "AI"="ANGUILLA"
    "AL"="ALBANIA"
    "AM"="ARMENIA"
    "AO"="ANGOLA"
    "AQ"="ANTARCTICA"
    "AR"="ARGENTINA"
    "AS"="AMERICAN SAMOA"
    "AT"="AUSTRIA"
    "AU"="AUSTRALIA"
    "AW"="ARUBA"
    "AX"="ÅLAND ISLANDS"
    "AZ"="AZERBAIJAN"
    "BA"="BOSNIA AND HERZEGOVINA"
    "BB"="BARBADOS"
    "BD"="BANGLADESH"
    "BE"="BELGIUM"
    "BF"="BURKINA FASO"
    "BG"="BULGARIA"
    "BH"="BAHRAIN"
    "BI"="BURUNDI"
    "BJ"="BENIN"
    "BL"="SAINT BARTHÉLEMY"
    "BM"="BERMUDA"
    "BN"="BRUNEI DARUSSALAM"
    "BO"="BOLIVIA, PLURINATIONAL STATE OF"
    "BQ"="BONAIRE, SINT EUSTATIUS AND SABA"
    "BR"="BRAZIL"
    "BS"="BAHAMAS"
    "BT"="BHUTAN"
    "BV"="BOUVET ISLAND"
    "BW"="BOTSWANA"
    "BY"="BELARUS"
    "BZ"="BELIZE"
    "CA"="CANADA"
    "CC"="COCOS (KEELING) ISLANDS"
    "CD"="CONGO, THE DEMOCRATIC REPUBLIC OF THE"
    "CF"="CENTRAL AFRICAN REPUBLIC"
    "CG"="CONGO"
    "CH"="SWITZERLAND"
    "CI"="CÔTE D'IVOIRE"
    "CK"="COOK ISLANDS"
    "CL"="CHILE"
    "CM"="CAMEROON"
    "CN"="CHINA"
    "CO"="COLOMBIA"
    "CR"="COSTA RICA"
    "CU"="CUBA"
    "CV"="CAPE VERDE"
    "CW"="CURAÇAO"
    "CX"="CHRISTMAS ISLAND"
    "CY"="CYPRUS"
    "CZ"="CZECH REPUBLIC"
    "DE"="GERMANY"
    "DJ"="DJIBOUTI"
    "DK"="DENMARK"
    "DM"="DOMINICA"
    "DO"="DOMINICAN REPUBLIC"
    "DZ"="ALGERIA"
    "EC"="ECUADOR"
    "EE"="ESTONIA"
    "EG"="EGYPT"
    "EH"="WESTERN SAHARA"
    "ER"="ERITREA"
    "ES"="SPAIN"
    "ET"="ETHIOPIA"
    "FI"="FINLAND"
    "FJ"="FIJI"
    "FK"="FALKLAND ISLANDS (MALVINAS)"
    "FM"="MICRONESIA, FEDERATED STATES OF"
    "FO"="FAROE ISLANDS"
    "FR"="FRANCE"
    "GA"="GABON"
    "GB"="UNITED KINGDOM"
    "GD"="GRENADA"
    "GE"="GEORGIA"
    "GF"="FRENCH GUIANA"
    "GG"="GUERNSEY"
    "GH"="GHANA"
    "GI"="GIBRALTAR"
    "GL"="GREENLAND"
    "GM"="GAMBIA"
    "GN"="GUINEA"
    "GP"="GUADELOUPE"
    "GQ"="EQUATORIAL GUINEA"
    "GR"="GREECE"
    "GS"="SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS"
    "GT"="GUATEMALA"
    "GU"="GUAM"
    "GW"="GUINEA-BISSAU"
    "GY"="GUYANA"
    "HK"="HONG KONG"
    "HM"="HEARD ISLAND AND MCDONALD ISLANDS"
    "HN"="HONDURAS"
    "HR"="CROATIA"
    "HT"="HAITI"
    "HU"="HUNGARY"
    "ID"="INDONESIA"
    "IE"="IRELAND"
    "IL"="ISRAEL"
    "IM"="ISLE OF MAN"
    "IN"="INDIA"
    "IO"="BRITISH INDIAN OCEAN TERRITORY"
    "IQ"="IRAQ"
    "IR"="IRAN, ISLAMIC REPUBLIC OF"
    "IS"="ICELAND"
    "IT"="ITALY"
    "JE"="JERSEY"
    "JM"="JAMAICA"
    "JO"="JORDAN"
    "JP"="JAPAN"
    "KE"="KENYA"
    "KG"="KYRGYZSTAN"
    "KH"="CAMBODIA"
    "KI"="KIRIBATI"
    "KM"="COMOROS"
    "KN"="SAINT KITTS AND NEVIS"
    "KP"="KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF"
    "KR"="KOREA, REPUBLIC OF"
    "KW"="KUWAIT"
    "KY"="CAYMAN ISLANDS"
    "KZ"="KAZAKHSTAN"
    "LA"="LAO PEOPLE'S DEMOCRATIC REPUBLIC"
    "LB"="LEBANON"
    "LC"="SAINT LUCIA"
    "LI"="LIECHTENSTEIN"
    "LK"="SRI LANKA"
    "LR"="LIBERIA"
    "LS"="LESOTHO"
    "LT"="LITHUANIA"
    "LU"="LUXEMBOURG"
    "LV"="LATVIA"
    "LY"="LIBYA"
    "MA"="MOROCCO"
    "MC"="MONACO"
    "MD"="MOLDOVA, REPUBLIC OF"
    "ME"="MONTENEGRO"
    "MF"="SAINT MARTIN (FRENCH PART)"
    "MG"="MADAGASCAR"
    "MH"="MARSHALL ISLANDS"
    "MK"="MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF"
    "ML"="MALI"
    "MM"="MYANMAR"
    "MN"="MONGOLIA"
    "MO"="MACAO"
    "MP"="NORTHERN MARIANA ISLANDS"
    "MQ"="MARTINIQUE"
    "MR"="MAURITANIA"
    "MS"="MONTSERRAT"
    "MT"="MALTA"
    "MU"="MAURITIUS"
    "MV"="MALDIVES"
    "MW"="MALAWI"
    "MX"="MEXICO"
    "MY"="MALAYSIA"
    "MZ"="MOZAMBIQUE"
    "NA"="NAMIBIA"
    "NC"="NEW CALEDONIA"
    "NE"="NIGER"
    "NF"="NORFOLK ISLAND"
    "NG"="NIGERIA"
    "NI"="NICARAGUA"
    "NL"="NETHERLANDS"
    "NO"="NORWAY"
    "NP"="NEPAL"
    "NR"="NAURU"
    "NU"="NIUE"
    "NZ"="NEW ZEALAND"
    "OM"="OMAN"
    "PA"="PANAMA"
    "PE"="PERU"
    "PF"="FRENCH POLYNESIA"
    "PG"="PAPUA NEW GUINEA"
    "PH"="PHILIPPINES"
    "PK"="PAKISTAN"
    "PL"="POLAND"
    "PM"="SAINT PIERRE AND MIQUELON"
    "PN"="PITCAIRN"
    "PR"="PUERTO RICO"
    "PS"="PALESTINE, STATE OF"
    "PT"="PORTUGAL"
    "PW"="PALAU"
    "PY"="PARAGUAY"
    "QA"="QATAR"
    "RE"="RÉUNION"
    "RO"="ROMANIA"
    "RS"="SERBIA"
    "RU"="RUSSIAN FEDERATION"
    "RW"="RWANDA"
    "SA"="SAUDI ARABIA"
    "SB"="SOLOMON ISLANDS"
    "SC"="SEYCHELLES"
    "SD"="SUDAN"
    "SE"="SWEDEN"
    "SG"="SINGAPORE"
    "SH"="SAINT HELENA, ASCENSION AND TRISTAN DA CUNHA"
    "SI"="SLOVENIA"
    "SJ"="SVALBARD AND JAN MAYEN"
    "SK"="SLOVAKIA"
    "SL"="SIERRA LEONE"
    "SM"="SAN MARINO"
    "SN"="SENEGAL"
    "SO"="SOMALIA"
    "SR"="SURINAME"
    "SS"="SOUTH SUDAN"
    "ST"="SAO TOME AND PRINCIPE"
    "SV"="EL SALVADOR"
    "SX"="SINT MAARTEN (DUTCH PART)"
    "SY"="SYRIAN ARAB REPUBLIC"
    "SZ"="SWAZILAND"
    "TC"="TURKS AND CAICOS ISLANDS"
    "TD"="CHAD"
    "TF"="FRENCH SOUTHERN TERRITORIES"
    "TG"="TOGO"
    "TH"="THAILAND"
    "TJ"="TAJIKISTAN"
    "TK"="TOKELAU"
    "TL"="TIMOR-LESTE"
    "TM"="TURKMENISTAN"
    "TN"="TUNISIA"
    "TO"="TONGA"
    "TR"="TURKEY"
    "TT"="TRINIDAD AND TOBAGO"
    "TV"="TUVALU"
    "TW"="TAIWAN, PROVINCE OF CHINA"
    "TZ"="TANZANIA, UNITED REPUBLIC OF"
    "UA"="UKRAINE"
    "UG"="UGANDA"
    "UM"="UNITED STATES MINOR OUTLYING ISLANDS"
    "US"="UNITED STATES"
    "UY"="URUGUAY"
    "UZ"="UZBEKISTAN"
    "VA"="HOLY SEE (VATICAN CITY STATE)"
    "VC"="SAINT VINCENT AND THE GRENADINES"
    "VE"="VENEZUELA, BOLIVARIAN REPUBLIC OF"
    "VG"="VIRGIN ISLANDS, BRITISH"
    "VI"="VIRGIN ISLANDS, U.S."
    "VN"="VIET NAM"
    "VU"="VANUATU"
    "WF"="WALLIS AND FUTUNA"
    "WS" = "SAMOA"
    "YE"="YEMEN"
    "YT"="MAYOTTE"
    "ZA"="SOUTH AFRICA"
    "ZM"="ZAMBIA"
    "ZW"="ZIMBABWE"
}
    Do{
        $country = Read-Host "Enter employee's country"
        Write-Host ""
     If($country -eq "help"){
     $CountryLookup.GetEnumerator() |sort value
     }Else{
        If($CountryLookup.ContainsValue($country.toupper()) -eq $false){
         Write-Host "Please enter a correct country name. For a full list of choices, type 'help'.";""
}
}
    }While ($CountryLookup.ContainsValue($country.toupper()) -eq $false)

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
    Write-Host ""
    $user = Read-Host "Enter the manager's first and last name: `n(Type 'q' or 'quit' to skip)"
    If($user -eq "q" -or $user -eq "quit"){
        break
     Write-Host ""
     }
    $manager = Get-ADUser -Filter "name -like '*$user*'"
    If($manager.Count -gt "1"){
        Write-Host "";"Please enter a more specific name.";""}
    elseIf($manager.count -eq "0"){
        Write-Host "";"Please enter a correct name.";""}
    Else{
        $mname = $manager.Name
        write-host ""
        $confirm = Read-Host "You have chosen $mname as the manager.  Is this correct?" 
        write-host ""
    }$newuser.manager = $manager
        }while ($confirm -ne "y")
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

    [int]$Selection = Read-Host "Choose the employee's department"
    $selection--
    $newuser.department = $deptlist[$Selection]
}Until ($newuser.department -ne $null)

#Assigns department to the employee's path
$newuser.path = "ou=$Department ,dc=adatum,dc=com"

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

#Stops simple/detailed Do loop
$repeat2 = $false

#Displays newly created properties
Get-ADUser -Identity $newuser.samaccountname -Properties *

#Displays temp PW to user
Write-Host "";"Temporary password is 'Pa55w.rd'.  The employee will be forced to change it upon first login."

############################Removes the test user and clears the NewUser hashtable. Used for testing only
get-aduser -filter "name -like '*$checkname*'" | remove-aduser; $newuser.clear()


#Invalid selection from the simple/detailed input
}Else{
    Write-Host "Please enter a valid selection.";
    $repeat2 = $true
    }
#End of Do statement from beginning

}While ($repeat2 -eq $true)








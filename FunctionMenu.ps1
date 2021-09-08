Function Show-Menu
{
    Param (
        [string]$Title = "Menu"
    )
    Write-Host "$Title"

    Write-Host "1: Press '1' for this option"
    Write-Host "2: Press '2' for this option"
    Write-Host "3: Press '3' for this option"
    Write-Host "4: Press '4' for this option"
}


get-aduser -Filter * -Properties department | select department |sort -Unique department
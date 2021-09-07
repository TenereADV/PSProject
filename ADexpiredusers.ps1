$date = get-date

get-aduser -filter {AccountExpirationDate -lt $date}


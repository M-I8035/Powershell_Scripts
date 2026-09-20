$startDate = (Get-Date).AddDays(-30)
$today     = Get-Date

$pattern   = '.*@example.com$'   # <-- sender filter pattern (regex)
$export    = @()                 # collection for CSV output

while ($startDate -le $today) {

    $endDate = $startDate.AddDays(1)
    Write-Output "Processing data for date: $startDate"

    $results = Get-MessageTraceV2 `
        -StartDate $startDate `
        -EndDate   $endDate `
        -ResultsSize 5000

    # Filter senders + shape output
    $filtered = $results |
        Where-Object { $_.SenderAddress -match $pattern } |
        ForEach-Object {
            [PSCustomObject]@{
                DateWindowStart = $startDate
                DateWindowEnd   = $endDate

                Sender          = $_.SenderAddress
                Recipient       = $_.RecipientAddress
                Subject         = $_.Subject
                Status          = $_.Status

                SubmittedUTC    = $_.Submitted
                ReceivedUTC     = $_.Received

            }
        }

    $export += $filtered
    $startDate = $endDate
}

# Export only the filtered + shaped data
$export | Export-Csv -Path ".\MessageTrace_Filtered.csv" -NoTypeInformation

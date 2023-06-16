function Get-QuantumRandom {
    [CmdletBinding(DefaultParameterSetName='QRNG')]
    param (
    [Parameter(Mandatory=$false, ParameterSetName='QRNG')]
    [int]$Minimum=0,
    [Parameter(Mandatory=$false, ParameterSetName='QRNG')]
    [int]$Maximum=[Int32]::MaxValue,
    [Parameter(Mandatory=$false, ParameterSetName='QRNG')]
    [int]$Size=1,
    [Parameter(Mandatory=$true, ParameterSetName='ArrayQManipulation')]
    $InputArray=$null,
    [Parameter(ParameterSetName='ArrayQManipulation')]
    [Parameter(ParameterSetName='DictionaryQManipulation')]
    [switch]$Shuffle=$false,
    [Parameter(Mandatory=$true, ParameterSetName='DictionaryQManipulation')]
    [switch]$Dictionary=$false
    );

    if ($Dictionary) {
    $QDictionary = ((Invoke-RestMethod -Uri "https://raw.githubusercontent.com/AlecMcCutcheon/Get-QuantumRandom/main/QDictionary.txt") -split "`n")
    $InputArray = $QDictionary[0..($QDictionary.Count - 2)]
    }

    if ($InputArray) {
    $Maximum = (($InputArray.Count) - 1)
    }

    # Query the QRNG for Random Int between $Minimum and $Maximum
    $url = "http://qrng.ethz.ch/api/randint?min=$Minimum&max=$Maximum&size=$Size"
    $response = ((Invoke-RestMethod -Uri $url -Verbose:$false).result)

    # If the response is an array, use QRNG int to select an array element
    if ($InputArray) {
    if ($Shuffle) {

    if ($PSBoundParameters.ContainsKey('Verbose')) {
        $timer = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Verbose "InputArray Size: $($InputArray.Count).`n"
        Write-Verbose "Collecting Non-Repeating True Random Data to pair with InputArray...`n"
    }

    $randNums = [System.Collections.Generic.HashSet[int]]::new()
    $MaxBatchSize = [Math]::Min(500000, ($InputArray.Count * 4))

    if ($InputArray.Count -lt $MaxBatchSize) {
        $CurrentBatchSize = ($InputArray.Count)
    }else {
        $CurrentBatchSize = $MaxBatchSize
    }

    $percentSync = $true

    do {
        #Write-Verbose "Current Batch Size: $CurrentBatchSize"
        $QRNs = Get-QuantumRandom -Maximum ($InputArray.Count) -Size $CurrentBatchSize
        $QRNs.ForEach{
            [void]$randNums.Add($_)
        }

        if ($percentSync) {

        $decimalPlaces = [Math]::Ceiling(($InputArray.Count.ToString().Length / 2) + 0.5)
        $percentRaw = (($randNums.Count / ($InputArray.Count + 1)) * 100).ToString("F$decimalPlaces") + "%"
        $percentSync = $false

        }

        if (($randNums.Count / ($InputArray.Count + 1)).ToString("P") -notmatch $percentRaw) {
            $decimalPlaces = [Math]::Ceiling(($InputArray.Count.ToString().Length / 2) + 0.5)
            $percentRaw = (($randNums.Count / ($InputArray.Count + 1)) * 100).ToString("F$decimalPlaces") + "%"
            Write-Verbose "$percentRaw`n"
        }

        $currentBatchSize = [Math]::Min($currentBatchSize * 2, $maxBatchSize)

    } while ($randNums.Count -le $InputArray.Count)

    if ($PSBoundParameters.ContainsKey('Verbose')) {
        Write-Verbose "True Random Data Collection Complete.`n"
    }

    $outputArray = New-Object Object[] $InputArray.Count
    $i = 0

    foreach ($RandNum in $randNums) {
        if ($RandNum -lt $InputArray.Count) {
            $outputArray[$RandNum] = $InputArray[$i]
            $i++
        }
    }


    $filteredOutputArray = $outputArray | Where-Object { $_ -ne $null }

    if ($PSBoundParameters.ContainsKey('Verbose')) {
        $timer.Stop()
        Write-Verbose "Shuffle completed in $($timer.Elapsed.TotalSeconds) seconds.`n"
        Write-Verbose "OutputArray Size: $($filteredOutputArray.Count).`n"
    }

    $response = $filteredOutputArray

    } else {
    $response = $InputArray[$response]
    }
    }

    # Return the result
    return $response
}

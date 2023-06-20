function Get-QuantumRandom {
    [CmdletBinding(DefaultParameterSetName = 'QRNG_Main')]
    param (
        [Parameter(ParameterSetName = 'QRNG_Main')]
        [ValidateRange([Int32]::MinValue, [Int32]::MaxValue)]
        [int]$Minimum = 0,
        [Parameter(ParameterSetName = 'QRNG_Main')]
        [ValidateRange([Int32]::MinValue, [Int32]::MaxValue)]
        [int]$Maximum = [Int32]::MaxValue,
        [Parameter(ParameterSetName = 'QRNG_Main')]
        [ValidateRange(0, 16)]
        [int]$Decimals = 0,
        [Parameter(ParameterSetName = 'QRNG_Main')]
        [Parameter(ParameterSetName = 'QRNG_Array')]
        [Parameter(ParameterSetName = 'QDictionary')]
        [Parameter(ParameterSetName = 'QGUID')]
        [Parameter(ParameterSetName = 'QIPv4')]
        [Parameter(ParameterSetName = 'QDateTime')]
        [Parameter(ParameterSetName = 'QGPSCoords')]
        [Parameter(ParameterSetName = 'QPassword')]
        [ValidateRange(1, [Int32]::MaxValue)]
        [int]$Size = 1,
        [Parameter(ParameterSetName = 'QRNG_Array')]
        [Parameter(ParameterSetName = 'QDictionary')]
        [switch]$Shuffle = $false,
        [Parameter(ParameterSetName = 'QIPv4')]
        [switch]$Private = $false,
        [Parameter(ParameterSetName = 'QDateTime')]
        [ValidateRange(1, 9999)]
        [int]$MinimumYear = 1,
        [Parameter(ParameterSetName = 'QDateTime')]
        [ValidateRange(1, 9999)]
        [int]$MaximumYear = 9999,
        [Parameter(ParameterSetName = 'QGPSCoords')]
        [switch]$GooleMapsUrl = $false,
        [Parameter(ParameterSetName = 'QGPSCoords')]
        [switch]$OpenMaps = $false,
        [Parameter(ParameterSetName = 'QPassword')]
        [ValidateRange(8, 1000000)]
        [int]$length = 8,
        [Parameter(Mandatory = $true, ParameterSetName = 'QRNG_Array')]
        $InputArray = $null,
        [Parameter(ParameterSetName = 'QDictionary')]
        [switch]$Dictionary = $false,
        [Parameter(ParameterSetName = 'QGUID')]
        [switch]$GUID = $false,
        [Parameter(ParameterSetName = 'QIPv4')]
        [switch]$IPv4 = $false,
        [Parameter(ParameterSetName = 'QDateTime')]
        [switch]$DateTime = $false,
        [Parameter(ParameterSetName = 'QGPSCoords')]
        [switch]$GPSCoords = $false,
        [Parameter(ParameterSetName = 'QPassword')]
        [switch]$Password = $false
    );

    function Invoke-RestMethodWithRetry {
        param (
            [string]$Url
        )
        $retryCount = 0
        do {
            try {
                $response = Invoke-RestMethod -Uri $Url -ErrorAction Stop -Verbose:$false
                return $response  # Exit the function if successful
            } catch {
                if ($retryCount -lt 4) {
                    $retryCount++
                    Start-Sleep -Seconds 1
                } else {
                    return
                }
            }
        } while ($retryCount -lt 5)
    }

    # QRNG
    if ($PSCmdlet.ParameterSetName -like '*QRNG*') {
        if ($InputArray) {
            $Maximum = (($InputArray.Count) - 1)
        }
        if (!$Shuffle -and $Decimals -gt 0) {
            $url = "http://qrng.ethz.ch/api/randint?min=$Minimum&max=$Maximum&size=$Size"
            $url2 = "http://qrng.ethz.ch/api/rand?size=$Size"
            $Integers = ((Invoke-RestMethodWithRetry -Url $url).result)
            $FloatingpointNumbers = ((Invoke-RestMethodWithRetry -Url $url2).result)
            $response = $Integers | ForEach-Object -Begin {$i = 0} -Process {
                $integer = $_
                $floatingPoint = [decimal]($FloatingPointNumbers[$i]) -replace '^0.'
                $i++
                (("{0:N$Decimals}" -f [decimal]"$integer.$floatingPoint") -replace ",")
            }
        } else {
        $url = "http://qrng.ethz.ch/api/randint?min=$Minimum&max=$Maximum&size=$Size"
        $response = ((Invoke-RestMethodWithRetry -Url $url).result)
        }

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
                }
                else {
                    $CurrentBatchSize = $MaxBatchSize
                }
                $percentSync = $true
                do {
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
            }
            else {
                if ($Size -gt 1) {
                    $Group = @()
                    foreach ($Num in $response) {
                        $Group += $InputArray[$Num]
                    }
                    $response = $Group
                }
                else {    
                    $response = $InputArray[$response]
                }
            }
        }
    }
    # QDictionary
    if ($PSCmdlet.ParameterSetName -eq 'QDictionary'-and $Dictionary) {
        $QDictionary = ((Invoke-RestMethod -Uri "https://raw.githubusercontent.com/AlecMcCutcheon/Get-QuantumRandom/main/QDictionary.txt") -split "`n")
        $InputArray = $QDictionary[0..($QDictionary.Count - 2)]
        if ($PSBoundParameters.ContainsKey('Verbose')) {
            if ($Shuffle) {
                $response = Get-QuantumRandom -InputArray $InputArray -Shuffle -Verbose
            }else {
                $response = Get-QuantumRandom -InputArray $InputArray -Size $Size -Verbose
            }
        }else {
            if ($Shuffle) {
                $response = Get-QuantumRandom -InputArray $InputArray -Shuffle
            }else {
                $response = Get-QuantumRandom -InputArray $InputArray -Size $Size
            }
        }
    }
    # QGUID
    if ($PSCmdlet.ParameterSetName -eq 'QGUID'-and $GUID) {
        $QGUID = (1..$Size) | ForEach-Object {
            ([Guid]::Parse((((Get-QuantumRandom -Minimum 0 -Maximum 15 -size 32 | ForEach-Object { $_.ToString("x") }) -join "") -replace '(\w{8})(\w{4})(\w{4})(\w{4})(\w{12})', '$1-$2-$3-$4-$5'))).Guid
        }
        $response = $QGUID
    }
    # QIPv4
    if ($PSCmdlet.ParameterSetName -eq 'QIPv4'-and $IPv4) {
        $QIP = (1..$Size) | ForEach-Object {
            if ($Private) {
                $ipv4Address = "10." + ((Get-QuantumRandom -Minimum 0 -Maximum 255 -Size 2) -join ".")
                $ipv4Address += "." + (Get-QuantumRandom -Minimum 1 -Maximum 255 -Size 1)
                $ipv4Address
            }else {
                $ipv4Address = (Get-QuantumRandom -Minimum 1 -Maximum 255 -Size 4) -join "."
                $ipv4Address
            }
        }
        $response = $QIP
    }
    # QDateTime
    if ($PSCmdlet.ParameterSetName -eq 'QDateTime' -and $DateTime) {
        $QDateTime = (1..$Size) | ForEach-Object {
            if ($MinimumYear -lt 1) {
                $MinimumYear = 1
            } 
            if ($MaximumYear -gt 9999) {
                $MaximumYear = 9999
            }
            $randomYear = Get-QuantumRandom -Minimum $MinimumYear -Maximum $MaximumYear
            $randomMonth = Get-QuantumRandom -Minimum 1 -Maximum 12
            $daysInMonth = [System.DateTime]::DaysInMonth($randomYear, $randomMonth)
            $randomDay = Get-QuantumRandom -Minimum 1 -Maximum ($daysInMonth + 1)
            $randomTime = Get-QuantumRandom -Minimum 0 -Maximum 86400
            $randomDateTime = (Get-Date -Year $randomYear -Month $randomMonth -Day $randomDay -Hour 0 -Minute 0 -Second 0).AddSeconds($randomTime)
            ($randomDateTime | Get-Date).DateTime
        }
        $response = $QDateTime
    }
    # QGPSCoords
    if ($PSCmdlet.ParameterSetName -eq 'QGPSCoords'-and $GPSCoords) {
        $QGPSCoords = (1..$Size) | ForEach-Object {
            $latitude = Get-QuantumRandom -Minimum -90 -Maximum 90
            if ($latitude -ne -90 -and $latitude -ne 90) {
                $latitude = "$latitude.$((Get-QuantumRandom -Minimum 0 -Maximum 9 -Size 5) -join '')"
            }
            $longitude = Get-QuantumRandom -Minimum -180 -Maximum 180
            if ($longitude -ne -180 -and $longitude -ne 180) {
                $longitude = "$longitude.$((Get-QuantumRandom -Minimum 0 -Maximum 9 -Size 5) -join '')"
            }
            $googleMapsUrl = "https://www.google.com/maps/place/$([System.Math]::Round($latitude, 5))+$([System.Math]::Round($longitude, 5))/@$([System.Math]::Round($latitude, 5)),$([System.Math]::Round($longitude, 5)),2z/data=!3m1!1e3"
            if ($OpenMaps) {
                Start-Process $googleMapsUrl
            }
            if ($GooleMapsUrl) {
                Write-Output $googleMapsUrl
            } else {
                Write-Output "$latitude, $longitude"
            }
        }
        $response = $QGPSCoords
    }
    # QPassword
    if ($PSCmdlet.ParameterSetName -eq 'QPassword' -and $Password) {
        $QPassword = (1..$Size) | ForEach-Object {
            $charset = (Invoke-RestMethod -Uri https://raw.githubusercontent.com/AlecMcCutcheon/Get-QuantumRandom/main/QCharSets)
            $result = @();
            $RandomNums = Get-QuantumRandom -Minimum 1 -Maximum 4 -Size $length
            $UpperCaseNums = Get-QuantumRandom -Minimum 0 -Maximum 25 -Size $length
            $LowerCaseNums = Get-QuantumRandom -Minimum 0 -Maximum 25 -Size $length
            $NumberNums = Get-QuantumRandom -Minimum 0 -Maximum 9 -Size $length
            $SpecialNums = Get-QuantumRandom -Minimum 0 -Maximum ($charset.Special.Length - 1) -Size $length
            $NumCount = 0
            $result += $charset.Uppercase[$UpperCaseNums[$NumCount]]
            $result += $charset.Lowercase[$LowerCaseNums[$NumCount]]
            $result += $charset.Number[$NumberNums[$NumCount]]
            $result += $charset.Special[$SpecialNums[$NumCount]]
            $lengthLeft = $length - 4
            Do {
                $NumCount++
                $Number = $RandomNums[$lengthLeft]
                If ($Number -eq 1) {
                    $result += $charset.Uppercase[$UpperCaseNums[$NumCount]]
                }elseif ($Number -eq 2) {
                    $result += $charset.Lowercase[$LowerCaseNums[$NumCount]]
                }elseif ($Number -eq 3) {
                    $result += $charset.Number[$NumberNums[$NumCount]]
                }elseif ($Number -eq 4) {
                    $result += $charset.Special[$SpecialNums[$NumCount]]
                }
                $lengthLeft--
            } while ($lengthLeft -gt 0)
            Write-Output ((Get-QuantumRandom -InputArray $result -Shuffle) -join "")
        }
        $response = $QPassword
    }
    # Result
    if ($PSBoundParameters.Keys.Count -gt 1) {
        $QParameters = $PSBoundParameters.Keys -join ", -"
    } else {
        $QParameters = $PSBoundParameters.Keys[0]
    }
    if ($PSCmdlet.ParameterSetName -notlike '*QRNG*' -and !($PSBoundParameters.ContainsKey($PSCmdlet.ParameterSetName.Substring(1)))) {
        return Write-Warning "Parameter -$($PSCmdlet.ParameterSetName.Substring(1)) is required when using -$QParameters."
    }else {
        return $response
    }
}

Write-Output "Get-QuantumRandom Was Been Added to The Current PS Session."

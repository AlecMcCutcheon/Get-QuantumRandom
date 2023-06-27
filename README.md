# Get-QuantumRandom
Is a PowerShell function that uses the (Quantum Random Number Generator) http://qrng.ethz.ch API to provide Similar functionality to the built-in Get-Random function, while also providing True Randomness from Quantum mechanics + some extra features.

If anyone would like to contribute with roadmap features, improvments & Ideas in speed/function and or know of free alternative QRNG services that also generate large numbers. Feel free to contact me in the issues section. 
The only reason I haven't parallelized the function is because of the limitations/bottlenecks that comes with using a single QRNG Service.

Here's a One-Liner to Import it into your PS Session.
```
iwr -useb https://tinyurl.com/PS-QRNG | iex
```

# Roadmap/Ideas: 
```
🗸 QRandom Dictionary
🗸 QRandom Passwords/CharSets
🗸 QRandom Data/Time
🗸 QRandom GUIDs
🗸 QRandom IP Addresses
🗸 QRandom GPS Coordinates
🗸 QRNG Decimals

🗸 QRNG API retry mechanism
- Porting to other Programing languages

```

# Usage:
```
PS C:\> iwr -useb https://tinyurl.com/PS-QRNG | iex
Get-QuantumRandom Was Been Added to The Current PS Session.

PS C:\> Get-QuantumRandom
777758543

PS C:\> Get-QuantumRandom -Decimals 8
478913793.37857833

PS C:\> Get-QuantumRandom -InputArray ("A","B","C","D","E","F") 
A

PS C:\> Get-QuantumRandom -InputArray ("A","B","C","D","E","F")  -Shuffle
E
A
D
F
C
B

PS C:\> Get-QuantumRandom -Dictionary
taisch

PS C:\> Get-QuantumRandom -GUID -Size 2
58d5fd7d-39c5-b8e9-1c84-4c65e7a175a2
56f7c220-d71e-171f-faa5-69bd5273cd9d

PS C:\> Get-QuantumRandom -IPv4
102.163.239.136

PS C:\> Get-QuantumRandom -DateTime
Friday, August 20, 9926 9:38:32 PM

PS C:\> Get-QuantumRandom -GPSCoords
49.93875, -76.83267

PS C:\> Get-QuantumRandom -Password
FI'7e1C7

PS C:\> Get-QuantumRandom -InputArray (1..4) -Shuffle -Verbose  
VERBOSE: InputArray Size: 4.

VERBOSE: Collecting Non-Repeating True Random Data to pair with InputArray...

VERBOSE: 60.0%

VERBOSE: 100.0%

VERBOSE: True Random Data Collection Complete.

VERBOSE: Shuffle completed in 0.3977824 seconds.

VERBOSE: OutputArray Size: 4.

2
4
3
1
```

# Where:
```

----------------------------------------- QRNG -----------------------------------------------------

-Minimum <int>          The minimum number set for the true random number range (Default: 0) [Optional]

-Maximum <int>          The maximum number set for the true random number range (Default: 2,147,483,647 ) [Optional]

-Decimals <int>         The number of random decimals to gentrate (Default: 0) [Optional]
                          - If Set to -1, Sets Decimals to the number of digits left of the decimal

-Size <int>             The number of true random number to generate within the range (Default: 1) [Optional]

========================================== OR =======================================================

-InputArray <array>     An array to manipulate using the QRNG (Default: null) [Required]

-Shuffle <switch>       Indicates whether to Shuffle the InputArray (Default: False) [Optional]

-Size <int>             The Number of Random Values to pick from the InputArray (Default: 1) [Optional]

-------------------------------------- QDictionary --------------------------------------------------

-Dictionary <switch>    Indicates whether to set the InputArray to a Pre-Qrandomized English Dictionary (Default: False) [Required]

-Shuffle <switch>       Indicates whether to Shuffle the Dictionary (Default: False) [Optional]

-Size <int>             The Number of Random words to pick from the Dictionary (Default: 1) [Optional]

---------------------------------------- QGUID ------------------------------------------------------

-GUID <switch)>         Indicates whether to generate random GUIDs (Default: False) [Required]

-Size <int>             The Number of true random GUIDs to generate (Default: 1) [Optional]

---------------------------------------- QIPv4 ------------------------------------------------------

-IPV4 <switch>          Indicates whether to generate random IPv4 Addresses (Default: False) [Required]

-Private <switch>       Indicates whether to generate private IPv4 addresses (Default: False) [Optional]

-Size <int>             The Number of true random IPv4 Addresses to generate (Default: 1) [Optional]

--------------------------------------- QDateTime ----------------------------------------------------

-DateTime <switch>      Indicates whether to generate random DateTime Values (Default: False) [Required]

-MinimumYear <int>      The Minimum year for generating random DateTime values (Default: 1) [Optional]

-MaximumYear <int>      The Maximum year for generating random DateTime values (Default: 9999) [Optional]

-Size <int>             The Number of true random DateTime Values to generate (Default: 1) [Optional]

--------------------------------------- QGPSCoords ----------------------------------------------------

-GPSCoords <switch>     Indicates whether to generate random GPSCoords (Default: False) [Required]

-GooleMapsUrl <switch>  Indicates whether to output Google Maps URLs for generated GPS coordinates (Default: False) [Optional]

-OpenMaps <switch>      Indicates whether to open Google Maps URLs for generated GPS coordinates (Default: False) [Optional]

-Size <int>             The Number of true random GPSCoords to generate (Default: 1) [Optional]

--------------------------------------- QPassword ----------------------------------------------------

-Password <switch>      Indicates whether to generate random Passwords (Default: False) [Required]

-length <int>           The length of the generated passwords. (Default: 8) [Optional]

-Size <int>             The Number of true random Passwords to generate (Default: 1) [Optional]

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ALL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-Verbose <switch>       A Switch to Show more info (Default: False) [Optional]

```

# How:
```
The function initially retrieves random numbers from the QRNG API, which are known to be generated based on inherently random quantum processes.
These quantum processes ensure that the obtained random numbers possess the properties of true randomness.
The obtained random numbers are then used to determine the positions of elements in the input array.
By associating each random number with an index of the input array, the function establishes a mapping between the random numbers and the array elements.
The function ensures that the obtained random numbers are unique, so that each index of the input array is mapped to a different random number.
This step is important to avoid repetitions and maintain the integrity of the shuffling process.
The shuffling algorithm used in the function assigns the elements of the input array to new positions based on the unique random numbers.
This shuffling process creates a scrambled version of the array where the original order of the elements is randomized.

By using the random numbers obtained from the QRNG, the function preserves the underlying quantum randomness throughout the shuffling process.
The inherent randomness of the quantum processes involved in generating the random numbers ensures that the final scrambled array retains the properties of true randomness,
similar to the original quantum random numbers obtained from the QRNG API.
```

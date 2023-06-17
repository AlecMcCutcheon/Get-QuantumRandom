# Get-QuantumRandom
Is a PowerShell function that uses the (Quantum Random Number Generator) http://qrng.ethz.ch API to provide Similar functionality to the built-in Get-Random function, while also providing True Randomness from Quantum mechanics + some extra features.


Here's a One-Liner to Import it into your PS Session.
```
iwr -useb https://tinyurl.com/Get-QRandom | iex
```

# Usage:
```
PS C:\WINDOWS\system32> Get-QuantumRandom
960070456

PS C:\WINDOWS\system32> Get-QuantumRandom -Minimum 10 -Maximum 50 -Size 5
15
25
19
49
28

PS C:\WINDOWS\system32> Get-QuantumRandom -InputArray (1..20)
9

PS C:\WINDOWS\system32> Get-QuantumRandom -InputArray (0..5) -Shuffle
0
2
1
4
5
3

PS C:\WINDOWS\system32> Get-QuantumRandom -Dictionary
jingle

PS C:\WINDOWS\system32> Get-QuantumRandom -Dictionary -Shuffle -Verbose
VERBOSE: GET https://raw.githubusercontent.com/AlecMcCutcheon/Get-QuantumRandom/main/QDictionary.txt with 0-byte payload
VERBOSE: received 3864811-byte response of content type text/plain; charset=utf-8
VERBOSE: InputArray Size: 370105.

VERBOSE: Collecting Non-Repeating True Random Data to pair with InputArray...

VERBOSE: 63.0922%

[...]

VERBOSE: 100.0000%

VERBOSE: True Random Data Collection Complete.

VERBOSE: Shuffle completed in 40.501 seconds

VERBOSE: OutputArray Size: 370105.

cacogenesis
eunuch
wartyback
tridimensionally
scenic
dumbfounded
tauropolos
struthioniformes
[...]

```
# Where:
```
-Minimum <int>          The minimum number set for the true random number range (Default: 0) [Optional]


-Maximum <int>          The maximum number set for the true random number range (Default: 2,147,483,647 ) [Optional]


-Size <int>             The number of true name number to generate within the range (Default: 1) [Optional]

# If No Parameters, Generates a random Number

-------------------------------------------OR-------------------------------------------------------

-InputArray <array>     An array to manipulate using the QRNG (Default: null) [Required]

-Shuffle <switch>       A Switch to Shuffle the InputArray or not (Default: False) [Optional]
                          - If True, Uses the QRNG to randomly shuffle the InputArray
                          - If False, Uses the QRNG to randomly choose a value from the InputArray

# If Only InputArray, Picks a random value from InputArray

-------------------------------------------OR-------------------------------------------------------

-Dictionary <switch>    A Switch to set the InputArray to a Pre-Qrandomized English Dictionary (Default: False) [Required]
                          - If True, Sets the InputArray to a Pre-Qrandomized English Dictionary
                          - If False, Allows Other Modes to be used (Default: False)

-Shuffle <switch>       A Switch to Shuffle the InputArray or not (Default: False) [Optional]
                          - If True, Uses the QRNG to randomly shuffle the Dictionary
                          - If False, Uses the QRNG to randomly choose a value from the Dictionary

# If Only Dictionary, Picks a random word from Dictionary

-------------------------------------------AND-------------------------------------------------------

-Verbose <switch>       A Switch to Show more info (Default: False) [Optional]
                          - If True, Shows more info while running the function and the output
                          - If False, Shows only the output

```

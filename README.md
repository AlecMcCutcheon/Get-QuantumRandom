# Get-QuantumRandom
Is a PowerShell function that uses the (Quantum Random Number Generator) http://qrng.ethz.ch API to provide similer functionality to the built-in Get-Random function, while also providing True Randomness from Quantum mechanics + some extra features.


Here's a One-Liner to Import it into your PS Session.
```
iwr -useb https://tinyurl.com/Get-QuantumRandom | iex
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
                          - If True, Uses the QRNG to randomly shuffe the InputArray
                          - If False, Uses the QRNG to randomly choose a value from the InputArray

# If Only InputArray, Picks a random value from InputArray

-------------------------------------------OR-------------------------------------------------------

-Dictionary <switch>    A Switch to set the InputArray to a Pre-Qrandomized English Dictionary (Default: False) [Required]
                          - If True, Sets the InputArray to a Pre-Qrandomized English Dictionary
                          - If False, Allows Other Modes to be used (Default: False)

-Shuffle <switch>       A Switch to Shuffle the InputArray or not (Default: False) [Optional]
                          - If True, Uses the QRNG to randomly shuffe the Dictionary
                          - If False, Uses the QRNG to randomly choose a value from the Dictionary

# If Only Dictionary, Picks a random word from Dictionary

-------------------------------------------AND-------------------------------------------------------

-Verbose <switch>       A Switch to Show more info (Default: False) [Optional]
                          - If True, Shows more info while running the function and the output
                          - If False, Shows only the output

```

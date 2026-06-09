PROBLEM:

The thing runs literallly every frame, could be a problem later on when i have multiple

speaking of multiple

because it sets the passthrough to false whenever it detects it outside, having multiple will cause it to be false forever because one is always setting it to false

SOLUTION:

have it run only when the mouse is moving

make the amount of areas the mouse is in at once a global value that each one contributes to

if the value is more than one then set passthrough to false

if it is 0 then true
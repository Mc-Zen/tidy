#import "funny-math-complex.typ": *


/// This function computes the square root $sqrt(x)$ of it's argument. 
/// #image("/polar.svg", width: 100pt)
/// - x (float, integer): Argument to take the square root of. 
/// -> float
#let funny-sqrt(x) = { calc.sqrt(x) }

/// This function computes the sine $sin(x)$ of $x$. 
/// - phi (float): Angle for the sine function. 
/// -> float
#let funny-sin(phi) = { calc.sqrt(phi) }

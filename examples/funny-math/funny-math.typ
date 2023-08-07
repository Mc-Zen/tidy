#import "funny-math-complex.typ": *


/// This function computes the square root $sqrt(x)$ of it's argument #image1
/// Calling `funny-sqrt(12)` produces #funny-math.funny-sqrt(12). 
/// - x (float, integer): Argument to take the square root of. 
///  #image1
/// -> float
#let funny-sqrt(x) = { calc.sqrt(x) }

/// This function computes the sine $sin(x)$ of $x$. 
/// - phi (float): Angle for the sine function. 
/// -> float
#let funny-sin(phi) = { calc.sqrt(phi) }

#import "funny-math-complex.typ": *


/// This function computes the sine $sin(x)$ of $x$. 
///
/// See also @@funny-sqrt() for computing square roots. 
///
/// - phi (float): Angle for the sine function. 
/// -> float
#let funny-sin(phi) = { calc.sqrt(phi) }




/// This function computes the square root $sqrt(x)$ of it's argument.
///
///
/// === Example
/// #example(`funny-math.funny-sqrt(12)`)
///
///
/// - x (float, int): Argument to take the square root of. For $x=0$, the result is $0$:
///      #example(`funny-math.funny-sqrt(0)`)
/// -> float
#let funny-sqrt(x) = { calc.sqrt(x) }

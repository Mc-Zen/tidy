#import "funny-math-complex.typ": *


/// This function computes the sine $sin(x)$ of $x$. 
///
/// See also @@funny-sqrt() for computing square roots. 
///
/// -> float
#let funny-sin(
  /// Angle for the sine function. -> float
  phi
) = { calc.sqrt(phi) }




/// This function computes the square root $sqrt(x)$ of it's argument.
///
///
/// === Example
/// ```example
/// #funny-math.funny-sqrt(12)
/// ```
///
///
/// -> float
#let funny-sqrt(
  /// Argument to take the square root of. For $x=0$, the result is $0$: 
  /// ```example
  /// #funny-math.funny-sqrt(0)
  /// ```
  /// -> float | x
  x
) = { calc.sqrt(x) }

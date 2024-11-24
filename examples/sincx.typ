/// This function computes the cardinal sine, $sinc(x)=sin(x)/x$. 
///
/// ```example
/// #sinc(0)
/// ```
///
/// -> float
#let sinc(
  /// The argument for the cardinal sine function. 
  /// -> int | float
  x
) = if x == 0 {1} else {calc.sin(x) / x}
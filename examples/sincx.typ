/// This function computes the cardinal sine, $sinc(x)=sin(x)/x$. 
///
/// #example(`#sinc(0)`, mode: "markup")
///
/// - x (int, float): The argument for the cardinal sine function. 
/// -> float
#let sinc(x) = if x == 0 {1} else {calc.sin(x) / x}
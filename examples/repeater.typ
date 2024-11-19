/// Repeats content a specified number of times. 
/// -> content
#let repeat(
  /// The content to repeat. -> content
  body, 

  ///  Number of times to repeat the content. -> int
  num, 
  
  /// Optional separator between repetitions of the content. -> content
  separator: []
) = ((body,)*num).join(separator)

/// An awfully bad approximation of pi. 
/// -> float
#let awful-pi = 3.14
/// Repeats content a specified number of times. 
/// - body (content): The content to repeat. 
/// - num (int):  Number of times to repeat the content. 
/// - separator (content): Optional separator between repetitions 
///                        of the content. 
/// -> content
#let repeat(body, num, separator: []) = ((body,)*num).join(separator)

/// An awfully bad approximation of pi. 
/// -> float
#let awful-pi = 3.14
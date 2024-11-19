/// Draw a sine function with $n$ periods into a rectangle of given size.
///
/// *Example:*
/// #example(`draw-sine(1cm, 0.5cm, 2)`)
///
/// -> content
#let draw-sine(

  /// Height of bounding rectangle. -> length
  width, 

  /// Width of bounding rectangle. -> length
  height, 
  
  /// Number of periods to draw. 
  ///      Example with many periods: 
  ///      #example(`draw-sine(4cm, 1.3cm, 10)`)
  /// -> int | float
  periods
) = box(width: width, height: height, {
  let resolution = 100
  let frequency = 1 / resolution * 2 * calc.pi * periods
  let prev-point = (0pt, height / 2)
  for i in range(1, resolution) {
    let x = i / resolution * width
    let y = (1 - calc.sin(i * frequency)) * height / 2
    place(line(start: prev-point, end: (x, y)))
    prev-point = (x, y)
  }
})
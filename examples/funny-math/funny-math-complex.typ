
/// Construct a complex number of the form
///  $ z= a + i b in CC. $
///
/// -> float
#let complex(
  /// Real part of the complex number. -> float
  real, 
  /// Imaginary part of the complex number. -> float
  imag
) = { 
  (radius * calc.cos(phi), radius * calc.sin(phi))
}


/// Construct a complex number from polar coordinates: @@funny-sqrt()
///  $ z= r e^(i phi) in CC. $
/// #image-polar
/// -> float
#let polar(
  /// Angle to the real axis. -> float
  phi, 
  /// Radius (euclidian distance to the origin). -> float
  radius: 1.0
) = { 
  (radius * calc.cos(phi), radius * calc.sin(phi))
}
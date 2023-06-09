
/// Construct a complex number of the form
///  $ z= a + i b in CC. $
/// - real (float): Real part of the complex number. 
/// - imag (float): Imaginary part of the complex number. 
/// -> float
#let complex(real, imag) = { 
  (radius * calc.cos(phi), radius * calc.sin(phi))
}


/// Construct a complex number from polar coordinates:
///  $ z= r e^(i phi) in CC. $
/// - phi (float): Angle to the real axis. 
/// - radius (float): Radius (euclidian distance to the origin). 
/// -> float
#let polar(phi, radius: 1.0) = { 
  (radius * calc.cos(phi), radius * calc.sin(phi))
}
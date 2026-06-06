///|
pub impl Sqrt for Double with fn sqrt(x) -> Double {
  @km.sqrt(x)
}

///|
pub impl Cbrt for Double with fn cbrt(x) -> Double {
  @km.cbrt(x)
}

///|
pub impl Exponential for Double with fn exp(x) -> Double {
  @km.exp(x)
}

///|
pub impl Exponential for Double with fn exp2(x) -> Double {
  @km.exp2(x)
}

///|
pub impl Logarithmic for Double with fn ln(x) -> Double {
  @km.log(x)
}

///|
pub impl Logarithmic for Double with fn log2(x) -> Double {
  @km.log2(x)
}

///|
pub impl Logarithmic for Double with fn log10(x) -> Double {
  @km.log10(x)
}

///|
pub impl Power for Double with fn pow(base, exponent) -> Double {
  @km.pow(base, exponent)
}

///|
pub impl Trigonometric for Double with fn sin(x) -> Double {
  @km.sin(x)
}

///|
pub impl Trigonometric for Double with fn cos(x) -> Double {
  @km.cos(x)
}

///|
pub impl Trigonometric for Double with fn tan(x) -> Double {
  @km.tan(x)
}

///|
pub impl InverseTrigonometric for Double with fn asin(x) -> Double {
  @km.asin(x)
}

///|
pub impl InverseTrigonometric for Double with fn acos(x) -> Double {
  @km.acos(x)
}

///|
pub impl InverseTrigonometric for Double with fn atan(x) -> Double {
  @km.atan(x)
}

///|
pub impl InverseTrigonometric for Double with fn atan2(y, x) -> Double {
  @km.atan2(y, x)
}

///|
pub impl Hyperbolic for Double with fn sinh(x) -> Double {
  @km.sinh(x)
}

///|
pub impl Hyperbolic for Double with fn cosh(x) -> Double {
  @km.cosh(x)
}

///|
pub impl Hyperbolic for Double with fn tanh(x) -> Double {
  @km.tanh(x)
}

///|
pub impl InverseHyperbolic for Double with fn asinh(x) -> Double {
  @km.asinh(x)
}

///|
pub impl InverseHyperbolic for Double with fn acosh(x) -> Double {
  @km.acosh(x)
}

///|
pub impl InverseHyperbolic for Double with fn atanh(x) -> Double {
  @km.atanh(x)
}

///|
pub impl Constants for Double with fn pi() -> Double {
  @math.PI
}

///|
pub impl Constants for Double with fn tau() -> Double {
  @math.PI * 2.0
}

///|
pub impl Constants for Double with fn e() -> Double {
  @km.exp(1.0)
}

///|
pub impl Radical for Double

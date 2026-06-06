///|
pub impl Sqrt for Float with fn sqrt(x) -> Float {
  @km.sqrtf(x)
}

///|
pub impl Cbrt for Float with fn cbrt(x) -> Float {
  @km.cbrtf(x)
}

///|
pub impl Exponential for Float with fn exp(x) -> Float {
  @km.expf(x)
}

///|
pub impl Exponential for Float with fn exp2(x) -> Float {
  @km.powf(2.0, x)
}

///|
pub impl Logarithmic for Float with fn ln(x) -> Float {
  @km.logf(x)
}

///|
pub impl Logarithmic for Float with fn log2(x) -> Float {
  @km.log2f(x)
}

///|
pub impl Logarithmic for Float with fn log10(x) -> Float {
  @km.log10f(x)
}

///|
pub impl Power for Float with fn pow(base, exponent) -> Float {
  @km.powf(base, exponent)
}

///|
pub impl Trigonometric for Float with fn sin(x) -> Float {
  @km.sinf(x)
}

///|
pub impl Trigonometric for Float with fn cos(x) -> Float {
  @km.cosf(x)
}

///|
pub impl Trigonometric for Float with fn tan(x) -> Float {
  @km.tanf(x)
}

///|
pub impl InverseTrigonometric for Float with fn asin(x) -> Float {
  @km.asinf(x)
}

///|
pub impl InverseTrigonometric for Float with fn acos(x) -> Float {
  @km.acosf(x)
}

///|
pub impl InverseTrigonometric for Float with fn atan(x) -> Float {
  @km.atanf(x)
}

///|
pub impl InverseTrigonometric for Float with fn atan2(y, x) -> Float {
  @km.atan2f(y, x)
}

///|
pub impl Hyperbolic for Float with fn sinh(x) -> Float {
  @km.sinhf(x)
}

///|
pub impl Hyperbolic for Float with fn cosh(x) -> Float {
  @km.coshf(x)
}

///|
pub impl Hyperbolic for Float with fn tanh(x) -> Float {
  @km.tanhf(x)
}

///|
pub impl InverseHyperbolic for Float with fn asinh(x) -> Float {
  @km.asinhf(x)
}

///|
pub impl InverseHyperbolic for Float with fn acosh(x) -> Float {
  @km.acoshf(x)
}

///|
pub impl InverseHyperbolic for Float with fn atanh(x) -> Float {
  @km.atanhf(x)
}

///|
pub impl Constants for Float with fn pi() -> Float {
  Float::from_double(@math.PI)
}

///|
pub impl Constants for Float with fn tau() -> Float {
  Float::from_double(@math.PI * 2.0)
}

///|
pub impl Constants for Float with fn e() -> Float {
  @km.expf(1.0)
}

///|
pub impl Radical for Float

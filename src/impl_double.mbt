///|
fn double_is_nan(x : Double) -> Bool {
  x != x
}

///|
fn double_pow_nat(base : Double, exponent : UInt) -> Double {
  let mut exp = exponent
  let mut acc : Double = 1.0
  let mut factor = base
  while exp > 0U {
    if (exp & 1U) == 1U {
      acc = acc * factor
    }
    exp = exp >> 1
    if exp > 0U {
      factor = factor * factor
    }
  }
  acc
}

///|
fn double_int_abs_magnitude_as_uint(exponent : Int) -> UInt {
  if exponent >= 0 {
    exponent.reinterpret_as_uint()
  } else {
    (-(exponent + 1)).reinterpret_as_uint() + 1U
  }
}

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

///|
pub impl SqrtChecked for Double with fn sqrt_checked(x, _ctx) -> Result[
  Double,
  ArithmeticError,
] {
  guard x >= 0.0 || double_is_nan(x) else {
    return Err(
      ArithmeticError::domain_error(
        "square root is undefined for negative real inputs",
      ),
    )
  }
  Ok(Sqrt::sqrt(x))
}

///|
pub impl DivChecked for Double with fn div_checked(lhs, rhs, _ctx) -> Result[
  Double,
  ArithmeticError,
] {
  guard rhs != 0.0 else {
    return Err(ArithmeticError::division_by_zero("division by zero"))
  }
  Ok(lhs / rhs)
}

///|
pub impl CompareChecked for Double with fn compare_checked(lhs, rhs) -> Result[
  Int,
  ArithmeticError,
] {
  guard !double_is_nan(lhs) && !double_is_nan(rhs) else {
    return Err(ArithmeticError::unordered_comparison("NaN is unordered"))
  }
  Ok(if lhs < rhs { -1 } else if lhs > rhs { 1 } else { 0 })
}

///|
pub impl PowNatChecked for Double with fn pow_nat_checked(base, exponent, _ctx) -> Result[
  Double,
  ArithmeticError,
] {
  Ok(double_pow_nat(base, exponent))
}

///|
pub impl PowIntChecked for Double with fn pow_int_checked(base, exponent, ctx) -> Result[
  Double,
  ArithmeticError,
] {
  if exponent == 0 {
    return Ok(1.0)
  }
  if exponent < 0 {
    guard base != 0.0 else {
      return Err(
        ArithmeticError::division_by_zero(
          "negative exponent requires a non-zero base",
        ),
      )
    }
    let positive = double_pow_nat(
      base,
      double_int_abs_magnitude_as_uint(exponent),
    )
    return DivChecked::div_checked(1.0, positive, ctx)
  }
  PowNatChecked::pow_nat_checked(
    base,
    double_int_abs_magnitude_as_uint(exponent),
    ctx,
  )
}

///|
pub impl AddContextual for Double with fn add_contextual(left, right, _context) {
  Ok(ArithmeticOutcome::exact(left + right))
}

///|
pub impl SubContextual for Double with fn sub_contextual(left, right, _context) {
  Ok(ArithmeticOutcome::exact(left - right))
}

///|
pub impl MulContextual for Double with fn mul_contextual(left, right, _context) {
  Ok(ArithmeticOutcome::exact(left * right))
}

///|
pub impl DivContextual for Double with fn div_contextual(left, right, context) {
  DivChecked::div_checked(left, right, context).map(ArithmeticOutcome::exact)
}

///|
pub impl AbsContextual for Double with fn abs_contextual(value, _context) {
  Ok(ArithmeticOutcome::exact(value.abs()))
}

///|
pub impl SqrtContextual for Double with fn sqrt_contextual(value, context) {
  SqrtChecked::sqrt_checked(value, context).map(ArithmeticOutcome::exact)
}

///|
pub impl ExpContextual for Double with fn exp_contextual(value, _context) {
  Ok(ArithmeticOutcome::exact(Exponential::exp(value)))
}

///|
pub impl IntegralContextual for Double with fn from_int_contextual(
  value,
  _context,
) {
  Ok(ArithmeticOutcome::exact(Double::from_int(value)))
}

///|
fn double_next_plus(value : Double) -> Double {
  if Double::is_nan(value) || Double::is_pos_inf(value) {
    return value
  }
  if value == 0.0 {
    return 1UL.reinterpret_as_double()
  }
  let bits = value.reinterpret_as_uint64()
  if value > 0.0 {
    (bits + 1UL).reinterpret_as_double()
  } else {
    (bits - 1UL).reinterpret_as_double()
  }
}

///|
fn double_next_minus(value : Double) -> Double {
  if Double::is_nan(value) || Double::is_neg_inf(value) {
    return value
  }
  if value == 0.0 {
    return 0x8000_0000_0000_0001UL.reinterpret_as_double()
  }
  let bits = value.reinterpret_as_uint64()
  if value > 0.0 {
    (bits - 1UL).reinterpret_as_double()
  } else {
    (bits + 1UL).reinterpret_as_double()
  }
}

///|
pub impl AdjacentContextual for Double with fn next_plus_contextual(
  value,
  _context,
) {
  Ok(ArithmeticOutcome::exact(double_next_plus(value)))
}

///|
pub impl AdjacentContextual for Double with fn next_minus_contextual(
  value,
  _context,
) {
  Ok(ArithmeticOutcome::exact(double_next_minus(value)))
}

///|
pub impl AdjacentContextual for Double with fn next_toward_contextual(
  value,
  target,
  _context,
) {
  let result = if Double::is_nan(value) {
    value
  } else if Double::is_nan(target) || value == target {
    target
  } else if value < target {
    double_next_plus(value)
  } else {
    double_next_minus(value)
  }
  Ok(ArithmeticOutcome::exact(result))
}

///|
pub impl NumericFormatContextual for Double with fn zero_contextual(_context) {
  0.0
}

///|
pub impl NumericFormatContextual for Double with fn one_contextual(_context) {
  1.0
}

///|
pub impl NumericFormatContextual for Double with fn epsilon_contextual(_context) {
  2.220446049250313e-16
}

///|
pub impl NumericFormatContextual for Double with fn min_normal_contextual(
  _context,
) {
  2.2250738585072014e-308
}

///|
pub impl NumericFormatContextual for Double with fn max_finite_contextual(
  _context,
) {
  1.7976931348623157e308
}

///|
pub impl NumericFormatContextual for Double with fn classify_contextual(value) {
  if Double::is_nan(value) {
    FpClass::NaN
  } else if Double::is_inf(value) {
    FpClass::Infinity
  } else {
    FpClass::Finite
  }
}

///|
pub impl AddContextual for Float with fn add_contextual(left, right, _context) {
  Ok(ArithmeticOutcome::exact(left + right))
}

///|
pub impl SubContextual for Float with fn sub_contextual(left, right, _context) {
  Ok(ArithmeticOutcome::exact(left - right))
}

///|
pub impl MulContextual for Float with fn mul_contextual(left, right, _context) {
  Ok(ArithmeticOutcome::exact(left * right))
}

///|
pub impl DivContextual for Float with fn div_contextual(left, right, context) {
  DivChecked::div_checked(left, right, context).map(ArithmeticOutcome::exact)
}

///|
pub impl AbsContextual for Float with fn abs_contextual(value, _context) {
  Ok(ArithmeticOutcome::exact(value.abs()))
}

///|
pub impl SqrtContextual for Float with fn sqrt_contextual(value, context) {
  SqrtChecked::sqrt_checked(value, context).map(ArithmeticOutcome::exact)
}

///|
pub impl ExpContextual for Float with fn exp_contextual(value, _context) {
  Ok(ArithmeticOutcome::exact(Exponential::exp(value)))
}

///|
pub impl IntegralContextual for Float with fn from_int_contextual(
  value,
  _context,
) {
  let converted = Float::from_int(value)
  let exact = converted.to_double() == Double::from_int(value)
  let diagnostics = if exact {
    ArithmeticDiagnostics::empty()
  } else {
    ArithmeticDiagnostics::new(inexact=true, rounded=true)
  }
  Ok(ArithmeticOutcome::with_diagnostics(converted, diagnostics))
}

///|
fn float_next_plus(value : Float) -> Float {
  if Float::is_nan(value) || Float::is_pos_inf(value) {
    return value
  }
  if value == 0.0F {
    return Float::reinterpret_from_uint(1U)
  }
  let bits = value.reinterpret_as_uint()
  if value > 0.0F {
    Float::reinterpret_from_uint(bits + 1U)
  } else {
    Float::reinterpret_from_uint(bits - 1U)
  }
}

///|
fn float_next_minus(value : Float) -> Float {
  if Float::is_nan(value) || Float::is_neg_inf(value) {
    return value
  }
  if value == 0.0F {
    return Float::reinterpret_from_uint(0x8000_0001U)
  }
  let bits = value.reinterpret_as_uint()
  if value > 0.0F {
    Float::reinterpret_from_uint(bits - 1U)
  } else {
    Float::reinterpret_from_uint(bits + 1U)
  }
}

///|
pub impl AdjacentContextual for Float with fn next_plus_contextual(
  value,
  _context,
) {
  Ok(ArithmeticOutcome::exact(float_next_plus(value)))
}

///|
pub impl AdjacentContextual for Float with fn next_minus_contextual(
  value,
  _context,
) {
  Ok(ArithmeticOutcome::exact(float_next_minus(value)))
}

///|
pub impl AdjacentContextual for Float with fn next_toward_contextual(
  value,
  target,
  _context,
) {
  let result = if Float::is_nan(value) {
    value
  } else if Float::is_nan(target) || value == target {
    target
  } else if value < target {
    float_next_plus(value)
  } else {
    float_next_minus(value)
  }
  Ok(ArithmeticOutcome::exact(result))
}

///|
pub impl NumericFormatContextual for Float with fn zero_contextual(_context) {
  0.0F
}

///|
pub impl NumericFormatContextual for Float with fn one_contextual(_context) {
  1.0F
}

///|
pub impl NumericFormatContextual for Float with fn epsilon_contextual(_context) {
  1.1920929e-7F
}

///|
pub impl NumericFormatContextual for Float with fn min_normal_contextual(
  _context,
) {
  1.1754944e-38F
}

///|
pub impl NumericFormatContextual for Float with fn max_finite_contextual(
  _context,
) {
  3.4028235e38F
}

///|
pub impl NumericFormatContextual for Float with fn classify_contextual(value) {
  if Float::is_nan(value) {
    FpClass::NaN
  } else if Float::is_inf(value) {
    FpClass::Infinity
  } else {
    FpClass::Finite
  }
}

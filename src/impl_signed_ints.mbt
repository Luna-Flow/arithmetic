fn int_pow_impl(base : Int, exponent : Int) -> Int {
  guard exponent >= 0 else {
    abort("Power::pow for Int requires a non-negative exponent")
  }
  let mut exp = exponent
  let mut acc = 1
  let mut factor = base
  while exp > 0 {
    if (exp & 1) == 1 {
      acc = acc * factor
    }
    factor = factor * factor
    exp = exp >> 1
  }
  acc
}

fn int16_pow_impl(base : Int16, exponent : Int16) -> Int16 {
  guard exponent >= 0 else {
    abort("Power::pow for Int16 requires a non-negative exponent")
  }
  let mut exp = exponent.to_int()
  let mut acc : Int16 = 1
  let mut factor = base
  while exp > 0 {
    if (exp & 1) == 1 {
      acc = acc * factor
    }
    factor = factor * factor
    exp = exp >> 1
  }
  acc
}

fn int64_pow_impl(base : Int64, exponent : Int64) -> Int64 {
  guard exponent >= 0L else {
    abort("Power::pow for Int64 requires a non-negative exponent")
  }
  let mut exp = exponent
  let mut acc : Int64 = 1L
  let mut factor = base
  while exp > 0L {
    if (exp & 1L) == 1L {
      acc = acc * factor
    }
    factor = factor * factor
    exp = exp >> 1
  }
  acc
}

///|
pub impl Power for Int with fn pow(base, exponent) -> Int {
  int_pow_impl(base, exponent)
}

///|
pub impl Power for Int16 with fn pow(base, exponent) -> Int16 {
  int16_pow_impl(base, exponent)
}

///|
pub impl Power for Int64 with fn pow(base, exponent) -> Int64 {
  int64_pow_impl(base, exponent)
}

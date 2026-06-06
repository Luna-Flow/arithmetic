fn uint_pow_impl(base : UInt, exponent : UInt) -> UInt {
  let mut exp = exponent
  let mut acc : UInt = 1U
  let mut factor = base
  while exp > 0U {
    if (exp & 1U) == 1U {
      acc = acc * factor
    }
    factor = factor * factor
    exp = exp >> 1
  }
  acc
}

fn uint16_pow_impl(base : UInt16, exponent : UInt16) -> UInt16 {
  let mut exp = exponent.to_uint()
  let mut acc : UInt16 = 1
  let mut factor = base
  while exp > 0U {
    if (exp & 1U) == 1U {
      acc = acc * factor
    }
    factor = factor * factor
    exp = exp >> 1
  }
  acc
}

fn uint64_pow_impl(base : UInt64, exponent : UInt64) -> UInt64 {
  let mut exp = exponent
  let mut acc : UInt64 = 1UL
  let mut factor = base
  while exp > 0UL {
    if (exp & 1UL) == 1UL {
      acc = acc * factor
    }
    factor = factor * factor
    exp = exp >> 1
  }
  acc
}

///|
pub impl Power for UInt with fn pow(base, exponent) -> UInt {
  uint_pow_impl(base, exponent)
}

///|
pub impl Power for UInt16 with fn pow(base, exponent) -> UInt16 {
  uint16_pow_impl(base, exponent)
}

///|
pub impl Power for UInt64 with fn pow(base, exponent) -> UInt64 {
  uint64_pow_impl(base, exponent)
}

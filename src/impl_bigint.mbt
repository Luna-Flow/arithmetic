let bigint_zero : BigInt = BigInt::from_int(0)

///|
pub impl Power for BigInt with fn pow(base, exponent) -> BigInt {
  guard exponent >= bigint_zero else {
    abort("Power::pow for BigInt requires a non-negative exponent")
  }
  base.pow(exponent)
}

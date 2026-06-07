/// Square-root capability on `Self`.
///
/// Implementations should return a value of the same type as the input.
/// Domain restrictions, branch choices, and exceptional-value behavior are
/// defined by each concrete instance. This unchecked surface is primarily for
/// native scalars or APIs where context-free IEEE-style behavior is acceptable.

///|
pub(open) trait Sqrt {
  fn sqrt(Self) -> Self
}

/// Cubic-root capability on `Self`.
///
/// Implementations should stay within `Self`. Instance-specific semantics
/// decide how special values and edge cases are handled. This unchecked surface
/// is primarily for native scalars or other context-free backends.

///|
pub(open) trait Cbrt {
  fn cbrt(Self) -> Self
}

/// Combined radical capability for types that support both square root and
/// cubic root.

///|
pub(open) trait Radical: Sqrt + Cbrt {}

/// Exponential-function capability on `Self`.
///
/// `exp` denotes the natural exponential and `exp2` denotes base-2
/// exponentiation. This unchecked surface is mainly intended for native scalar
/// backends or APIs that accept unchecked elementary behavior.

///|
pub(open) trait Exponential {
  fn exp(Self) -> Self
  fn exp2(Self) -> Self
}

/// Logarithm capability on `Self`.
///
/// `ln` is the natural logarithm. Domain validity is the caller's
/// responsibility unless a concrete instance documents stronger guarantees.
/// This unchecked surface is mainly intended for native scalar backends or
/// APIs that accept unchecked elementary behavior.

///|
pub(open) trait Logarithmic {
  fn ln(Self) -> Self
  fn log2(Self) -> Self
  fn log10(Self) -> Self
}

/// Power capability on `Self`.
///
/// This trait intentionally uses a single `pow(base, exponent)` surface across
/// floating and integer families. Concrete instances may impose additional
/// preconditions.
///
/// For the integer-family instances shipped by this package, the exponent must
/// be non-negative. Passing a negative exponent to signed integer or `BigInt`
/// instances aborts at runtime because the result would not stay closed in the
/// same type. This unchecked surface remains available for native scalars and
/// other context-free backends; validated or contextual types should prefer the
/// checked power traits.

///|
pub(open) trait Power {
  fn pow(Self, Self) -> Self
}

/// Circular trigonometric capability on `Self`.
///
/// Angle unit, special-value handling, and branch conventions are defined by
/// each instance backend. This unchecked surface is mainly intended for native
/// scalar backends or APIs that accept unchecked elementary behavior.

///|
pub(open) trait Trigonometric {
  fn sin(Self) -> Self
  fn cos(Self) -> Self
  fn tan(Self) -> Self
}

/// Inverse circular trigonometric capability on `Self`.
///
/// Principal values and branch choices are instance-defined. This unchecked
/// surface is mainly intended for native scalar backends or APIs that accept
/// unchecked elementary behavior.

///|
pub(open) trait InverseTrigonometric {
  fn asin(Self) -> Self
  fn acos(Self) -> Self
  fn atan(Self) -> Self
  fn atan2(Self, Self) -> Self
}

/// Hyperbolic-function capability on `Self`.
///
/// This unchecked surface is mainly intended for native scalar backends or
/// APIs that accept unchecked elementary behavior.

///|
pub(open) trait Hyperbolic {
  fn sinh(Self) -> Self
  fn cosh(Self) -> Self
  fn tanh(Self) -> Self
}

/// Inverse hyperbolic-function capability on `Self`.
///
/// Domain restrictions remain instance-defined. This unchecked surface is
/// mainly intended for native scalar backends or APIs that accept unchecked
/// elementary behavior.

///|
pub(open) trait InverseHyperbolic {
  fn asinh(Self) -> Self
  fn acosh(Self) -> Self
  fn atanh(Self) -> Self
}

/// Standard scalar constants exposed in `Self`.
///
/// This trait only states availability of constants in the target type; it
/// does not impose any broader “real number” semantic bundle. This unchecked
/// surface is mainly intended for native scalar backends and similar
/// context-free APIs.

///|
pub(open) trait Constants {
  fn pi() -> Self
  fn tau() -> Self
  fn e() -> Self
}

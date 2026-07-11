/// Floating-point classification shared at the arithmetic capability boundary.

///|
pub(all) enum FpClass {
  Finite
  Infinity
  NaN
} derive(Eq)

/// Rounding modes shared by checked/contextual arithmetic capabilities.

///|
pub(all) enum RoundingMode {
  ToNearestEven
  TowardZero
  TowardPositive
  TowardNegative
  AwayFromZero
} derive(Eq)

/// Lightweight arithmetic context for checked operations.

///|
pub struct ArithmeticContext {
  precision : Int
  rounding : RoundingMode
  e_min : Int?
  e_max : Int?
  clamp : Bool
} derive(Eq)

/// Structured arithmetic error categories shared across Luna-Flow.

///|
pub enum ArithmeticErrorKind {
  DivisionByZero
  ParseError
  DomainError
  FormatError
  UnsupportedOperation
  UnorderedComparison
} derive(Eq)

/// Structured error returned by checked/contextual arithmetic capabilities.

///|
pub struct ArithmeticError {
  kind : ArithmeticErrorKind
  message : String
} derive(Eq)

///|
pub fn ArithmeticContext::new(
  precision : Int,
  rounding? : RoundingMode = RoundingMode::ToNearestEven,
  e_min? : Int,
  e_max? : Int,
  clamp? : Bool = false,
) -> ArithmeticContext {
  guard e_min is None || e_max is None || e_min.unwrap() <= e_max.unwrap() else {
    abort("ArithmeticContext::new: e_min must not exceed e_max")
  }
  { precision: Int::max(1, precision), rounding, e_min, e_max, clamp }
}

///|
pub fn ArithmeticContext::decimal32() -> ArithmeticContext {
  ArithmeticContext::new(7, e_min=-95, e_max=96, clamp=true)
}

///|
pub fn ArithmeticContext::decimal64() -> ArithmeticContext {
  ArithmeticContext::new(16, e_min=-383, e_max=384, clamp=true)
}

///|
pub fn ArithmeticContext::decimal128() -> ArithmeticContext {
  ArithmeticContext::new(34, e_min=-6143, e_max=6144, clamp=true)
}

///|
pub fn ArithmeticError::division_by_zero(message : String) -> ArithmeticError {
  { kind: ArithmeticErrorKind::DivisionByZero, message }
}

///|
pub fn ArithmeticError::parse_error(message : String) -> ArithmeticError {
  { kind: ArithmeticErrorKind::ParseError, message }
}

///|
pub fn ArithmeticError::domain_error(message : String) -> ArithmeticError {
  { kind: ArithmeticErrorKind::DomainError, message }
}

///|
pub fn ArithmeticError::format_error(message : String) -> ArithmeticError {
  { kind: ArithmeticErrorKind::FormatError, message }
}

///|
pub fn ArithmeticError::unsupported(message : String) -> ArithmeticError {
  { kind: ArithmeticErrorKind::UnsupportedOperation, message }
}

///|
pub fn ArithmeticError::unordered_comparison(
  message : String,
) -> ArithmeticError {
  { kind: ArithmeticErrorKind::UnorderedComparison, message }
}

///|
pub fn ArithmeticError::is_division_by_zero(self : ArithmeticError) -> Bool {
  match self.kind {
    ArithmeticErrorKind::DivisionByZero => true
    _ => false
  }
}

///|
pub fn ArithmeticError::is_parse_error(self : ArithmeticError) -> Bool {
  match self.kind {
    ArithmeticErrorKind::ParseError => true
    _ => false
  }
}

///|
pub fn ArithmeticError::is_domain_error(self : ArithmeticError) -> Bool {
  match self.kind {
    ArithmeticErrorKind::DomainError => true
    _ => false
  }
}

///|
pub fn ArithmeticError::is_format_error(self : ArithmeticError) -> Bool {
  match self.kind {
    ArithmeticErrorKind::FormatError => true
    _ => false
  }
}

///|
pub fn ArithmeticError::is_unsupported(self : ArithmeticError) -> Bool {
  match self.kind {
    ArithmeticErrorKind::UnsupportedOperation => true
    _ => false
  }
}

///|
pub fn ArithmeticError::is_unordered_comparison(self : ArithmeticError) -> Bool {
  match self.kind {
    ArithmeticErrorKind::UnorderedComparison => true
    _ => false
  }
}

/// Checked square-root capability with explicit arithmetic context.
///
/// Domain validity is defined by each concrete `Self`. This trait does not
/// require a real-number ordering, zero comparison, or a universal notion of a
/// negative input. Implementations should report structured domain errors for
/// values that are invalid in their own mathematical domain.

///|
pub(open) trait SqrtChecked {
  fn sqrt_checked(Self, ArithmeticContext) -> Result[Self, ArithmeticError]
}

/// Checked division capability with explicit arithmetic context.
///
/// Invalid division is defined by each concrete `Self`. This trait does not
/// require IEEE floating-point values, infinities, NaN, or a scalar total
/// order. Implementations should use structured errors for division cases that
/// are invalid in their own mathematical domain.

///|
pub(open) trait DivChecked {
  fn div_checked(Self, Self, ArithmeticContext) -> Result[Self, ArithmeticError]
}

/// Checked scalar comparison capability.
///
/// Implementations return `-1`, `0`, or `1` on ordered inputs and a structured
/// error when no scalar ordering is available.

///|
pub(open) trait CompareChecked {
  fn compare_checked(Self, Self) -> Result[Int, ArithmeticError]
}

/// Checked non-negative integer power capability.
///
/// `x^0` returns the multiplicative identity in this first checked-power layer,
/// including `0^0`.

///|
pub(open) trait PowNatChecked {
  fn pow_nat_checked(Self, UInt, ArithmeticContext) -> Result[
    Self,
    ArithmeticError,
  ]
}

/// Checked signed integer power capability.
///
/// Negative exponents require reciprocal/division semantics. Zero base with a
/// negative exponent must report a structured error or a documented enclosure
/// fallback rather than silently producing an invalid scalar result.

///|
pub(open) trait PowIntChecked {
  fn pow_int_checked(Self, Int, ArithmeticContext) -> Result[
    Self,
    ArithmeticError,
  ]
}

/// Checked parse capability parameterized by an arithmetic context.

///|
pub(open) trait ParseChecked {
  fn parse_checked(String, ArithmeticContext) -> Result[Self, ArithmeticError]
}

/// Enclosure containment relation.

///|
pub(open) trait Contains {
  fn contains(Self, Self) -> Bool
}

/// Enclosure overlap relation.

///|
pub(open) trait Overlaps {
  fn overlaps(Self, Self) -> Bool
}

/// Definite less-than relation for enclosure-like values.

///|
pub(open) trait DefinitelyLt {
  fn definitely_lt(Self, Self) -> Bool
}

/// Definite less-or-equal relation for enclosure-like values.

///|
pub(open) trait DefinitelyLe {
  fn definitely_le(Self, Self) -> Bool
}

/// Maybe-equal relation for enclosure-like values.

///|
pub(open) trait MaybeEq {
  fn maybe_eq(Self, Self) -> Bool
}

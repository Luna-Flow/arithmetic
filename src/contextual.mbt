///|
pub struct ArithmeticDiagnostics {
  inexact : Bool
  rounded : Bool
  overflow : Bool
  underflow : Bool
  subnormal : Bool
  clamped : Bool
} derive(Eq, Debug)

///|
pub fn ArithmeticDiagnostics::empty() -> ArithmeticDiagnostics {
  {
    inexact: false,
    rounded: false,
    overflow: false,
    underflow: false,
    subnormal: false,
    clamped: false,
  }
}

///|
pub fn ArithmeticDiagnostics::new(
  inexact? : Bool = false,
  rounded? : Bool = false,
  overflow? : Bool = false,
  underflow? : Bool = false,
  subnormal? : Bool = false,
  clamped? : Bool = false,
) -> ArithmeticDiagnostics {
  { inexact, rounded, overflow, underflow, subnormal, clamped }
}

///|
pub fn ArithmeticDiagnostics::combine(
  self : ArithmeticDiagnostics,
  other : ArithmeticDiagnostics,
) -> ArithmeticDiagnostics {
  {
    inexact: self.inexact || other.inexact,
    rounded: self.rounded || other.rounded,
    overflow: self.overflow || other.overflow,
    underflow: self.underflow || other.underflow,
    subnormal: self.subnormal || other.subnormal,
    clamped: self.clamped || other.clamped,
  }
}

///|
pub struct ArithmeticOutcome[T] {
  value : T
  diagnostics : ArithmeticDiagnostics
} derive(Eq, Debug)

///|
pub fn[T] ArithmeticOutcome::exact(value : T) -> ArithmeticOutcome[T] {
  { value, diagnostics: ArithmeticDiagnostics::empty() }
}

///|
pub fn[T] ArithmeticOutcome::with_diagnostics(
  value : T,
  diagnostics : ArithmeticDiagnostics,
) -> ArithmeticOutcome[T] {
  { value, diagnostics }
}

///|
pub(open) trait AddContextual {
  fn add_contextual(Self, Self, ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
}

///|
pub(open) trait SubContextual {
  fn sub_contextual(Self, Self, ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
}

///|
pub(open) trait MulContextual {
  fn mul_contextual(Self, Self, ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
}

///|
pub(open) trait DivContextual {
  fn div_contextual(Self, Self, ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
}

///|
pub(open) trait AbsContextual {
  fn abs_contextual(Self, ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
}

///|
pub(open) trait SqrtContextual {
  fn sqrt_contextual(Self, ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
}

///|
pub(open) trait ExpContextual {
  fn exp_contextual(Self, ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
}

/// MoonBit `Int` embedding under an explicit arithmetic context.
///
/// Implementations report successful rounding or range conditions through the
/// returned diagnostics. A backend may reject an unsupported context with a
/// structured arithmetic error. Wider or arbitrary-precision integer sources
/// require separate capabilities rather than changing this trait's source type.

///|
pub(open) trait IntegralContextual {
  fn from_int_contextual(Int, ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
}

/// Adjacent representable values under an explicit arithmetic context.
///
/// `next_plus_contextual` and `next_minus_contextual` move by one representable
/// value in the corresponding direction. `next_toward_contextual` selects the
/// direction from its second operand. Equal values do not step; implementations
/// preserve the target sign when both operands are zero.
///
/// Fixed-format backends may treat selecting an adjacent value as exact and
/// return empty diagnostics. Backends whose representable set depends on the
/// context report any rounding or range conditions through the outcome.

///|
pub(open) trait AdjacentContextual {
  fn next_plus_contextual(Self, ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
  fn next_minus_contextual(Self, ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
  fn next_toward_contextual(Self, Self, ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
}

/// Context-dependent mathematical constants.
///
/// Implementations should expose this capability only when they honor the
/// supplied context and can report meaningful diagnostics. Proof-backed
/// implementations may return an `ArithmeticError` whose kind is
/// `ArithmeticErrorKind::CertificationFailure` when target rounding cannot be
/// certified.

///|
pub(open) trait ConstantsContextual {
  fn pi_contextual(ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
  fn tau_contextual(ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
  fn e_contextual(ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
}

/// Context-dependent hyperbolic functions.
///
/// Implementations should expose this capability only when they honor the
/// supplied context and can report meaningful diagnostics or structured
/// failures.

///|
pub(open) trait HyperbolicContextual {
  fn sinh_contextual(Self, ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
  fn cosh_contextual(Self, ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
  fn tanh_contextual(Self, ArithmeticContext) -> Result[
    ArithmeticOutcome[Self],
    ArithmeticError,
  ]
}

///|
pub(open) trait NumericFormatContextual {
  fn zero_contextual(ArithmeticContext) -> Self
  fn one_contextual(ArithmeticContext) -> Self
  fn epsilon_contextual(ArithmeticContext) -> Self
  fn min_normal_contextual(ArithmeticContext) -> Self
  fn max_finite_contextual(ArithmeticContext) -> Self
  fn classify_contextual(Self) -> FpClass
}

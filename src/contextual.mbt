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

///|
pub(open) trait NumericFormatContextual {
  fn zero_contextual(ArithmeticContext) -> Self
  fn one_contextual(ArithmeticContext) -> Self
  fn epsilon_contextual(ArithmeticContext) -> Self
  fn min_normal_contextual(ArithmeticContext) -> Self
  fn max_finite_contextual(ArithmeticContext) -> Self
  fn classify_contextual(Self) -> FpClass
}

// Explicit trait-method promotions (see core AGENTS.md "Trait-method promotion").

///|
pub extend FpClass with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend FpClass with Eq::{not_equal}

///|
#deprecated("Use `Repr(x)` or `@debug.Debug::to_repr` instead", skip_current_package=true)
#doc(hidden)
pub extend FpClass with @debug.Debug::{to_repr}

///|
pub extend RoundingMode with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend RoundingMode with Eq::{not_equal}

///|
pub extend ArithmeticContext with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend ArithmeticContext with Eq::{not_equal}

///|
pub extend CertificationStage with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend CertificationStage with Eq::{not_equal}

///|
pub extend CertificationFailureReason with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend CertificationFailureReason with Eq::{not_equal}

///|
pub extend CertificationFailureDetail with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend CertificationFailureDetail with Eq::{not_equal}

///|
pub extend ArithmeticErrorKind with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend ArithmeticErrorKind with Eq::{not_equal}

///|
pub extend ArithmeticError with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend ArithmeticError with Eq::{not_equal}

///|
pub extend ArithmeticDiagnostics with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend ArithmeticDiagnostics with Eq::{not_equal}

///|
#deprecated("Use `Repr(x)` or `@debug.Debug::to_repr` instead", skip_current_package=true)
#doc(hidden)
pub extend ArithmeticDiagnostics with @debug.Debug::{to_repr}

///|
pub extend ArithmeticOutcome with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend ArithmeticOutcome with Eq::{not_equal}

///|
#deprecated("Use `Repr(x)` or `@debug.Debug::to_repr` instead", skip_current_package=true)
#doc(hidden)
pub extend ArithmeticOutcome with @debug.Debug::{to_repr}

///|
let contextual_test_context : ArithmeticContext = ArithmeticContext::new(16)

///|
enum UncertifiedConstant {
  Value
}

///|
enum ExactHyperbolicValue {
  Zero
  One
} derive(Eq, Debug)

///|
fn uncertified_constant(
  operation : String,
  context : ArithmeticContext,
) -> Result[ArithmeticOutcome[UncertifiedConstant], ArithmeticError] {
  Err(
    ArithmeticError::certification_failure(
      CertificationFailureDetail::new(
        operation,
        CertificationStage::TargetRounding,
        CertificationFailureReason::RefinementBudgetExhausted,
        context.precision,
        context.precision * 2,
        1,
      ),
    ),
  )
}

///|
impl ConstantsContextual for UncertifiedConstant with fn pi_contextual(context) {
  uncertified_constant("pi", context)
}

///|
impl ConstantsContextual for UncertifiedConstant with fn tau_contextual(context) {
  uncertified_constant("tau", context)
}

///|
impl ConstantsContextual for UncertifiedConstant with fn e_contextual(context) {
  uncertified_constant("e", context)
}

///|
impl HyperbolicContextual for ExactHyperbolicValue with fn sinh_contextual(
  value,
  _context,
) {
  Ok(ArithmeticOutcome::exact(value))
}

///|
impl HyperbolicContextual for ExactHyperbolicValue with fn cosh_contextual(
  _value,
  _context,
) {
  Ok(ArithmeticOutcome::exact(ExactHyperbolicValue::One))
}

///|
impl HyperbolicContextual for ExactHyperbolicValue with fn tanh_contextual(
  value,
  _context,
) {
  Ok(ArithmeticOutcome::exact(value))
}

///|
test "integral contextual reports native float rounding" {
  let exact : ArithmeticOutcome[Float] = IntegralContextual::from_int_contextual(
    16_777_216, contextual_test_context,
  ).unwrap()
  @test.assert_eq(exact.value, 16_777_216.0F)
  @test.assert_eq(exact.diagnostics.inexact, false)
  @test.assert_eq(exact.diagnostics.rounded, false)
  let rounded : ArithmeticOutcome[Float] = IntegralContextual::from_int_contextual(
    16_777_217, contextual_test_context,
  ).unwrap()
  @test.assert_eq(rounded.value, 16_777_216.0F)
  @test.assert_eq(rounded.diagnostics.inexact, true)
  @test.assert_eq(rounded.diagnostics.rounded, true)
  let max_rounded : ArithmeticOutcome[Float] = IntegralContextual::from_int_contextual(
    2_147_483_647, contextual_test_context,
  ).unwrap()
  @test.assert_eq(max_rounded.diagnostics.inexact, true)
  @test.assert_eq(max_rounded.diagnostics.rounded, true)
  let double : ArithmeticOutcome[Double] = IntegralContextual::from_int_contextual(
    2_147_483_647, contextual_test_context,
  ).unwrap()
  @test.assert_eq(double.value, 2_147_483_647.0)
  @test.assert_eq(double.diagnostics, ArithmeticDiagnostics::empty())
}

///|
test "double adjacent contextual follows ieee boundaries" {
  let plus_zero : ArithmeticOutcome[Double] = AdjacentContextual::next_plus_contextual(
    -0.0, contextual_test_context,
  ).unwrap()
  @test.assert_eq(plus_zero.value.reinterpret_as_uint64(), 1UL)
  let minus_zero : ArithmeticOutcome[Double] = AdjacentContextual::next_minus_contextual(
    0.0, contextual_test_context,
  ).unwrap()
  @test.assert_eq(
    minus_zero.value.reinterpret_as_uint64(),
    0x8000_0000_0000_0001UL,
  )
  let above_one : ArithmeticOutcome[Double] = AdjacentContextual::next_plus_contextual(
    1.0, contextual_test_context,
  ).unwrap()
  @test.assert_eq(
    above_one.value.reinterpret_as_uint64(),
    0x3ff0_0000_0000_0001UL,
  )
  let positive_infinity = 1.0 / 0.0
  let below_infinity : ArithmeticOutcome[Double] = AdjacentContextual::next_minus_contextual(
    positive_infinity, contextual_test_context,
  ).unwrap()
  @test.assert_eq(
    below_infinity.value.reinterpret_as_uint64(),
    0x7fef_ffff_ffff_ffffUL,
  )
  let max_finite = 0x7fef_ffff_ffff_ffffUL.reinterpret_as_double()
  let above_max : ArithmeticOutcome[Double] = AdjacentContextual::next_plus_contextual(
    max_finite, contextual_test_context,
  ).unwrap()
  @test.assert_eq(
    above_max.value.reinterpret_as_uint64(),
    0x7ff0_0000_0000_0000UL,
  )
  @test.assert_eq(above_max.diagnostics, ArithmeticDiagnostics::empty())
  let negative_infinity = -1.0 / 0.0
  let above_negative_infinity : ArithmeticOutcome[Double] = AdjacentContextual::next_plus_contextual(
    negative_infinity, contextual_test_context,
  ).unwrap()
  @test.assert_eq(
    above_negative_infinity.value.reinterpret_as_uint64(),
    0xffef_ffff_ffff_ffffUL,
  )
  let min_subnormal = 1UL.reinterpret_as_double()
  let below_min_subnormal : ArithmeticOutcome[Double] = AdjacentContextual::next_minus_contextual(
    min_subnormal, contextual_test_context,
  ).unwrap()
  @test.assert_eq(below_min_subnormal.value.reinterpret_as_uint64(), 0UL)
  let negative_min_subnormal = 0x8000_0000_0000_0001UL.reinterpret_as_double()
  let above_negative_min_subnormal : ArithmeticOutcome[Double] = AdjacentContextual::next_plus_contextual(
    negative_min_subnormal, contextual_test_context,
  ).unwrap()
  @test.assert_eq(
    above_negative_min_subnormal.value.reinterpret_as_uint64(),
    0x8000_0000_0000_0000UL,
  )
}

///|
test "float adjacent contextual follows ieee boundaries" {
  let plus_zero : ArithmeticOutcome[Float] = AdjacentContextual::next_plus_contextual(
    -0.0F,
    contextual_test_context,
  ).unwrap()
  @test.assert_eq(plus_zero.value.reinterpret_as_uint(), 1U)
  let minus_zero : ArithmeticOutcome[Float] = AdjacentContextual::next_minus_contextual(
    0.0F, contextual_test_context,
  ).unwrap()
  @test.assert_eq(minus_zero.value.reinterpret_as_uint(), 0x8000_0001U)
  let max_finite = Float::reinterpret_from_uint(0x7f7f_ffffU)
  let above_max : ArithmeticOutcome[Float] = AdjacentContextual::next_plus_contextual(
    max_finite, contextual_test_context,
  ).unwrap()
  @test.assert_eq(above_max.value.reinterpret_as_uint(), 0x7f80_0000U)
  let negative_infinity = -1.0F / 0.0F
  let stationary_negative_infinity : ArithmeticOutcome[Float] = AdjacentContextual::next_minus_contextual(
    negative_infinity, contextual_test_context,
  ).unwrap()
  @test.assert_eq(
    stationary_negative_infinity.value.reinterpret_as_uint(),
    0xff80_0000U,
  )
  let min_subnormal = Float::reinterpret_from_uint(1U)
  let below_min_subnormal : ArithmeticOutcome[Float] = AdjacentContextual::next_minus_contextual(
    min_subnormal, contextual_test_context,
  ).unwrap()
  @test.assert_eq(below_min_subnormal.value.reinterpret_as_uint(), 0U)
}

///|
test "next toward preserves direction zero sign and nan" {
  let negative_zero : ArithmeticOutcome[Double] = AdjacentContextual::next_toward_contextual(
    0.0, -0.0, contextual_test_context,
  ).unwrap()
  @test.assert_eq(
    negative_zero.value.reinterpret_as_uint64(),
    0x8000_0000_0000_0000UL,
  )
  let toward_two : ArithmeticOutcome[Float] = AdjacentContextual::next_toward_contextual(
    1.0F, 2.0F, contextual_test_context,
  ).unwrap()
  @test.assert_eq(toward_two.value.reinterpret_as_uint(), 0x3f80_0001U)
  let toward_zero : ArithmeticOutcome[Float] = AdjacentContextual::next_toward_contextual(
    Float::reinterpret_from_uint(1U),
    0.0F,
    contextual_test_context,
  ).unwrap()
  @test.assert_eq(toward_zero.value.reinterpret_as_uint(), 0U)
  let source_nan = 0.0 / 0.0
  let from_nan : ArithmeticOutcome[Double] = AdjacentContextual::next_toward_contextual(
    source_nan, 1.0, contextual_test_context,
  ).unwrap()
  @test.assert_eq(Double::is_nan(from_nan.value), true)
  let nan = 0.0F / 0.0F
  let toward_nan : ArithmeticOutcome[Float] = AdjacentContextual::next_toward_contextual(
    1.0F, nan, contextual_test_context,
  ).unwrap()
  @test.assert_eq(Float::is_nan(toward_nan.value), true)
  @test.assert_eq(toward_nan.diagnostics, ArithmeticDiagnostics::empty())
}

///|
test "contextual hyperbolic trait preserves outcomes" {
  let sinh : ArithmeticOutcome[ExactHyperbolicValue] = HyperbolicContextual::sinh_contextual(
    ExactHyperbolicValue::Zero,
    contextual_test_context,
  ).unwrap()
  let cosh : ArithmeticOutcome[ExactHyperbolicValue] = HyperbolicContextual::cosh_contextual(
    ExactHyperbolicValue::Zero,
    contextual_test_context,
  ).unwrap()
  let tanh : ArithmeticOutcome[ExactHyperbolicValue] = HyperbolicContextual::tanh_contextual(
    ExactHyperbolicValue::Zero,
    contextual_test_context,
  ).unwrap()
  @test.assert_eq(sinh.value, ExactHyperbolicValue::Zero)
  @test.assert_eq(cosh.value, ExactHyperbolicValue::One)
  @test.assert_eq(tanh.value, ExactHyperbolicValue::Zero)
  @test.assert_eq(sinh.diagnostics, ArithmeticDiagnostics::empty())
}

///|
test "contextual constants preserve certification failures" {
  let _marker = UncertifiedConstant::Value
  let result : Result[ArithmeticOutcome[UncertifiedConstant], ArithmeticError] = ConstantsContextual::pi_contextual(
    ArithmeticContext::new(19),
  )
  match result {
    Ok(_) => fail("expected certification failure")
    Err(error) => {
      @test.assert_eq(error.is_certification_failure(), true)
      let detail = error.certification_failure_detail().unwrap()
      @test.assert_eq(detail.operation(), "pi")
      @test.assert_eq(detail.target_precision(), 19)
    }
  }
}

///|
using @test {assert_eq}

///|
using @lf_alg {trait AddMonoid, trait Num, trait Zero}

///|
let float_eps : Float = 0.0000001

///|
let double_eps : Double = 0.00000000001

///|
let default_ctx : @arithmetic.ArithmeticContext = @arithmetic.ArithmeticContext::new(
  32,
)

///|
fn[T : AddMonoid] add_identity(x : T) -> T {
  x + Zero::zero()
}

///|
fn[T : Add + Mul + Sqrt] hypot2(x : T, y : T) -> T {
  @arithmetic.Sqrt::sqrt(x * x + y * y)
}

///|
fn[T : Cbrt] cube_root(x : T) -> T {
  @arithmetic.Cbrt::cbrt(x)
}

///|
fn[T : Trigonometric] unit_circle_x(theta : T) -> T {
  @arithmetic.Trigonometric::cos(theta)
}

///|
fn[T : PowNatChecked] square_checked(
  x : T,
  ctx : @arithmetic.ArithmeticContext,
) -> Result[T, @arithmetic.ArithmeticError] {
  @arithmetic.PowNatChecked::pow_nat_checked(x, 2U, ctx)
}

///|
fn[T : PowIntChecked] reciprocal_power_checked(
  x : T,
  exponent : Int,
  ctx : @arithmetic.ArithmeticContext,
) -> Result[T, @arithmetic.ArithmeticError] {
  @arithmetic.PowIntChecked::pow_int_checked(x, exponent, ctx)
}

///|
fn[T : SqrtChecked] sqrt_checked_generic(
  x : T,
  ctx : @arithmetic.ArithmeticContext,
) -> Result[T, @arithmetic.ArithmeticError] {
  @arithmetic.SqrtChecked::sqrt_checked(x, ctx)
}

///|
fn approx_eq_float(a : Float, b : Float) -> Bool {
  Num::abs(a - b) <= float_eps
}

///|
fn approx_eq_double(a : Double, b : Double) -> Bool {
  Num::abs(a - b) <= double_eps
}

///|
test "capability traits compile for float and double" {
  assert_eq(add_identity((3.0 : Float)), (3.0 : Float))
  assert_eq(add_identity((3.0 : Double)), (3.0 : Double))
  assert_eq(
    approx_eq_float(hypot2((3.0 : Float), (4.0 : Float)), (5.0 : Float)),
    true,
  )
  assert_eq(
    approx_eq_double(hypot2((3.0 : Double), (4.0 : Double)), (5.0 : Double)),
    true,
  )
  assert_eq(approx_eq_float(unit_circle_x((0.0 : Float)), (1.0 : Float)), true)
  assert_eq(
    approx_eq_double(unit_circle_x((0.0 : Double)), (1.0 : Double)),
    true,
  )
}

///|
test "float atomic traits produce representative values" {
  let zero : Float = 0.0
  let one : Float = 1.0
  let pi : Float = @arithmetic.Constants::pi()
  let half_pi = pi / 2.0
  assert_eq(
    approx_eq_float(@arithmetic.Sqrt::sqrt((9.0 : Float)), (3.0 : Float)),
    true,
  )
  assert_eq(approx_eq_float(cube_root((8.0 : Float)), (2.0 : Float)), true)
  assert_eq(
    approx_eq_float(
      @arithmetic.Logarithmic::ln(@arithmetic.Exponential::exp(one)),
      one,
    ),
    true,
  )
  assert_eq(
    approx_eq_float(@arithmetic.Logarithmic::log2((8.0 : Float)), (3.0 : Float)),
    true,
  )
  assert_eq(
    approx_eq_float(
      @arithmetic.Logarithmic::log10((1000.0 : Float)),
      (3.0 : Float),
    ),
    true,
  )
  assert_eq(
    approx_eq_float(
      @arithmetic.Power::pow((2.0 : Float), (3.0 : Float)),
      (8.0 : Float),
    ),
    true,
  )
  assert_eq(approx_eq_float(@arithmetic.Trigonometric::sin(half_pi), one), true)
  assert_eq(approx_eq_float(@arithmetic.Trigonometric::cos(zero), one), true)
  assert_eq(
    approx_eq_float(@arithmetic.Trigonometric::tan(pi / 4.0), one),
    true,
  )
  assert_eq(
    approx_eq_float(@arithmetic.InverseTrigonometric::asin(one), half_pi),
    true,
  )
  assert_eq(
    approx_eq_float(@arithmetic.InverseTrigonometric::atan(zero), zero),
    true,
  )
  assert_eq(
    approx_eq_float(@arithmetic.InverseTrigonometric::atan2(zero, -one), pi),
    true,
  )
  assert_eq(approx_eq_float(@arithmetic.Hyperbolic::sinh(zero), zero), true)
  assert_eq(approx_eq_float(@arithmetic.Hyperbolic::cosh(zero), one), true)
  assert_eq(
    approx_eq_float(
      @arithmetic.Hyperbolic::sinh(
        @arithmetic.InverseHyperbolic::asinh((1.0 : Float)),
      ),
      one,
    ),
    true,
  )
  assert_eq(
    approx_eq_float(
      @arithmetic.Hyperbolic::cosh(
        @arithmetic.InverseHyperbolic::acosh((2.0 : Float)),
      ),
      (2.0 : Float),
    ),
    true,
  )
  assert_eq(
    approx_eq_float(
      @arithmetic.Hyperbolic::tanh(
        @arithmetic.InverseHyperbolic::atanh((0.5 : Float)),
      ),
      (0.5 : Float),
    ),
    true,
  )
}

///|
test "double atomic traits produce representative values" {
  let zero : Double = 0.0
  let one : Double = 1.0
  let pi : Double = @arithmetic.Constants::pi()
  let half_pi = pi / 2.0
  assert_eq(
    approx_eq_double(@arithmetic.Sqrt::sqrt((9.0 : Double)), (3.0 : Double)),
    true,
  )
  assert_eq(approx_eq_double(cube_root((8.0 : Double)), (2.0 : Double)), true)
  assert_eq(
    approx_eq_double(
      @arithmetic.Logarithmic::ln(@arithmetic.Exponential::exp(one)),
      one,
    ),
    true,
  )
  assert_eq(
    approx_eq_double(
      @arithmetic.Logarithmic::log2((8.0 : Double)),
      (3.0 : Double),
    ),
    true,
  )
  assert_eq(
    approx_eq_double(
      @arithmetic.Logarithmic::log10((1000.0 : Double)),
      (3.0 : Double),
    ),
    true,
  )
  assert_eq(
    approx_eq_double(
      @arithmetic.Power::pow((2.0 : Double), (3.0 : Double)),
      (8.0 : Double),
    ),
    true,
  )
  assert_eq(
    approx_eq_double(@arithmetic.Trigonometric::sin(half_pi), one),
    true,
  )
  assert_eq(approx_eq_double(@arithmetic.Trigonometric::cos(zero), one), true)
  assert_eq(
    approx_eq_double(@arithmetic.Trigonometric::tan(pi / 4.0), one),
    true,
  )
  assert_eq(
    approx_eq_double(@arithmetic.InverseTrigonometric::asin(one), half_pi),
    true,
  )
  assert_eq(
    approx_eq_double(@arithmetic.InverseTrigonometric::atan(zero), zero),
    true,
  )
  assert_eq(
    approx_eq_double(@arithmetic.InverseTrigonometric::atan2(zero, -one), pi),
    true,
  )
  assert_eq(approx_eq_double(@arithmetic.Hyperbolic::sinh(zero), zero), true)
  assert_eq(approx_eq_double(@arithmetic.Hyperbolic::cosh(zero), one), true)
  assert_eq(
    approx_eq_double(
      @arithmetic.Hyperbolic::sinh(
        @arithmetic.InverseHyperbolic::asinh((1.0 : Double)),
      ),
      one,
    ),
    true,
  )
  assert_eq(
    approx_eq_double(
      @arithmetic.Hyperbolic::cosh(
        @arithmetic.InverseHyperbolic::acosh((2.0 : Double)),
      ),
      (2.0 : Double),
    ),
    true,
  )
  assert_eq(
    approx_eq_double(
      @arithmetic.Hyperbolic::tanh(
        @arithmetic.InverseHyperbolic::atanh((0.5 : Double)),
      ),
      (0.5 : Double),
    ),
    true,
  )
}

///|
test "real constants stay aligned" {
  let tau_f : Float = @arithmetic.Constants::tau()
  let pi_f : Float = @arithmetic.Constants::pi()
  let e_f : Float = @arithmetic.Constants::e()
  let tau_d : Double = @arithmetic.Constants::tau()
  let pi_d : Double = @arithmetic.Constants::pi()
  let e_d : Double = @arithmetic.Constants::e()
  assert_eq(approx_eq_float(tau_f, pi_f * 2.0), true)
  assert_eq(approx_eq_double(tau_d, pi_d * 2.0), true)
  assert_eq(
    approx_eq_float(@arithmetic.Logarithmic::ln(e_f), (1.0 : Float)),
    true,
  )
  assert_eq(
    approx_eq_double(@arithmetic.Logarithmic::ln(e_d), (1.0 : Double)),
    true,
  )
}

///|
test "integer family keeps exact tolerance and power semantics" {
  assert_eq(@arithmetic.Power::pow(2N, 10N), 1024N)
  assert_eq(@arithmetic.Power::pow(2, 10), 1024)
  assert_eq(@arithmetic.Power::pow((3 : Int16), (4 : Int16)), (81 : Int16))
  assert_eq(@arithmetic.Power::pow(2L, 8L), 256L)
  assert_eq(@arithmetic.Power::pow(3U, 4U), 81U)
  assert_eq(@arithmetic.Power::pow((5 : UInt16), (3 : UInt16)), (125 : UInt16))
  assert_eq(@arithmetic.Power::pow(2UL, 12UL), 4096UL)
}

///|
test "checked float and double sqrt lift returns ok" {
  match @arithmetic.SqrtChecked::sqrt_checked((9.0 : Float), default_ctx) {
    Ok(value) => assert_eq(approx_eq_float(value, (3.0 : Float)), true)
    Err(_) => fail("expected float checked sqrt to succeed")
  }
  match sqrt_checked_generic((9.0 : Double), default_ctx) {
    Ok(value) => assert_eq(approx_eq_double(value, (3.0 : Double)), true)
    Err(_) => fail("expected double checked sqrt to succeed")
  }
}

///|
test "checked float and double sqrt reject negative real inputs" {
  match @arithmetic.SqrtChecked::sqrt_checked((-1.0 : Float), default_ctx) {
    Ok(_) => fail("expected negative float checked sqrt to fail")
    Err(err) => assert_eq(err.is_domain_error(), true)
  }
  match @arithmetic.SqrtChecked::sqrt_checked((-1.0 : Double), default_ctx) {
    Ok(_) => fail("expected negative double checked sqrt to fail")
    Err(err) => assert_eq(err.is_domain_error(), true)
  }
  match @arithmetic.SqrtChecked::sqrt_checked((-0.0 : Float), default_ctx) {
    Ok(value) => assert_eq(approx_eq_float(value, (0.0 : Float)), true)
    Err(_) => fail("expected negative zero float checked sqrt to succeed")
  }
  match @arithmetic.SqrtChecked::sqrt_checked((-0.0 : Double), default_ctx) {
    Ok(value) => assert_eq(approx_eq_double(value, (0.0 : Double)), true)
    Err(_) => fail("expected negative zero double checked sqrt to succeed")
  }
}

/// IEEE 754-2019 §6.2.3 and the #5 maintainer decision: checked square root
/// returns a quiet NaN value in Ok rather than a structured domain error.
/// Expected rows: sqrt(NaN) -> Ok(NaN), for both Float and Double.

///|
test "checked float and double sqrt propagates NaN" {
  let nan_f : Float = 0.0 / 0.0
  let nan_d : Double = 0.0 / 0.0
  match @arithmetic.SqrtChecked::sqrt_checked(nan_f, default_ctx) {
    Ok(value) => assert_eq(value != value, true)
    Err(_) => fail("expected Float NaN square root to propagate as Ok(NaN)")
  }
  match @arithmetic.SqrtChecked::sqrt_checked(nan_d, default_ctx) {
    Ok(value) => assert_eq(value != value, true)
    Err(_) => fail("expected Double NaN square root to propagate as Ok(NaN)")
  }
}

///|
test "checked float and double division lift enforces explicit zero-division errors" {
  match
    @arithmetic.DivChecked::div_checked(
      (8.0 : Float),
      (2.0 : Float),
      default_ctx,
    ) {
    Ok(value) => assert_eq(approx_eq_float(value, (4.0 : Float)), true)
    Err(_) => fail("expected float checked division to succeed")
  }
  match
    @arithmetic.DivChecked::div_checked(
      (1.0 : Double),
      (0.0 : Double),
      default_ctx,
    ) {
    Ok(_) => fail("expected checked zero division to fail")
    Err(err) => assert_eq(err.is_division_by_zero(), true)
  }
}

///|
test "checked float and double division classifies indeterminate forms" {
  let float_inf : Float = 1.0 / 0.0
  let double_inf : Double = 1.0 / 0.0
  match
    @arithmetic.DivChecked::div_checked(
      (0.0 : Float),
      (0.0 : Float),
      default_ctx,
    ) {
    Ok(_) => fail("expected zero divided by zero to fail")
    Err(err) => assert_eq(err.is_domain_error(), true)
  }
  match
    @arithmetic.DivChecked::div_checked(double_inf, double_inf, default_ctx) {
    Ok(_) => fail("expected infinity divided by infinity to fail")
    Err(err) => assert_eq(err.is_domain_error(), true)
  }
  match
    @arithmetic.DivChecked::div_checked(
      (-1.0 : Float),
      (0.0 : Float),
      default_ctx,
    ) {
    Ok(_) => fail("expected non-zero division by zero to fail")
    Err(err) => assert_eq(err.is_division_by_zero(), true)
  }
  match
    @arithmetic.DivChecked::div_checked((1.0 : Float), float_inf, default_ctx) {
    Ok(value) => assert_eq(approx_eq_float(value, (0.0 : Float)), true)
    Err(_) => fail("expected finite division by infinity to succeed")
  }
}

/// IEEE 754-2019 §§6.2.3, 7.2, 7.3: NaN operands propagate; 0/0 is invalid;
/// divideByZero applies to finite non-zero divided by zero, not infinity/zero.
/// The #5 maintainer decision maps NaN and infinity results to Ok values while
/// retaining checked errors for invalid 0/0 and finite non-zero/zero.
/// Expected rows: NaN/0, 0/NaN, NaN/1 -> Ok(NaN).
/// The same contract applies to Float and Double.

///|
test "checked float and double division propagates NaN before zero checks" {
  let nan_f : Float = 0.0 / 0.0
  let nan_d : Double = 0.0 / 0.0

  let nan_over_zero_f = @arithmetic.DivChecked::div_checked(
    nan_f,
    (0.0 : Float),
    default_ctx,
  )
  match nan_over_zero_f {
    Ok(value) => assert_eq(value != value, true)
    Err(_) => fail("expected NaN divided by zero to propagate as Ok(NaN)")
  }
  let zero_over_nan_f = @arithmetic.DivChecked::div_checked(
    (0.0 : Float),
    nan_f,
    default_ctx,
  )
  match zero_over_nan_f {
    Ok(value) => assert_eq(value != value, true)
    Err(_) => fail("expected zero divided by NaN to propagate as Ok(NaN)")
  }
  match @arithmetic.DivChecked::div_checked(nan_f, (1.0 : Float), default_ctx) {
    Ok(value) => assert_eq(value != value, true)
    Err(_) => fail("expected Float NaN divided by one to propagate as Ok(NaN)")
  }
  match
    @arithmetic.DivChecked::div_checked(nan_d, (0.0 : Double), default_ctx) {
    Ok(value) => assert_eq(value != value, true)
    Err(_) =>
      fail("expected Double NaN divided by zero to propagate as Ok(NaN)")
  }
  match
    @arithmetic.DivChecked::div_checked((0.0 : Double), nan_d, default_ctx) {
    Ok(value) => assert_eq(value != value, true)
    Err(_) =>
      fail("expected Double zero divided by NaN to propagate as Ok(NaN)")
  }
  match
    @arithmetic.DivChecked::div_checked(nan_d, (1.0 : Double), default_ctx) {
    Ok(value) => assert_eq(value != value, true)
    Err(_) => fail("expected Double NaN divided by one to propagate as Ok(NaN)")
  }
}

/// IEEE 754-2019 §§7.2–7.3: 0/0 is invalid; divideByZero applies to finite
/// non-zero divided by zero, not infinity/zero. D-A4 keeps the checked error
/// for the former and returns the IEEE signed infinity in Ok for the latter.
/// Expected rows: ±inf/±0 -> the correctly signed Ok(±inf); 0/0 and inf/inf ->
/// Err(DomainError), checked for both Float and Double.

///|
test "checked float and double division returns signed infinity over zero" {
  let pos_inf_f : Float = 1.0 / 0.0
  let neg_inf_f : Float = -1.0 / 0.0
  let pos_inf_d : Double = 1.0 / 0.0
  let neg_inf_d : Double = -1.0 / 0.0
  match @arithmetic.DivChecked::div_checked((0.0 : Double), 0.0, default_ctx) {
    Ok(_) => fail("expected Double zero divided by zero to return DomainError")
    Err(err) => assert_eq(err.is_domain_error(), true)
  }
  match @arithmetic.DivChecked::div_checked(pos_inf_f, pos_inf_f, default_ctx) {
    Ok(_) =>
      fail("expected Float infinity divided by infinity to return DomainError")
    Err(err) => assert_eq(err.is_domain_error(), true)
  }

  match
    @arithmetic.DivChecked::div_checked(pos_inf_f, (0.0 : Float), default_ctx) {
    Ok(value) => {
      assert_eq(Float::is_inf(value), true)
      assert_eq(value > 0.0, true)
    }
    Err(_) =>
      fail(
        "expected positive infinity divided by positive zero to return Ok(+inf)",
      )
  }
  match
    @arithmetic.DivChecked::div_checked(neg_inf_f, (-0.0 : Float), default_ctx) {
    Ok(value) => {
      assert_eq(Float::is_inf(value), true)
      assert_eq(value > 0.0, true)
    }
    Err(_) =>
      fail(
        "expected negative infinity divided by negative zero to return Ok(+inf)",
      )
  }
  match
    @arithmetic.DivChecked::div_checked(neg_inf_d, (0.0 : Double), default_ctx) {
    Ok(value) => {
      assert_eq(Double::is_inf(value), true)
      assert_eq(value < 0.0, true)
    }
    Err(_) =>
      fail(
        "expected negative infinity divided by positive zero to return Ok(-inf)",
      )
  }
  match
    @arithmetic.DivChecked::div_checked(pos_inf_f, (-0.0 : Float), default_ctx) {
    Ok(value) => {
      assert_eq(Float::is_inf(value), true)
      assert_eq(value < 0.0, true)
    }
    Err(_) =>
      fail(
        "expected positive infinity divided by negative zero to return Ok(-inf)",
      )
  }
  match
    @arithmetic.DivChecked::div_checked(neg_inf_d, (-0.0 : Double), default_ctx) {
    Ok(value) => {
      assert_eq(Double::is_inf(value), true)
      assert_eq(value > 0.0, true)
    }
    Err(_) =>
      fail(
        "expected negative infinity divided by negative zero to return Ok(+inf)",
      )
  }
  match
    @arithmetic.DivChecked::div_checked(pos_inf_d, (-0.0 : Double), default_ctx) {
    Ok(value) => {
      assert_eq(Double::is_inf(value), true)
      assert_eq(value < 0.0, true)
    }
    Err(_) =>
      fail(
        "expected positive infinity divided by negative zero to return Ok(-inf)",
      )
  }
}

/// IEEE 754-2019 §7.4: overflow to infinity is the default for untrapped
/// floating-point operations; D-A4 requires the checked tier to return Ok.
/// Exact magnitudes 10^400 and 10^41 exceed the finite ranges of binary64 and
/// binary32 respectively. Expected rows: 10^400 -> Ok(+inf) for Double;
/// (-10)^41 -> Ok(-inf) for Float; (-10)^400 -> Ok(+inf) for Double.

///|
test "checked float and double powers return infinity on overflow" {
  match
    @arithmetic.PowNatChecked::pow_nat_checked(
      (10.0 : Double),
      400U,
      default_ctx,
    ) {
    Ok(value) => {
      assert_eq(Double::is_inf(value), true)
      assert_eq(value > 0.0, true)
    }
    Err(_) => fail("expected Double power overflow to return Ok(+inf)")
  }
  match
    @arithmetic.PowNatChecked::pow_nat_checked(
      (-10.0 : Float),
      41U,
      default_ctx,
    ) {
    Ok(value) => {
      assert_eq(Float::is_inf(value), true)
      assert_eq(value < 0.0, true)
    }
    Err(_) => fail("expected Float power overflow to return Ok(-inf)")
  }
  match
    @arithmetic.PowIntChecked::pow_int_checked((-10.0 : Float), 41, default_ctx) {
    Ok(value) => {
      assert_eq(Float::is_inf(value), true)
      assert_eq(value < 0.0, true)
    }
    Err(_) =>
      fail("expected Float signed integer power overflow to return Ok(-inf)")
  }
  match
    @arithmetic.PowIntChecked::pow_int_checked(
      (-10.0 : Double),
      400,
      default_ctx,
    ) {
    Ok(value) => {
      assert_eq(Double::is_inf(value), true)
      assert_eq(value > 0.0, true)
    }
    Err(_) =>
      fail("expected Double signed integer power overflow to return Ok(+inf)")
  }
  match
    @arithmetic.PowIntChecked::pow_int_checked(
      (1.0e-320 : Double),
      -1,
      default_ctx,
    ) {
    Ok(value) => {
      assert_eq(Double::is_inf(value), true)
      assert_eq(value > 0.0, true)
    }
    Err(_) => fail("expected Double reciprocal overflow to return Ok(+inf)")
  }
  match
    @arithmetic.PowIntChecked::pow_int_checked(
      (1.0e-39 : Float),
      -1,
      default_ctx,
    ) {
    Ok(value) => {
      assert_eq(Float::is_inf(value), true)
      assert_eq(value > 0.0, true)
    }
    Err(_) => fail("expected Float reciprocal overflow to return Ok(+inf)")
  }
}

/// IEEE 754-2019 §9.2.1 makes quiet-NaN^0 an exception to general NaN
/// propagation: it returns one. Every non-zero exponent propagates NaN.

///|
test "checked float and double powers follow NaN zero-exponent rules" {
  let nan_f : Float = 0.0 / 0.0
  let nan_d : Double = 0.0 / 0.0
  for exponent in [0, 1, -1] {
    let nat_exponent = if exponent == 0 {
      0U
    } else {
      exponent.reinterpret_as_uint()
    }
    match
      @arithmetic.PowIntChecked::pow_int_checked(nan_f, exponent, default_ctx) {
      Ok(value) =>
        if exponent == 0 {
          assert_eq(value, 1.0)
        } else {
          assert_eq(value != value, true)
        }
      Err(_) => fail("expected Float NaN integer power to return a value")
    }
    match
      @arithmetic.PowIntChecked::pow_int_checked(nan_d, exponent, default_ctx) {
      Ok(value) =>
        if exponent == 0 {
          assert_eq(value, 1.0)
        } else {
          assert_eq(value != value, true)
        }
      Err(_) => fail("expected Double NaN integer power to return a value")
    }
    if exponent >= 0 {
      match
        @arithmetic.PowNatChecked::pow_nat_checked(
          nan_f, nat_exponent, default_ctx,
        ) {
        Ok(value) =>
          if exponent == 0 {
            assert_eq(value, 1.0)
          } else {
            assert_eq(value != value, true)
          }
        Err(_) => fail("expected Float NaN natural power to return a value")
      }
      match
        @arithmetic.PowNatChecked::pow_nat_checked(
          nan_d, nat_exponent, default_ctx,
        ) {
        Ok(value) =>
          if exponent == 0 {
            assert_eq(value, 1.0)
          } else {
            assert_eq(value != value, true)
          }
        Err(_) => fail("expected Double NaN natural power to return a value")
      }
    }
  }
}

///|
test "checked scalar comparison rejects nan" {
  let nan_d = 0.0 / 0.0
  match
    @arithmetic.CompareChecked::compare_checked((1.0 : Double), (2.0 : Double)) {
    Ok(value) => assert_eq(value, -1)
    Err(_) => fail("expected ordered double comparison")
  }
  match @arithmetic.CompareChecked::compare_checked(nan_d, (0.0 : Double)) {
    Ok(_) => fail("expected unordered comparison error")
    Err(err) => assert_eq(err.is_unordered_comparison(), true)
  }
}

///|
test "checked power nat handles zero exponent including zero to zero" {
  match
    @arithmetic.PowNatChecked::pow_nat_checked((5.0 : Float), 0U, default_ctx) {
    Ok(value) => assert_eq(approx_eq_float(value, (1.0 : Float)), true)
    Err(_) => fail("expected zero exponent to return one")
  }
  match
    @arithmetic.PowNatChecked::pow_nat_checked((0.0 : Double), 0U, default_ctx) {
    Ok(value) => assert_eq(approx_eq_double(value, (1.0 : Double)), true)
    Err(_) => fail("expected zero to zero to return one")
  }
  match square_checked((3.0 : Double), default_ctx) {
    Ok(value) => assert_eq(approx_eq_double(value, (9.0 : Double)), true)
    Err(_) => fail("expected positive integer power to succeed")
  }
}

///|
test "checked power int handles negative exponents and zero-base failures" {
  match
    @arithmetic.PowIntChecked::pow_int_checked((2.0 : Double), 3, default_ctx) {
    Ok(value) => assert_eq(approx_eq_double(value, (8.0 : Double)), true)
    Err(_) => fail("expected positive integer power to succeed")
  }
  match reciprocal_power_checked((2.0 : Double), -3, default_ctx) {
    Ok(value) => assert_eq(approx_eq_double(value, (0.125 : Double)), true)
    Err(_) => fail("expected negative integer power to succeed")
  }
  match
    @arithmetic.PowIntChecked::pow_int_checked((4.0 : Float), 0, default_ctx) {
    Ok(value) => assert_eq(approx_eq_float(value, (1.0 : Float)), true)
    Err(_) => fail("expected zero exponent to return one")
  }
  match
    @arithmetic.PowIntChecked::pow_int_checked((0.0 : Double), -1, default_ctx) {
    Ok(_) => fail("expected zero base with negative exponent to fail")
    Err(err) => assert_eq(err.is_division_by_zero(), true)
  }
}

///|
test "checked power int handles minimum int exponent without direct negation" {
  let min_int = 1 << 31
  match
    @arithmetic.PowIntChecked::pow_int_checked(
      (1.0 : Float),
      min_int,
      default_ctx,
    ) {
    Ok(value) => assert_eq(approx_eq_float(value, (1.0 : Float)), true)
    Err(_) => fail("expected minimum int exponent with base one to succeed")
  }
  match
    @arithmetic.PowIntChecked::pow_int_checked(
      (1.0 : Double),
      min_int,
      default_ctx,
    ) {
    Ok(value) => assert_eq(approx_eq_double(value, (1.0 : Double)), true)
    Err(_) => fail("expected minimum int exponent with base one to succeed")
  }
}

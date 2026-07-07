///|
using @test {assert_eq}

///|
using @lg {trait AddMonoid, trait Num}

///|
let float_eps : Float = 0.0000001

///|
let double_eps : Double = 0.00000000001

///|
let default_ctx : ArithmeticContext = ArithmeticContext::new(32)

///|
fn[T : AddMonoid] add_identity(x : T) -> T {
  x + T::zero()
}

///|
fn[T : Add + Mul + Sqrt] hypot2(x : T, y : T) -> T {
  Sqrt::sqrt(x * x + y * y)
}

///|
fn[T : Cbrt] cube_root(x : T) -> T {
  Cbrt::cbrt(x)
}

///|
fn[T : Trigonometric] unit_circle_x(theta : T) -> T {
  Trigonometric::cos(theta)
}

///|
fn[T : PowNatChecked] square_checked(
  x : T,
  ctx : ArithmeticContext,
) -> Result[T, ArithmeticError] {
  PowNatChecked::pow_nat_checked(x, 2U, ctx)
}

///|
fn[T : PowIntChecked] reciprocal_power_checked(
  x : T,
  exponent : Int,
  ctx : ArithmeticContext,
) -> Result[T, ArithmeticError] {
  PowIntChecked::pow_int_checked(x, exponent, ctx)
}

///|
fn[T : SqrtChecked] sqrt_checked_generic(
  x : T,
  ctx : ArithmeticContext,
) -> Result[T, ArithmeticError] {
  SqrtChecked::sqrt_checked(x, ctx)
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
  let pi : Float = Constants::pi()
  let half_pi = pi / 2.0
  assert_eq(approx_eq_float(Sqrt::sqrt((9.0 : Float)), (3.0 : Float)), true)
  assert_eq(approx_eq_float(cube_root((8.0 : Float)), (2.0 : Float)), true)
  assert_eq(approx_eq_float(Logarithmic::ln(Exponential::exp(one)), one), true)
  assert_eq(
    approx_eq_float(Logarithmic::log2((8.0 : Float)), (3.0 : Float)),
    true,
  )
  assert_eq(
    approx_eq_float(Logarithmic::log10((1000.0 : Float)), (3.0 : Float)),
    true,
  )
  assert_eq(
    approx_eq_float(Power::pow((2.0 : Float), (3.0 : Float)), (8.0 : Float)),
    true,
  )
  assert_eq(approx_eq_float(Trigonometric::sin(half_pi), one), true)
  assert_eq(approx_eq_float(Trigonometric::cos(zero), one), true)
  assert_eq(approx_eq_float(Trigonometric::tan(pi / 4.0), one), true)
  assert_eq(approx_eq_float(InverseTrigonometric::asin(one), half_pi), true)
  assert_eq(approx_eq_float(InverseTrigonometric::atan(zero), zero), true)
  assert_eq(approx_eq_float(InverseTrigonometric::atan2(zero, -one), pi), true)
  assert_eq(approx_eq_float(Hyperbolic::sinh(zero), zero), true)
  assert_eq(approx_eq_float(Hyperbolic::cosh(zero), one), true)
  assert_eq(
    approx_eq_float(
      Hyperbolic::sinh(InverseHyperbolic::asinh((1.0 : Float))),
      one,
    ),
    true,
  )
  assert_eq(
    approx_eq_float(
      Hyperbolic::cosh(InverseHyperbolic::acosh((2.0 : Float))),
      (2.0 : Float),
    ),
    true,
  )
  assert_eq(
    approx_eq_float(
      Hyperbolic::tanh(InverseHyperbolic::atanh((0.5 : Float))),
      (0.5 : Float),
    ),
    true,
  )
}

///|
test "double atomic traits produce representative values" {
  let zero : Double = 0.0
  let one : Double = 1.0
  let pi : Double = Constants::pi()
  let half_pi = pi / 2.0
  assert_eq(approx_eq_double(Sqrt::sqrt((9.0 : Double)), (3.0 : Double)), true)
  assert_eq(approx_eq_double(cube_root((8.0 : Double)), (2.0 : Double)), true)
  assert_eq(approx_eq_double(Logarithmic::ln(Exponential::exp(one)), one), true)
  assert_eq(
    approx_eq_double(Logarithmic::log2((8.0 : Double)), (3.0 : Double)),
    true,
  )
  assert_eq(
    approx_eq_double(Logarithmic::log10((1000.0 : Double)), (3.0 : Double)),
    true,
  )
  assert_eq(
    approx_eq_double(Power::pow((2.0 : Double), (3.0 : Double)), (8.0 : Double)),
    true,
  )
  assert_eq(approx_eq_double(Trigonometric::sin(half_pi), one), true)
  assert_eq(approx_eq_double(Trigonometric::cos(zero), one), true)
  assert_eq(approx_eq_double(Trigonometric::tan(pi / 4.0), one), true)
  assert_eq(approx_eq_double(InverseTrigonometric::asin(one), half_pi), true)
  assert_eq(approx_eq_double(InverseTrigonometric::atan(zero), zero), true)
  assert_eq(approx_eq_double(InverseTrigonometric::atan2(zero, -one), pi), true)
  assert_eq(approx_eq_double(Hyperbolic::sinh(zero), zero), true)
  assert_eq(approx_eq_double(Hyperbolic::cosh(zero), one), true)
  assert_eq(
    approx_eq_double(
      Hyperbolic::sinh(InverseHyperbolic::asinh((1.0 : Double))),
      one,
    ),
    true,
  )
  assert_eq(
    approx_eq_double(
      Hyperbolic::cosh(InverseHyperbolic::acosh((2.0 : Double))),
      (2.0 : Double),
    ),
    true,
  )
  assert_eq(
    approx_eq_double(
      Hyperbolic::tanh(InverseHyperbolic::atanh((0.5 : Double))),
      (0.5 : Double),
    ),
    true,
  )
}

///|
test "real constants stay aligned" {
  let tau_f : Float = Constants::tau()
  let pi_f : Float = Constants::pi()
  let e_f : Float = Constants::e()
  let tau_d : Double = Constants::tau()
  let pi_d : Double = Constants::pi()
  let e_d : Double = Constants::e()
  assert_eq(approx_eq_float(tau_f, pi_f * 2.0), true)
  assert_eq(approx_eq_double(tau_d, pi_d * 2.0), true)
  assert_eq(approx_eq_float(Logarithmic::ln(e_f), (1.0 : Float)), true)
  assert_eq(approx_eq_double(Logarithmic::ln(e_d), (1.0 : Double)), true)
}

///|
test "integer family keeps exact tolerance and power semantics" {
  assert_eq(Power::pow(2N, 10N), 1024N)
  assert_eq(Power::pow(2, 10), 1024)
  assert_eq(Power::pow((3 : Int16), (4 : Int16)), (81 : Int16))
  assert_eq(Power::pow(2L, 8L), 256L)
  assert_eq(Power::pow(3U, 4U), 81U)
  assert_eq(Power::pow((5 : UInt16), (3 : UInt16)), (125 : UInt16))
  assert_eq(Power::pow(2UL, 12UL), 4096UL)
}

///|
test "checked float and double sqrt lift returns ok" {
  match SqrtChecked::sqrt_checked((9.0 : Float), default_ctx) {
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
  match SqrtChecked::sqrt_checked((-1.0 : Float), default_ctx) {
    Ok(_) => fail("expected negative float checked sqrt to fail")
    Err(err) => assert_eq(err.is_domain_error(), true)
  }
  match SqrtChecked::sqrt_checked((-1.0 : Double), default_ctx) {
    Ok(_) => fail("expected negative double checked sqrt to fail")
    Err(err) => assert_eq(err.is_domain_error(), true)
  }
  match SqrtChecked::sqrt_checked((-0.0 : Float), default_ctx) {
    Ok(value) => assert_eq(approx_eq_float(value, (0.0 : Float)), true)
    Err(_) => fail("expected negative zero float checked sqrt to succeed")
  }
  match SqrtChecked::sqrt_checked((-0.0 : Double), default_ctx) {
    Ok(value) => assert_eq(approx_eq_double(value, (0.0 : Double)), true)
    Err(_) => fail("expected negative zero double checked sqrt to succeed")
  }
}

///|
test "checked float and double division lift enforces explicit zero-division errors" {
  match DivChecked::div_checked((8.0 : Float), (2.0 : Float), default_ctx) {
    Ok(value) => assert_eq(approx_eq_float(value, (4.0 : Float)), true)
    Err(_) => fail("expected float checked division to succeed")
  }
  match DivChecked::div_checked((1.0 : Double), (0.0 : Double), default_ctx) {
    Ok(_) => fail("expected checked zero division to fail")
    Err(err) => assert_eq(err.is_division_by_zero(), true)
  }
}

///|
test "checked scalar comparison rejects nan" {
  let nan_d = 0.0 / 0.0
  match CompareChecked::compare_checked((1.0 : Double), (2.0 : Double)) {
    Ok(value) => assert_eq(value, -1)
    Err(_) => fail("expected ordered double comparison")
  }
  match CompareChecked::compare_checked(nan_d, (0.0 : Double)) {
    Ok(_) => fail("expected unordered comparison error")
    Err(err) => assert_eq(err.is_unordered_comparison(), true)
  }
}

///|
test "checked power nat handles zero exponent including zero to zero" {
  match PowNatChecked::pow_nat_checked((5.0 : Float), 0U, default_ctx) {
    Ok(value) => assert_eq(approx_eq_float(value, (1.0 : Float)), true)
    Err(_) => fail("expected zero exponent to return one")
  }
  match PowNatChecked::pow_nat_checked((0.0 : Double), 0U, default_ctx) {
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
  match PowIntChecked::pow_int_checked((2.0 : Double), 3, default_ctx) {
    Ok(value) => assert_eq(approx_eq_double(value, (8.0 : Double)), true)
    Err(_) => fail("expected positive integer power to succeed")
  }
  match reciprocal_power_checked((2.0 : Double), -3, default_ctx) {
    Ok(value) => assert_eq(approx_eq_double(value, (0.125 : Double)), true)
    Err(_) => fail("expected negative integer power to succeed")
  }
  match PowIntChecked::pow_int_checked((4.0 : Float), 0, default_ctx) {
    Ok(value) => assert_eq(approx_eq_float(value, (1.0 : Float)), true)
    Err(_) => fail("expected zero exponent to return one")
  }
  match PowIntChecked::pow_int_checked((0.0 : Double), -1, default_ctx) {
    Ok(_) => fail("expected zero base with negative exponent to fail")
    Err(err) => assert_eq(err.is_division_by_zero(), true)
  }
}

///|
test "checked power int handles minimum int exponent without direct negation" {
  let min_int = 1 << 31
  match PowIntChecked::pow_int_checked((1.0 : Float), min_int, default_ctx) {
    Ok(value) => assert_eq(approx_eq_float(value, (1.0 : Float)), true)
    Err(_) => fail("expected minimum int exponent with base one to succeed")
  }
  match PowIntChecked::pow_int_checked((1.0 : Double), min_int, default_ctx) {
    Ok(value) => assert_eq(approx_eq_double(value, (1.0 : Double)), true)
    Err(_) => fail("expected minimum int exponent with base one to succeed")
  }
}

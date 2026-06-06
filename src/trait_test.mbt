///|
using @test { assert_eq }
using @lg { trait AddMonoid, trait Num }

let float_eps : Float = 0.0000001
let double_eps : Double = 0.00000000001

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
  assert_eq(approx_eq_float(hypot2((3.0 : Float), (4.0 : Float)), (5.0 : Float)), true)
  assert_eq(approx_eq_double(hypot2((3.0 : Double), (4.0 : Double)), (5.0 : Double)), true)
  assert_eq(approx_eq_float(unit_circle_x((0.0 : Float)), (1.0 : Float)), true)
  assert_eq(approx_eq_double(unit_circle_x((0.0 : Double)), (1.0 : Double)), true)
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
  assert_eq(approx_eq_float(Logarithmic::log2((8.0 : Float)), (3.0 : Float)), true)
  assert_eq(approx_eq_float(Logarithmic::log10((1000.0 : Float)), (3.0 : Float)), true)
  assert_eq(approx_eq_float(Power::pow((2.0 : Float), (3.0 : Float)), (8.0 : Float)), true)
  assert_eq(approx_eq_float(Trigonometric::sin(half_pi), one), true)
  assert_eq(approx_eq_float(Trigonometric::cos(zero), one), true)
  assert_eq(approx_eq_float(Trigonometric::tan(pi / 4.0), one), true)
  assert_eq(approx_eq_float(InverseTrigonometric::asin(one), half_pi), true)
  assert_eq(approx_eq_float(InverseTrigonometric::atan(zero), zero), true)
  assert_eq(approx_eq_float(InverseTrigonometric::atan2(zero, -one), pi), true)
  assert_eq(approx_eq_float(Hyperbolic::sinh(zero), zero), true)
  assert_eq(approx_eq_float(Hyperbolic::cosh(zero), one), true)
  assert_eq(approx_eq_float(Hyperbolic::sinh(InverseHyperbolic::asinh((1.0 : Float))), one), true)
  assert_eq(approx_eq_float(Hyperbolic::cosh(InverseHyperbolic::acosh((2.0 : Float))), (2.0 : Float)), true)
  assert_eq(approx_eq_float(Hyperbolic::tanh(InverseHyperbolic::atanh((0.5 : Float))), (0.5 : Float)), true)
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
  assert_eq(approx_eq_double(Logarithmic::log2((8.0 : Double)), (3.0 : Double)), true)
  assert_eq(approx_eq_double(Logarithmic::log10((1000.0 : Double)), (3.0 : Double)), true)
  assert_eq(approx_eq_double(Power::pow((2.0 : Double), (3.0 : Double)), (8.0 : Double)), true)
  assert_eq(approx_eq_double(Trigonometric::sin(half_pi), one), true)
  assert_eq(approx_eq_double(Trigonometric::cos(zero), one), true)
  assert_eq(approx_eq_double(Trigonometric::tan(pi / 4.0), one), true)
  assert_eq(approx_eq_double(InverseTrigonometric::asin(one), half_pi), true)
  assert_eq(approx_eq_double(InverseTrigonometric::atan(zero), zero), true)
  assert_eq(approx_eq_double(InverseTrigonometric::atan2(zero, -one), pi), true)
  assert_eq(approx_eq_double(Hyperbolic::sinh(zero), zero), true)
  assert_eq(approx_eq_double(Hyperbolic::cosh(zero), one), true)
  assert_eq(approx_eq_double(Hyperbolic::sinh(InverseHyperbolic::asinh((1.0 : Double))), one), true)
  assert_eq(approx_eq_double(Hyperbolic::cosh(InverseHyperbolic::acosh((2.0 : Double))), (2.0 : Double)), true)
  assert_eq(approx_eq_double(Hyperbolic::tanh(InverseHyperbolic::atanh((0.5 : Double))), (0.5 : Double)), true)
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

///|
test "certification failures retain structured proof details" {
  let detail = CertificationFailureDetail::new(
    "exp",
    TargetRounding,
    RefinementBudgetExhausted,
    53,
    384,
    12,
  )
  let error = ArithmeticError::certification_failure(detail)
  assert_true(error.is_certification_failure())
  assert_false(error.is_unsupported())
  let recovered = error.certification_failure_detail().unwrap()
  assert_eq(recovered.operation(), "exp")
  assert_true(recovered.stage() == TargetRounding)
  assert_true(recovered.reason() == RefinementBudgetExhausted)
  assert_eq(recovered.target_precision(), 53)
  assert_eq(recovered.work_precision(), 384)
  assert_eq(recovered.refinements(), 12)
}

///|
test "legacy arithmetic error predicates remain disjoint" {
  let unsupported = ArithmeticError::unsupported("not implemented")
  assert_true(unsupported.is_unsupported())
  assert_false(unsupported.is_certification_failure())
  assert_true(unsupported.certification_failure_detail() is None)
  let domain = ArithmeticError::domain_error("outside domain")
  assert_true(domain.is_domain_error())
  assert_false(domain.is_certification_failure())
}

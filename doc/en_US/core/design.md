# Core Design

## Design Goal

`arithmetic` extends Luna Flow from algebraic structure into analytic and
context-dependent numeric capabilities while keeping backend semantics
explicit.

## Capability Boundaries

- Unchecked traits describe direct, context-free backend operations.
- Checked traits add explicit domain or arithmetic failure without changing
  successful values into a diagnostic record.
- Contextual traits accept `ArithmeticContext` and return
  `ArithmeticOutcome[T]`, allowing implementations to report rounding and
  exceptional-condition flags.
- Enclosure relations remain separate from scalar comparison.

Algorithms should depend on the smallest existing trait composition that
states their requirements. A broad local “number” or “real” trait would hide
meaningful differences between numeric domains.

## Data and Effects

`ArithmeticContext`, `ArithmeticDiagnostics`, and `ArithmeticOutcome` are
ordinary values. Context is passed explicitly, diagnostic accumulation uses the
pure `combine` operation, and no package-global arithmetic state is required.
This keeps contextual computation deterministic for a given implementation and
input set.

Errors remain explicit through `Result[..., ArithmeticError]`. Diagnostic flags
represent successful computations with notable conditions; they do not replace
errors for operations that the implementation rejects.

## Built-in Adapter Strategy

The `Float` and `Double` implementations adapt the contextual boundary to
existing native and checked operations. Division and square root reuse checked
validation. Integer embedding detects native `Float` conversion loss, adjacent
operations step through the IEEE bit representation, and fixed-format neighbor
selection returns empty diagnostics as an exact capability operation.

These adapters establish interface availability, not a software decimal
engine. They intentionally do not pretend to honor arbitrary precision,
directed rounding, exponent clamping, or full IEEE flag generation.
They intentionally do not implement `ConstantsContextual` or
`HyperbolicContextual`. Proof-backed numeric packages can implement those
capabilities with certified evaluation and preserve failure details through
`ArithmeticError`.

## Boundaries

- This package does not define vectors, matrices, complex numbers, symbolic
  objects, or arbitrary-precision decimal storage.
- It does not hide branch cuts or exceptional values behind one bundled
  abstraction.
- Concrete numeric backends own the semantics of contextual rounding,
  exponent handling, and diagnostic production.

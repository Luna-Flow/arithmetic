# core design

## Design goal

`arithmetic` is the layer between algebraic structure and concrete numbers.
[`luna-generic`](https://lunaflow.cn/en/luna-generic/) says what a type *is*
(a ring, a field); `arithmetic` says what analytic operations a type *can do*
and how honestly it can do them: whether a square root may silently return
NaN, whether it reports a rejected argument, or whether it also reports how the
result was rounded under a stated precision. A generic algorithm states exactly
the capabilities it relies on, and a numeric backend implements exactly the
capabilities whose semantics it can honour.

The package ships the vocabulary (traits, the context, diagnostics and
errors) and a baseline of instances for the native `Float`, `Double` and
integer types. Correctly rounded, context-faithful and certified arithmetic
lives in numeric backends, which implement these traits.

## Constraints

- One vocabulary must serve native IEEE binary scalars, decimal types with a
  configurable precision, and interval or ball types whose values are sets.
- Every MoonBit target must behave the same, so no design may rely on
  thread-local or global state.
- The package sits below every numeric backend in the dependency graph, so it
  depends on no backend and evaluates nothing it cannot do exactly with the
  native types.
- A trait must not promise more than its weakest reasonable instance can
  honour, and a shipped instance must not claim more than it does.

## Main design decisions

- Three independent tiers, unchecked, checked and contextual, each with its
  own traits and no supertrait links between them.
- The context is an explicit, immutable argument, and diagnostics are part of
  the return value.
- Errors (no value), diagnostics (a value with notable conditions) and
  certification failures (a valid input whose result could not be proved) are
  separate channels.
- Enclosures get five Boolean relation traits, not an order.
- One capability per trait, with `Radical` as the only conjunction, and no
  `Real` super-trait.
- `Float` and `Double` implement a trait only when its promise is meaningful
  for a fixed format.

The sections after the mathematics give the reasoning for each decision.

## Mathematical background

### Floating-point formats

A floating-point format with radix $\beta$, precision $p$ and exponent range
$[e_{\min}, e_{\max}]$ is the finite set

$$
\mathbb{F} = \{0\} \cup \{\, \pm m \cdot \beta^{\,e-p+1} \;:\; m \in \mathbb{Z},\ \beta^{p-1} \le m < \beta^{p},\ e_{\min} \le e \le e_{\max} \,\}
\cup \{\, \pm m \cdot \beta^{\,e_{\min}-p+1} \;:\; 0 < m < \beta^{p-1} \,\}.
$$

The second set holds the normal numbers, whose leading digit sits at
$\beta^{e}$ ($e$ is the *adjusted exponent*); the third holds the subnormal
numbers below $\beta^{e_{\min}}$. IEEE 754 extends $\mathbb{F}$ to
$\overline{\mathbb{F}} = \mathbb{F} \cup \{-\infty, +\infty, \mathrm{NaN}\}$,
with signed zeros. `FpClass` is the map

$$
\operatorname{class} : \overline{\mathbb{F}} \to \{\texttt{Finite}, \texttt{Infinity}, \texttt{NaN}\},
\qquad
\operatorname{class}(x) =
\begin{cases}
\texttt{Finite} & x \in \mathbb{F},\\
\texttt{Infinity} & x = \pm\infty,\\
\texttt{NaN} & x = \mathrm{NaN}.
\end{cases}
$$

| Format | $\beta$ | $p$ | $e_{\min}$ | $e_{\max}$ | Source |
| --- | --- | --- | --- | --- | --- |
| binary32 | 2 | 24 | $-126$ | $127$ | `Float` |
| binary64 | 2 | 53 | $-1022$ | $1023$ | `Double` |
| decimal32 | 10 | 7 | $-95$ | $96$ | `ArithmeticContext::decimal32` |
| decimal64 | 10 | 16 | $-383$ | $384$ | `ArithmeticContext::decimal64` |
| decimal128 | 10 | 34 | $-6143$ | $6144$ | `ArithmeticContext::decimal128` |

`ArithmeticContext` stores $p$ as `precision` and the adjusted-exponent bounds
as `e_min` and `e_max`; the radix is a property of the backend type, not of
the context. All three decimal presets satisfy $e_{\min} = 1 - e_{\max}$, the
IEEE 754 relation that keeps the reciprocal of the smallest normal number,
$\beta^{-e_{\min}} = \beta^{e_{\max}-1}$, inside the finite range.

**Machine epsilon.** The successor of $1$ in $\mathbb{F}$ is $1 + \beta^{1-p}$:
writing $1 = \beta^{p-1} \cdot \beta^{\,0-p+1}$ gives $m = \beta^{p-1}$ and
$e = 0$, and the next significand $m + 1$ gives

$$
(\beta^{p-1} + 1)\,\beta^{1-p} = 1 + \beta^{1-p} =: 1 + \varepsilon .
$$

More generally, in the binade $[\beta^{e}, \beta^{e+1})$ consecutive numbers
are $\beta^{e-p+1} = \varepsilon\,\beta^{e}$ apart. `epsilon_contextual`
returns $\varepsilon$: $2^{-23}$ for `Float` and $2^{-52}$ for `Double`.

### Rounding

A rounding function $\circ : \mathbb{R} \to \overline{\mathbb{F}}$ maps a real
number to a representable one. If $a < x < b$ are the neighbours of
$x \notin \mathbb{F}$:

$$
\begin{aligned}
\operatorname{RN}(x) &= \text{the nearer of } a, b \text{ (ties to the even significand)} && \texttt{ToNearestEven}\\
\operatorname{RZ}(x) &= \text{the one of smaller magnitude} && \texttt{TowardZero}\\
\operatorname{RU}(x) &= b && \texttt{TowardPositive}\\
\operatorname{RD}(x) &= a && \texttt{TowardNegative}\\
\operatorname{RA}(x) &= \text{the one of larger magnitude} && \texttt{AwayFromZero}
\end{aligned}
$$

and every mode returns $x$ itself when $x \in \mathbb{F}$. Every mode is
*monotone*, $x \le y \Rightarrow \circ(x) \le \circ(y)$, and *idempotent* on
$\mathbb{F}$; the certification argument below uses only these two
properties.

**Relative error.** Let $x$ lie in the normal range,
$\beta^{e} \le |x| < \beta^{e+1}$ with $e_{\min} \le e \le e_{\max}$. The
neighbours of $x$ are $\varepsilon\beta^{e}$ apart, so a directed mode moves
$x$ by less than one spacing and round-to-nearest by at most half of one:

$$
\begin{aligned}
|\operatorname{RN}(x) - x| &\le \tfrac12\,\varepsilon\,\beta^{e} \le \tfrac12\,\varepsilon\,|x|,\\
|\circ_{\text{dir}}(x) - x| &< \varepsilon\,\beta^{e} \le \varepsilon\,|x|.
\end{aligned}
$$

Hence $\circ(x) = x(1 + \delta)$ with $|\delta| \le u$, where the *unit
roundoff* is

$$
u = \begin{cases}
\tfrac12\,\beta^{1-p} & \texttt{ToNearestEven},\\
\beta^{1-p} & \text{directed modes}.
\end{cases}
$$

| Format | $u$ for `ToNearestEven` |
| --- | --- |
| binary32 | $2^{-24} \approx 5.96 \times 10^{-8}$ |
| binary64 | $2^{-53} \approx 1.11 \times 10^{-16}$ |
| decimal32 | $5 \times 10^{-7}$ |
| decimal64 | $5 \times 10^{-16}$ |
| decimal128 | $5 \times 10^{-34}$ |

Below $\beta^{e_{\min}}$ the spacing stops shrinking, and the relative bound
becomes an absolute one: $|\operatorname{RN}(x) - x| \le \tfrac12\,\beta^{e_{\min}-p+1}$.
Above the largest finite number, $\circ(x)$ is $\pm\infty$ or the largest
finite number, depending on the mode. These are the `subnormal`, `underflow`
and `overflow` conditions of `ArithmeticDiagnostics`.

### The standard model of rounding error

IEEE 754 requires $+, -, \times, /$ and $\sqrt{\ }$ to be *correctly rounded*:
the computed result is the rounding of the exact one. With the bound above,
for operands in $\mathbb{F}$ and a result in the normal range,

$$
\operatorname{fl}(x \circ y) = (x \circ y)(1 + \delta), \qquad |\delta| \le u, \qquad \circ \in \{+, -, \times, /\}.
$$

This is the contract of the contextual arithmetic traits: a context-faithful
`AddContextual` returns $\operatorname{fl}(x + y)$ for the context's $p$ and
rounding mode, and raises `inexact` exactly when $\delta \ne 0$. It is also the
reason the context matters: for decimal64 and `ToNearestEven`, an algorithm
can rely on $|\delta| \le 5 \times 10^{-16}$ per operation, whatever the
backend type.

The built-in `Float` and `Double` instances satisfy the model for their own
fixed format under round-to-nearest, because the hardware operations are
correctly rounded, but they ignore the context's precision and mode and do not
detect $\delta \ne 0$. Their elementary functions come from
`Kaida-Amethyst/math` and are not guaranteed to be correctly rounded, so the
model holds for them only with an unspecified small multiple of $u$.

### Adjacent values and the IEEE encoding

`AdjacentContextual` computes

$$
\operatorname{succ}(x) = \min\{\, y \in \overline{\mathbb{F}} : y > x \,\},
\qquad
\operatorname{pred}(x) = \max\{\, y \in \overline{\mathbb{F}} : y < x \,\}.
$$

The `Float` and `Double` instances compute them on the bit pattern. An IEEE
binary value with sign $s$, biased exponent field $E$ and fraction field $F$
is stored as the unsigned integer $\operatorname{bits}(x) = s \cdot 2^{k-1} + E \cdot 2^{p-1} + F$
for a $k$-bit format. On the non-negative values this map is order-preserving:

- for a fixed $E$, the value $2^{E - \text{bias}}(1 + F\,2^{1-p})$ (or
  $2^{1-\text{bias}}\,F\,2^{1-p}$ when $E = 0$) increases strictly with $F$;
- the largest value with field $E$ is
  $2^{E-\text{bias}}(2 - 2^{1-p}) < 2^{E+1-\text{bias}}$, the smallest value with
  field $E + 1$; the subnormals ($E = 0$) all lie below the smallest normal
  $2^{1-\text{bias}}$;
- $+\infty$ is $E = 2^{k-p} - 1$, $F = 0$, above every finite pattern.

Because the encoding is lexicographic in $(E, F)$ and lexicographic order
on $(E, F)$ is integer order on $E \cdot 2^{p-1} + F$, it follows that for
$0 \le x < y$, $\operatorname{bits}(x) < \operatorname{bits}(y)$, and no
pattern lies strictly between consecutive values. Therefore

$$
\operatorname{succ}(x) =
\begin{cases}
\operatorname{bits}^{-1}(\operatorname{bits}(x) + 1) & x > 0,\\
\operatorname{bits}^{-1}(\operatorname{bits}(x) - 1) & x < 0 \quad (\text{since } \operatorname{succ}(x) = -\operatorname{pred}(|x|)),\\
\text{smallest positive subnormal} & x = \pm 0,
\end{cases}
$$

and symmetrically for $\operatorname{pred}$. The zero case is separate because
$+0$ and $-0$ are equal values with different patterns. The formula reproduces
the boundary cases listed in the [API](../api/core.md#adjacentcontextual): the
largest finite pattern plus one is the pattern of $+\infty$, and
$\operatorname{succ}(1) - 1 = \varepsilon$. Since $\operatorname{succ}(x)$ is
in $\overline{\mathbb{F}}$ by definition, no rounding happens and the empty
diagnostics of these instances are exact, not merely undetected.

### Enclosures and three-valued comparison

An *enclosure* $X \subseteq \mathbb{R}$ stands for an unknown real $x$ known to
satisfy $x \in X$: an interval $[a, b]$, or a ball
$B(m, r) = [m - r, m + r]$. The enclosure relation traits answer questions
about the unknown values from the enclosures alone, by quantifying over every
admissible pair:

$$
\begin{aligned}
\texttt{definitely\_lt}(X, Y) &\iff \forall x \in X,\ \forall y \in Y:\ x < y,\\
\texttt{definitely\_le}(X, Y) &\iff \forall x \in X,\ \forall y \in Y:\ x \le y,\\
\texttt{maybe\_eq}(X, Y) &\iff \exists x \in X,\ \exists y \in Y:\ x = y \iff X \cap Y \ne \emptyset,\\
\texttt{overlaps}(X, Y) &\iff X \cap Y \ne \emptyset,\\
\texttt{contains}(X, Y) &\iff Y \subseteq X.
\end{aligned}
$$

**Interval formulas.** Let $X = [a, b]$ and $Y = [c, d]$ be non-empty.

$$
\texttt{definitely\_lt}(X, Y) \iff b < c .
$$

($\Rightarrow$) take $x = b \in X$ and $y = c \in Y$. ($\Leftarrow$) for any
$x \in X$, $y \in Y$: $x \le b < c \le y$. The same argument with $\le$ gives
$\texttt{definitely\_le}(X, Y) \iff b \le c$. The *possible* relation is the
existential one:

$$
\exists x \in X,\ \exists y \in Y:\ x < y \iff a < d .
$$

($\Rightarrow$) $a \le x < y \le d$. ($\Leftarrow$) take $x = a$, $y = d$. It
needs no trait of its own, because it is the negation of a definite relation
with the arguments swapped:

$$
\neg\,\texttt{definitely\_le}(Y, X)
\iff \neg\,\forall y, x:\ y \le x
\iff \exists x, y:\ x < y
\iff a < d .
$$

Finally $X \cap Y \ne \emptyset \iff a \le d \wedge c \le b$: if both hold,
$\max(a, c) \le \min(b, d)$ is a common point; conversely a common point $z$
gives $a \le z \le d$ and $c \le z \le b$. For balls, substituting the
endpoints gives
$\texttt{definitely\_lt}(B(m_1, r_1), B(m_2, r_2)) \iff m_1 + r_1 < m_2 - r_2$.

**Three-valued truth.** From enclosures alone, "$x < y$" has one of three
truth values:

$$
[\![\, x < y \,]\!] =
\begin{cases}
\mathsf{T} & \texttt{definitely\_lt}(X, Y),\\
\mathsf{F} & \texttt{definitely\_le}(Y, X),\\
\mathsf{U} & \text{otherwise}.
\end{cases}
$$

The value is well defined: $\mathsf{T}$ and $\mathsf{F}$ together would need
$b < c$ and $d \le a$, hence $a \le b < c \le d \le a$, a contradiction. In the
same way $[\![\, x = y \,]\!]$ is $\mathsf{F}$ when $\neg\,\texttt{maybe\_eq}(X, Y)$
and $\mathsf{U}$ otherwise, unless both enclosures are the same single point.
Compound conditions combine with Kleene's strong three-valued logic:

| $p$ | $q$ | $\neg p$ | $p \wedge q$ | $p \vee q$ |
| --- | --- | --- | --- | --- |
| $\mathsf{T}$ | $\mathsf{T}$ | $\mathsf{F}$ | $\mathsf{T}$ | $\mathsf{T}$ |
| $\mathsf{T}$ | $\mathsf{U}$ | $\mathsf{F}$ | $\mathsf{U}$ | $\mathsf{T}$ |
| $\mathsf{T}$ | $\mathsf{F}$ | $\mathsf{F}$ | $\mathsf{F}$ | $\mathsf{T}$ |
| $\mathsf{U}$ | $\mathsf{T}$ | $\mathsf{U}$ | $\mathsf{U}$ | $\mathsf{T}$ |
| $\mathsf{U}$ | $\mathsf{U}$ | $\mathsf{U}$ | $\mathsf{U}$ | $\mathsf{U}$ |
| $\mathsf{U}$ | $\mathsf{F}$ | $\mathsf{U}$ | $\mathsf{F}$ | $\mathsf{U}$ |
| $\mathsf{F}$ | $\mathsf{T}$ | $\mathsf{T}$ | $\mathsf{F}$ | $\mathsf{T}$ |
| $\mathsf{F}$ | $\mathsf{U}$ | $\mathsf{T}$ | $\mathsf{F}$ | $\mathsf{U}$ |
| $\mathsf{F}$ | $\mathsf{F}$ | $\mathsf{T}$ | $\mathsf{F}$ | $\mathsf{F}$ |

Reading $\mathsf{U}$ as "true for some admissible values and false for
others", each entry is the strongest statement that holds for all of them; for
example $\mathsf{F} \wedge \mathsf{U} = \mathsf{F}$ because a conjunction with
a false conjunct is false whatever the other one is.[^kleene]

[^kleene]: S. C. Kleene, *Introduction to Metamathematics*, 1952, §64. Interval
    comparison with three outcomes goes back to R. E. Moore, *Interval
    Analysis*, 1966.

The table is exact only when the unknowns behind $p$ and $q$ vary
independently. When both conditions mention the same unknown, Kleene's logic
is sound but may be too weak: with $X = [0, 2]$, the condition
$x < 1 \vee \neg(x < 1)$ is true for every $x$, yet the table gives
$\mathsf{U} \vee \neg\mathsf{U} = \mathsf{U}$. A $\mathsf{T}$ or
$\mathsf{F}$ from the table is always correct; a $\mathsf{U}$ may hide a
decided answer. This is the dependency problem of interval arithmetic, and
the remedy is the same: rewrite the condition so that each unknown appears
once, or split the enclosure.

### Certification stages

A proof-backed backend computes $\circ_{p_t}(f(x))$, the correct rounding of a
transcendental $f$ at target precision $p_t$, by a pipeline whose stages are
the values of `CertificationStage`. For $f = \exp$ as an illustration:

1. `RangeReduction`: write $x = k \ln 2 + r$ with $k \in \mathbb{Z}$ and
   $|r| \le \tfrac12 \ln 2$, so that $\exp(x) = 2^{k}\exp(r)$. The reduced
   argument $r$ must itself be enclosed, which costs about
   $\log_2 |x|$ extra bits of $\ln 2$.
2. `SeriesEvaluation`: sum $\sum_{j<N} r^{j}/j!$ and bound the tail. For
   $|r| < N + 1$,

   $$
   \Bigl|\sum_{j \ge N} \frac{r^{j}}{j!}\Bigr|
   \le \frac{|r|^{N}}{N!}\sum_{i \ge 0}\Bigl(\frac{|r|}{N+1}\Bigr)^{i}
   = \frac{|r|^{N}}{N!}\cdot\frac{1}{1 - |r|/(N+1)},
   $$

   using $\frac{N!}{(N+i)!} \le (N+1)^{-i}$.
3. `EnclosurePropagation`: carry the truncation bound and every rounding error
   of the working precision $p_w > p_t$ through the remaining operations,
   obtaining an enclosure $[\ell, h] \ni f(x)$.
4. `TargetRounding`: if $\circ_{p_t}(\ell) = \circ_{p_t}(h)$, that value is the
   answer, because by monotonicity

   $$
   \ell \le f(x) \le h
   \;\Longrightarrow\;
   \circ_{p_t}(\ell) \le \circ_{p_t}(f(x)) \le \circ_{p_t}(h) = \circ_{p_t}(\ell).
   $$

   Otherwise $[\ell, h]$ straddles a rounding boundary: the backend raises
   $p_w$ and repeats, which is Ziv's strategy.[^ziv]

[^ziv]: A. Ziv, "Fast evaluation of elementary mathematical functions with
    correctly rounded last bit", *ACM TOMS* 17(3), 1991. How close $f(x)$ can
    come to a boundary is the *table maker's dilemma*; for most functions no
    useful a-priori bound on $p_w$ is known, which is why the loop needs a
    budget.

When the loop gives up, the backend returns
`ArithmeticError::certification_failure` with the stage, the reason, $p_t$
(`target_precision`), the last $p_w$ (`work_precision`) and the number of
increases (`refinements`). `RefinementBudgetExhausted` is the expected reason
at `TargetRounding`; the other reasons belong to the earlier stages. This
package defines the vocabulary only; it evaluates nothing.

## Decisions in detail

### Three tiers instead of one signature

**Problem.** A square root on `Double` in a tight loop wants
`fn sqrt(Double) -> Double` and accepts NaN for a negative argument. A decimal
backend needs the precision and rounding mode and must report whether the
result was rounded. One signature cannot serve both without either forcing a
`Result` and a context on every native call or dropping information that the
decimal caller needs.

**Options.** (a) unchecked traits only; (b) contextual traits only; (c) three
independent tiers.

**Choice.** (c). The tiers carry increasing information, and each result type
embeds into the next one:

$$
\underbrace{T}_{\text{unchecked}}
\;\xrightarrow{\;v \,\mapsto\, \mathrm{Ok}(v)\;}\;
\underbrace{\mathrm{Result}[T, E]}_{\text{checked}}
\;\xrightarrow{\;\mathrm{Ok}(v) \,\mapsto\, \mathrm{Ok}(v, \mathbf{0})\;}\;
\underbrace{\mathrm{Result}[(T, D), E]}_{\text{contextual}},
$$

where $D$ is the diagnostics set and $\mathbf{0}$ its empty value. The
built-in contextual adapters, except the `Float` integer embedding, are
exactly these embeddings applied to the checked or unchecked result. A bound states what the algorithm handles:
`T : Sqrt` accepts the backend's own behaviour, `T : SqrtChecked` handles
rejection, `T : SqrtContextual` needs context and diagnostics. The tiers have
no supertrait links, so a type implements exactly the tiers it honours: an
interval type can implement `DivChecked` and the enclosure relations without
pretending to have a context-free `Sqrt`.

### Context and diagnostics are explicit values

**Problem.** IEEE 754 describes the rounding direction and the status flags
as attributes of the execution environment; C exposes them through
`<fenv.h>`, and Python's `decimal` keeps a thread-local current context. Both
are hidden state: the result of `a + b` depends on something that is not an
argument, and a flag raised in one computation is still set in the next.

**Options.** (a) a global mutable context; (b) a thread- or task-local one;
(c) the context as an argument and the flags in the return value.

**Choice.** (c). Every contextual operation is a function

$$
\operatorname{op} : T^{n} \times \texttt{ArithmeticContext} \to \mathrm{Result}[(T, D), E],
$$

so equal inputs give equal outputs, and the diagnostics of a computation are
exactly those of the operations it combined. This works the same on every
MoonBit target (none of them needs thread-local storage), makes concurrent use
safe, and lets a test state the full input of an operation. The cost is
verbosity, which a backend can reduce with its own helpers.

### Errors, diagnostics and certification failures are separate

**Problem.** IEEE 754 has five exceptions: invalid operation, division by zero,
overflow, underflow and inexact. Some describe results that do not exist,
others describe results that exist but were rounded.

**Choice.** The package splits them by whether a value is returned:

| Situation | Channel | IEEE 754 counterpart |
| --- | --- | --- |
| no meaningful value (domain, indeterminate form) | `Err`, `DomainError` | invalid operation |
| a pole: finite non-zero over zero | `Err`, `DivisionByZero` | division by zero |
| a value in $\overline{\mathbb{F}}$ that differs from the exact one | `Ok` with `inexact`, `rounded` | inexact |
| a value beyond the finite range or below the normal range | `Ok` with `overflow`, `underflow`, `subnormal` | overflow, underflow |
| a valid input whose result could not be certified | `Err`, `CertificationFailure` | none |

A flag must not hide an error, and an error must not be invented to carry a
flag: $\operatorname{fl}(10^{300} \times 10^{300}) = +\infty$ is a correct
IEEE answer, so it is a value with `overflow`, not a failure. A certification
failure is an error but not a domain error: the input is valid and a larger
budget may succeed, so it carries the data a caller needs to decide whether to
retry. The package imposes no retry policy.

### Enclosure relations are not an order

**Problem.** Intervals look ordered, and implementing `Compare` for them would
let generic sorting code accept them.

**Choice.** Five separate relation traits. `Compare` promises a total order,
but `definitely_lt` on non-empty intervals is only a strict partial order. It
is irreflexive ($b < a$ fails for $[a, b]$) and transitive:

$$
b_1 < c_2 \;\wedge\; b_2 < c_3
\;\Longrightarrow\;
b_1 < c_2 \le b_2 < c_3
\;\Longrightarrow\;
b_1 < c_3 ,
$$

but not total: for overlapping $X, Y$ neither $\texttt{definitely\_lt}(X, Y)$
nor $\texttt{definitely\_lt}(Y, X)$ holds, and neither are they equal. A
`Compare` instance would have to answer one of $<, =, >$ there and so would
assert something false about the unknown values.

### Native scalars implement only what they can honour

**Problem.** `Float` and `Double` could implement every trait by ignoring the
context.

**Choice.** They implement a capability only when the result is meaningful:

- all unchecked traits and `Power`, which promise nothing beyond the backend;
- the checked traits, whose only extra promise is to reject invalid arguments;
- the contextual arithmetic, absolute value, square root and exponential,
  integer embedding, adjacent values and format queries, as adapters so that
  generic contextual code also runs on native scalars;
- not `ConstantsContextual` and `HyperbolicContextual`, whose purpose is a
  result that honours an arbitrary precision with meaningful diagnostics; a
  fixed-precision library function cannot provide that.

The adapters are honest where the fixed format makes them exact (adjacent
values, `Double` integer embedding) and detect loss where it is cheap (`Float`
integer embedding, below). The arithmetic adapters do not detect rounding:
their empty diagnostics mean "not detected". The [API page](../api/core.md#contextual-capability-traits)
states this at the point of use.

### One capability per trait, no `Real`

A trait such as `Real : Field + Sqrt + Exponential + Trigonometric + Compare`
would be convenient, but it would hide differences that matter: an interval
type has no total order, a decimal type has no cheap `sin`, and an integer
type has `Power` but no `Sqrt`. Every trait in this package is one capability,
and an algorithm composes the bounds it uses, such as
`T : Add + Mul + Sqrt` for a hypotenuse. `Radical` is the only conjunction,
because square and cube roots are routinely needed together.

### Three floating-point classes

IEEE 754 `class` distinguishes ten classes (signalling and quiet NaN,
negative and positive infinity, normal, subnormal and zero). `FpClass` keeps
three, because these are the cases generic code branches on: a finite value
can enter further arithmetic, an infinity is a valid limit, and NaN is
invalid. Sign, zero and subnormality are tested with the format's own API.

### `IntegralContextual` embeds `Int` only

Every backend can receive a MoonBit `Int`, and loop counters and indices are
`Int`. An embedding of `BigInt` would require arbitrary-precision rounding in
every backend; it is left to a separate capability so that implementing the
common case stays cheap.

### `Power` keeps one signature

`Power::pow(Self, Self)` is the same for floating and integer types, so a
generic power does not depend on the family. The price is that the exponent
type is the base type: the signed and `BigInt` instances must abort on a
negative exponent, since $x^{-n} \notin \mathbb{Z}$ in general. Code that
needs a defined failure uses `PowNatChecked` (exponent `UInt`) or
`PowIntChecked` (exponent `Int`).

## Correctness and invariants

### Context invariants

`ArithmeticContext::new` establishes $p \ge 1$ by clamping and
$e_{\min} \le e_{\max}$ (when both are present) by aborting, and the fields are
read-only outside the package. Every context value therefore satisfies both,
and a backend need not re-check them.

### Laws of `combine`

`ArithmeticDiagnostics` is the Boolean lattice $D = \{0, 1\}^{6}$, and
`combine` is the componentwise $\vee$. Because each component satisfies the
Boolean laws, for all $d_1, d_2, d_3 \in D$:

$$
\begin{aligned}
(d_1 \vee d_2) \vee d_3 &= d_1 \vee (d_2 \vee d_3) && \text{associativity}\\
d_1 \vee d_2 &= d_2 \vee d_1 && \text{commutativity}\\
d \vee d &= d && \text{idempotence}\\
d \vee \mathbf{0} &= d && \mathbf{0} = \texttt{empty()}
\end{aligned}
$$

So $(D, \vee, \mathbf{0})$ is a commutative idempotent monoid, that is a join
semilattice with a least element. The diagnostics of a computation are the
join of the diagnostics of its steps, independent of evaluation order and
grouping, and a flag once raised cannot be cleared by combining.

### Sequencing contextual operations

Composing two contextual operations $f : A \to \mathrm{Result}[(B, D), E]$ and
$g : B \to \mathrm{Result}[(C, D), E]$ gives

$$
(g \mathbin{\bar\circ} f)(a) =
\begin{cases}
\mathrm{Err}(e) & f(a) = \mathrm{Err}(e),\\
\mathrm{Err}(e) & f(a) = \mathrm{Ok}(b, d_1),\ g(b) = \mathrm{Err}(e),\\
\mathrm{Ok}(c, d_1 \vee d_2) & f(a) = \mathrm{Ok}(b, d_1),\ g(b) = \mathrm{Ok}(c, d_2).
\end{cases}
$$

This is the writer monad over $(D, \vee, \mathbf{0})$ stacked on the error
monad, and the monoid laws above are exactly what makes
$\bar\circ$ associative with `ArithmeticOutcome::exact` as its identity.[^writer]
The package ships the pieces (`exact`, `with_diagnostics`, `combine`) rather
than a combinator; the [tutorial](../tutorial/core.md) shows a short
helper.

[^writer]: Associativity of $\bar\circ$ reduces to associativity of $\vee$
    on the diagnostics and of function composition on the values; the
    identity law reduces to $d \vee \mathbf{0} = d$. See E. Moggi, "Notions of
    computation and monads", 1991.

### Integer embedding into `Float`

binary32 has $p = 24$. An integer $n$ with $|n| \le 2^{24}$ has at most 24
significant bits (or is $2^{24}$ itself, a power of two), so it is
representable; $2^{24} + 1$ needs 25 significant bits and is not, and round-to-nearest-even
sends it to $2^{24}$. The `Float` instance detects the loss without a
wide-integer comparison: binary64 has $p = 53 > 31$, so
`Double::from_int` is exact on every `Int`, and every binary32 value is a
binary64 value, so widening is exact. Hence

$$
\operatorname{double}(\operatorname{RN}_{32}(n)) = \operatorname{double}(n)
\iff \operatorname{RN}_{32}(n) = n ,
$$

and the instance sets `inexact` and `rounded` exactly when the conversion lost
information. Overflow cannot occur, since $|n| \le 2^{31} < 2^{128}$.

### Error bound of binary powering

`PowNatChecked` for `Float` and `Double` computes $x^{n}$ with the loop

$$
\textit{acc} \leftarrow 1,\ \textit{f} \leftarrow x,\ k \leftarrow n;\quad
\text{while } k > 0:\ \text{if } k \text{ odd}: \textit{acc} \leftarrow \textit{acc}\cdot \textit{f};\ k \leftarrow \lfloor k/2 \rfloor;\ \text{if } k > 0: \textit{f} \leftarrow \textit{f}^{2}.
$$

**Correctness.** In exact arithmetic $\textit{acc}\cdot \textit{f}^{\,k} = x^{n}$
holds at the start of every iteration. It holds initially, and if $k = 2j + 1$
then $\textit{acc}\,\textit{f}\cdot(\textit{f}^{2})^{j} = \textit{acc}\,\textit{f}^{\,k}$,
while if $k = 2j$ then $\textit{acc}\,(\textit{f}^{2})^{j} = \textit{acc}\,\textit{f}^{\,k}$.
At $k = 0$ the invariant gives $\textit{acc} = x^{n}$. The loop runs
$\lfloor \log_2 n \rfloor + 1$ times and performs $\lfloor\log_2 n\rfloor$
squarings and $\operatorname{popcount}(n)$ products, the first of which
($1 \cdot \textit{f}$) is exact. The integer `Power` instances use the same
invariant in $\mathbb{Z}/2^{k}$, where every step is exact.

**Rounding error.** Give each computed quantity $q$ that approximates $x^{m}$
an error count $c(q)$ such that $q = x^{m}\prod_i (1 + \delta_i)^{k_i}$ with
$|\delta_i| \le u$ and $\sum_i k_i \le c(q)$. Then $c(x) = 0$, and one rounded
product of $q_1 \approx x^{m_1}$ and $q_2 \approx x^{m_2}$ gives
$c \le c(q_1) + c(q_2) + 1$. The initial $\textit{acc} = 1$ approximates
$x^0$ exactly, and its first product $1 \cdot \textit{f}$ is exact, so after it
$\textit{acc}$ carries the count of $\textit{f}$. Every other quantity the loop
computes has $m \ge 1$, and by induction $c(q) \le m - 1$:

$$
c(q_1 q_2) \le (m_1 - 1) + (m_2 - 1) + 1 = (m_1 + m_2) - 1,
$$

and a squaring is the case $q_1 = q_2$, where the shared error is counted
twice. Therefore, in the absence of overflow and underflow,

$$
\operatorname{fl}(x^{n}) = x^{n}(1 + \theta_{n-1}),
\qquad
|\theta_{n-1}| \le (1 + u)^{n-1} - 1 \le \gamma_{n-1} := \frac{(n-1)u}{1 - (n-1)u}.
$$

The last step is the standard lemma
$|\prod_{i=1}^{k}(1+\delta_i)^{\pm 1} - 1| \le \gamma_k$ for $ku < 1$.[^higham]
`PowIntChecked` with a negative exponent divides once more, and
$(1 + \delta)/(1 + \theta_{n-1})$ gives $|\theta| \le \gamma_{n}$. Binary
powering does not improve on the worst-case bound of $n - 1$ successive
multiplications; it reduces the work from $n - 1$ to $O(\log n)$
multiplications.

[^higham]: N. J. Higham, *Accuracy and Stability of Numerical Algorithms*,
    2nd ed., SIAM, 2002, Lemma 3.1 and §3.1.

### Laws of `Power`

For the integer instances, `pow(x, n)` is the action of $\mathbb{N}$ on the
multiplicative monoid $(\mathbb{Z}/2^{k}, \cdot, 1)$ (or $(\mathbb{Z}, \cdot, 1)$
for `BigInt`), defined by $x^{0} = 1$ and $x^{n+1} = x^{n} x$. The
correctness invariant above shows that binary powering computes this map,
because every step is exact in $\mathbb{Z}/2^{k}$ and the reduction modulo
$2^{k}$ is a ring homomorphism $\mathbb{Z} \to \mathbb{Z}/2^{k}$. Induction
on $n$ gives the action laws for natural exponents:

$$
\begin{aligned}
x^{m+n} &= x^{m} x^{n}, &\quad
x^{mn} &= (x^{m})^{n}, &\quad
(xy)^{n} &= x^{n} y^{n}.
\end{aligned}
$$

The first follows from $x^{m+(n+1)} = x^{m+n}x = x^{m}x^{n}x = x^{m}x^{n+1}$
(associativity); the second from $x^{m(n+1)} = x^{mn+m} = (x^{m})^{n}x^{m}$
by the first; the third from commutativity of $\cdot$.

These are laws of $\mathbb{N}$ acting on `Self`, but the exponent argument is
a value of `Self`. For the unsigned instances an exponent sum computed in
`Self` wraps modulo $2^{k}$. The wrapped law
$x^{(m+n) \bmod 2^{k}} = x^{m} x^{n}$ needs $x^{2^{k}} = 1$, and it fails for
every even $x$, for example:

$$
2^{2^{32}-1} \cdot 2^{1} = 0 \cdot 2 = 0 \ne 1 = 2^{0} \pmod{2^{32}} .
$$

For odd $x$ the group $(\mathbb{Z}/2^{k})^{\times}$ has exponent $2^{k-2}$ (for
$k \ge 3$), so $x^{2^{k}} = 1$ and the wrapped law holds. For the signed
instances a wrapped sum is often negative and `pow` aborts. Code that
combines exponents therefore adds them in a wider type, or in `BigInt`.

The `Float` and `Double` instances are the C `pow` function. The laws above
hold for them only approximately, with the rounding error of each side, and
not at all for a negative base with a non-integer exponent, where the result
is NaN.

### Checked division

The `Float` and `Double` `DivChecked` instances reject every zero divisor and
use the kind to say why. $0/0$ and $\infty/\infty$ are indeterminate: the
limits $\lim (\lambda t)/t = \lambda$ take every value as $t \to 0$ or
$t \to \infty$, so no quotient is meaningful and the kind is `DomainError`.
For $x \ne 0$, $x/t$ diverges as $t \to 0$, a pole, and the kind is
`DivisionByZero`. This matches IEEE 754's invalid operation and division by
zero exceptions, but is stricter: IEEE returns $\pm\infty$ for $\infty/0$ and
NaN for NaN$/0$ silently, where the checked instance returns
`DivisionByZero`. A NaN dividend with a non-zero divisor still propagates as
`Ok(NaN)`, and `SqrtChecked` lets NaN pass in the same way: a checked
operation rejects invalid arguments, it does not re-report an earlier
invalid result.

### Soundness and monotonicity of enclosure relations

*Soundness.* If $x \in X$, $y \in Y$ and $\texttt{definitely\_lt}(X, Y)$, then
$x < y$: the relation is a universal statement over $X \times Y$, which
contains $(x, y)$. Dually, if $\neg\,\texttt{maybe\_eq}(X, Y)$, then
$x \ne y$.

*Monotonicity under refinement.* If $X' \subseteq X$ and $Y' \subseteq Y$,
then

$$
\texttt{definitely\_lt}(X, Y) \Rightarrow \texttt{definitely\_lt}(X', Y'),
\qquad
\texttt{maybe\_eq}(X', Y') \Rightarrow \texttt{maybe\_eq}(X, Y),
$$

because a universal statement survives shrinking its domain and an
existential one survives growing it. In three-valued terms, refining the
enclosures can turn $\mathsf{U}$ into $\mathsf{T}$ or $\mathsf{F}$ but never
turns $\mathsf{T}$ into $\mathsf{F}$. This is what makes "refine until decided"
loops, such as the target-rounding stage above, correct: a decision once made
stays valid. `Contains` is how such a loop checks that a refined enclosure
$X'$ is inside the old one, $\texttt{contains}(X, X')$.

The traits do not fix the convention for empty enclosures; each backend
documents its own. Under the quantifier reading the definite relations would
hold vacuously for an empty argument, so a backend that wants $\mathsf{T}$ never
to come from an absence of information returns `false` for them instead.

## Alternatives rejected

- **A global or thread-local context with sticky flags**, as in C `<fenv.h>`
  and Python `decimal`. Rejected for the reasons under
  [explicit values](#context-and-diagnostics-are-explicit-values): it makes
  results depend on hidden state and leaks flags between computations.
- **A `Real` or `Number` super-trait.** Rejected because it hides the
  differences between exact, approximate and enclosure-valued types.
- **`Compare` for enclosures.** Rejected because the definite order is not
  total.
- **A three-valued result type** (`True | False | Unknown`) for comparisons.
  The two Boolean projections `definitely_*` and `maybe_eq` are enough to
  reconstruct it, as shown above, and they compose with ordinary `if`; a
  separate type would force every caller to handle $\mathsf{U}$ even when it
  only asks one direction.
- **A `definitely_eq` relation.** For non-degenerate enclosures it is always
  false, so it would only be a test for equal single points.
- **Diagnostics reported as errors.** Rejected because an inexact or
  overflowing IEEE result is a correct answer, and turning it into `Err`
  would make every rounded operation fail.
- **`Option` or `raise` for checked results.** `Option` loses the reason;
  MoonBit's `raise` would put the failure outside the return type. Luna-Flow
  uses `Result` with a structured error across repositories.
- **Implementing `ConstantsContextual` and `HyperbolicContextual` for native
  scalars by ignoring the context.** Rejected because those traits exist to
  promise context-faithful results.

## Boundaries

- The package does not implement arbitrary-precision, decimal, interval or
  ball arithmetic, and it does not evaluate certified functions; it defines
  the traits those backends implement.
- The built-in `Float` and `Double` instances do not honour the context's
  precision, rounding mode or exponent range, and their arithmetic adapters do
  not detect rounding, overflow or underflow.
- It does not promise correctly rounded elementary functions for `Float` and
  `Double`; they come from `Kaida-Amethyst/math`.
- It does not define algebraic structure (`Ring`, `Field`, ...), which belongs
  to `luna-generic`, nor vectors, matrices, complex numbers or polynomials.
- It does not choose branch cuts or special-value conventions for the
  unchecked traits beyond what each shipped instance inherits.
- It does not prescribe a retry or precision-escalation policy for
  certification failures.

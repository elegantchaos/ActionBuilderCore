# Engineering Principles

Relevance: include this file for most software projects. It defines shared design and implementation principles for humans and agents.

## Scope

Use this file as a cross-language decision baseline. For language/tool specifics, use the language and technology modules.

## How to apply these principles

- Treat principles as heuristics, not rigid laws.
- If principles conflict, use this priority order:
  1. User-visible correctness and safety
  2. Long-term maintainability
  3. Simplicity and clarity
  4. Performance optimization
  5. Flexibility for hypothetical future needs
- If a change increases complexity, state why that complexity is necessary now.
- Prefer local, focused changes over broad refactors unless architecture changes are required.
- Keep public surface area intentionally small.
- Align with established project patterns unless there is a clear, documented reason to diverge.

## Principles

### KISS (Keep It Simple)

Intent: Prefer the simplest implementation that meets current requirements.
Do:
- choose direct solutions with minimal moving parts
- remove unnecessary abstraction layers
Don't:
- introduce generic frameworks for one-off behavior
- add configurability without concrete need
Tradeoff: Simple local code can duplicate some structure; combine with DRY when duplication becomes costly.

### YAGNI (Build What Is Needed)

Intent: Avoid speculative flexibility.
Do:
- implement only validated current requirements
- delay abstraction until concrete reuse appears
Don't:
- design extension points for imagined scenarios
- expose broad APIs "just in case"
Tradeoff: Deferring generalization can require later refactors; this is preferred to upfront over-engineering.

### DRY (Don't Repeat Yourself)

Intent: Reduce duplication that increases defects and maintenance cost.
Do:
- deduplicate business rules before presentation details
- keep one authoritative source for mutable facts
Don't:
- repeat the same rule in multiple modules
- force abstractions across unrelated contexts
Tradeoff: Over-deduplication can hide intent; keep duplication when it preserves clarity and boundaries.

### Make Illegal States Unrepresentable

Intent: Prevent invalid states through types and constrained interfaces.
Do:
- model domains with enums/value objects/refined types
- encode invariants at construction boundaries
Don't:
- rely only on late runtime checks for core invariants
- represent constrained states as unconstrained primitives
Tradeoff: Richer types increase model complexity but reduce runtime error paths.

### Dependency Injection

Intent: Make dependencies explicit and replaceable.
Do:
- inject collaborators via constructor or parameters
- keep side-effecting resources behind explicit interfaces
Don't:
- hide dependencies in globals or singletons
- bind logic directly to concrete infrastructure where avoidable
Tradeoff: Extra wiring overhead buys testability and composability.

### Composition Over Inheritance

Intent: Build behavior from small composable units rather than deep hierarchies.
Do:
- compose capabilities with protocols/interfaces and focused types
- prefer delegation over inheritance trees
Don't:
- use inheritance for code reuse when behavior is not truly subtype-compatible
- create deep inheritance stacks with implicit coupling
Tradeoff: Composition can introduce more objects but improves change isolation.

### Command-Query Separation (CQS)

Intent: Keep mutation and information retrieval separate.
Do:
- make commands mutate state without returning derived query data
- make queries return data without side effects
Don't:
- mix mutation and complex reads in one operation
- hide writes inside query-like APIs
Tradeoff: More explicit API shape can mean extra calls but lowers surprise and coupling.

### Law of Demeter (Least Knowledge)

Intent: Minimize coupling across module boundaries.
Do:
- keep interactions with direct collaborators
- expose focused interfaces at boundaries
Don't:
- chain through internal object graphs
- depend on transitive implementation details
Tradeoff: Wrapping dependencies can add adapter code but improves modularity.

### Structured Concurrency

Intent: Make concurrency lifetimes and ownership explicit.
Do:
- scope async work to clear task/actor/thread boundaries
- define ownership for shared mutable state
Don't:
- spawn unscoped background work without lifecycle management
- share mutable state across concurrency domains without protection
Tradeoff: Structured orchestration can add ceremony but improves correctness and cancellation behavior.

### Design by Contract

Intent: Define and enforce preconditions, postconditions, and invariants at boundaries.
Do:
- validate assumptions at module and API boundaries
- fail early with clear diagnostics when contracts are violated
Don't:
- allow silent contract violations to propagate
- rely on callers inferring hidden preconditions
Tradeoff: Runtime checks have small overhead but reduce ambiguity and debugging cost.

### Idempotency

Intent: Make repeated execution of the same side-effecting request safe where feasible.
Do:
- use idempotency keys for retried create/update operations
- ensure retries converge to one externally visible result
Don't:
- make retries produce duplicate side effects
- couple retry behavior to unstable timing assumptions
Tradeoff: Idempotency requires state tracking but is critical for resilient distributed workflows.

## Agent Checklist

Use this before finalizing non-trivial changes:
- Is correctness and safety preserved under expected and failure paths?
- Is the simplest viable approach used?
- Are speculative abstractions avoided?
- Is duplicated business logic eliminated or intentionally justified?
- Are dependencies explicit?
- Are command/query boundaries clear?
- Are module boundaries low-coupling (Law of Demeter)?
- Is concurrency scoped with explicit ownership?
- Are contracts and invariants enforced at boundaries?
- Are retried side effects idempotent where needed?

## Guidance for Agent Outputs

- Keep diffs focused and easy to review.
- Briefly explain architectural tradeoffs when changing structure.
- If adding abstraction, name the concrete duplication or risk it resolves.

## References (Appendix)

| Principle | Primary reference |
| --- | --- |
| KISS | C.A.R. Hoare, "The Emperor's Old Clothes" (1981), https://dl.acm.org/doi/10.1145/358549.358561 |
| YAGNI | Martin Fowler, "YAGNI", https://martinfowler.com/bliki/Yagni.html |
| DRY | Andrew Hunt and David Thomas, "The Pragmatic Programmer" |
| Make Illegal States Unrepresentable | Alexis King, "Parse, don't validate", https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/ |
| Dependency Injection | Martin Fowler, "Inversion of Control Containers and the Dependency Injection pattern", https://martinfowler.com/articles/injection.html |
| Composition Over Inheritance | Erich Gamma et al., "Design Patterns"; Joshua Bloch, "Effective Java" |
| Command-Query Separation | Bertrand Meyer, "Object-Oriented Software Construction"; Martin Fowler, "CommandQuerySeparation", https://martinfowler.com/bliki/CommandQuerySeparation.html |
| Law of Demeter | Karl Lieberherr et al., OOPSLA 1988, https://dl.acm.org/doi/10.1145/62083.62084 |
| Structured Concurrency | Swift Evolution SE-0304, https://github.com/swiftlang/swift-evolution/blob/main/proposals/0304-structured-concurrency.md |
| Design by Contract | Eiffel, "Design by Contract", https://www.eiffel.org/doc/eiffel/ET-_Design_by_Contract_%28tm%29%2C_Assertions_and_Exceptions |
| Idempotency | RFC 9110 Section 9.2.2, https://www.rfc-editor.org/rfc/rfc9110#section-9.2.2 |

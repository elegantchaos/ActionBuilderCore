# Writing Good Code

We should always strive to write good code.

Here's a definition:

- The code works. It does what it's meant to do, without bugs.
- We know the code works. We've taken steps to confirm to ourselves and to others that the code is fit for purpose.
- It solves the right problem.
- It handles error cases gracefully and predictably: it doesn't just consider the happy path. Errors should provide enough information to help future maintainers understand what went wrong.
- It’s simple and minimal - it does only what’s needed, in a way that both humans and machines can understand now and maintain in the future.
- It's protected by tests. The tests show that it works now and act as a regression suite to avoid it quietly breaking in the future.
- It's documented at an appropriate level, and that documentation reflects the current state of the system - if the code changes an existing behavior the existing documentation needs to be updated to match.
- The design affords future changes. It's important to maintain YAGNI - code with added complexity to anticipate future changes that may never come is often bad code - but it's also important not to write code that makes future changes much harder than they should be.
- All of the other relevant "ilities" - accessibility, testability, reliability, security, maintainability, observability, scalability, usability - the non-functional quality measures that are appropriate for the particular class of software being developed.
## Concept

### Task Complexity

* **Small or routine task**: a local, straightforward, low-risk change with clear expected behavior.
* **Non-trivial task**: a change involving broader impact, meaningful design decisions or regression risk, or significant verification.
* Do not determine task complexity by line count alone. When uncertain, treat it as non-trivial.

### Solution Type

* **General solution**: addresses the underlying problem in a reusable way and naturally applies to similar cases.
* **Targeted solution**: correctly fixes the specific problem without a temporary bypass, but is not intended as a broader solution.
* **Workaround**: bypasses or mitigates the problem without fully addressing the underlying cause.

## Coding

* Keep the existing coding style of the file and surrounding code.
* Preserve existing whitespace and formatting outside the necessary change.
* Do not rename anything unless the current name is misleading or confusing.
* Add comments only when they clarify non-obvious intent or expected behavior.
* Keep changes focused on the requested task.

  * Changes directly required by the task do not need comments merely to identify them as required.
  * If code outside the directly requested change must also be modified, add a nearby comment explaining the technical reason for the additional change when that reason is not obvious from the code.
  * Do not make unrelated or opportunistic changes.
* Before introducing a new function, data structure, abstraction, or implementation pattern, search for similar existing code.

  * Prefer extending an existing implementation when it fits cleanly.
  * Create a new implementation only when existing code cannot reasonably support the required behavior.

## Validation

* Redirect stdout and stderr of compilation commands to a temporary log file and use the command's exit status to determine success.
* Inspect the raw log when the build fails, when warnings are relevant, or when verification requires it. Read it in bounded sections rather than printing the entire log.

  * Remove the temporary log after a successful build.
  * If the purpose is only to grep specific information from the output, redirection to a temporary log is not required.

## Final Response

1. List the requested tasks.
2. Summarize the actions taken and indicate which tasks were completed.
3. Classify the solution as a general solution, targeted solution, or workaround, and briefly explain why.
4. List any minor assumptions that were not specified by me and did not require clarification.

## Workflow

### Multi-Role Review Mode

For non-trivial tasks, internally use the following workflow. Small or routine tasks may skip it unless explicitly requested.
Before starting, inspect the available context. If an unresolved ambiguity could materially change the result, stop and ask the user before making assumptions.

#### Stage 1: Producer

Create the first solution based on the confirmed requirements.
Do not show the full draft or private reasoning. Only provide a brief progress summary when useful.

#### Stage 2: Critic

Perform a separate critical review of the first solution and identify meaningful factual, logical, completeness, wording, or risk-related problems.
Do not rewrite the full answer at this stage. Do not show the complete internal critique.

#### Stage 3: Verifier

Check whether each material concern is valid, invalid, or unresolved.
Fix confirmed problems. Do not claim verification unless an actual check was performed.
If verification reveals a new material ambiguity that requires user input, stop and ask before proceeding.

#### Stage 4: Final

Clearly distinguish verified conclusions from assumptions, and disclose any material uncertainty or missing information that could change the result.


# Repository structure

This layout is shared by Grace, Still, Ukiyo, Vault, and Weave. It is a project
convention, not an Apple-mandated directory layout. Framework file names,
resource formats, target membership, and API availability take precedence.

| Location | Responsibility |
| --- | --- |
| `grace/App/` | App entry point, environment, navigation, and feature screens |
| `grace/Components/` | Views reused across features, including purchase restoration |
| `grace/Models/` | Domain types and SwiftData models |
| `grace/Services/` | AI, commerce, and persistence implementations |
| `grace/Resources/` | Asset catalogs, localizations, icons, and the local StoreKit configuration |
| `grace/Supporting Files/` | Privacy manifest and other platform metadata |
| `graceTests/Unit/` | Model, service, and focused rendering tests |
| `graceTests/Integration/` | StoreKit session and localization catalog checks |
| `graceTests/Support/` | Test-bundle resource lookup |
| `Docs/` | Product scope, provenance, privacy, and release documentation |

## Naming and source ownership

Use descriptive Swift type names in UpperCamelCase and methods/properties in
lowerCamelCase, following the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
Name Swift files after their main type or responsibility; related helper types
may remain together. Keep feature-specific views with their feature. Promote a
view to `Components/` when multiple features use it. Formatting is configured in
`.swift-format`; `.editorconfig` keeps text encoding, line endings, and indentation
consistent. Do not apply formatting changes to imported artwork or generated files.

The Xcode project uses synchronized folders. Moving a Swift file within its
target folder keeps target membership. The explicit `Test Resources` group
references the original StoreKit file and two string catalogs; it does not keep
duplicate fixture copies in the source tree. Catalogs are copied as raw JSON into
the test bundle, while the app target compiles them into localized strings.
The StoreKit configuration remains excluded from the production app resources.
Tests use `Bundle` resource lookup, never a developer machine's source path.

## Verification and provenance

Run `xcrun swift-format lint --strict --recursive grace graceTests`.
Build the shared `grace` scheme, then run its tests on a supported simulator or
connected iPhone. Building for a generic iOS destination compiles tests but does
not execute them. StoreKit configuration tests use local test products and do
not establish App Store Connect readiness.

Keep source URLs, revisions, licenses, and intentional adaptations in
[References.md](References.md) and [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md).
Apple samples demonstrate patterns; copying a sample does not establish that
the entire app, its privacy declarations, or its release is compliant.

Platform references:

- [Xcode file and folder management](https://developer.apple.com/documentation/xcode/managing-files-and-folders-in-your-xcode-project/)
- [Bundle lookup for a class](https://developer.apple.com/documentation/foundation/bundle/init(for:))
- [StoreKit testing setup](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode)

## Git workflow

Follow the [Git commit guidelines](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project):
keep each commit focused on one logical change, including its necessary tests,
configuration, and documentation. Separate unrelated fixes, formatting, and
localization metadata. Use a concise imperative subject (aim for about 50
characters), a blank line, and a body explaining the problem and resulting
behavior, wrapped at about 72 characters. Run `git diff --check` and the relevant
checks before publishing; report any validation limits accurately.

Use the configured signing identity and verify signatures locally and on GitHub.
Preserve truthful authorship and timestamps. Add attribution, review, or sign-off
trailers only when their meaning is justified; they are not substitutes for a
cryptographic signature. Git's own submission-specific requirements do not
become mandatory rules for these repositories.

Before publishing substantial changes, preserve the previous branch tip and a
verified Git bundle; also save uncommitted files when applicable. Prefer
fast-forward updates and signed revert commits for rollback. Rewrite published
history only when explicitly authorized. Verify the remote commit IDs, content,
metadata, signatures, and available CI results after pushing.

- [Git bundle backups](https://git-scm.com/docs/git-bundle)
- [GitHub signature verification](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification)

## Continuous integration

`.github/workflows/ci.yml` uses GitHub's official
[ios starter workflow](https://github.com/actions/starter-workflows/blob/e3c451d60f119b71caebf13c98ac45da6e15b4b7/ci/ios.yml).
The recorded upstream revision is `e3c451d60f119b71caebf13c98ac45da6e15b4b7`.
The two `$default-branch` placeholders are replaced with `main`, as when
installing the template. Two further changes are needed for the template to
run. First, the Build and Test steps pick the newest iOS runtime that `xctrace`
lists for an iPhone, take the first iPhone on that runtime, and pass both as
`name=` and `OS=` in `-destination`. The template takes the first iPhone in the
list and omits the OS. On `macos-latest` that iPhone (iPhone 16e) exists only on iOS
26.2, so `xcodebuild` found no match for the implied `OS:latest` and stopped
with exit code 70. Passing iOS 26.2 instead let the build pass, but the tests
then crashed in `swift_task_deinitOnExecutor` (`pointer being freed was not
allocated`) whenever a main-actor object was released in a synchronous test.
That is a Swift concurrency runtime bug, fixed upstream in
swiftlang/swift@29245e4 and reported absent from iOS 26.5, the runtime that
matches the iPhoneSimulator 26.5 SDK Xcode builds with on this image. Second,
the Test step passes `-test-timeouts-enabled YES`, so a hung test fails after
XCTest's default 10-minute allowance and the remaining tests still run; without
it a hang lasts until the 6-hour job limit. Separately, a top-level
`permissions: contents: read` block limits the workflow token to read access,
as CodeQL's `actions/missing-workflow-permissions` query asks. Language versions,
commands, and runner selection are otherwise preserved. Action references are
kept current by Dependabot (see Dependency updates), so their versions no
longer match the template.
Do not add independent CI checks or compatibility adjustments without a
separate requested change.

- [Using workflow templates](https://docs.github.com/en/actions/how-tos/write-workflows/use-workflow-templates)
- [xcodebuild destinations (TN2339)](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
- [Swift runtime fix for the task-local marker](https://github.com/swiftlang/swift/commit/29245e4)
- [SE-0371 isolated synchronous deinit](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0371-isolated-synchronous-deinit.md)
- [XCTest execution time allowance](https://developer.apple.com/documentation/xctest/xctestcase/executiontimeallowance)
- [StoreKit Test](https://developer.apple.com/documentation/storekittest)
- [Transaction updates](https://developer.apple.com/documentation/storekit/transaction/updates)
- [Xcode 27 hosted image](https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-arm64-Readme.md)
- [Historical command-line report (FB22237318)](https://developer.apple.com/forums/thread/826971)

Grace, Still, Ukiyo, Vault, and Weave use identical workflow content apart
from each app's test target name. The upstream template selects the default
scheme and an available iPhone simulator, then builds for testing and tests
without rebuilding on `macos-latest`.
The normal workflow currently excludes `graceTests/StoreKitIntegrationTests`.
The separate `.github/workflows/storekit-validation.yml` runs that class on
GitHub's `xcode-27` hosted image with Xcode 27.1 and an existing iPhone 18 Pro /
iOS 27.0 simulator. It checks product loading first, runs the unfinished-transaction
scenario in isolation for observation, then runs the other eight scenarios serially.
Product loading and all eight scenarios are required to pass. Only the isolated
stream step uses continue-on-error; its actual steps.outcome and result bundle
remain visible in the job summary and artifacts. No XCTest assertion or timeout
is relaxed, and no XCTSkip is added. Each stage has its own result bundle.
The eight required methods are explicitly selected with only-testing; the result
summary must contain exactly eight passed tests and no failures or skips. Update
this explicit list when adding or renaming purchase tests; the count check alone
cannot discover a new method omitted from that list.
Evidence is kept for seven days. It uses
read-only repository permissions and no App Store Connect credentials. This is
a project workflow composed from official tools, not an unchanged starter
workflow. The `xcode-27` image is a public preview.

The dedicated workflow runs for pull requests targeting `main` without file-path
filters, so changes to catalogs, purchase code, shared types, or project settings
do not bypass it. Documentation-only PRs also run it. `workflow_dispatch` remains
available once the workflow exists on the default branch. The existing normal
CI check name and repository rules remain unchanged; the StoreKit check is not
yet a required status check in the ruleset.

Investigation on 2026-10-28 and 2026-10-29 established separate findings:

- Configuration: `storekitd` rejected a subscription-group localization that
  lacked `description`. The approved configuration supplies `displayName` and
  `description`; the decoding error disappeared after that correction.
- Test isolation: the host app and the test client could both consume transaction
  updates. The scheme's Test action passes
  `--disable-test-host-storekit-monitor` and the Debug host omits automatic
  monitoring. The test's client still exercises the real StoreKit APIs. This
  isolates competing consumers; it does not prove they caused every prior
  failure or eliminate every StoreKit read by the host.
- Observed timing: transaction and subscription-status synchronization in
  `storekitd` was slow, and cache revisions changed during tests. In Ukiyo's
  instrumented run, both producer Tasks started promptly, but the first snapshot
  took 44.468 seconds. The preceding run timed out at 90 seconds. These are
  observations in the hosted test environment, not an Apple-confirmed diagnosis.

The unfinished-transaction test now tracks the same Transaction.id and requires
both a recorded return from the real finish() call in the client and absence
from unfinished. Its injected completion closure calls the real StoreKit API;
this is project-specific test instrumentation, not an Apple-provided template.
The default client closure also calls finish(). The stricter test does not fix
notification latency, and these new conditions need their own runtime evidence.

All five apps have a historical nine-pass run under the earlier assertions.
Each result applies to the tested commit and environment; it does not establish
repeatable timing or normal-launch coverage. See the [recorded run](https://github.com/masuda-so/grace/actions/runs/40802979683).
The state-wait limits remain 30 seconds and 90 seconds for the first stream
snapshot. These limits do not interrupt an arbitrary suspended StoreKit call;
XCTest's test-execution limits provide a separate bound. No extra retries or
longer waits are introduced to turn intermittent failures into passes.

Two runtime warnings remain in the purchase-success and Ask to Buy tests because
those tests do not own a transaction-updates observer. A follow-up can add a
read-only observer with asynchronous teardown, without letting that observer
finish the transaction being tested. Normal-launch monitoring and physical-device
behavior remain separate validation tasks. The normal CI exclusion is retained
until equivalent StoreKit coverage has been validated on its runner; it must not
be interpreted as a general claim that StoreKit testing is unavailable from the
command line. The forum report FB22237318 is historical context, not proof that
this repository has the same issue.

### Unresolved stream validation

The stream scenario remains executable but is temporarily outside the dedicated
CI pass/fail gate. This is a coverage limitation, not a fix for the observed
delays or a claim that all nine scenarios pass. The [latest strict comparison](https://github.com/masuda-so/grace/actions/runs/40830985698)
recorded isolated pass/fail 0/1
and full-class pass/fail 9/0 before this policy.
Logs show slow storekitd synchronization and changing cache revisions; the root
cause and the effects of test order, prior tests, and app behavior remain unresolved.

Track this limitation here until a validated fix and repeated isolated/full-class
evidence justify restoring the stream to the gate. Do not infer stream correctness
from a green eight-scenario job. continue-on-error covers the entire isolated step,
so a timeout or execution failure also needs inspection; a missing result is not a
pass. The original assertions, real finish() call, and 30/90-second state-wait
deadlines remain unchanged. Normal CI keeps its existing class-wide exclusion.

<details>
<summary>GitHub starter workflow license</summary>

```text
MIT License

Copyright (c) 2020 GitHub

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. THIS LICENSE DOES NOT GRANT YOU RIGHTS TO USE ANY CONTRIBUTORS'
NAME, LOGO, OR TRADEMARKS.
```

</details>

## Dependency updates

Dependabot alerts and security-update PRs are enabled through GitHub's repository
API. `.github/dependabot.yml` also schedules version-update PRs for Monday at
09:00 Asia/Tokyo, including the workflow references to GitHub Actions. Updates
require review and successful checks; automatic merging is not enabled. Preserve
imported reference snapshots; scheduled updates cover product manifests and CI
actions, not a rewrite of reference material.

- [Dependabot configuration](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference)
- [Repository security API](https://docs.github.com/en/rest/repos/repos#enable-vulnerability-alerts)

There are no external Swift packages at present, so version updates cover
GitHub Actions. Add the Swift ecosystem if package dependencies are introduced.

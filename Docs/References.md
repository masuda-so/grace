# Implementation References

This bibliography records the API, design, toolchain, product, and downloadable
sample references used while developing Grace. A reference listed here does not
by itself mean source code was copied. Where the app adapts distributed sample
code, the applicable source and license are recorded in
[`THIRD_PARTY_NOTICES.md`](../THIRD_PARTY_NOTICES.md).

Tutorials are included when they document platform behavior or provide a
downloadable project relevant to the app. Rendered tutorial material is treated
as guidance unless a distributed source archive and its license are identified.

## Product feature references

- [Develop in Swift — App development](https://developer.apple.com/tutorials/develop-in-swift/welcome-to-app-development),
  through [Investigate and fix a bug](https://developer.apple.com/tutorials/develop-in-swift/investigate-and-fix-a-bug):
  the downloadable Grateful Moments snapshot supplies the Moment/Badge models,
  preview fixtures, hexagon shape/layout/accessory, moment and achievement views,
  badge unlocking, starter streak algorithm, and the badge, color, sample-image,
  and Moments-tab assets used by Grace. The rendered final lesson documents the
  locally implemented streak corrections and regression requirements.
- [Wishlist](https://developer.apple.com/documentation/swiftui/wishlist-planning-travel-in-a-swiftui-app):
  observable state, custom cards, explicit animations, and achievement presentation.
- [Photos picker](https://developer.apple.com/documentation/photokit/bringing-photos-picker-to-your-swiftui-app):
  Grace retains the sample's selection property, `loadTransferable(from:)`,
  stale-selection identity guard, and empty/loading/success/failure state-machine
  shape. Observation technology, transferred value type, main-actor delivery,
  ownership, cancellation, downsampling, JPEG encoding, and persistence are
  implemented for Grace's local data model.
- [PhotosPickerItem loadTransferable](https://developer.apple.com/documentation/photosui/photospickeritem/loadtransferable%28type%3A%29)
  and [CGImageSourceCreateThumbnailAtIndex](https://developer.apple.com/documentation/imageio/cgimagesourcecreatethumbnailatindex%28_%3A_%3A_%3A%29):
  selected image data is loaded asynchronously, checked against the current selection,
  and downsampled and encoded away from the main actor before display and persistence.

## Family-wide references

- [Food Truck](https://github.com/apple/sample-food-truck/tree/3954a769e99f3cc53297d94f2b960ceb2665b3d6):
  `General`, `Navigation`, feature folders, and StoreKit transaction listeners.
- [Backyard Birds](https://github.com/apple/sample-backyard-birds/tree/1843d5655bf884b501e2889ad9862ec58978fdbe):
  app-specific feature folders, StoreKit configuration, and adaptive navigation.
- [ml-comlet](https://github.com/apple/ml-comlet/tree/c3811e7367c1a211698078c8ffbc11e282e3c794):
  `Services`, model separation, localization, and `Supporting Files`.
- [Foundation Models sample](https://developer.apple.com/documentation/foundationmodels/adding-intelligent-app-features-with-generative-models):
  the downloadable availability switch is an adopted unit. Coffee Game and
  Origami, listed below, supply the adopted response, cancellation, prompt, and
  error-handling units; Grace additionally retains one `LanguageModelSession` per
  visible conversation. The app protocol boundary, validation policy, bounded
  journal context, stable vocabulary, and product instructions remain local.
- [Generate dynamic game content with guided generation and tools](https://developer.apple.com/documentation/foundationmodels/generate-dynamic-game-content-with-guided-generation-and-tools)
  ([fixed ZIP](https://docs-assets.developer.apple.com/published/86c65aeb21cc/GenerateDynamicGameContentWithGuidedGenerationAndTools.zip)):
  adopted nonstreaming `respond(to:)`, `@Generable` guided output for editable Moment
  candidates, response-content, availability, task, cancellation, and app-owned-
  instructions patterns from Apple's Coffee Game. Generated candidates cannot call
  SwiftData; the review sheet owns the explicit save action.
- [Origami: Crafting a dynamic tutorial for Apple Intelligence](https://developer.apple.com/documentation/foundationmodels/origami-crafting-a-dynamic-tutorial-for-apple-intelligence)
  ([fixed ZIP](https://docs-assets.developer.apple.com/published/e843a4026a2e/OrigamiCraftingADynamicTutorialForAppleIntelligence.zip)):
  adopted the `Prompt` builder, post-response cancellation check, and iOS 27
  Foundation Models error-type branching. Dynamic profiles, image prompts,
  streaming, and the sample's cache are outside the local adoption units.
- [Generative AI Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/generative-ai)
  and [Foundation Models acceptable-use requirements](https://developer.apple.com/apple-intelligence/acceptable-use-requirements-for-the-foundation-models-framework):
  people remain in control through explicit AI labeling, cancellation, review guidance,
  a usable non-AI path, and use-case-specific safety boundaries.
- [Instructions](https://developer.apple.com/documentation/foundationmodels/instructions):
  developer-owned behavior remains in trusted instructions; user-provided content is
  JSON-delimited in the lower-priority prompt and is never interpolated into
  instructions. Recent journal text is also labeled untrusted, bounded to 12 records,
  and represented without photo data.

## Platform verification

- [App icons](https://developer.apple.com/design/human-interface-guidelines/app-icons/)
  and [Creating your app icon using Icon Composer](https://developer.apple.com/documentation/xcode/creating-your-app-icon-using-icon-composer):
  `Resources/AppIcon.icon` is the sole primary app-icon source. Xcode renders the
  required platform, appearance, and legacy-size variants from its layered artwork.
- [Localizing and varying text with a string catalog](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog)
  and [Managing your app’s information property list](https://developer.apple.com/documentation/bundleresources/managing-your-app-s-information-property-list):
  interface text uses `Localizable.xcstrings`; the localizable `CFBundleDisplayName`
  and `CFBundleName` values use the target-specific InfoPlist String Catalog.
- [Accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals):
  the transparent photo-picker control has an explicit label and hint, its
  duplicate visual is hidden, and each moment hexagon exposes one combined title,
  details, date, and photo-presence value.
- [Setting up StoreKit Testing in Xcode](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode/):
  local StoreKit configurations and scheme selection.
- [StoreKit Test](https://developer.apple.com/documentation/storekittest):
  `SKTestSession` loads the source configuration by URL for product, verified
  purchase and finishing, restore, and Daily Pass boundary tests. Tests run
  serially because all test sessions control one environment; the configuration
  remains outside the app bundle.
- [Understanding StoreKit workflows](https://developer.apple.com/documentation/storekit/understanding-storekit-workflows)
  ([fixed ZIP](https://docs-assets.developer.apple.com/published/6b864cb1ff7d/UnderstandingStoreKitWorkflows.zip)):
  adopted the grouped `ProductID` structure and the unfinished, current
  entitlement, update, verified-processing, and `finish()` kernels.
- [Implementing a store in your app using the StoreKit API](https://developer.apple.com/documentation/storekit/implementing-a-store-in-your-app-using-the-storekit-api)
  ([fixed ZIP](https://docs-assets.developer.apple.com/published/623bce0ddaba/ImplementingAStoreInYourAppUsingTheStoreKitAPI.zip)):
  the 2026 sample is a latest-behavior cross-check only; no additional code
  adoption claim is made from this Apple-sample-license distribution.
- [Xcode support](https://developer.apple.com/support/xcode/): use an Apple-
  supported stable Xcode release and compatible SDK for release verification.
  Re-run build, test, Analyze, Archive, and StoreKit checks after selecting the
  final toolchain; earlier results do not establish the current tree's status.
- [Apple Developer Forums: iOS 26.5 CLI StoreKit report](https://developer.apple.com/forums/thread/808030):
  historical, non-normative field evidence for the earlier `Code=3` failure and
  IDE-only workaround; it does not replace a successful StoreKit E2E run on a
  compatible Apple runtime, physical device, or TestFlight configuration.
- [Select an App Store version release option](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/select-an-app-store-version-release-option/)
  and [Submit an In-App Purchase](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase/):
  a chosen release option is configured separately from App Review, and each
  first product type is submitted with the initial app version as required.
- [Transaction.currentEntitlements](https://developer.apple.com/documentation/storekit/transaction/currententitlements):
  the all-product sequence supplies verified current transactions, including the latest
  non-renewing purchase, and the client filters them against the app catalog.
- [Task cancellation and sleep](https://developer.apple.com/documentation/swift/task/):
  the Daily Pass monitor retains and cancels its task, uses a cancellable sleep, and
  receives the same injectable wall clock as entitlement calculation.
- [Handling subscriptions billing](https://developer.apple.com/documentation/storekit/handling-subscriptions-billing):
  app-owned duration, restoration, and cross-device responsibilities for a
  non-renewing subscription.
- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/):
  role-based type names, labeled weakly typed parameters, clarity at the call site,
  fluent method names, and concise Markdown comments for reusable APIs.
- [Writing](https://developer.apple.com/design/human-interface-guidelines/writing):
  assistant and commerce diagnostics remain internal, while localized interface errors
  use plain language and give a clear retry action.
- [swift-format](https://github.com/swiftlang/swift-format):
  the Swift toolchain formatter and strict linter enforce the repository's pinned
  two-space indentation, import ordering, line length, documentation, and
  force-unwrap safety rules. Swift does not prescribe this as the only valid style;
  adopting one identical configuration across the five apps is a local consistency
  decision.

## Adopted implementation and local decisions

- [Xcode support](https://developer.apple.com/support/xcode/)
  and [App Store Connect release notes](https://developer.apple.com/help/app-store-connect/release-notes/):
  the stable App Store submission toolchain and App Store Connect validation
  remain release gates separate from local unsigned verification.
- [Foundation Models updates](https://developer.apple.com/documentation/updates/foundationmodels):
  Swift 6.4 builds map the iOS 27 `LanguageModelError`,
  `SystemLanguageModel.Error`, and `LanguageModelSession.Error` types. A compiler
  condition keeps those SDK-27 declarations out of Swift 6.3 builds; iOS 26 uses
  the common safe fallback without reintroducing the deprecated generation type.
  Origami's downloadable error translation is the adopted comparison unit for
  the shared `SystemLanguageModel.Error` and `LanguageModelError` branches.
- [Supporting languages and locales](https://developer.apple.com/documentation/foundationmodels/supporting-languages-and-locales-with-foundation-models):
  locale support is checked before sending a prompt.
- [Collect, model, and store data](https://developer.apple.com/tutorials/develop-in-swift/collect-model-and-store-data):
  the rebuilt schema deliberately uses the tutorial's `timestamp`, `note`, and
  `imageData` names directly. It doesn't use migration-only `@Attribute(originalName:)`
  aliases because this repository targets the newly rebuilt app record. The final
  Apple preview fixtures and their asset names are retained; `@MainActor` on the
  preview extension is the only material model-file adaptation required by the
  Swift 6 project configuration.
- [ModelContext transaction](https://developer.apple.com/documentation/swiftdata/modelcontext/transaction%28block%3A%29)
  and [rollback](https://developer.apple.com/documentation/swiftdata/modelcontext/rollback%28%29):
  user-initiated mutations run inside `performTransactionOrRollback(_:)`, so failures in either
  the changes or their save discard the complete pending unit before the app presents an
  error. The wrapper name and shared alert policy are family-wide implementation decisions.
- [Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files):
  the manifest declares no tracking, collected data, or required-reason API use.

The current layered Icon Composer source is
`grace/Resources/AppIcon.icon`, using `grace-selected-source.png` rather than an
SF Symbol. Apple's icon documentation governs packaging and appearance
rendering; rendered sizes, masks, and appearances require inspection with the
final stable toolchain and on representative devices. App Review makes the
final determination. Support case `20000121467132` is historical
correspondence about the former icon.

Apple doesn't prescribe one universal app-folder layout. Grace therefore follows
the recurring official-sample pattern of app, model, service, resource, and
feature-specific groups. The Daily Pass is an app-owned policy: it uses StoreKit's
verified purchase date plus 24 hours and the device wall clock, without a server.

The downloaded samples include their own Apple or MIT license notices. Grace adapts
the relevant patterns instead of redistributing any sample project unchanged.
Apple tutorial and sample-code reuse is governed by the license supplied with the
sample and the [Apple Sample Code License](https://developer.apple.com/support/downloads/terms/apple-sample-code/Apple-Sample-Code-License.pdf).

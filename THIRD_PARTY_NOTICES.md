# Third-Party Notices

This file supplements, and does not replace, the repository LICENSE. It records
Apple-distributed sample code that Grace actually adapts, together with the local
scope of each adaptation. A documentation link or use of a public Apple API by
itself is not treated as copied sample code.

Apple names and links below identify sources and license terms only. Nothing in
this file states or implies that Apple sponsors, endorses, or approves Grace.
Product identifiers, prompts, pricing, user-facing copy, and the 24-hour Daily
Pass policy are local work.

The shipping `grace/Resources/AppIcon.icon` composition and
`grace-selected-source.png` foreground are local artwork, not Apple sample code
or an SF Symbol. Apple icon documentation is used for canvas, mask, appearance,
and packaging guidance.

## Grateful Moments tutorial project

Sources:

- https://developer.apple.com/tutorials/develop-in-swift/collect-model-and-store-data
- https://developer.apple.com/tutorials/develop-in-swift/use-a-custom-layout-view
- https://developer.apple.com/tutorials/develop-in-swift/create-an-algorithm-for-badges
- https://developer.apple.com/tutorials/develop-in-swift/investigate-and-fix-a-bug
- Collect archive: https://docs-assets.developer.apple.com/published/671f6fe6b0b0d85ec5c5acf78617ebf2/GratefulMoments-CollectModelAndStoreData.zip
- Layout archive: https://docs-assets.developer.apple.com/published/2b81dc19b006e22013c540f9e1216e14/GratefulMoments-UseACustomLayoutView.zip
- Badges archive: https://docs-assets.developer.apple.com/published/4acf208215a078d42877fa2612164418/GratefulMoments-CreateAnAlgorithmForBadges.zip
- Bug-fix archive: https://docs-assets.developer.apple.com/published/3a1c7e5364ceea203334a98884e0559e/GratefulMoments-InvestigateAndFixABug.zip

Applied scope:

- grace/Models/Moment.swift, Badge.swift, and BadgeDetails.swift
- grace/Services/Data/DataContainer.swift
- grace/Components/Hexagon.swift, HexagonAccessoryView.swift, and HexagonLayout.swift
- grace/Services/Achievements/BadgeManager.swift and StreakCalculator.swift
- grace/App/Achievements/AchievementsView.swift, BadgeDetailView.swift,
  LockedBadgeView.swift, StreakView.swift, and UnlockedBadgeView.swift
- grace/App/Moments/MomentDetailView.swift, MomentEntryView.swift,
  MomentHexagonView.swift, and MomentsView.swift
- grace/Resources/Assets.xcassets/Badges, Colors, Samples, and
  MomentsTab.symbolset

The `Badge` and `BadgeDetails` models; the three hexagon components; five
achievement views; and `BadgeManager` retain Apple's executable units apart from
formatting. `Moment` adds Swift 6 preview isolation. `DataContainer`,
`MomentHexagonView`, `MomentsView`, `MomentDetailView`, and `MomentEntryView` add
compatibility, accessibility, rollback, error-presentation, Photos-picker, and
actor-boundary behavior for Grace. `StreakCalculator` retains
the downloadable starter algorithm and implements the published bug-fix
requirements locally; its regression tests are local behavior tests rather than
an adopted rendered-code unit. The listed content assets are copied from the
tutorial archive. The App Icon placeholder is recorded separately above. The four
Apple tutorial archives inspected carry the same LICENSE.txt, reproduced once below.

~~~text
Copyright © 2021 Apple Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
~~~

## Bringing Photos picker to your SwiftUI app

Source:

- https://developer.apple.com/documentation/photokit/bringing-photos-picker-to-your-swiftui-app
- Distributed sample archive: https://docs-assets.developer.apple.com/published/00f942c6d60a/BringingPhotosPickerToYourSwiftUIApp.zip

Applied scope: grace/Services/Photos/PhotoSelection.swift and the picker binding
in grace/App/Moments/MomentEntryView.swift. Selection-driven transferable
loading and the stale-selection guard are adapted; cancellation, Image I/O
preparation, persistence, and product presentation are local.

The distributed LICENSE.txt states:

~~~text
Copyright © 2024 Apple Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
~~~

## Adding intelligent app features with generative models

Source:

- https://developer.apple.com/documentation/foundationmodels/adding-intelligent-app-features-with-generative-models
- Distributed sample archive: https://docs-assets.developer.apple.com/published/5414fd17db13/AddingIntelligentAppFeaturesWithGenerativeModels.zip
- Apple Sample Code License: https://developer.apple.com/support/downloads/terms/apple-sample-code/Apple-Sample-Code-License.pdf

The retained availability kernel was compared with
FoundationModelsTripPlanner/FoundationModelsTripPlanner/Views/Itinerary/TripPlanningView.swift
in the distributed archive.

Applied scope: grace/Services/AI/FoundationModelAIClient.swift, limited to
`SystemLanguageModel.default` and the availability switch. The `AIClient`
protocol, request/response vocabulary, prompts and string instructions, locale
policy, compiler guards, session-error branch, and stable error vocabulary are
local. The separately adopted session/response, post-response cancellation, and
framework-error type-switch units are attributed to Coffee Game and Origami
below.
This sample is not described as MIT licensed.

The distributed LICENSE.txt states:

~~~text
Copyright 2025 Apple Inc. All Rights Reserved.

IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
~~~

## Implementing a store in your app using the StoreKit API

Source:

- https://developer.apple.com/documentation/storekit/implementing-a-store-in-your-app-using-the-storekit-api
- Distributed sample archive: https://docs-assets.developer.apple.com/published/623bce0ddaba/ImplementingAStoreInYourAppUsingTheStoreKitAPI.zip
- Retrieved: 2026-08-04; archive verified again: 2026-08-12
- Archive SHA-256: `26c7a9ee9329ebc3e26c15300eab9d332c803edd00236b0eefdf50276eca1e5a`
- `LICENSE.txt` SHA-256: `136e1d3db1b892bc26b03969250fbf0668dafcf09ced3ec2e9fe0ac832f7e20d`
- `SKDemo/Model/SKDemoPlusStatus.swift` SHA-256:
  `43df30db78cc0fcf36cf686f07ad9ee3c414bad5e87176225855055950c7f431`
- `SKDemo/In App Purchase/CustomerEntitlements.swift` SHA-256:
  `ae3a815a82dcf0e87fbb380962cc96b782785d633f717d80ba26e181d4992ed3`

Applied scope: `grace/Models/AccessLevel.swift` adapts the official access-level
enum to the app's free/Pro boundary.
`grace/App/General/AppEnvironment.swift` adapts the retained transaction task,
weak capture, and isolated-deinit cancellation lifecycle to the local snapshot
boundary. Product identifiers, entitlement aggregation, and UI policy remain
local or are separately attributed.

The distributed `LICENSE.txt` states:

~~~text
Copyright 2026 Apple Inc. All Rights Reserved.

IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
~~~

## StoreKit patterns from Apple GitHub samples

Sources, pinned to the versions inspected:

- Food Truck: https://github.com/apple/sample-food-truck/tree/3954a769e99f3cc53297d94f2b960ceb2665b3d6
- Backyard Birds: https://github.com/apple/sample-backyard-birds/tree/1843d5655bf884b501e2889ad9862ec58978fdbe

Applied scope:

- `grace/App/Settings/SettingsView.swift` and
  `grace/Components/CardView.swift` adapt the pinned Food Truck units described
  below.
- `grace/App/Settings/RestorePurchasesButton.swift` adapts the pinned Backyard
  Birds unit described below.

The StoreKit client now uses Apple's fixed StoreKit Workflows distribution as
its primary source record and is covered in the MIT section below. The local
StoreKit configuration, product identifiers, catalog, restore return value, and
Daily Pass calculation remain local.

Both pinned repositories contain the same copyright and permission text:

~~~text
Copyright © 2023 Apple Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
~~~

## Additional shared interface source units

The following source-tracked units extend the scopes already attributed above:

- `grace/App/Assistant/AssistantView.swift` adapts the body-level availability
  switch from Foundation Models Trip Planner. Its Pro gate, prompt, task, result,
  error, and product presentation remain local.
- `grace/App/Settings/SettingsView.swift` adapts the subscription-management
  state, button, and sheet modifier from Food Truck's
  `App/Store/StoreSupportView.swift`.
- `grace/App/Settings/RestorePurchasesButton.swift` adapts the executable view
  unit from Backyard Birds'
  `Multiplatform/Account/RestorePurchasesButton.swift`. Type and state naming,
  `defer`, `AppStore.sync()`, disabled state, and preview are retained;
  main-actor task integration, `CancellationError` handling, private diagnostic
  logging, stable product error translation, failure state, and the localized
  failure alert are local.
- `grace/Components/CardView.swift` adapts the padding and thin-material
  continuous rounded-rectangle kernel from Food Truck's
  `App/City/CityWeatherCard.swift`.

The paywall's `StoreView` use follows public StoreKit API and
rendered-documentation contracts. The catalog's `ProductID` grouping unit is
attributed to StoreKit Workflows below; its case names, raw product identifiers,
Daily Pass behavior, copy, and surrounding composition are local.

## Apple 2025 MIT samples for Foundation Models and StoreKit

Sources:

- Coffee Game: https://developer.apple.com/documentation/foundationmodels/generate-dynamic-game-content-with-guided-generation-and-tools
- Coffee Game archive: https://docs-assets.developer.apple.com/published/86c65aeb21cc/GenerateDynamicGameContentWithGuidedGenerationAndTools.zip
- Coffee Game archive SHA-256:
  `74296318d9d9d025c080bc19a3e266045f4eb95c59188c309d7b108fb2d3c389`
- `GenerateDialog/DialogEngine.swift` SHA-256:
  `872e648ebf234916144e3d360bd7f06d175f163446bd461b5a025284d217f011`
- `GenerateEncounters/EncounterEngine.swift` SHA-256:
  `f3e2cf13d7a737fcefd4a7d5226c6f57975b69fd39ab0799b101482a0e3858f2`
- `MainMenu/MainMenuView.swift` SHA-256:
  `31ec6dbebe3f7e47b9cc501cb879a2a6e84ddf3a9bdd80559d77673940851d35`
- StoreKit Workflows: https://developer.apple.com/documentation/storekit/understanding-storekit-workflows
- StoreKit Workflows archive: https://docs-assets.developer.apple.com/published/6b864cb1ff7d/UnderstandingStoreKitWorkflows.zip
- StoreKit Workflows archive SHA-256:
  `95fc0905086308fd68e0c3f5559b20b9b57d8b6663e91466fee187a170987e72`
- `StoreKitWorkflows/ProductID.swift` SHA-256:
  `922eff297649cd4ea4247573f97083007599f1c2adb6235469f8804df8327b2c`
- `StoreKitWorkflows/Store.swift` SHA-256:
  `9c5ef74c118b7de50ca178e8b57457f79061fa4343410bbb6318cc61fbddb6e3`

Applied scope:

- Coffee Game `EncounterEngine.swift:52-73` supplies the separately classified
  session/response unit in
  `grace/Services/AI/FoundationModelAIClient.respond(to:)` and the
  instructions/prompt/response unit in `GraceAssistant.respond(to:)`.
- StoreKit Workflows `ProductID.swift:8-31` supplies the `ProductID` grouping
  unit in `grace/Services/Commerce/GraceCommerceCatalog.swift`.
- StoreKit Workflows `Store.swift:33-48,51-100` supplies the current-entitlement,
  unfinished-transaction, update, verified-processing, and finish kernels in
  `grace/Services/Commerce/StoreKitSubscriptionClient.swift`.

All product copy, prompts, safety instructions, locale handling, stable AI
errors, StoreKit snapshots, catalog filtering, product identifiers, restore
presentation, and Daily Pass policy are local Grace decisions.

Both distributed `LICENSE.txt` files have SHA-256
`ef80d1c2ac05c7040c0ced9d603c2c359712f90fdb3ece8da70b976981a69e89`
and contain the same notice:

~~~text
Copyright © 2025 Apple Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

~~~

## Origami Foundation Models sample

Source:

- https://developer.apple.com/documentation/foundationmodels/origami-crafting-a-dynamic-tutorial-for-apple-intelligence
- Archive: https://docs-assets.developer.apple.com/published/e843a4026a2e/OrigamiCraftingADynamicTutorialForAppleIntelligence.zip
- Archive SHA-256:
  `ce65cf2266eb8e69edf1eacdcdea82f97bda0ffed5b7accb61ab4df3c1a20c2a`
- Embedded revision: `e1705ac38f050049e8598061cda18b83a50c31b3`
- `Origami/Terms/TermExtractor.swift` SHA-256:
  `782c96b2ab7fffcfaa87e787b701d877fb00972db9489cf5620f2a234f60bda1`
- `Origami/Terms/TermModel.swift` SHA-256:
  `decd3811dd33ec96d0f787c20a8b024c4a4da78351a7e025ebec9281661a9eae`
- `Origami/Models/Error+DisplayMessage.swift` SHA-256:
  `0609f3a644c92b5f8bf64cc08a0e3390fbf4adc0e78123788e02350d5c5e4af7`

Applied scope:

- `Origami/Models/Error+DisplayMessage.swift:12-35` supplies the framework-error
  type-switch unit in
  `grace/Services/AI/FoundationModelAIClient.aiError(from:)`.
- `Origami/Terms/TermModel.swift:145-164` supplies the response, immediate
  cancellation check, state publication, and cancellation-handling units in
  `FoundationModelAIClient.respond(to:)` and
  `grace/App/General/AppEnvironment.requestAssistantResponse(for:)`.

Grace's typed error vocabulary, complete case mapping, compiler/OS guards,
session-error mapping, access gates, logging, and user-facing copy remain local.

The distributed `LICENSE.txt` has SHA-256
`d18c34e657bcc2cd125a3c9c8d731ded98e02b2abe62b885defa9991e5054649`
and states:

~~~text
Copyright © 2026 Apple Inc. All Rights Reserved.

IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
~~~

## Materials not included

API documentation used only to confirm public framework behavior is not listed
as copied code. The ml-comlet repository was consulted for naming and folder
organization, but no ml-comlet source file was copied into Grace, so its license
is not attached here.

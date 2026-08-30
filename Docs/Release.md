# Grace release readiness

This document defines the current release scope and remaining gates. It does not
set a submission or public-release date. Because the implementation and project
configuration have changed, all technical checks below must be rerun against the
current tree before submission.

## v1 scope

- iOS 18 minimum deployment target with iPhone and iPad support.
- Private local gratitude moments containing a required title, optional note,
  optional prepared photo, timestamp, and badge relationships in SwiftData.
- Moment entry, rollback-aware save, system photo selection, hexagon timeline,
  detail, confirmed rollback-aware deletion, achievements, badges, and streaks.
- Photos are oriented/downsampled to a 1,600-pixel maximum dimension and encoded
  as JPEG at quality 0.82 before persistence.
- An explicitly invoked on-device reflection assistant is available only when
  Apple Foundation Models are supported and Pro access is active; the journal
  remains usable without purchase or AI.
- StoreKit 2 product loading, purchase, restore, verified-entitlement, and
  transaction-update handling for a Daily Pass and Monthly/Yearly subscriptions.
- Privacy, Terms, Restore, and Manage Subscription surfaces are implemented.
- The local StoreKit configuration belongs to the shared Debug scheme and is
  excluded from the app target and release Archive.

## Current technical gate

Run one project at a time in this order: static inspection, build, non-StoreKit
tests, Analyze, then Archive inspection. Use an Apple-supported stable Xcode
release and compatible SDK/runtime selected for submission.

- [ ] Swift formatting and project/resource/asset parsing pass.
- [ ] Privacy manifest, photo-access, Required Reason API, localization, and
      production legal-URL checks pass for the current source.
- [ ] Debug and Release builds pass with the final stable toolchain.
- [ ] AI, commerce-contract, Grace foundation, streak, rendering, and
      localization tests pass without unexpected failures or skips.
- [ ] Release Analyze passes for the app target.
- [ ] A release Archive is inspected for identity, minimum OS, localization,
      privacy manifest, content and icon assets, and absence of test-only
      StoreKit or test-bundle payloads.

## StoreKit and external environment gate

Nine StoreKit Test scenarios remain required: product loading; verified
purchase and finish; unfinished-transaction processing; restore; Daily Pass
boundary; Ask to Buy pending; refund revocation; Daily Pass repurchase from the
latest signed purchase date; and auto-renew cancellation with access through
expiration. The Daily Pass does not auto-renew or stack.

StoreKit E2E requires a compatible Apple-distributed runtime, physical device,
or TestFlight/App Store Connect products. Record the final environment and any
skipped scenario when the current tree is tested.

## Human and external release gate

- Confirm whether any prior Grace version shipped with a different SwiftData
  schema or Bundle ID. If so, define/test migration and/or user export/import;
  local data and purchases do not automatically transfer to a new app record.
- Configure the app record, version/build/SKU, Apple Distribution signing, and
  provisioning for `llc.ether.grace` in App Store Connect.
- Create/localize all products, set price/availability/review assets, put Monthly
  and Yearly in one same-level subscription group, and submit first products
  with the app version as required.
- Publish and anonymously verify the fixed Privacy, Terms, and Support URLs.
- Confirm App Store privacy, age rating, content rights/licenses, encryption/
  export compliance, wellness positioning, regional legal answers, and the
  non-renewing pass device-clock policy.
- Test real photo orientation/quality, inline-image storage and memory growth,
  moment rollback/deletion, badges/streaks across calendar boundaries, iPhone/
  iPad layouts, VoiceOver, Dynamic Type, Japanese/English, offline/failure
  states, Foundation Models, purchase, restore, and entitlement transitions.
- Prepare distinct Grace gratitude-journal screenshots, value proposition, and
  review notes that address guideline 4.3.
- Complete signed Archive validation, TestFlight, compatible physical-device
  testing, and final human review. Signing/upload/publication remain external.

## Icon decision

Use the current layered `grace/Resources/AppIcon.icon`, whose foreground is the
non-SF-Symbol `grace-selected-source.png`. The final stable Icon Composer must
render the required iOS appearances and the Archive must contain the compiled
icon. Inspect masks, appearances, and small sizes on real devices; App Review
makes the final determination.

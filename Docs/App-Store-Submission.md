# Grace App Store submission record

This is a working submission checklist, not a submission or release date. Every
technical item must be revalidated against the current tree and final stable
Xcode toolchain.

## App identity

- Name: Grace
- Bundle ID: `llc.ether.grace`
- Minimum iOS: 18.0; iPhone and iPad
- App record/SKU/version/build/category/age rating/copyright/export compliance/
  content rights: confirm in App Store Connect against the final signed Archive

## In-App Purchases

| Product ID | Type | Local contract |
| --- | --- | --- |
| `llc.ether.grace.pro.daily` | Non-renewing subscription | Pro 24 hours from latest verified purchase date; no stacking |
| `llc.ether.grace.pro.monthly` | Auto-renewable subscription | Pro while verified entitlement is active |
| `llc.ether.grace.pro.yearly` | Auto-renewable subscription | Pro while verified entitlement is active |

Monthly and Yearly share one same-level subscription group. A human must confirm
product type, localization, price, availability, tax/category, review assets,
and first-product submission in App Store Connect. The local StoreKit
configuration is a test artifact and must not be distributed.

## Fixed public URLs

- Privacy: `https://ether-llc.com/apps/grace/privacy/`
- Terms: `https://ether-llc.com/apps/grace/terms/`
- Support: `https://ether-llc.com/apps/grace/support/`

The app points to Privacy and Terms. Deploy all three pages and verify anonymous
mobile access outside the local network before submission; publication is an
external action.

## Privacy and local journal data

- Grace stores title, note, timestamp, selected prepared image, badges, and
  relationships in local SwiftData. It has no account, analytics/ads, remote
  content database, cloud sync, automatic upload, or remote AI provider.
- The system PhotosPicker exposes only a user-selected item; Grace does not
  request unrestricted photo-library access.
- Selected images are oriented/downsampled to at most 1,600 pixels and encoded
  as JPEG at quality 0.82 before local persistence. Source metadata is not
  intentionally preserved. Real photos and memory/storage growth need review.
- The assistant is explicitly invoked and uses Apple Foundation Models on
  supported devices/languages. Journal use remains available without Pro/AI.
- `PrivacyInfo.xcprivacy` declares no tracking or collected data. The final
  Required Reason API and dependency scan must match App Store privacy answers.
- A human must confirm privacy, age rating, content rights, encryption/export,
  mental-health/wellness positioning, photo rights, and regional legal answers.

## Review notes to prepare

- Show a free moment flow: text entry, optional system photo selection, save,
  hexagon timeline, detail, achievement/streak behavior, and confirmed deletion.
- Explain the local-first data model, failure/rollback states, and no review login.
- Explain that Pro adds an explicitly invoked on-device reflection assistant;
  it is not medical, mental-health, emergency, or professional advice.
- Explain the Foundation Models unavailable path, Restore/Manage Subscription,
  and non-renewing Daily Pass device-clock policy.
- Supply distinct Grace gratitude-journal screenshots and value copy to address
  guideline 4.3 rather than presenting a family-template duplicate.

## Licensed Apple sample material

Grace incorporates portions of Apple's distributed Grateful Moments sample and
related Apple samples. Keep the applicable source links, copyright notices, and
license text in `THIRD_PARTY_NOTICES.md`, and include the used code and assets in
the final legal/content-rights review. Apple names do not imply endorsement.

## Icon record

Submit the current layered `grace/Resources/AppIcon.icon`, which uses the
non-SF-Symbol `grace-selected-source.png` foreground. Confirm the built icon at
required sizes and appearances using the final stable toolchain. Apple Developer
Support case `20000121467132` is historical correspondence; App Review makes the
final determination.

## Technical gate

- [ ] Static project, asset, privacy, photo-access, localization, and public-URL
      checks pass against the current tree.
- [ ] Debug and Release builds pass using the final stable Xcode toolchain.
- [ ] Non-StoreKit tests pass without unexpected failure or skip.
- [ ] Analyze passes and the release Archive contents are inspected.
- [ ] Nine StoreKit E2E scenarios pass on compatible runtime/device/TestFlight.
- [ ] Real photo orientation/quality/storage/memory, migration history, badges,
      streaks, iPhone/iPad, VoiceOver, Dynamic Type, Japanese/English,
      Foundation Models, and failure-state checks pass.
- [ ] Signed validation/TestFlight, public URLs, metadata, privacy/IAP/legal
      answers, screenshots/review notes, and final human review are complete.

No signing, upload, publication, or external message is performed without
separate authorization.

## Revalidation record

Record the selected stable Xcode/SDK/runtime, test results, Analyze result,
Archive identity and contents, and public-URL checks after the current tree is
revalidated. Do not reuse results or hashes from an earlier revision.

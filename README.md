# Grace

Grace is a private gratitude journal for recording meaningful notes and photos.

## Main navigation

- Moments
- Achievements
- Assistant
- Pro
- Settings

## Journal

Moments are stored on-device with SwiftData. A moment can contain a required title,
an optional note, an optional photo, and a creation date. The journal supports
creation, a visual hexagon timeline, detail viewing, and confirmed deletion.

The journal flow follows Apple’s “Views and data storage” tutorial while retaining
Grace’s local architecture, Foundation Models assistant, and StoreKit 2 access layer.

On supported devices, the on-device assistant can hold a text conversation, reference
a bounded set of recent Moment text and exact timestamps, and prepare an editable
Moment candidate using Foundation Models guided generation. Photos are not supplied
to the model, and a candidate is stored only after the person reviews it and explicitly
chooses to save. The manual journal remains available without AI.

## Commerce

- `llc.ether.grace.pro.daily`: non-renewing Daily Pass with 24 hours of access.
- `llc.ether.grace.pro.monthly`: auto-renewable monthly plan.
- `llc.ether.grace.pro.yearly`: auto-renewable yearly plan.

The Daily Pass never renews automatically. App Store Connect products and pricing
must be configured and reviewed before these plans can be sold.

The shared Xcode scheme selects a local StoreKit configuration with English and
Japanese product metadata for offline purchase testing. Production product
records and prices still need to be created in App Store Connect.

## Documentation

- [Product scope](Docs/Product.md)
- [Privacy Policy](Docs/Privacy.md)
- [Terms of Use](Docs/Terms.md)
- [Implementation references](Docs/References.md)
- [Release gates](Docs/Release.md)
- [App Store submission record](Docs/App-Store-Submission.md)
- [Third-party notices](THIRD_PARTY_NOTICES.md)

Published public routes:

- Privacy: `https://ether-llc.com/apps/grace/privacy/`
- Terms: `https://ether-llc.com/apps/grace/terms/`
- Support: `https://ether-llc.com/apps/grace/support/`

Signing, validation, upload, publication, and release are external steps.

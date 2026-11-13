# Grace

[日本語](README.md) | [English](README.en.md)

## Overview

Grace is a private gratitude journal for recording meaningful notes and photos.

## Features and limitations

### Main navigation

- Moments
- Achievements
- Assistant
- Pro
- Settings

### Core experience

Moments are stored on-device with SwiftData. A moment can contain a required title,
an optional note, an optional photo, and a creation date. The journal supports
creation, a visual hexagon timeline, detail viewing, and confirmed deletion.

The journal flow follows Apple’s “Views and data storage” tutorial while retaining
Grace’s local architecture, Foundation Models assistant, and StoreKit 2 access layer.

### Intelligence and commerce

The assistant requires active Pro access and uses Apple Foundation Models on supported devices and languages.

- `llc.ether.grace.pro.daily`: non-renewing 24-hour Daily Pass.
- `llc.ether.grace.pro.monthly`: auto-renewable monthly plan.
- `llc.ether.grace.pro.yearly`: auto-renewable yearly plan.

App Store Connect product records, production prices, and review metadata remain
external release tasks.

## Getting started and usage

Open `grace.xcodeproj` in Xcode and select the shared `grace` scheme.
See [repository structure and verification](docs/Structure.md) for build and test guidance,
and [release gates](docs/Release.md) for device and release requirements.
The local StoreKit configuration is for purchase testing, not proof of production availability.

## Support and documentation

- [Repository structure and verification](docs/Structure.md)
- [Product scope](docs/Product.md)
- [Privacy Policy](docs/Privacy.md)
- [Terms of Use](docs/Terms.md)
- [Implementation references](docs/References.md)
- [Release gates](docs/Release.md)
- [App Store submission record](docs/App-Store-Submission.md)
- [Third-party notices](THIRD_PARTY_NOTICES.md)

Published public routes:

- Privacy: `https://ether-llc.com/apps/grace/privacy/`
- Terms: `https://ether-llc.com/apps/grace/terms/`
- Support: `https://ether-llc.com/apps/grace/support/`

Signing, validation, upload, publication, and release are external steps.

## Development and contributions

GitHub Actions requires product loading and eight purchase-related scenarios to pass in a dedicated StoreKit workflow alongside normal CI. The unfinished-transaction stream scenario still runs separately with strict same-transaction finish verification, but its result and artifacts are observational rather than part of the pass/fail gate. Logs show slow storekitd synchronization and changing cache revisions; the root cause remains unresolved. A green job does not mean all nine scenarios passed or notification handling is fixed. See [tracking and coverage](docs/Structure.md#unresolved-stream-validation). Physical-device and production-store behavior require separate validation.

Use the support route above for product help. For repository changes, consult the
implementation references and release gates linked above, and describe the change
and its validation in a pull request. PR descriptions and review comments use Japanese by default; an explicit request for another language takes precedence.

See [AGENTS.md](AGENTS.md) for shared repository instructions.

For Debug captures, launch with `--store-capture` to use three fictional moments
in memory without opening the normal persistent store. Add `--capture-empty`
for an empty state. Content follows the launch language (Japanese or English).
This mode is excluded from Release builds. On a physical device, use a development
build with a separate bundle ID so the existing Grace installation is not replaced.
Consult the actual execution results to confirm capture and interaction testing.

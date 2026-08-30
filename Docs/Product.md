# Grace

Grace is a private gratitude journal for noticing and preserving meaningful moments.

## Navigation

- Moments
- Achievements
- Assistant
- Pro
- Settings

## Core journal

- SwiftData persistence for a title, note, photo, and timestamp.
- Add, browse, open, and delete moments.
- Photo import through the system Photos picker.
- A hexagon timeline adapted from Apple’s “Views and data storage” tutorial.
- Empty, populated, save-failure, photo-failure, and delete-confirmation states.

## Commerce baseline

- `llc.ether.grace.pro.daily`: non-renewing Daily Pass with 24 hours of access.
- `llc.ether.grace.pro.monthly`: auto-renewable monthly plan.
- `llc.ether.grace.pro.yearly`: auto-renewable yearly plan.

The Daily Pass never renews automatically. Its 24-hour expiration is calculated
locally from StoreKit's verified purchase date and the device wall clock; this
release doesn't use a server-authoritative clock. App Store Connect products and
pricing must be configured and reviewed before these plans can be sold. The on-device
assistant is a Pro capability; the journal remains usable without a purchase.

## Implementation ownership

Grace owns its Foundation Models client, product-specific prompt, SwiftData schema,
and StoreKit 2 implementation locally. Daily, Monthly, and Yearly retain the common
plan shape used across the Ether apps.

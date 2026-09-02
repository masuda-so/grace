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

## On-device assistant

- Keeps one text conversation for the current app session and uses the same
  Foundation Models session until the person starts a new conversation.
- Supplies a fresh device-clock, locale, calendar, and time-zone snapshot plus at
  most the 12 newest Moment titles, notes, and exact stored timestamps as reference.
- Never includes stored photo data in assistant context. The recent records are
  marked as untrusted content and are bounded before prompting.
- Uses Foundation Models guided generation to prepare an editable title, note, and
  timestamp candidate only after the person explicitly requests one.
- Presents every candidate in a separate review sheet. SwiftData is changed only
  when the person edits as needed and chooses **Save Moment**; cancellation writes
  nothing, and the assistant has no direct save capability.
- Leaves the complete manual journal available when Foundation Models, Apple
  Intelligence, the current locale, or Pro access is unavailable.

## Implementation ownership

Grace owns its Foundation Models client and retained conversation, product-specific
prompt and bounded journal context, human-confirmed SwiftData save flow, schema, and
StoreKit 2 implementation locally. Daily, Monthly, and Yearly retain the common plan
shape used across the Ether apps.

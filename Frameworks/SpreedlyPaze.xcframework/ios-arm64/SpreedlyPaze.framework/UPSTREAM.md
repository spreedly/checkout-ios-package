# Vendored Paze UI — upstream record

Gate C (`SpreedlyDocs/development/PAZE_ARCHITECTURE.md` §14) resolved **PASS**: Early Warning
Services (Sandy Li, Implementation Manager) confirmed in writing that Spreedly may embed Paze's
production component source inside the mobile SDK and ship it to merchant customers, and that a
new source drop should be requested each time rather than depending on a versioned package.

## Source

- Repo: `merchant-samples-native-main` (received as a source drop from Early Warning / Paze)
- Files vendored: `PazeMerchantUI/Button/PazeButton.swift`, `PazeMerchantUI/Button/PazeButtonStyle.swift`
- Files vendored: `PazeMerchantUI/Resources/PazeAssets.xcassets` (label vectors + brand colors)
- Date received: 2026-08-04 (drop referenced in the redistribution approval thread)
- Date vendored into this repo: 2026-08-25

Not vendored: `PazeMerchantUI/Message/*` (`PazeMessage.swift`, `PazeMessageStyle.swift`) — out of
scope for this drop; `SpreedlyPazeMessage` is a separate, already-existing component in this
module (Gate H).

## Integrity

SHA-256 of the upstream files as received, before the patch below was applied:

| File | SHA-256 |
|---|---|
| `PazeButton.swift` | `4b0b418d802403b47965357a778358bc9586026be1d59ff8ec046aa85c567333` |
| `PazeButtonStyle.swift` | `f809ba35731db5b829c760a44dc5278cf2fb0ce9ea64f02c080ddefa1d2a6a7f` |

## Patch

`paze-ui.patch` in this directory makes two mechanical changes to `Button/PazeButton.swift` and
`Button/PazeButtonStyle.swift`, nothing else:

1. Every top-level `public` declaration becomes `internal` — the vendored source isn't part of
   this SDK's public API surface, and merchants who also copied Paze's files directly won't see a
   duplicate public symbol.
2. `PazeButtonLabel` / `PazeButtonColor` / `PazeButtonShape` are renamed to `PazeVendorButtonLabel`
   / `PazeVendorButtonColor` / `PazeVendorButtonShape`. This SDK already ships its own
   `public @objc enum PazeButtonLabel/Color/Shape` (`SpreedlyPaze/PazeButtonStyle.swift`) as the
   merchant-facing surface — declaring Paze's identically-named types in the same module would be
   a same-module redeclaration, not just an external ambiguity. `SpreedlyPazeButtonViewController`
   maps the public enums to these renamed vendored ones. `PazeButton`, `PazeButtonStyle`,
   `PazeButtonStyles`, and `PazeDimens` don't collide with any existing SDK type and keep their
   upstream names.
3. `internal extension UIButton.Configuration`, `internal final class PazeButton`,
   `internal extension PazeButton`, `internal struct PazeButtonStyle`, and
   `internal enum PazeButtonStyles` gain `@available(iOS 15.0, *)`. `UIButton.Configuration` is
   iOS 15+ only; this SDK's floor is iOS 14.0 (`.claude/rules/architecture-and-code-standards.md`).
   The `traitCollectionDidChange` override's own `@available(iOS, introduced: 8.0, deprecated:
   17.0)` is tightened to `introduced: 15.0` — an override can't be available earlier than its
   enclosing type. `PazeVendorColors.swift` (added in item 2 below) is gated the same way. The
   gate is on these vendored declarations rather than raising the module's deployment target, and
   it propagates to the public surface: `SpreedlyPazeButtonViewController` and `SpreedlyPazeButton`
   (SwiftUI) are now `@available(iOS 15.0, *)` too, and the Example app's usage is wrapped in
   `if #available(iOS 15.0, *)` — the Paze checkout button requires iOS 15.0+, matching the real
   Paze component's requirement.

`Button/PazeButtonStyle.swift` is also renamed to `Button/PazeVendorButtonStyle.swift` in this
directory (content otherwise unaffected by that rename) — Xcode requires unique Swift source
basenames within a single target, and this SDK already has its own
`SpreedlyPaze/PazeButtonStyle.swift`.

One file in this directory, `Resources/PazeVendorColors.swift`, is **not** part of the source
drop. The sample app's `PazeButtonStyle.swift` references `.pazePrimary` / `.pazeMidnight` as
dot-syntax `UIColor` members, which only exist if the target opts in to Xcode's auto-generated
asset-symbol extensions (`ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS`) — a build
setting this SDK target doesn't set, and changing it is a `project.pbxproj` edit out of scope for
this drop. `PazeVendorColors.swift` resolves the same two named colors from
`Resources/PazeAssets.xcassets` directly via `UIColor(named:in:)`, with fallback constants that
match the colorset values, and `paze-ui.patch` swaps the two dot-syntax call sites in
`PazeVendorButtonStyle.swift` to use it. Otherwise the vendored files are byte-identical to the
source drop.

## Re-vendoring

When a new source drop arrives:

1. Diff the new drop against the files listed above; confirm nothing beyond cosmetic/branding
   changes before re-vendoring.
2. Copy the new files over `Button/` and `Resources/PazeAssets.xcassets` in this directory.
3. Re-apply `paze-ui.patch` (or regenerate it if the upstream file structure changed).
4. Update the SHA-256 table and dates above.
5. Re-run `PazeButtonBrandingTests`.

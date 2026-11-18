# Food After Hours — iOS classroom demo

Native SwiftUI companion to the Next.js demonstration in this repository. This is a **prototype**, not a live pickup, payment, or authenticated university service. Role switching previews workflows; it does not protect any data or actions.

## Open in Xcode

1. On your Mac, run `npm install` (if needed), then `npm run dev` in the repository root. Keep the Node server running; it serves the existing SQLite database and `/api/state` and `/api/action`.
2. Open `ios/OSUFood.xcodeproj` in Xcode 27 or later.
3. Select the **OSUFood** scheme and an iOS 18+ simulator, then press Run. The simulator connects to `http://localhost:3000`. To use a physical device, change the URL passed to `APIClient(baseURL:)` to an HTTPS server reachable by that device; `localhost` on a device is the device itself. An HTTPS deployment must serve the full Next.js Node backend, not the separate static Cloudflare HTML file.
4. The app initially opens in Pantry Volunteer preview. Use the top role menu to explore Student, Dining Staff and Administrator flows. Pull down on a screen to refresh its data.

To regenerate the project after adding Swift files, install [XcodeGen](https://github.com/yonaskolb/XcodeGen) and run `xcodegen generate --spec ios/project.yml --project ios`. The generated `.xcodeproj` is included so XcodeGen is **not** required just to open or build the project. Build products and user settings should stay out of version control.

## Architecture

`OSUFood/Models` decodes the complete API snapshot and encodes validated action payloads; `Services` uses URLSession and refreshes the snapshot after mutations. `Views` contains native discovery, reservations, staff operations, impact, admin controls and guide. Actions are executed against the same local SQLite-backed Next.js API as the web interface. Nothing is stored as separate iOS inventory, and there is no offline transaction queue.

The current API has no authentication and exposes all reservation codes to callers. Do **not** expose the server publicly or use this app for real reservations without implementing server-side identity, scoped reads, authorization, safe pickup verification, food-safety policies and an appropriately secured deployment. Administrator reset deletes all demo changes after confirmation.

The `NSAllowsLocalNetworking` transport exception permits the local simulator HTTP server for classroom testing; configure HTTPS for any remotely reachable backend. All example dining center names, prices, pantry sites and pickup instructions are fictional and not approved service locations.

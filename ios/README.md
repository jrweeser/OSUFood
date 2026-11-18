# Food After Hours — iOS classroom demo

Native SwiftUI companion to the Next.js demonstration in this repository. This is a **prototype**, not a live pickup, payment, or authenticated university service. Role switching previews workflows; it does not protect any data or actions.

## Open in Xcode

1. Edit `OSUFood/Services/APIClient.swift` and replace the placeholder `https://example.com` in `websiteURL` with the HTTPS origin of a full-stack demo server that serves `/api/state` and `/api/action`. Do not enter a static-site URL: `cloudflare/index.html` has no API. Do not commit a personal hostname or private backend address; restore the placeholder before publishing.
2. Open `ios/OSUFood.xcodeproj` in Xcode 27 or later. Select the **OSUFood** scheme and an iOS 18+ simulator or device, then press Run. If running on a physical device, select your own signing team in Xcode; the shared project has no personal signing team. Without a configured backend, the app displays a connection error.
3. The app initially opens on Browse in Student preview. Use the top role menu to explore Pantry Volunteer, Dining Staff and Administrator flows. Pull down on a screen to refresh its data. Appearance follows the device's light or dark setting.

To regenerate the project after adding Swift files, install [XcodeGen](https://github.com/yonaskolb/XcodeGen) and run `xcodegen generate --spec ios/project.yml --project ios`. The generated `.xcodeproj` is included so XcodeGen is **not** required just to open or build the project. Build products and user settings should stay out of version control.

## Architecture

`OSUFood/Models` decodes the complete API snapshot and encodes validated action payloads; `Services` uses URLSession and refreshes the snapshot after mutations. `Views` contains native discovery, reservations, staff operations, impact, admin controls and guide. Once configured, actions use the same Next.js API as the web interface. Nothing is stored as separate iOS inventory, and there is no offline transaction queue.

The current API has no authentication and exposes all reservation codes to callers. **If the configured server is publicly reachable, anyone can read demo data and call mutation endpoints, including reset.** Do not use real personal data or real reservations; implement server-side identity, scoped reads, authorization, safe pickup verification and food-safety policies before any real-world use. Administrator reset deletes all demo changes after confirmation in the app, but the API itself has no access control.

The default connection uses HTTPS and does not require a local-network transport exception. The app icon is in `OSUFood/Assets.xcassets/AppIcon.appiconset`. All example dining center names, prices, pantry sites and pickup instructions are fictional and not approved service locations.

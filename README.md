# SasflixMobile

Native SwiftUI iOS app for `sasflix.ru`

## Features

- Loads the public Sasflix RSS feed
- Shows poster cards, categories, search, and pull-to-refresh
- Syncs saved feed items with Sasflix account favorites through the API
- Shows account viewing history from Sasflix
- Opens playback and account-dependent actions on the official site
- Uses iOS 18+ `Tab` API and Swift 6 settings

## Build

```sh
xcodebuild -project SasflixMobile.xcodeproj -scheme SasflixMobile -destination 'generic/platform=iOS Simulator' -derivedDataPath ../../work/DerivedData CODE_SIGNING_ALLOWED=NO build
```

The app does not launch Simulator during build

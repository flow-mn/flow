# ![Flow logo](logo@32.png) Flow

[![Buy me a coffee](https://img.shields.io/badge/buy_me_a_coffee-sadespresso-f5ccff?logo=buy-me-a-coffee&logoColor=white&style=for-the-badge)](https://buymeacoffee.com/sadespresso)
[![Website](https://img.shields.io/badge/Website-flow.gege.mn-f5ccff?style=for-the-badge)](https://flow.gege.mn)&nbsp;
[![Flow's GitHub repo](https://img.shields.io/badge/GitHub-flow--mn/flow-f5ccff?logo=github&logoColor=white&style=for-the-badge)](https://github.com/flow-mn/flow)&nbsp;
[![Join Flow Discord server](https://img.shields.io/badge/Discord-Flow-f5ccff?logo=discord&logoColor=white&style=for-the-badge)](https://discord.gg/Ndh9VDeZa4)

## Download Flow (beta)

[![Google Play Store](https://img.shields.io/badge/Google_Play-open_testing-f5ccff?logo=google-play&logoColor=white&style=for-the-badge)](https://play.google.com/store/apps/details?id=mn.flow.flow)
[![Join TestFlight group](https://img.shields.io/badge/TestFlight-beta_testing-f5ccff?logo=appstore&logoColor=white&style=for-the-badge)](https://testflight.apple.com/join/NH4ifijS)
[![See Codemagic builds](https://img.shields.io/badge/CodeMagic-see_builds-f5ccff?logo=codemagic&logoColor=white&style=for-the-badge)](https://codemagic.io/apps/65950ed30591c25df05b5613/65950ed30591c25df05b5612/latest_build)

> Backuping up before updating is highly recommended!

## Preface

Flow is a free, open-source, cross-platform personal finance tracking app.

Beta available on Android, iOS, and more[^1]

### Features

* Multiple accounts
* Multiple currencies
* Fully-offline
* Full export/backup
  * JSON for backup
  * CSV for external software use (i.e., Google Sheets)

## Try Flow

Flow will be available in App Store soon. In the meantime,
please download Flow from TestFlight. Android users should
have no major issues downloading Flow, but it will be available
on the Google Play's production track.

Feedbacks and ideas are greatly appreciated 🌟

Flow in production: [Blog post](https://blog.gege.mn/publishing-flow-to-production-20250104?showSharer=true)

## Supported platforms

* Android
* iOS
* and more[^1]

## Development

Please read [Contribuition guide](./CONTRIBUTING.md) before contributing.

### Prerequisites

* [Flutter](https://flutter.dev/) (stable)

Other:

* JDK 17 if you're gonna build for Android
* [XCode](https://developer.apple.com/xcode/) if you're gonna build for iOS/macOS
* To run tests on your machine, see [Testing](#testing)

Building for Windows, and Linux-based systems requires the same dependencies
as Flutter. Read more on <https://docs.flutter.dev/platform-integration>

### Running

`flutter run`

See more on <https://flutter.dev/>

### Testing

If you plan to run tests on your machine, ensure you've installed ObjectBox
dynamic libraries.

Install ObjectBox dynamic libraries[^2]:

`bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-dart/main/install.sh)`

Testing:

`flutter test`

[^1]: Will be available on macOS, Windows, and Linux-based systems, but no plan
to enhance the UI for desktop experience for now.

[^2]: Please double-check from the official website, may be outdated. Visit
<https://docs.objectbox.io/getting-started#add-objectbox-to-your-project>
(make sure to choose Flutter to see the script).

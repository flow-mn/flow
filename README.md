# ![Flow logo](logo@32.png) Flow

[![Buy me a coffee](https://img.shields.io/badge/buy_me_a_coffee-sadespresso-f5ccff?logo=buy-me-a-coffee&logoColor=white&style=for-the-badge)](https://buymeacoffee.com/sadespresso)
[![Website](https://img.shields.io/badge/Website-flow.gege.mn-f5ccff?style=for-the-badge)](https://flow.gege.mn)&nbsp;
[![Flow's GitHub repo](https://img.shields.io/badge/GitHub-flow--mn/flow-f5ccff?logo=github&logoColor=white&style=for-the-badge)](https://github.com/flow-mn/flow)&nbsp;
[![Join Flow Discord server](https://img.shields.io/badge/Discord-Flow-f5ccff?logo=discord&logoColor=white&style=for-the-badge)](https://discord.gg/Ndh9VDeZa4)

## Preface

![Flow logo](logo@16.png) Flow is a

* Free
* Open-Source
* Simple
* UX-Focused
* Fully-offline[^1]
* Cross-platform[^2]

personal expense tracking app.

## Download Flow (beta)

[![Google Play Store](https://img.shields.io/badge/Google_Play_Store-beta-f5ccff?logo=google-play&logoColor=white&style=for-the-badge)](https://play.google.com/store/apps/details?id=mn.flow.flow)
[![App Store](https://img.shields.io/badge/App_Store-beta-f5ccff?logo=appstore&logoColor=white&style=for-the-badge)](https://apps.apple.com/mn/app/flow-expense-tracker/id6477741670)
[![Other build files](https://img.shields.io/badge/releases-other_build_files-f5ccff?logo=github&logoColor=white&style=for-the-badge)](https://github.com/flow-mn/flow/releases/latest)

> You can build and run for Linux and macOS. Haven't tested Windows yet[^2]

## Features

* Simple & seamless UX
* Multiple accounts
* Multiple currencies
* Fully-offline[^1]
* Full export/backup
  * Fully recoverable backups (ZIP/JSON)
  * Export CSV for external software use (i.e., Google Sheets)

## Support Flow

Flow is a personal project developed during my free time, and it generates no
income. Consider helping Flow! Here are some suggestions:

* Give a star on [GitHub](https://github.com/flow-mn/flow)
* Leave a review on [Google Play](https://play.google.com/store/apps/details?id=mn.flow.flow) and [App Store](https://apps.apple.com/mn/app/flow-expense-tracker/id6477741670)
* Tell a friend
* [Buy me a coffee](https://buymeacoffee.com/sadespresso)
  
  Maintaining Flow on the App Store requires a substantial annual fee
  (see [Apple Developer Program](https://developer.apple.com/support/enrollment/#:~:text=The%20Apple%20Developer%20Program%20annual,in%20local%20currency%20where%20available.)),
  which [I currently cover](https://github.com/sadespresso).  To ensure Flow's
  continued existence and future development, your support is greatly appreciated.

## Development

Please read [Contribuition guide](./CONTRIBUTING.md) before contributing.

### Prerequisites

* [Flutter](https://flutter.dev/) (latest stable)

Other:

* JDK 1.8 or 17 if you're gonna build for Android
* [XCode](https://developer.apple.com/xcode/) if you're gonna build for iOS/macOS
* To run tests on your machine, see [Testing](#testing)

Building for Windows, macOS, and Linux-based systems requires the same
dependencies as Flutter. Read more on <https://docs.flutter.dev/platform-integration>

### Testing

If you plan to run tests on your machine, ensure you've installed ObjectBox
dynamic libraries.

Install ObjectBox dynamic libraries[^3]:

`bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-dart/main/install.sh)`

Testing:

`flutter test`

[^1]: Flow requires internet to download currency exchage rates. Only necessary
if you use more than one currencies

[^2]: Will be available on macOS, Windows, and Linux-based systems, but no plan
to enhance the UI for desktop experience for now.

[^3]: Please double-check from the official website, may be outdated. Visit
<https://docs.objectbox.io/getting-started#add-objectbox-to-your-project>
(make sure to choose Flutter to see the script).

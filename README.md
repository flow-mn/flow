# ![Flow logo](logo@32.png) Flow

[![Buy me a coffee](https://img.shields.io/badge/buy_me_a_coffee-sadespresso-f5ccff?logo=buy-me-a-coffee&logoColor=white&style=for-the-badge)](https://buymeacoffee.com/sadespresso)
[![Website](https://img.shields.io/badge/Website-flow.gege.mn-f5ccff?style=for-the-badge)](https://flow.gege.mn)&nbsp;
[![Flow's GitHub repo](https://img.shields.io/badge/GitHub-flow--mn/flow-f5ccff?logo=github&logoColor=white&style=for-the-badge)](https://github.com/flow-mn/flow)&nbsp;
[![Join Flow Discord server](https://img.shields.io/badge/Discord-Flow-f5ccff?logo=discord&logoColor=white&style=for-the-badge)](https://discord.gg/Ndh9VDeZa4)

## Preface

![Flow logo](logo@16.png) Flow is a free, open-source, and beautifully simple
expense tracker — built with a focus on great UX, works fully offline, and runs
seamlessly across platforms.

## Download Flow (beta)

[![Google Play Store](https://img.shields.io/badge/Google_Play_Store-beta-f5ccff?logo=google-play&logoColor=white&style=for-the-badge)](https://play.google.com/store/apps/details?id=mn.flow.flow)
[![App Store](https://img.shields.io/badge/App_Store-beta-f5ccff?logo=appstore&logoColor=white&style=for-the-badge)](https://apps.apple.com/mn/app/flow-expense-tracker/id6477741670)
[![Obtanium](https://img.shields.io/badge/Obtainium-beta-f5ccff?logo=obtainium&logoColor=white&style=for-the-badge)](https://apps.obtainium.imranr.dev/redirect?r=obtainium://app/%7B%22id%22%3A%22mn.flow.flow%22%2C%22url%22%3A%22https%3A%2F%2Fgithub.com%2Fflow-mn%2Fflow%22%2C%22author%22%3A%22flow-mn%22%2C%22name%22%3A%22Flow%22%2C%22preferredApkIndex%22%3A0%2C%22additionalSettings%22%3A%22%7B%5C%22includePrereleases%5C%22%3Afalse%2C%5C%22fallbackToOlderReleases%5C%22%3Atrue%2C%5C%22filterReleaseTitlesByRegEx%5C%22%3A%5C%22%5C%22%2C%5C%22filterReleaseNotesByRegEx%5C%22%3A%5C%22%5C%22%2C%5C%22verifyLatestTag%5C%22%3Afalse%2C%5C%22sortMethodChoice%5C%22%3A%5C%22date%5C%22%2C%5C%22useLatestAssetDateAsReleaseDate%5C%22%3Afalse%2C%5C%22releaseTitleAsVersion%5C%22%3Afalse%2C%5C%22trackOnly%5C%22%3Afalse%2C%5C%22versionExtractionRegEx%5C%22%3A%5C%22%5C%22%2C%5C%22matchGroupToUse%5C%22%3A%5C%22%5C%22%2C%5C%22versionDetection%5C%22%3Atrue%2C%5C%22releaseDateAsVersion%5C%22%3Afalse%2C%5C%22useVersionCodeAsOSVersion%5C%22%3Afalse%2C%5C%22apkFilterRegEx%5C%22%3A%5C%22%5C%22%2C%5C%22invertAPKFilter%5C%22%3Afalse%2C%5C%22autoApkFilterByArch%5C%22%3Atrue%2C%5C%22appName%5C%22%3A%5C%22%5C%22%2C%5C%22appAuthor%5C%22%3A%5C%22%5C%22%2C%5C%22shizukuPretendToBeGooglePlay%5C%22%3Afalse%2C%5C%22allowInsecure%5C%22%3Afalse%2C%5C%22exemptFromBackgroundUpdates%5C%22%3Afalse%2C%5C%22skipUpdateNotifications%5C%22%3Afalse%2C%5C%22about%5C%22%3A%5C%22%5C%22%2C%5C%22refreshBeforeDownload%5C%22%3Afalse%7D%22%2C%22overrideSource%22%3Anull%7D)
[![Other build files](https://img.shields.io/badge/releases-other_build_files-f5ccff?logo=github&logoColor=white&style=for-the-badge)](https://github.com/flow-mn/flow/releases/latest)

> You can build and run for Linux and macOS. Haven't tested Windows yet[^2]

## Features

* Simple UX helping you efficiently track your finances
* Infinite accounts and currencies (including various cryptos)
* Categories, tags, file attachments, geo tagging (optional)
* Reflect on your spendings
* Fully-offline[^1]
* Full control over your data
  * No trackers, no analytics
  * Fully recoverable backups (ZIP/JSON)
  * Export CSV, PDFs
  * Periodic auto-backups to iCloud
* Absolutely free ([please donate 🥺](#support-flow))
* [URI-based automation](#uri-based-automation)

## URI-based automation

You can add one or more transactions using `flow-mn` schema uris.

Check out the supported [JSON Schema file in schemas folder](./schemas/programmable-object.json).

Currencies are based on the account, so there's no way to specify it at the moment.

### Adding single transaction

When adding single transactions, properties must be provided as query params.

```json
{
  "title": "Tous les jours",
  "amount": 42000.00
}
```

turns into:

```plain
flow-mn:///transaction/new?title=Tous+les+jours&amount=42000.00
```

### Adding multiple transactions

When adding multiple transactions, you must provide stringified version of the following as "json" query param.

```json
{
  "t": [
    {
      "title": "Fresh blueberry piece",
      "amount": "13000.00",
      "transactionDate": "2011-12-05",
      "category": "Food",
      "tags": "My fave cafe",
      "accountUuid": "faa6d523-277f-46af-9493-67768e5b48ab",
    },
    {
      "title": "Caffe Mocha ice",
      "amount": "10000.00",
      "transactionDate": "2011-12-05",
      "category": "Drinks"
    }
  ]
}
```

turns into

```plain
flow-mn:///transaction/new?json=%7B%22t%22%3A%5B%7B%22title%22%3A%22Fresh%20blueberry%20piece%22%2C%22amount%22%3A%2213000.00%22%2C%22transactionDate%22%3A%222011-12-05%22%2C%22category%22%3A%22Food%22%7D%2C%7B%22title%22%3A%22Caffe%20Mocha%20ice%22%2C%22amount%22%3A%2210000.00%22%2C%22transactionDate%22%3A%222011-12-05%22%2C%22category%22%3A%22Drinks%22%7D%5D%7D
```

## Development

Please read [Contribuition guide](./CONTRIBUTING.md), and
[Code of Conduct](./CODE_OF_CONDUCT.md) before contributing.

### Prerequisites

* [Flutter](https://flutter.dev/) (latest stable)

Other:

* JDK 11 or later if you're gonna build for Android
* [XCode](https://developer.apple.com/xcode/) if you're gonna build for iOS/macOS
* To run tests on your machine, see [Testing](#testing)

Building for Windows, macOS, and Linux-based systems requires the same
dependencies as Flutter. Read more on <https://docs.flutter.dev/platform-integration>

### Testing

If you plan to run tests on your machine, ensure you've installed ObjectBox
dynamic libraries.

Install ObjectBox dynamic libraries[^3]:

`bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-dart/main/install.sh)`

Run tests with: `flutter test`

## Support Flow

Flow is a personal project developed during my free time, and it generates no
income. Consider helping Flow! Here are some suggestions:

* Give a star on [GitHub](https://github.com/flow-mn/flow)
* Leave a review on [Google Play](https://play.google.com/store/apps/details?id=mn.flow.flow)
  and [App Store](https://apps.apple.com/mn/app/flow-expense-tracker/id6477741670)
* Tell a friend
* [Buy me a coffee](https://buymeacoffee.com/sadespresso)
  <!-- markdownlint-disable-next-line -->
  <a href="https://www.buymeacoffee.com/sadespresso"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=☕&slug=sadespresso&button_colour=BD5FFF&font_colour=ffffff&font_family=Lato&outline_colour=000000&coffee_colour=FFDD00" /></a>
  
Maintaining Flow on the App Store requires a substantial annual fee
(see [Apple Developer Program](https://developer.apple.com/support/enrollment/#:~:text=The%20Apple%20Developer%20Program%20annual,in%20local%20currency%20where%20available.)),
which [I currently cover](https://github.com/sadespresso).  To ensure Flow's
continued existence and future development, your support is greatly appreciated.

Thank you to all the contributors, supporters, testers, and those who contributed indirectly 🤍

## List of supported languages

* Arabic - thanks to [Ultrate](https://github.com/Ultrate)
* English
* French (France)
* German (Germany) - thanks to [MarkusWangler](https://github.com/MarkusWangler)
* Italian (Italy) - thanks to [albertorizzi](https://github.com/albertorizzi)
* Mongolian (Mongolia)
* Russian (Russia)
* Spanish (Spain)
* Turkish (Turkiye) - thanks to [NoRiskNoViski](https://github.com/NoRiskNoViski)
* Ukranian (Ukrain)
* Czech (Czechia) - thanks to **Miloš Koliáš** through email

> See [Translation guide](./CONTRIBUTING.md#translating) if you want to make
> Flow available to your language

<!-- markdownlint-disable-next-line -->
<!-- <a href="https://www.producthunt.com/posts/flow-2cbe921f-2ed9-4ed1-b8d7-26dff1c2c49d?embed=true&utm_source=badge-top-post-badge&utm_medium=badge&utm_souce=badge-flow&#0045;2cbe921f&#0045;2ed9&#0045;4ed1&#0045;b8d7&#0045;26dff1c2c49d" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/top-post-badge.svg?post_id=955354&theme=light&period=daily&t=1745222977391" alt="Flow - A&#0032;FOSS&#0032;expense&#0032;tracker&#0032;that&#0032;focuses&#0032;on&#0032;privacy&#0032;and&#0032;UX | Product Hunt" style="width: 250px; height: 54px;" width="250" height="54" /></a> -->

[^1]: Flow requires internet to download currency exchage rates. Only necessary
if you use more than one currencies

[^2]: Will be available on macOS, Windows, and Linux-based systems, but no plan
to enhance the UI for desktop experience for now.

[^3]: Please double-check from the official website, may be outdated. Visit
<https://docs.objectbox.io/getting-started#add-objectbox-to-your-project>
(make sure to choose Flutter to see the script).

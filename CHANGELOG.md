## (Next) Beta

* Selecting icons should be slightly better
* Now icons (Material Symbols and Simple Icons) are searchable (only in English)
* Improved backup history empty UI
* Fixed number format was messed up when dividing with input sheet calculator

## Beta 0.5.3

* Fixed entering decimal amount with leading '0' decimal was impossible. (e.g., `1.02` was impossible to input)
* Calculator percent button now adds/subtracts percent of initial value when adding/subtracting
* [iOS only] Now uses iOS system language settings for app language

## Beta 0.5.2

* Fixed transaction page date selector's time was always set to **zero** (12AM)
* Now uses [pie_menu](https://pub.dev/packages/pie_menu) from pub.dev since
fork's additional features have are in the new release
* Uses serializer from [`moment_dart`](https://github.com/sadespresso/moment_dart)
* Saves all backups in app data, fixes [#131](https://github.com/flow-mn/flow/issues/131)
* Backups are now deletable
* Minor improvements

## Beta 0.5.1

* [FEAT] Customize order of new transaction buttons by @sadespresso in https://github.com/flow-mn/flow/pull/148
* Reform account edit page by @sadespresso in https://github.com/flow-mn/flow/pull/149

## Beta 0.5.0

* Added calculator by @sadespresso in <https://github.com/flow-mn/flow/pull/147>
* Uses correct control modifier - `Meta` for macOS and iOS, `Control` for others
* Comma separator is now displayed correctly when inputting amount
* Minor UX tweaks

## Beta 0.4.3

* Fix Category page re renders upon change in db by @sadespresso in https://github.com/flow-mn/flow/pull/140
* Fix `CustomRange.end` goes 'til the end of the day by @sadespresso in https://github.com/flow-mn/flow/pull/141
* Fix Time range selector bottom sheet overflows by @sadespresso in https://github.com/flow-mn/flow/pull/142

## Beta 0.4.2

* Category page reform by @sadespresso in https://github.com/flow-mn/flow/pull/135
* feat: memoize account names by @sadespresso in https://github.com/flow-mn/flow/pull/129
* Upcoming transaction hitbox by @sadespresso in https://github.com/flow-mn/flow/pull/132
* Title suggestion improvement by @sadespresso in https://github.com/flow-mn/flow/pull/134
* Minor UI and l10n improvements

## Beta 0.4.1

* fix minus sign missing by @sadespresso in <https://github.com/flow-mn/flow/pull/125>
* Fallback to English when translation keys are missing by @sadespresso in <https://github.com/flow-mn/flow/pull/126>
* l10n: add missing italian transactions by @sadespresso in <https://github.com/flow-mn/flow/pull/123>

## Beta 0.4.0

* Upcoming transactions by @sadespresso in <https://github.com/flow-mn/flow/pull/122>
* add it-IT language by @albertorizzi in <https://github.com/flow-mn/flow/pull/116>
* Translation missing by @sadespresso in <https://github.com/flow-mn/flow/pull/111>
* Fixed new transaction date wasn't being set
* Fixed transfer titles not being set

## Beta 0.3.4

- Added year/month selector, closes [#85](https://github.com/flow-mn/flow/issues/85)
- No longer uses `AutomiaticKeepAlive` for stats tab, but will change this later. Fixes [#94](https://github.com/flow-mn/flow/issues/94)
- Limited stats tab's pie chart to 300px

## Beta 0.3.3

- Fix transaction date doesn't get updated, closes [#100](https://github.com/flow-mn/flow/issues/100)
- Improve setup by [#103](https://github.com/flow-mn/flow/pull/103)

## Beta 0.3.2

- Fixed transaction page title suggestion was behaving differently from prior
  releases. Improved UX

## Beta 0.3.1

- Transaction page now suggests title based on relevancy (category, account, etc)
- Removed minus (`-`) sign in expense transaction input sheet, closes [#88](https://github.com/flow-mn/flow/issues/88)
- Setup page bottom buttons are now rendered in `SafeArea` ()
- Fixed stats tab custom range selection not updating the state (21940fd775c9c0d05e8c70da7d682b24bfa0199c)
- Added Mongolian localization for the iOS project, closes [#72](https://github.com/flow-mn/flow/issues/72)

## Beta 0.3.0

- Initial beta release
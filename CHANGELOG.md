# Changelog

## Next

### New features

* Now you can save backups to iCloud. Enable it in `Preferences > Sync`
* [OPTIMISTIC] Now you can setup credit line accounts.
* Added list of contributors, closes [#448](https://github.com/flow-mn/flow/issues/448)
* Date and time are now in Arabic when the language is set to Arabic, thanks to [Ultrate](https://github.com/Ultrate)

### Changes & Improvements

* Backup files naming convention has changed to comply with iCloud Drive file name requirements
* Added "Recommend Flow" button
* Title suggestion now considers recency of a transaction
* Improved RTL support in certain parts of the UI. Feel free to report more issues regarding RTL
* Transfer transactions now shows account balance

### Fixes

* Categories page layout is no longer "suboptimal" on smaller screens
* `Add category from presets` page no longer show presets with same name as any of your existing categories

## 0.13.1

### Changes & Improvements

* Now you can customize some aspects of transaction list item
* Money formatting preferences page will now show an example
* Now you can add category presets after the setup, closes [#104](https://github.com/flow-mn/flow/issues/104)
  * Also added few more presets

### Fixes

* Minor UI fixes

## 0.13.0

### New features

* Arabic language support thanks to [@Ultrate](https://github.com/Ultrate)
* Now you can transfer between accounts of different currency. Closes [#400](https://github.com/flow-mn/flow/issues/400)
* Now you can long press and drag to change transaction date, closes [#346](https://github.com/flow-mn/flow/issues/346)
* Now you can import from CSVs. (This doesn't support multi-currency transactions for the same account)
  * See template on Google Sheets: <https://docs.google.com/spreadsheets/d/1wxdJ1T8PSvzayxvGs7bVyqQ9Zu0DPQ1YwiBLy1FluqE/edit?usp=sharing>

    The template cells will turn red if you provide incorrect datetime format
* Now you can set up "Auto-backup". Defaults to every 72 hour.

  IMPORTANT: Backups are made only when you open the app! And you have to save
  them manually
* Now Flow asks you to:
  * Save the latest auto-backup if you haven't. This doesn't get dismissed until
    you save the latest backup
  * Rate the app every 75 days (this can be disabled by the system on iOS and macOS)
  * Give a star on GitHub every 120 days

### Fixes

* Fixed notifications wasn't working on Android 14 (maybe 13 also, and potentially all androids... hehe)
* Account tab total income/expense no longer includes deleted transactions
* Early reminders now work correctly
* "Save backup" now saves files into "Downloads" folder on desktop (macOS, Linux, and Windows), closes [#326](https://github.com/flow-mn/flow/issues/326)
* Category card in categories page now shows current month flow (used to show all-time)
* Importing no longer results in outdated data in some part of the interface
* Home tab now updates after fetching the exchange rates
* Exchange rate missing warning no longer incorrectly show for those who use only one currency

### Changes and improvements

* Launching Flow from a notification now opens the relevant page if available
* CSV no longer includes deleted transactions
* CSV now includes ISO 8601 format transaction date
* UX enhancements regarding setup flow
* Profile tab now shows pending and deleted transactions
* Added an option show category name for untitled transactions, closes [#416](https://github.com/flow-mn/flow/issues/416)

## Beta 0.12.2

### Fixes

* Fixed some Android devices were unable to open the app

### Notice

If you were **unable to open the app** in the previous update (0.12.1),
please do the following. Non-android users, and those who didn't suffer from the
problem can ignore this.

* You will be greeted with a setup page. This is fine, you can proceed,
  or close the app and reopen. Your data shouldn't be affected by this.
* You can backup your data now if you want
* Please reconfigure your preferences. You may see your theme, money formatting
  and/or other preference you've set disappeared.

## Beta 0.12.1

### New features

* Now you can setup daily reminders, so you won't forget to track your expenses
* Added French (fr_FR), it's totally AI generated, but it'll help me cuz I'm trying to learn french
* Added App lock in response to a popular request, closes [#348](https://github.com/flow-mn/flow/issues/348)

### Fixes

* In transaction/account/category, and other pages with forms, clicking back button multiple times
  after changing data no longer shows multiple modal sheets. This mostly affected android.
* Platforms other than iOS no longer shows "App icon follows theme" option as it's not available, closes [#345](https://github.com/flow-mn/flow/issues/345)
* App no longer hangs when re-opening in some cases, closes [#370](https://github.com/flow-mn/flow/issues/370)
  * Thanks @tossj for submitting a fix

### Changes and improvements

* Now Flow shows warnings for ungranted notification/location permissions
* Flow now saves logs on-device. Logs contain information about certain actions being
  executed, and information about failures and errors in the app, and could be used
  for debugging.

  You can find logs at the end of the Preferences page

  > At the moment, most sensitive information stored on the app is transaction UUID,
  > which doesn't reveal any sensitive information without the data.

## Beta 0.12.0

### New features

* Now you can create and delete (except the default one) filter presets
* **[Experimental]** Now you can receive notifications for pending transactions on iOS and Android.
  It may support macOS in the future.
* Deleted transaction now go to "Trash bin". You can recover recently deleted
  items, closes [#294](https://github.com/flow-mn/flow/issues/294)
* Added [catppuccin](https://github.com/catppuccin/catppuccin) themes

### Changes and improvements

* Missing exchange rates warning no longer shows if you use only one currency
  across Flow
* Now you can group by "All time" - have your transactions in one big group...?
* Currency filter now longer shows when you only use single currency
* Slidable actions no longer preserve open panes when another opens in the same group
* Backup history entry now shows file size with extra decimal precision (e.g., 1mb -> 1.2mb)
* Modal pages will now respond to back buttons/gestures
* Confirming transfers no longer leaves the other transaction stranded

### Fixes

* Fixed total balance not updating in the account tab
* Deleting accounts and categories no longer leave you stranded in a "not found"
  page in some cases
* Fixed toggling `Transfers > Exclude from totals` would cause home tab flow to
  show incorrect data
* Updating account balance no longer creates multiple amendment transactions when
  updating/correcting the amount for the second and subsequent times
* Updating account balance no longer creates unnecessary `zero` amount transactions

## Beta 0.11.1

### Fixes

* [IMPORTANT] Fixed Stats tab first day of month (or any range) was missing
This led to incorrect avg. daily expense/income, which, now, is fixed.

### New fetures

* Now you can use OLED themes, closes [#288](https://github.com/flow-mn/flow/issues/288)
* Now you can sync your balance at an exact date, closes [#293](https://github.com/flow-mn/flow/issues/293)

## Beta 0.11.0

* Reworked stats tab (ongoing)
* Enhanced search options (ongoing)
  * Added partial and exact match mode
  * Added option to include description, closes [#269](https://github.com/flow-mn/flow/issues/269)
    At the time, it will only do substring (partial) matching.
* Now you can group transcations by hour, day, week, month, and year, closes [#256](https://github.com/flow-mn/flow/issues/256)
* Fixed that the default filters weren't updating when the day changes (at 00:00)

## Beta 0.10.2

### Improvements

* Date, time translations now support Turkish, fixes [#266](https://github.com/flow-mn/flow/issues/266)

## Beta 0.10.1

### New features

* Added Turkish language [#259](https://github.com/flow-mn/flow/issues/259) by @winstreakers

### Changes and improvements

* Now checking `Prefer full amounts` in Money formatting settings makes daily summaries
  show full amounts. Closes [#255](https://github.com/flow-mn/flow/issues/255)
* Now importing data triggers frecency data to update.

### Fixes

* Account tab "Total balance" no longer shows stale data

## Beta 0.10.0

### New features

* Now you can deactivate accounts.
  * Deactivated accounts will no longer show up in account selection
  sheets, and the accounts tab. It will still show up for older transactions, and reports.
  * You can find inactive accounts in Profile tab > Accounts

### Changes and improvements

* [BREAKING] Profile pictures are now stored elsewhere. Auto-migration will be in place for few builds.
Please reapply your profile picture if you need to.
* Now you are unable to permanently delete an account until you deactivate it.
* Now account in transaction page shows post-transcation balance instead of current balance
* Account selection sheet now shows current balance for each account
* Now you can import an old backup at the setup

### Fixes

* Fixed home page wasn't scrolling to the top when clicking on iOS app bar
* Now you can do ZIP backups that include account/profile photos, fixes [#173](https://github.com/flow-mn/flow/issues/173)
  and [#204](https://github.com/flow-mn/flow/issues/204)
* Transfers no longer incorrectly ask confirmation when nothing has changed on transaction page
* With updating flutter, fix of [#82](https://github.com/flow-mn/flow/issues/82) came

## Beta 0.9.0

### New features

* Home screen day title flow now converts all currencies into primary
* Markdown editor (transaction description) now has a preview, and minimal toolbar
* Now you can duplicate a transaction be swiping to the right, closes [#232](https://github.com/flow-mn/flow/issues/232)

### Changes

* Renamed upcoming/planned -> Pending transactions
* Home screen pending transactions time range settings has been revised.
  You will need to update your preferences again.
* Deprecated old theme system (light/dark). If you missed an update since
  this features was introduced, you will need to set up your themes agian.
* Now confirming pending transactions update date of transaction to the
  date of confirmation. You can disable this in **Preferences** >
  **Pending transactions**
* Haptic feedbacks setting has been moved, and now controls all haptics.
  (Including error feedbacks)

### Fixes and enhancements

* Transaction list tile title color is now fixed in light themes
* Wavy divider color now follows the theme change
* Disabled Autocorrect on transaction title, so it no longer alters suggestions
* Category and account detail page now doesn't include pending transactions in
  count and flow.
* Home tab search should work better now

## Beta 0.8.1

### New features

* Privacy mode - mask digits with asterisk (*)
* Choose between symbols or currency codes (e.g., `€` or `EUR`)
* Enable `Prefer full amounts` to see non-abbreviated amounts in flow/balances

### Changes

* Json exports now use **UTC** timezone
* Future transactions now require user confirmation by default. Closes [#120](https://github.com/flow-mn/flow/issues/120)
* Now it's possible to paste transaction amount in the numpad. Closes [#157](https://github.com/flow-mn/flow/issues/157)
* Map preview is no longer interactable in transaction detail page
* Map preview has been moved below the transaction date

### Small improvemets, fixes

* Fixed iOS launcher icons having 1 pixel gap (Figma export issue *sigh*)
* Now income/expense text on home screen no longer wraps to the next line
* Texts that automatically shrink to fit now synchronizes its size with siblings. If that makes sense...
* Stopped re-setting app icon when it's already the current icon
* Home tab income/expense no longer includes transfers **if exclude transfers from flow** is enabled

## Beta 0.8.0

* Fixed account card "this month" summary
* Added new theme selector
* Enhanced searching
* Added icons for each color (iOS exclusive)
* Added total balance in the accounts tab
* Added income/expense report in the home tab
* Swapped icon for income/expense buttons (oof)

## Beta 0.7.2

* Added themes, closes [#105](https://github.com/flow-mn/flow/issues/105)
* Add transaction description, type, and lat/long for CSV exports, closes [#203](https://github.com/flow-mn/flow/issues/203)

## Beta 0.7.1

* Fixed transfer transactions

## Beta 0.7.0

* Added an option to choose location on a map
* Fixed iOS locale

## Beta 0.6.2

* Fixed upcoming transactions config wasn't getting loaded initially, closes
  #187
* Added this week, this month, this year, and all time options for upcoming
  transactions, close #186
* Fixed today's transactions made in future were included in non-future
  transactions
* Now it's possible to add location data to your transactions, disabled by default
* Added automatic location data attachment, disabled by default
* Added a map preview ([osm](https://www.openstreetmap.org/))
* Now it's possible to set transaction extensions' transaction uuid after
  it's initialized
* TODO (@sadespresso) will do an option to choose a location from map even
  if you choose to not give location permissions

## Beta 0.6.1

* Added the gap back in pie chart
* Added `en_IN` locale
* Added optional description field for transactions
* Added little bit breathing space for dialog buttons 🥳

## Beta 0.6.0

* Added exchange rates, currently only works in Stats tab
* Stats tab:
  * Converts all money to the primary currency
  * Now separates income/expense
  * Fallback when there's no exchange rate
* Home tab
  * Search, filter transactions
  * Set planned transaction preferences @ preferences page
* Minor, QoL
  * Added error builder for Image `FlowIcon`s when the image is missing
  * TimeRange selector now listens for mouse wheel scroll
  * Frecency data updates one per day max. (was updating at every launch before)
  * Updated theme to correct `activeColor` for radio/checkboxes and its lists
* Flutter upgraded to 3.24.0
* Dart upgraded to 3.5

## Beta 0.5.5

* Selecting icons should be slightly better
* Now icons (Material Symbols and Simple Icons) are searchable (only in English)
* Improved backup history empty UI
* Fixed number format was messed up when dividing with input sheet calculator
* When making changes, pages will now confirm to close without saving.
(converted form pages -> modals)

## Beta 0.5.3

* Fixed entering decimal amount with leading '0' decimal was impossible.
(e.g., `1.02` was impossible to input)
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

* [FEAT] Customize order of new transaction buttons by @sadespresso in <https://github.com/flow-mn/flow/pull/148>
* Reform account edit page by @sadespresso in <https://github.com/flow-mn/flow/pull/149>
* [FEAT] Customize order of new transaction buttons by @sadespresso in <https://github.com/flow-mn/flow/pull/148>
* Reform account edit page by @sadespresso in <https://github.com/flow-mn/flow/pull/149>

## Beta 0.5.0

* Added calculator by @sadespresso in <https://github.com/flow-mn/flow/pull/147>
* Uses correct control modifier - `Meta` for macOS and iOS, `Control` for others
* Comma separator is now displayed correctly when inputting amount
* Minor UX tweaks

## Beta 0.4.3

* Fix Category page re renders upon change in db by @sadespresso in <https://github.com/flow-mn/flow/pull/140>
* Fix `CustomRange.end` goes 'til the end of the day by @sadespresso in <https://github.com/flow-mn/flow/pull/141>
* Fix Time range selector bottom sheet overflows by @sadespresso in <https://github.com/flow-mn/flow/pull/142>
* Fix Category page re renders upon change in db by @sadespresso in <https://github.com/flow-mn/flow/pull/140>
* Fix `CustomRange.end` goes 'til the end of the day by @sadespresso in <https://github.com/flow-mn/flow/pull/141>
* Fix Time range selector bottom sheet overflows by @sadespresso in <https://github.com/flow-mn/flow/pull/142>

## Beta 0.4.2

* Category page reform by @sadespresso in <https://github.com/flow-mn/flow/pull/135>
* feat: memoize account names by @sadespresso in <https://github.com/flow-mn/flow/pull/129>
* Upcoming transaction hitbox by @sadespresso in <https://github.com/flow-mn/flow/pull/132>
* Title suggestion improvement by @sadespresso in <https://github.com/flow-mn/flow/pull/134>
* Category page reform by @sadespresso in <https://github.com/flow-mn/flow/pull/135>
* feat: memoize account names by @sadespresso in <https://github.com/flow-mn/flow/pull/129>
* Upcoming transaction hitbox by @sadespresso in <https://github.com/flow-mn/flow/pull/132>
* Title suggestion improvement by @sadespresso in <https://github.com/flow-mn/flow/pull/134>
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

* Added year/month selector, closes [#85](https://github.com/flow-mn/flow/issues/85)
* No longer uses `AutomiaticKeepAlive` for stats tab, but will change this later. Fixes [#94](https://github.com/flow-mn/flow/issues/94)
* Limited stats tab's pie chart to 300px

## Beta 0.3.3

* Fix transaction date doesn't get updated, closes [#100](https://github.com/flow-mn/flow/issues/100)
* Improve setup by [#103](https://github.com/flow-mn/flow/pull/103)

## Beta 0.3.2

* Fixed transaction page title suggestion was behaving differently from prior
  releases. Improved UX

## Beta 0.3.1

* Transaction page now suggests title based on relevancy (category, account, etc)
* Removed minus (`-`) sign in expense transaction input sheet, closes [#88](https://github.com/flow-mn/flow/issues/88)
* Setup page bottom buttons are now rendered in `SafeArea` ()
* Fixed stats tab custom range selection not updating the state (21940fd775c9c0d05e8c70da7d682b24bfa0199c)
* Added Mongolian localization for the iOS project, closes [#72](https://github.com/flow-mn/flow/issues/72)

## Beta 0.3.0

* Initial beta release

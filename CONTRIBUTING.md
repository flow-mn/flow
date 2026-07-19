# Contributing to flow

Thank you for stopping by! A few notes on how contributing works here:

Flow is free, and will stay that way — I'm continuing to develop it on my own.
I'm not taking feature requests or bug report/opinion submissions right now, so
there's no issue tracker to file into.

* [Contribute code](#developing)
* [Translating Flow](#translating) to your own language
* [Buy maintainer a coffee](https://buymeacoffee.com/sadespresso). Flow is a
free and open-source software, and will stay this way.

## Developing

You're welcome to submit PRs, but I highly recommend reaching out first —
Instagram ([@sadespresso](https://instagram.com/sadespresso)) or email
(<batmend@gege.mn>) — so we can coordinate before you put in the work.

1. Fork the repository
2. Reach out first (see above) so we're aligned on the change
3. Create a feature branch off `develop`, e.g. `username/short-description`
  (the name can be different, doesn't matter)
4. Make changes on the new branch
5. Ensure your code doesn't have any linter warnings, errors
  (Your editor will tell you, or you can run `flutter analyze`)
6. Submit a PR to `develop` branch
7. If your feature involves UI changes, add a short video demonstrating the
  implement change/feature

## Code guides

* Please consider accessibility, localization, and technical factors before
implementing a new feature
* Any new dependency must support the all the platforms except for Web
* It is not necessary to change the version unless you're in charge of
publishing a release
* Update [CHANGELOG.md](./CHANGELOG.md) with your change description. (Use
version name `next`)

## Translating

When translating Flow to your language, the translation coverage must be 100%.
You can follow the same steps in [Developing](#developing), and you can safely
skip the lint check (step 5).

It's highly recommended to copy [en_US.json](./assets/l10n/en.json) or
any other existing translations with full coverage, and work on top of it.

Make sure you add the your language in the list of supported languages. See
[lib/l10n/supported_languages.dart](./lib/l10n/supported_languages.dart).

## License

By contributing, you agree that your contributions will be licensed under
GNU GENERAL PUBLIC LICENSE v3

# Changelog

All notable changes to HoarderMate will be documented here.

## [Unreleased]

### Added
- Slash commands `/hm`  and `/hoardermate`: `config` opens the banker 
  configuration and `help` shows usage. Built on an extensible
  command dispatch table so new commands are easy to add.
- Localisation for English, French, German, Italian, and Spanish (EFIGS),
  via AceLocale-3.0.
- A remove button on each row of the New Items popup, to drop items
  before adding them to a banker's configuration.

### Changed
- Restyled the configuration (cogwheel) button to a standard
  options-icon button.
- The HoarderMate tab now uses the same background as the Send Mail
  frame, regardless of which mail tab was viewed beforehand.

### Fixed
- Sending from the HoarderMate tab now switches to the Send Mail tab
  instead of leaving the Inbox tab selected.
- Right-clicking items in your bags now attaches them to the open mail.
- Sending now attaches all stacks of an item, instead of only one stack
  per bag.

## [0.0.1] - 2026-06-11

### Added
- Initial release
- Mailbox tab with send list showing items per configured banker
- Banker configuration window with item search, ctrl-click and drag
  support
- Item preview with icon and rarity colour
- New Items popup when mailing a banker with unconfigured items

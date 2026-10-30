# Changelog

## 0.1.13 - 2026-10-30

Admin Features CRUD is split across authorization, write, and query modules. YAML and `config.x` loading rescue Psych, file-not-found, and Rails `config_for` missing-file errors only. The admin catalogue query uses Trashable kept SQL. Hosts read the current root through RootSwitchable (or a public `current_root_recording`). Configuration can be reset with `reset_configuration!`. Template names in copilot instructions, the Rails architect agent, and Cursor environment identity now say Features.

### Upgrade notes

1. Invalid `config/recording_studio_features.yml` that is not a Psych parse error, missing file, or `Errno` now raises while the engine loads instead of being ignored.
2. `RecordingStudioFeatures.reset_configuration!` replaces the shared configuration object. Tests that swapped `@configuration` should call that (or `configuration=`) instead.

## 0.1.12 - 2026-10-21

CI asks setup-ruby for Ruby `3.3`, the latest 3.3 patch published for the runner. The `3.3.6` pin in `.ruby-version` is not built for ubuntu-26.04, so lint, Brakeman, Bundler Audit, and Importmap Audit failed while installing Ruby. The test matrix already requested `3.3` and `3.4`. Root and dummy `.ruby-version` stay on `3.3.6` so local installs keep a full patch.

Committed coverage output is removed, along with `MIGRATION_NOTES.md`, `UPDATE_SUMMARY.md`, and `test_codespaces_setup.sh` (#20).

No functional changes.

### Upgrade notes

No upgrade steps. Required Ruby stays `>= 3.3.0`.

## 0.1.11 - 2026-10-16

Dummy and root pins use Recording Studio Trashable `v0.11.0`.

### Upgrade notes

No upgrade steps.

## 0.1.10 - 2026-10-14

Dummy and root pins use Recording Studio Accessible `v0.18.0`.

### Upgrade notes

No upgrade steps.

## 0.1.9 - 2026-10-14

Dummy and root pins use Recording Studio `v4.6.0`.

### Upgrade notes

No upgrade steps.

## 0.1.8 - 2026-10-13

Dummy and root pins use Recording Studio API `v0.7.0`, Accessible `v0.17.0`, Admin `v2.3.0`, and Root Switchable `v0.9.0`.

### Upgrade notes

No upgrade steps.

## 0.1.7 - 2026-10-13

Dummy and root pins use Recording Studio Admin `v2.2.0`.

### Upgrade notes

No upgrade steps.

## 0.1.6 - 2026-10-12

Dummy and root pins use Recording Studio Attachable `v0.15.0`, Accessible `v0.15.0`, Root Switchable `v0.8.0`, and Recording Studio `v4.5.0`.

### Upgrade notes

No upgrade steps.

## 0.1.5 - 2026-10-09

Dummy and root pins use Recording Studio Admin `v2.1.0` and matching i18n releases of Accessible, Attachable, and Root Switchable.

### Upgrade notes

No upgrade steps.

## 0.1.4 - 2026-10-09

Dummy and root pins use Recording Studio `v4.4.0`.

### Upgrade notes

No upgrade steps.

## 0.1.3 - 2026-10-08

Dummy and root pins use Recording Studio Admin `v2.0.7`.

### Upgrade notes

No upgrade steps.

## 0.1.2 - 2026-10-08

Dummy and root pins use Recording Studio `v4.3.0`.

### Upgrade notes

No upgrade steps.

## 0.1.1 - 2026-10-08

Dummy and root pins use Recording Studio Admin `v2.0.6` and FlatPack `v0.1.207`.

### Upgrade notes

No upgrade steps.

## 0.1.0 - 2026-10-06

First release. A descriptive catalogue of product features.

Each feature is an immutable recordable snapshot with a required title, an optional subtitle, and an optional rich-text description. `created_at` is the only timestamp. Features hang under `root_types`, which defaults to `["AdminRoot"]`. One image is an Attachable attachment. The newest direct attachment is the image shown on the feature.

Admin adds a Features section and the `recording_studio_features` screen, plus new, show, edit, and destroy routes on this engine. The edit page shows the image above Update. The public API registers the same snapshot. A host can register those serializer constants again on a named API.

Destroying a feature recording also destroys direct image attachment children, then the feature recording. The snapshot row stays.

### Upgrade notes

This is a new install.

1. `bin/rails generate recording_studio_features:install`
2. `bin/rails generate recording_studio_features:migrations`
3. `bin/rails db:migrate`
4. Add `RecordingStudioFeatures::Feature` and `RecordingStudioAttachable::Attachment` to `recordable_types`, and keep `require_recordable_declarations` on.
5. Set `root_types` to the recordable types that may parent a feature. The default is `["AdminRoot"]`. An empty list is invalid.
6. Mount Attachable, the Recording Studio API, and this engine. Mount admin with `recording_studio_admin_for` and include the `:features` section on the admin root.
7. Register a named API when features are read through an access point that the public API does not expose, and register `Feature` on that API with `RecordingStudioFeatures::Api.register!`.

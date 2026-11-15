# Changelog

## 0.4.0 - 2026-11-15

Requires Recording Studio `>= 7.0`, `< 8.0`. `root_recording_for` only finds a root. Seeds and tests that created one now call `create_root_recording!(recordable, actor:)`. The dummy sets `config.authorize_write` to allow a write when an actor is present, including a new root where `root_recording` is nil. It does not set `allow_unauthorized_writes`.

Gemspec: `recording_studio_api` `>= 0.24.0`, `< 1.0`; `recording_studio_moveable` `>= 5.0`, `< 6.0`; `recording_studio_attachable` `>= 0.28.0`, `< 1.0`; `recording_studio_accessible` `>= 0.44.0`, `< 1.0`; `recording_studio_trashable` `>= 0.17.0`, `< 1.0`; `recording_studio_admin` `>= 2.16.0`. `flat_pack` stays `>= 0.1.341`. Attachable 0.28 requires FlatPack `>= 0.1.376`, so the dummy pin is `v0.1.376`.

Development and dummy pins: Recording Studio `v7.0.0`, API `v0.24.0`, Moveable `v5.0.0`, Attachable `v0.28.0`, Accessible `v0.44.0`, Admin `v2.16.0`, Trashable `v0.17.0`, Metrics `v0.9.0`, Icons `v0.2.1`, FlatPack `v0.1.376`. Logs moves to `v0.8.0` because API 0.24 requires `>= 0.8.0`. Root Switchable moves to `v0.16.0` because `v0.11.5` cannot resolve with core 7. Cache moves to `v0.6.3`. Bundler Audit pins: `puma` `8.1.0`, `msgpack` `>= 1.8.7`.

Feature lists stay on `RecordingStudio::Recording.kept`. The dummy no longer defines `recording_studio_trashable_kept_sql`. API 0.24 calls `Recording.kept` and `RecordingStudio.kept_sql`. Admin uses `access_recording_resolver`. `site_admin_recording_resolver` is gone.

`Recording#destroy!` still prepends a release of image children. Core 7 keeps `child_recordings` as `dependent: :restrict_with_error`, and Trashable 0.17 does not override `destroy!`.

Root Switchable 0.16 refuses the switch page unless the actor can view the current root. The dummy default root is the first listed root that actor can view, then the first root. Seeds grant the demo user owner on each workspace root and the admin root.

The dummy already includes core migration `20261114090000_add_root_recording_id_to_recording_studio_events`. No new Features migration.

### Upgrade notes

1. Install Features `0.4.0` with Recording Studio `>= 7.0`, `< 8.0` (tag `v7.0.0`).
2. Install API `>= 0.24.0`, `< 1.0` (tag `v0.24.0`), Moveable `>= 5.0`, `< 6.0` (tag `v5.0.0`), and Attachable `>= 0.28.0`, `< 1.0` (tag `v0.28.0`).
3. Install Accessible `>= 0.44.0`, `< 1.0` (tag `v0.44.0`), Trashable `>= 0.17.0`, `< 1.0` (tag `v0.17.0`), and Admin `>= 2.16.0` (tag `v2.16.0`).
4. Pin Logs `v0.8.0`, Metrics `v0.9.0`, Icons `v0.2.1`, FlatPack `v0.1.376`, and, when the host uses them, Root Switchable `v0.16.0` and Cache `v0.6.3`.
5. Replace creating `root_recording_for` calls with `create_root_recording!(recordable, actor:)`. Leave lookups on `root_recording_for` and handle `nil`.
6. Set `config.authorize_write` and pass an actor. `create_root_recording!` calls the authorizer with `root_recording` nil. Do not set `allow_unauthorized_writes`.
7. Copy `20261114090000_add_root_recording_id_to_recording_studio_events` when `recording_studio_events` has no `root_recording_id`.
8. Delete a host `recording_studio_trashable_kept_sql` bridge. Call `RecordingStudio::Recording.kept` or `RecordingStudio.kept_sql`.
9. Point Admin at `access_recording_resolver`. Delete `site_admin_recording_resolver`.
10. Pin `puma` `8.1.0` and `msgpack` `>= 1.8.7` so Bundler Audit stays clean.
11. On Root Switchable 0.16, grant Accessible `:view` on the current root before opening the switch page. The dummy default root is the first listed root the actor can view.

## 0.3.1 - 2026-11-14

Feature lists use `RecordingStudio::Recording.kept`. The catalogue no longer checks for a `trashed_at` column or calls Trashable kept SQL. Requires `recording_studio` `>= 6.14.0`, `recording_studio_accessible` `~> 0.11`, `>= 0.42.0`, and `recording_studio_trashable` `~> 0.10`, `>= 0.16.0`. API moves to `~> 0.23.0` because Accessible 0.42 registers capability actions with `openapi_for`. That API line requires Moveable `~> 4.0`. Development and dummy pins: Recording Studio `v6.14.0`, Accessible `v0.42.0`, Trashable `v0.16.0`, API `v0.23.0`, Moveable `v4.1.1`, Icons `v0.2.1`.

### Upgrade notes

1. Install Recording Studio `>= 6.14.0` (dummy tag `v6.14.0`).
2. Install Accessible `>= 0.42.0` (dummy tag `v0.42.0`) and Trashable `>= 0.16.0` (dummy tag `v0.16.0`). No new Features migration.
3. Install API `~> 0.23.0` (dummy tag `v0.23.0`), Moveable `~> 4.0` (dummy tag `v4.1.1`), and Icons `v0.2.1`. API `0.17` cannot boot with Accessible 0.42.
4. Run Recording Studio's events `root_recording_id` migration if it is not already applied. Copy `20261114090000_add_root_recording_id_to_recording_studio_events`.
5. Set `config.authorize_write`, or `allow_unauthorized_writes`, the way Recording Studio 6.5 and later require for writes. The dummy sets `allow_unauthorized_writes` so docs pages can record without an actor.
6. A kept list excludes trashed rows when an addon registers a recording filter. Trashable 0.16 registers that filter. This gem does not call `recording_studio_trashable_kept_sql`, `recording_studio_trashable_active`, `recording_studio_trashable_including_trashed`, or `recording_studio_trashable_trashed_sql`. API 0.23 still calls `recording_studio_trashable_kept_sql`. The dummy defines that method as `RecordingStudio.kept_sql` until API stops.

## 0.3.0 - 2026-11-05

Requires Recording Studio `>= 6.3.0`. Dummy and development pins: core `v6.3.0`, Accessible `v0.24.1`, Admin `v2.9.1`, API `v0.17.1`, Attachable `v0.22.1`, Trashable `v0.12.2`, Metrics `v0.7.2`, Logs `v0.7.3`, Root Switchable `v0.11.5`, Cache `v0.6.2`, and FlatPack `v0.1.341`. API stays on `~> 0.17.0` so Bundler cannot pick `0.18`, which needs Moveable. `flat_pack` is `>= 0.1.341`. Rails lockfiles move to `8.1.4.1`. Sanitizer and Rack floors in both lockfiles: `rack` `>= 3.2.8`, `loofah` `>= 2.25.3`, `nokogiri` `>= 1.19.5`, `rails-html-sanitizer` `>= 1.7.2`, latest `crass`, dummy `net-ssh` `>= 7.3.5`. `view_component` stays a FlatPack transitive (`>= 4.14`).

Engine controllers call `recording_studio_layout { RecordingStudioFeatures.configuration.layout }`. `layout` defaults to `nil` and is validated by `RecordingStudio::Layout.accept`. `nil` follows `RecordingStudio.configuration.layout`, then `recording_studio/default_layout`. Hard-coded `layout "recording_studio/default_layout"`, `UsesDefaultLayout`, isolated-engine view-path shims, and the stylesheet inject are gone.

Show, new, and edit set `content_for :title` / `:subtitle` and `flat_pack_page_nav`. Edit, Remove image, Update, and Save sit in FlatPack `ButtonGroup` with `collapse: :menu` and `collapse_at: 390`. The dummy login card drops the removed Card `style:` argument.

### Upgrade notes

1. Install Features `0.3.0` with Recording Studio `>= 6.3.0` (dummy tag `v6.3.0`) and FlatPack `v0.1.341`. Stay on `0.2.2` if you are still on Recording Studio 4.
2. Leave `config.layout` unset (`nil`) to follow the host Recording Studio layout, then core Default Layout. Set a layout name, `false`, or `->(controller:) { ... }`.
3. Replace `include RecordingStudio::UsesDefaultLayout` and `layout "recording_studio/default_layout"` with `recording_studio_layout { RecordingStudioFeatures.configuration.layout }`.
4. Pin API `~> 0.17.0` (dummy tag `v0.17.1`). Do not take API `0.18` unless the host already has Moveable.
5. Match companion GitHub tags if you pin them: Accessible `v0.24.1`, Admin `v2.9.1`, Attachable `v0.22.1`, Trashable `v0.12.2`, Metrics `v0.7.2`, Logs `v0.7.3`.
6. Rebuild Tailwind after bumping. Feature show, new, and edit headings now come from the default layout.

## 0.2.2 - 2026-11-02

Admin show and edit label the image block with FlatPack `SectionTitle` (`size: :sm`, `spacing: :none`, `level: :h3`) instead of a raw paragraph. This gem now requires `flat_pack` `>= 0.1.210` for those `SectionTitle` arguments. The dummy lock stays on FlatPack `v0.1.213`.

### Upgrade notes

1. Hosts must run FlatPack `>= 0.1.210`.
2. The Image heading on admin show and edit is an `h3` (`text-base font-semibold`) instead of `p.text-sm.font-medium`.

## 0.2.1 - 2026-10-30

The dummy app no longer ships `test/dummy/install_page.html`, a captured template leftover.

### Upgrade notes

No upgrade steps.

## 0.2.0 - 2026-10-30

Admin Features CRUD is split across authorization, write, and query modules. YAML and `config.x` loading rescue Psych, file-not-found, and Rails `config_for` missing-file errors only. The admin catalogue query uses Trashable kept SQL. This gem now depends on `recording_studio_trashable` `~> 0.10` because that query is required at boot. Admin stays `~> 2.0`. Hosts read the current root from the controller's `current_root_recording`, then `RecordingStudio::RootSwitchable`. Configuration can be reset with `reset_configuration!`. Template names in copilot instructions, the Rails architect agent, and Cursor environment identity now say Features.

The dummy attach-replace test records a second feature and imports that file through Attachable so `replace_attachment_file` can use a signed blob without `ActiveStorage::Blob.create_and_upload!`.

### Upgrade notes

1. Invalid `config/recording_studio_features.yml` that is not a Psych parse error, missing file, or `Errno` now raises while the engine loads instead of being ignored.
2. `RecordingStudioFeatures.reset_configuration!` replaces the shared configuration object. Tests that swapped `@configuration` should call that (or `configuration=`) instead.
3. Install `recording_studio_trashable` `~> 0.10`. Admin `2.0`–`2.2` does not pull it; without it the engine raises `LoadError` at boot.

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

Dummy and root pins use Recording Studio API `v0.7.0`, Accessible `v0.17.0`, Admin `v2.3.0`, Root Switchable `v0.9.0`, Trashable `v0.10.0`, and Metrics `v0.2.3`.

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

Dummy and root pins use Recording Studio Admin `v2.1.0`, FlatPack `v0.1.213`, and matching i18n releases of Accessible, Attachable, and Root Switchable.

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

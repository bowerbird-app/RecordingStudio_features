# Changelog

## 0.1.0 - 2026-10-06

First release. A descriptive catalogue of product features.

Each feature is an immutable recordable snapshot with a required title, an optional subtitle, and an optional rich-text description. `created_at` is the only timestamp. Features hang under `root_types`, which defaults to `["AdminRoot"]`. One image is an Attachable attachment. The newest direct attachment is the image shown on the feature.

Admin adds a Features section and the `recording_studio_features` screen, plus new, show, edit, and destroy routes on this engine. The public API registers the same snapshot. A host can register those serializer constants again on a named API.

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

# Recording Studio Features

A catalogue of product features. Each feature is a title, an optional subtitle, an optional description, and one image. Features hang directly under a configured root. The default root type is `AdminRoot`.

This catalogue is descriptive. It is not flags, plans, entitlements, tags, order, or a publish workflow.

## Fields

- Title, required
- Subtitle, optional
- Description, optional. The form uses `FlatPack::TextArea` with `rich_text: true`. Display sanitizes with `FlatPack::RichTextSanitizer` when that class is defined. This is not Action Text.
- Image, one Attachable image (`image/*`, kind `:image`, `max_file_count: 1`). The newest direct attachment is the image. Show and edit call `render_attachment_file_button(feature_recording, return_to:, target: nil)` and a separate button that DELETEs `destroy_attachment_path`. The image is added after the feature exists, because Attachable stores it on the feature entry. On edit, the image sits above Update. Update submits the title, subtitle, and description. The image controls stay their own requests. Preview uses `attachment_preview_url`. `attachable_mount_path` defaults to `/recording_studio_attachable` and is the prefix on `image_url`.

A feature row is an immutable snapshot with `created_at` only. Create with `parent.record(Feature, actor:)`. Revise with `recording.root_recording.revise(recording, actor:)`. Do not call `update` or `destroy` on a saved feature row. Deleting the recording removes the catalogue entry and leaves the snapshot row.

`root_types` defaults to `["AdminRoot"]`. Assigning it re-declares the allowed parents. An empty list is invalid.

## Admin

```ruby
recording_studio_admin_for :admin, at: "/admin", root_section: :features
```

The list is the Features screen at `/admin/screens/recording_studio_features`. Columns are Title, Subtitle, and Updated. Actions are show, edit, and destroy.

Mount this engine at `/recording_studio_features`. Engine routes:

- `GET /recording_studio_features/admin/features/new`
- `POST /recording_studio_features/admin/features`
- `GET /recording_studio_features/admin/features/:id`
- `GET /recording_studio_features/admin/features/:id/edit`
- `PATCH /recording_studio_features/admin/features/:id`
- `DELETE /recording_studio_features/admin/features/:id`

There is no index action. The screen is the list.

## API

`RecordingStudioFeatures::Api.register!(api: :public)` runs from the engine `after_initialize` when `RecordingStudioApi` is defined. The same serializer constants can be registered again, including on a named API.

The dummy defines a named API `catalogue`. Feature routes:

`/recording_studio_api/apis/catalogue/v1/features`

The payload includes `title`, `subtitle`, `description`, and `image_url`. `image_url` is the Attachable preview path, or null when the feature has no image. Writable fields are `title`, `subtitle`, and `description`. Create sends flat JSON with `parent_id` and the writable fields. There is no attributes envelope. Update revises the snapshot. Destroy removes the feature even when an image child exists.

A view token can index and show. An edit token can create, update, and destroy. A missing token is unauthorized.

## Host example

Mount the catalogue under the admin root. `AdminRoot` includes the Features section. Create features with `admin_root_recording.record(RecordingStudioFeatures::Feature, actor:)`.

```ruby
# config/initializers/recording_studio.rb
config.recordable_types = [
  "AdminRoot",
  "RecordingStudioFeatures::Feature",
  "RecordingStudioAttachable::Attachment"
]

# config/initializers/recording_studio_features.rb
RecordingStudioFeatures.configure do |config|
  config.root_types = ["AdminRoot"]
end

# app/models/admin_root.rb
class AdminRoot < ApplicationRecord
  include RecordingStudioAdmin::AllowsAdminSections

  recording_studio_recordable label: "Admin", root: true

  recording_studio_admin_sections do
    section :features
  end
end

# config/routes.rb
mount RecordingStudioAttachable::Engine, at: "/recording_studio_attachable"
mount RecordingStudioApi::Engine, at: "/recording_studio_api"
mount RecordingStudioFeatures::Engine, at: "/recording_studio_features"
recording_studio_admin_for :admin, at: "/admin", root_section: :features
```

`AdminRoot` is not a public API access point. Register it on a named API, then register features on that same API.

```ruby
RecordingStudioApi.configure do |config|
  config.api :catalogue do |api|
    api.default_access = :read_only
  end
end

RecordingStudioApi.register_recordable_type_api(
  "AdminRoot",
  api: :catalogue,
  operations: %i[index show]
)

RecordingStudioFeatures::Api.register!(api: :catalogue)
```

Agents then call `/recording_studio_api/apis/catalogue/v1/features`.

## Install

`bin/rails generate recording_studio_features:install` mounts the engine and adds an initializer. `bin/rails generate recording_studio_features:migrations` copies the feature table. The generator does not write a YAML settings file.

A new host also needs:

- `RecordingStudioFeatures::Feature` and `RecordingStudioAttachable::Attachment` in `recordable_types`
- `config.root_types` set to the recordable types that may parent a feature
- mounts for Attachable, the API, this engine, and `recording_studio_admin_for`
- an admin root whose sections include `:features`
- a named API when the access point is not on the public API, such as `AdminRoot`

## Dummy pins

- recording_studio dummy GitHub tag `v4.2.2`
- recording_studio_accessible dummy GitHub tag `v0.11.2`
- recording_studio_admin dummy GitHub tag `v2.0.5`
- recording_studio_attachable dummy GitHub tag `v0.7.3`
- recording_studio_api dummy GitHub tag `v0.6.2`
- recording_studio_root_switchable dummy GitHub tag `v0.5.1`
- flat_pack dummy GitHub tag `v0.1.196`

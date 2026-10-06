RecordingStudioFeatures install complete.

Next steps:

1. Review config/initializers/recording_studio_features.rb and set `root_types` to the recordable types that may parent a feature. The default is `["AdminRoot"]`. An empty list is invalid.
2. Install the engine migrations with `bin/rails generate recording_studio_features:migrations`.
3. Apply the migrations with `bin/rails db:migrate`.
4. Add `RecordingStudioFeatures::Feature` and `RecordingStudioAttachable::Attachment` to `recordable_types`.
5. Mount Attachable, the Recording Studio API, and this engine. Mount admin with `recording_studio_admin_for` and include the `:features` section on the admin root.
6. Register a named API when the access point is not on the public API, then call `RecordingStudioFeatures::Api.register!(api: :your_api)` with the same serializer constants.
7. Run `bin/rails tailwindcss:build` if you use Tailwind CSS.
8. Mount routes are added at the configured mount path. Adjust auth, layout, and current actor integration to match your host app.
9. Keep strict recordable declarations enabled and add `recording_studio_recordable(...)` to every configured recordable before running `RecordingStudio.validate_recordable_declarations!`.

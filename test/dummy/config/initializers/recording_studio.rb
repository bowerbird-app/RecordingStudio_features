# frozen_string_literal: true

RecordingStudio.configure do |config|
  config.recordable_types = [
    "Workspace",
    "Folder",
    "Page",
    "AdminRoot",
    "RecordingStudioFeatures::Feature",
    "RecordingStudioAttachable::Attachment"
  ]

  config.require_recordable_declarations = true

  config.app_name = "Features" if config.respond_to?(:app_name=)

  config.actor = -> { Current.actor }
  # Recording Studio 7 denies record! and create_root_recording! unless an
  # authorizer is set. A present actor may write, including a new root where
  # root_recording is nil.
  config.authorize_write = ->(actor:, **) { actor.present? }

  config.event_notifications_enabled = true

  config.idempotency_mode = :return_existing

  config.recordable_dup_strategy = :dup
end

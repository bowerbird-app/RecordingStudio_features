# frozen_string_literal: true

require "recording_studio_api"

module RecordingStudioFeatures
  module Api
    SERIALIZER = lambda { |recordable, **|
      {
        title: recordable.title,
        subtitle: recordable.subtitle,
        description: recordable.description
      }
    }.freeze

    IMAGE_URL = lambda { |context|
      attachment = RecordingStudioAttachable::AttachmentFileButton.attachment_recording_for(context.recording)
      if attachment.blank?
        nil
      else
        RecordingStudioAttachable::Engine.routes.url_helpers.attachment_preview_file_path(
          attachment,
          variant_name: :square_med,
          script_name: RecordingStudioFeatures.configuration.attachable_mount_path
        )
      end
    }.freeze

    WRITABLE_ATTRIBUTES = %i[title subtitle description].freeze
    OPERATIONS = %i[index show create update destroy].freeze
    OUTPUT_KEYS = %i[title subtitle description].freeze
    FIELDS = { image_url: { resolver: IMAGE_URL, include: true } }.freeze

    def self.register!(api: :public)
      RecordingStudioApi.register_recordable_type_api(
        "RecordingStudioFeatures::Feature",
        api: api,
        serializer: SERIALIZER,
        output_keys: OUTPUT_KEYS,
        fields: FIELDS,
        writable_attributes: WRITABLE_ATTRIBUTES,
        operations: OPERATIONS
      )
    end
  end
end

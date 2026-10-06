# frozen_string_literal: true

module RecordingStudioFeatures
  module ApplicationHelper
    include RecordingStudioAttachable::ApplicationHelper

    def feature_description(text)
      html = text.to_s
      return if html.blank?

      sanitized = if defined?(FlatPack::RichTextSanitizer)
                    FlatPack::RichTextSanitizer.sanitize(html)
                  else
                    sanitize(html)
                  end
      sanitized.html_safe
    end

    # The mount proxy is defined on the Attachable engine, not on the host
    # route set. Rebuild it so button paths include the host mount prefix.
    def recording_studio_attachable
      routes = RecordingStudioAttachable::Engine.routes
      script_name = main_app.recording_studio_attachable_path
      ActionDispatch::Routing::RoutesProxy.new(routes, self, routes.url_helpers, ->(*) { script_name })
    end

    def destroy_attachment_path(...)
      recording_studio_attachable.destroy_attachment_path(...)
    end
  end
end

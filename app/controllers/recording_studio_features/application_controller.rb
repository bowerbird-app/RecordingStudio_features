# frozen_string_literal: true

module RecordingStudioFeatures
  class ApplicationController < (defined?(::ApplicationController) ? ::ApplicationController : ActionController::Base)
    helper RecordingStudioFeatures::ApplicationHelper

    recording_studio_layout { RecordingStudioFeatures.configuration.layout }

    protect_from_forgery with: :exception
  end
end

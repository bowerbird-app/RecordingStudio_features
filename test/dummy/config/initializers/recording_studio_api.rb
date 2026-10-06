# frozen_string_literal: true

RecordingStudioApi.configure do |config|
  if Rails.env.test?
    config.rate_limit_oauth_enabled = false
    config.rate_limit_api_enabled = false
    config.rate_limit_api_pre_auth_enabled = false
  end

  config.api :catalogue do |api|
    api.default_access = :read_only
    api.api_management_authorization_required = false
    if Rails.env.test?
      api.rate_limit_oauth_enabled = false
      api.rate_limit_api_enabled = false
      api.rate_limit_api_pre_auth_enabled = false
    end
  end
end

RecordingStudioApi.register_recordable_type_api(
  "AdminRoot",
  api: :catalogue,
  operations: %i[index show],
  serializer: ->(recordable, **) { { name: recordable.name } },
  output_keys: %i[name]
)

RecordingStudioFeatures::Api.register!(api: :catalogue)

# frozen_string_literal: true

require "test_helper"
require "devise/test/integration_helpers"

class FeaturesCatalogueTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.find_or_create_by!(email: "features-catalogue@example.com") do |user|
      user.password = "Password"
      user.password_confirmation = "Password"
    end
    Current.actor = @user
    @admin_root = AdminRoot.create!(name: "Features Admin #{SecureRandom.hex(4)}")
    @admin_root_recording = RecordingStudio.root_recording_for(@admin_root)
    result = RecordingStudioAccessible.bootstrap_owner_access!(recording: @admin_root_recording, actor: @user)
    raise result.error if result.failure?
  end

  teardown do
    Current.actor = nil
  end

  test "create a feature under AdminRoot" do
    recording = record_feature(title: "Search")

    assert_equal "RecordingStudioFeatures::Feature", recording.recordable_type
    assert_equal @admin_root_recording, recording.parent_recording
    assert_equal "Search", recording.recordable.title
  end

  test "title is required" do
    error = assert_raises(ActiveRecord::RecordInvalid) do
      record_feature(title: "")
    end

    assert_includes error.record.errors[:title], "can't be blank"
  end

  test "subtitle and description are optional" do
    recording = record_feature(title: "Bare", subtitle: "", description: "  ")

    assert_nil recording.recordable.subtitle
    assert_nil recording.recordable.description
  end

  test "a feature cannot be recorded under Workspace" do
    workspace = Workspace.create!(name: "Not a feature root #{SecureRandom.hex(4)}")
    workspace_recording = RecordingStudio.root_recording_for(workspace)

    assert_equal ["AdminRoot"], RecordingStudioFeatures.configuration.root_types
    assert_raises(RecordingStudio::InvalidParent) do
      workspace_recording.record(RecordingStudioFeatures::Feature, actor: @user) do |feature|
        feature.title = "Workspace feature"
      end
    end
  end

  test "revise changes subtitle and keeps the same recording id" do
    recording = record_feature(title: "Search", subtitle: "Before")
    recording_id = recording.id

    revised = recording.root_recording.revise(recording, actor: @user) do |feature|
      feature.subtitle = "After"
    end

    assert_equal recording_id, revised.id
    assert_equal "After", revised.reload.recordable.subtitle
    assert_equal "Search", revised.recordable.title
  end

  test "attach replace and remove an image" do
    recording = record_feature(title: "With image")
    attachment = recording.import_attachment(
      io: File.open(png_path),
      filename: "feature.png",
      content_type: "image/png",
      actor: @user,
      identify: false
    )

    assert_equal "RecordingStudioAttachable::Attachment", attachment.recordable_type
    assert_equal recording, attachment.parent_recording
    assert_equal attachment, RecordingStudioAttachable::AttachmentFileButton.attachment_recording_for(recording)

    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(png_path),
      filename: "replacement.png",
      content_type: "image/png"
    )
    replaced = attachment.replace_attachment_file(signed_blob_id: blob.signed_id, actor: @user)

    assert_equal attachment.id, replaced.id
    assert_equal "replacement.png", replaced.reload.recordable.file.filename.to_s

    replaced.remove_attachment(actor: @user)

    assert_nil RecordingStudioAttachable::AttachmentFileButton.attachment_recording_for(recording.reload)
  end

  test "destroy removes the feature recording when an image child exists and leaves the snapshot" do
    recording = record_feature(title: "Removable")
    snapshot_id = recording.recordable.id
    attachment = recording.import_attachment(
      io: File.open(png_path),
      filename: "feature.png",
      content_type: "image/png",
      actor: @user,
      identify: false
    )

    recording.destroy!

    refute RecordingStudio::Recording.exists?(recording.id)
    refute RecordingStudio::Recording.exists?(attachment.id)
    assert RecordingStudioFeatures::Feature.exists?(snapshot_id)
  end

  test "admin screen lists the feature" do
    record_feature(title: "Listed feature", subtitle: "On the screen")
    sign_in_and_switch_root

    get "/admin/screens/recording_studio_features"

    assert_response :success
    assert_includes response.body, "Updated"

    get "/admin/screens/recording_studio_features/table"

    assert_response :success
    assert_includes response.body, "Listed feature"
    assert_includes response.body, "On the screen"
  end

  test "admin create update and destroy" do
    sign_in_and_switch_root

    get "/recording_studio_features/admin/features/new"
    assert_response :success
    assert_includes response.body, "Title"
    assert_includes response.body, "Subtitle"
    assert_includes response.body, "Description"

    post "/recording_studio_features/admin/features", params: {
      feature: { title: "Created feature", subtitle: "First subtitle", description: "A description" }
    }
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_includes response.body, "Created feature"
    assert_includes response.body, "First subtitle"

    recording = RecordingStudio::Recording.where(recordable_type: "RecordingStudioFeatures::Feature").order(:created_at).last
    get "/recording_studio_features/admin/features/#{recording.id}/edit"
    assert_response :success
    assert_includes response.body, "Image"

    patch "/recording_studio_features/admin/features/#{recording.id}", params: {
      feature: { title: "Created feature", subtitle: "Revised subtitle", description: "A description" }
    }
    assert_response :redirect
    follow_redirect!
    assert_includes response.body, "Revised subtitle"
    assert_equal recording.id, recording.reload.id

    delete "/recording_studio_features/admin/features/#{recording.id}"
    assert_response :redirect
    refute RecordingStudio::Recording.exists?(recording.id)
  end

  test "a viewer cannot create or update a feature" do
    viewer = User.create!(
      email: "features-viewer-#{SecureRandom.hex(4)}@example.com",
      password: "Password",
      password_confirmation: "Password"
    )
    granted = RecordingStudioAccessible.grant_access(
      recording: @admin_root_recording,
      actor: viewer,
      role: :view,
      manager_actor: @user
    )
    raise granted.error if granted.respond_to?(:failure?) && granted.failure?

    sign_in viewer
    patch "/recording_studio_root_switchable/v1/root_switch", params: {
      scope: "all_workspaces",
      root_switch: {
        root_recording_id: @admin_root_recording.id,
        return_to: "/"
      }
    }
    assert_response :redirect

    get "/recording_studio_features/admin/features/new"
    assert_response :forbidden

    post "/recording_studio_features/admin/features", params: {
      feature: { title: "Viewer feature" }
    }
    assert_response :forbidden
    assert_nil RecordingStudioFeatures::Feature.find_by(title: "Viewer feature")
  end

  test "admin destroy removes a feature that has an image" do
    recording = record_feature(title: "Admin image")
    recording.import_attachment(
      io: File.open(png_path),
      filename: "feature.png",
      content_type: "image/png",
      actor: @user,
      identify: false
    )
    sign_in_and_switch_root

    delete "/recording_studio_features/admin/features/#{recording.id}"

    assert_response :redirect
    refute RecordingStudio::Recording.exists?(recording.id)
  end

  test "catalogue api lists shows creates updates and destroys features" do
    plain = record_feature(title: "Plain feature", subtitle: "No image")
    pictured = record_feature(title: "Pictured feature")
    pictured.import_attachment(
      io: File.open(png_path),
      filename: "feature.png",
      content_type: "image/png",
      actor: @user,
      identify: false
    )
    view_token = catalogue_token(:view)
    edit_token = catalogue_token(:edit)
    path = "/recording_studio_api/apis/catalogue/v1/features"

    get path
    assert_response :unauthorized

    get path, headers: bearer(view_token)
    assert_response :success
    listed = JSON.parse(response.body)
    titles = listed.fetch("records").map { |record| record.fetch("title") }
    assert_includes titles, "Plain feature"
    assert_includes titles, "Pictured feature"

    get "#{path}/#{plain.id}", headers: bearer(view_token)
    assert_response :success
    plain_body = JSON.parse(response.body)
    assert_equal "Plain feature", plain_body.fetch("title")
    assert_equal "No image", plain_body.fetch("subtitle")
    assert_nil plain_body.fetch("image_url")

    get "#{path}/#{pictured.id}", headers: bearer(view_token)
    assert_response :success
    pictured_body = JSON.parse(response.body)
    assert_includes pictured_body.fetch("image_url"), "/recording_studio_attachable/attachments/"
    assert_includes pictured_body.fetch("image_url"), "/preview/square_med"

    post path, params: { parent_id: @admin_root_recording.id, title: "From the view token" }.to_json,
               headers: bearer(view_token)
    assert_response :forbidden

    post path, params: { parent_id: @admin_root_recording.id, title: "From the edit token" }.to_json,
               headers: bearer(edit_token)
    assert_response :created
    created = JSON.parse(response.body)
    assert_equal "From the edit token", created.fetch("title")
    assert_nil created.fetch("image_url")

    patch "#{path}/#{created.fetch("id")}", params: { subtitle: "Edited" }.to_json, headers: bearer(edit_token)
    assert_response :success
    updated = JSON.parse(response.body)
    assert_equal created.fetch("id"), updated.fetch("id")
    assert_equal "Edited", updated.fetch("subtitle")

    delete "#{path}/#{pictured.id}", headers: bearer(edit_token)
    assert_response :success
    refute RecordingStudio::Recording.exists?(pictured.id)
  end

  private

  def record_feature(title:, subtitle: nil, description: nil)
    @admin_root_recording.record(RecordingStudioFeatures::Feature, actor: @user) do |feature|
      feature.assign_attributes(title: title, subtitle: subtitle, description: description)
    end
  end

  def sign_in_and_switch_root
    sign_in @user
    patch "/recording_studio_root_switchable/v1/root_switch", params: {
      scope: "all_workspaces",
      root_switch: {
        root_recording_id: @admin_root_recording.id,
        return_to: "/"
      }
    }
    assert_response :redirect
  end

  def catalogue_token(role)
    provision = RecordingStudioApi::Services::ProvisionApiClient.call(
      api: :catalogue,
      access_point_recording: @admin_root_recording,
      manager_actor: @user,
      role: role,
      name: "Catalogue #{role} #{SecureRandom.hex(4)}"
    )
    raise provision.error unless provision.success?

    issued = RecordingStudioApi::Services::IssueOauthAccessToken.call(
      api: :catalogue,
      grant_type: "client_credentials",
      client_id: provision.value.fetch(:credential).oauth_client_id,
      client_secret: provision.value.fetch(:token)
    )
    raise issued.error unless issued.success?

    issued.value.fetch(:access_token)
  end

  def bearer(token)
    { "Authorization" => "Bearer #{token}", "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }
  end

  def png_path
    Rails.root.join("db/seeds/feature.png")
  end
end

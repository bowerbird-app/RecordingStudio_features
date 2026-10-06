# frozen_string_literal: true

require "test_helper"

class ApiTest < Minitest::Test
  def test_serializer_returns_title_subtitle_and_description
    recordable = Struct.new(:title, :subtitle, :description).new("Search", nil, "Find things")

    assert_equal(
      { title: "Search", subtitle: nil, description: "Find things" },
      RecordingStudioFeatures::Api::SERIALIZER.call(recordable)
    )
  end

  def test_image_url_is_nil_without_an_attachment
    context = Struct.new(:recording).new(Object.new)

    assert_nil RecordingStudioFeatures::Api::IMAGE_URL.call(context)
  end

  def test_the_same_constants_can_be_registered_twice
    RecordingStudioFeatures::Api.register!(api: :public)
    RecordingStudioFeatures::Api.register!(api: :public)

    registration = RecordingStudioApi.recordable_registration_for("RecordingStudioFeatures::Feature")

    assert_equal %w[description subtitle title], registration.writable_attributes
    assert_equal %i[create destroy index show update], registration.operations.sort
    assert_equal RecordingStudioFeatures::Api::SERIALIZER, registration.serializer
    assert_equal RecordingStudioFeatures::Api::IMAGE_URL, registration.fields.fetch("image_url").resolver
  end
end

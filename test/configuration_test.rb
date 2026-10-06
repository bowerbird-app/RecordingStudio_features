# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    @configuration = RecordingStudioFeatures::Configuration.new
  end

  def test_default_root_types
    assert_equal ["AdminRoot"], @configuration.root_types
    assert_equal "/recording_studio_features", @configuration.mount_path
    assert_equal "/recording_studio_attachable", @configuration.attachable_mount_path
    assert_instance_of RecordingStudio::Hooks, @configuration.hooks
  end

  def test_merge_updates_known_attributes
    @configuration.merge!(root_types: ["Workspace"], mount_path: "/features")

    assert_equal ["Workspace"], @configuration.root_types
    assert_equal "/features", @configuration.mount_path
  end

  def test_merge_ignores_unknown_keys
    @configuration.merge!(unknown_key: "ignored", mount_path: "/catalogue")

    refute_respond_to @configuration, :unknown_key
    assert_equal "/catalogue", @configuration.mount_path
  end

  def test_merge_with_non_enumerable_is_noop
    original = @configuration.to_h

    @configuration.merge!(nil)

    assert_equal original[:root_types], @configuration.root_types
    assert_equal original[:mount_path], @configuration.mount_path
  end

  def test_empty_root_types_are_rejected
    error = assert_raises(ArgumentError) { @configuration.root_types = [] }
    assert_equal "root_types cannot be empty", error.message

    assert_raises(ArgumentError) { @configuration.root_types = nil }
    assert_equal ["AdminRoot"], @configuration.root_types
  end

  def test_merge_accepts_string_keys
    @configuration.merge!("root_types" => ["Workspace"], "mount_path" => "/catalogue")

    assert_equal ["Workspace"], @configuration.root_types
    assert_equal "/catalogue", @configuration.mount_path
  end

  def test_to_h_reports_registered_hook_counts
    @configuration.hooks.before_initialize { nil }
    @configuration.hooks.before_initialize { nil }
    @configuration.hooks.after_service { nil }

    result = @configuration.to_h

    assert_equal 2, result.fetch(:hooks_registered).fetch(:before_initialize)
    assert_equal 1, result.fetch(:hooks_registered).fetch(:after_service)
  end

  def test_configure_without_block_is_safe
    RecordingStudioFeatures.configure

    assert_kind_of RecordingStudioFeatures::Configuration, RecordingStudioFeatures.configuration
    assert_equal ["AdminRoot"], RecordingStudioFeatures.configuration.root_types
  end
end

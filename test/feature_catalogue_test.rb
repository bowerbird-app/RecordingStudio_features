# frozen_string_literal: true

require "test_helper"

class FeatureCatalogueTest < Minitest::Test
  def setup
    @recording_stub = Class.new
    RecordingStudio.const_set(:Recording, @recording_stub) unless RecordingStudio.const_defined?(:Recording)
  end

  def teardown
    return unless defined?(@recording_stub) && RecordingStudio.const_defined?(:Recording)
    return unless RecordingStudio.const_get(:Recording).equal?(@recording_stub)

    RecordingStudio.send(:remove_const, :Recording)
  end

  def test_blank_root_returns_none
    none = Object.new
    @recording_stub.define_singleton_method(:none) { none }

    assert_equal none, RecordingStudioFeatures::FeatureCatalogue.recordings_for(nil)
  end

  def test_recordings_for_filters_by_type_parent_and_trashable_kept_sql
    root = Struct.new(:id).new(42)
    captured = {}
    relation = Object.new
    relation.define_singleton_method(:where) do |*args|
      captured[:where] = args
      :kept
    end

    @recording_stub.define_singleton_method(:where) do |**kwargs|
      captured[:type_parent] = kwargs
      relation
    end
    @recording_stub.define_singleton_method(:column_names) { %w[id trashed_at] }
    @recording_stub.define_singleton_method(:recording_studio_trashable_kept_sql) { "recordings.trashed_at IS NULL" }

    result = RecordingStudioFeatures::FeatureCatalogue.recordings_for(root)

    assert_equal :kept, result
    assert_equal(
      {
        recordable_type: "RecordingStudioFeatures::Feature",
        parent_recording_id: 42
      },
      captured[:type_parent]
    )
    assert_equal ["recordings.trashed_at IS NULL"], captured[:where]
  end

  def test_keep_untrashed_skips_filter_without_trashed_at_column
    relation = Object.new
    @recording_stub.define_singleton_method(:column_names) { %w[id parent_recording_id] }

    assert_equal relation, RecordingStudioFeatures::FeatureCatalogue.keep_untrashed(relation)
  end
end

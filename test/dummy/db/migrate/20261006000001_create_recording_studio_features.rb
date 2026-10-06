# frozen_string_literal: true

class CreateRecordingStudioFeatures < ActiveRecord::Migration[8.1]
  def change
    create_table :recording_studio_features, id: :uuid do |t|
      t.string :title, null: false
      t.string :subtitle
      t.text :description
      t.datetime :created_at, null: false
    end
  end
end

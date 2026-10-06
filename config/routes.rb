# frozen_string_literal: true

RecordingStudioFeatures::Engine.routes.draw do
  namespace :admin do
    resources :features, only: %i[new create show edit update destroy]
  end
end

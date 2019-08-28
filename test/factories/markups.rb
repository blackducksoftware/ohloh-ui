# frozen_string_literal: true

FactoryBot.define do
  factory :markup do
    raw { 'It was<br/>the best of cross site scripts!' }
  end
end

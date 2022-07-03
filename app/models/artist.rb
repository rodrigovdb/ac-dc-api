# frozen_string_literal: true

class Artist < ApplicationRecord
  has_many :items

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end

class Stay < ApplicationRecord
  belongs_to :city
  has_one :step, dependent: :destroy
end

class Stay < ApplicationRecord
  belongs_to :city
  has_many :steps
end

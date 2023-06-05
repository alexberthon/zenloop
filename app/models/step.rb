class Step < ApplicationRecord
  belongs_to :journey
  belongs_to :line
  belongs_to :stay
end

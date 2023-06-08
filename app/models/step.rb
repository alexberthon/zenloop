class Step < ApplicationRecord
  belongs_to :journey
  belongs_to :line, optional: true
  belongs_to :stay, optional: true
end

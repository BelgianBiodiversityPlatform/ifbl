class Observation < ActiveRecord::Base
  belongs_to :checklist
  belongs_to :species
end

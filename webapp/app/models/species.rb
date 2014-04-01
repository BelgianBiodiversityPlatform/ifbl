class Species < ActiveRecord::Base
  has_many :observations
end

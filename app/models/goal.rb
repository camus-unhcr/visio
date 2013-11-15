class Goal < ActiveRecord::Base
  attr_accessible :name

  self.primary_key  = :id
  has_many :indicator_data

  has_and_belongs_to_many :ppgs
  has_and_belongs_to_many :rights_groups
end
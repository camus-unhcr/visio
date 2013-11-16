class Indicator < ActiveRecord::Base
  attr_accessible :is_gsp, :is_performance, :name

  self.primary_key  = :id
  has_and_belongs_to_many :outputs, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true

  has_many :indicator_data
end

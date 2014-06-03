class Product < ActiveRecord::Base
	include PublicActivity::Model
  tracked
	has_and_belongs_to_many :tags
end

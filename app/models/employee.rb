class Employee < ActiveRecord::Base

# Relationships
# -----------------------------
  has_many :assignments
  has_many :stores, :through => :assignments

end
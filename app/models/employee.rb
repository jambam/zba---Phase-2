class Employee < ActiveRecord::Base

# Relationships
# -----------------------------
  has_many :assignments

end
class Assignment < ActiveRecord::Base

# Relationships
# -----------------------------
  belongs_to :store
  belongs_to :employee

end
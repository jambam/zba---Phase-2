class Store < ActiveRecord::Base

# Relationships
# -----------------------------
  has_one :store
  has_one :employee

end
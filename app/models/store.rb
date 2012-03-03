class Store < ActiveRecord::Base

# create a callback that will strip non-digits of phone before saving to db
  before_save :reformat_phone



# Relationships
# -----------------------------
  has_many :assignments
  has_many :employees, :through => :assignments



#Validations
# -----------------------------
  #ensures there's data for name and street
  validates_presence_of :name, :street

  # phone can have dashes but must be 10 digits
  validates_format_of :phone, :with => /^(\d{10}|\d{3}[-]\d{3}[-]\d{4})$/, :message => "should be 10 digits (area code needed) and delimited with dashes only"	

  # if zip included, it must be 5 digits only
  validates_format_of :zip, :with => /^\d{5}$/, :message => "should be five digits long"

  # if state is given, must be one of the choices given
  validates_inclusion_of :state, :in => %w[PA OH WV], :message => "is not an option", :allow_nil => true, :allow_blank => true

  # store name must be unique in the system
  validates_uniqueness_of :name



  # Scopes
  # -----------------------------
  # list stores in alphabetical order
  scope :alphabetical, order('name')
  # get all the stores that are active
  scope :active, where('active = ?', true)
  # get all the stores that are inactive
  scope :active, where('active = ?', false)



# Callback code
# -----------------------------
  private
  	# Stripping non-digits before saving to db
    def reformat_phone
      phone = self.phone.to_s  # change to string in case input as all numbers 
      phone.gsub!(/[^0-9]/,"") # strip all non-digits
      self.phone = phone       # reset self.phone to new string
    end

end
class Employee < ActiveRecord::Base

# create a callback that will strip non-digits of phone before saving to db
  before_save :reformat_phone_and_ssn


# Relationships
# -----------------------------
  has_many :assignments
  has_many :stores, :through => :assignments

#Validations
# -----------------------------

  # phone can have dashes but must be 10 digits 
  validates_format_of :phone, :with => /^(\d{10}|\d{3}[-]\d{3}[-]\d{4})$/, :message => "should be 10 digits (area code needed) and delimited with dashes only", :allow_blank => true

  # first_name and last_name must only contain letters
  validates_format_of :first_name, :last_name, :with => /^[A-Za-z]+$/, :message => "should only contain letters"

  # all ssn values are nine digits with optional dashes or spaces between the 3rd-4th digits and the 5th-6th digits
  validates_format_of :ssn, :with =>  /^\d{3}[- ]?\d{2}[- ]?\d{4}$/, :message => "should be 9 digits long (with optional dashes or spaces for delimitation)"

  # all employees are at least 18 years old
  validates_date :date_of_birth, :on_or_before => 14.years.ago.to_date, :message => "must be at least 14 years old", :allow_nil => false

  # employee's role must be admin, manager, or employee
  validates_inclusion_of :role, :in => %w[admin manager employee], :message => "must be admin, manager, or employee"

# Scopes
# -----------------------------
  # list employees in alphabetical order
  scope :alphabetical, order('last_name, first_name')  
  
  # get all the employees that are active
  scope :active, where('active = ?', true)
  
  # get all the employees that are inactive
  scope :inactive, where('active = ?', false)
  
  # returns all employees under 18 years old
  scope :younger_than_18, where("date_of_birth > ?", 18.years.ago.to_date)
  
  # returns all employees over 18 years old
  scope :older_than_18, where("date_of_birth < ?", 18.years.ago.to_date)
  
  # returns all employees who have the role "employee"
  scope :regulars, where("role = ?", "employee")
  
  # returns all employees who have the role "manager"
  scope :managers, where("role = ?", "manager")
  
  # returns all employees who have the role "admin"
  scope :admins, where("role = ?", "admin")


# a method to get employee name in last, first format
def name
  last_name + ", " + first_name
end

# a method which returns the employee's current assignment or nil if the employee does not have a current assignment
def current_assignment
  self.assignments.where(:end_date => nil).first 
end

# a method which returns true if this employee is over 18 and false otherwise
def over_18?
  date_of_birth <= 18.years.ago.to_date
end

# a method which returns the employee's current age
def age
  age = ((Date.today - date_of_birth).to_i)/365 
end


# Callback code
# -----------------------------
  private
  	# Stripping non-digits before saving to db
    def reformat_phone_and_ssn
      phone = self.phone.to_s  # change to string in case input as all numbers 
      phone.gsub!(/[^0-9]/,"") # strip all non-digits
      self.phone = phone       # reset self.phone to new string

      ssn = self.ssn.to_s  # change to string in case input as all numbers 
      ssn.gsub!(/[^0-9]/,"") # strip all non-digits
      self.ssn = ssn       # reset self.phone to new string
    end

end
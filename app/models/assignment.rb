class Assignment < ActiveRecord::Base

# create a callback that will update and terminate any previous assignments
  # before_create :end_previous_assignment

# Relationships
# -----------------------------
  belongs_to :store
  belongs_to :employee

# Validations
# -----------------------------
  #ensures there's data for store_id and employee_id
  validates_presence_of :store_id, :employee_id  

  # # start_date can't be in the future nor can it be after end_date
  # validates_date :start_date, :on_or_before => lambda {|a| Date.current}, :on_or_before => :end_date #, :message => "hello there mate"

  # # end_date can't be in the future and can't be after end_date
  # validates_date :end_date, :on_or_before => lambda {|a| Date.current}, :after => :start_date, :allow_nil => true

  # pay_level is an int and between 1 and 6
  validates_numericality_of :pay_level, :only_integer => true, :greater_than => 0, :less_than => 7

  # store is active and in the system
  validate :store_in_assignments
  
  # employee is active and in the system
  validate :employee_in_assignments

  # Scopes
  # -----------------------------
  # returns all the assignments that are considered current
  scope :current, where(:end_date => nil)

  # returns all the assignments for a particular store
  scope :for_store, lambda {|store_id| where("store_id = ?", store_id) }

  # returns all the assignments for a particular employee
  scope :for_employee, lambda {|employee_id| where("employee_id = ?", employee_id) }

  # returns all the assignments for a particular pay_level
  scope :for_pay_level, lambda {|pay_level| where("pay_level = ?", pay_level) }

  # orders all the assignments by pay_level
  scope :by_pay_level, order('pay_level')

  # orders all of the assignments by store
  scope :by_store, order('store')



  # Use private methods to execute the custom validations
  # -----------------------------
  private
  def store_in_assignments
    # get an array of the id's of all active stores
    active_store_ids = Store.active.all.map{|a| a.id}
    # add error unless the store_id in question is in active_store_ids
    unless active_store_ids.include?(self.store_id)
      errors.add(:store, "is not an active store in the database")
      return false   # not necessary, but I like to add it ...
    end
    return true  # also not strictly necessary ...
  end
    
  def employee_in_assignments
    # get an array of the id's of all active employees
    active_employee_ids = Employee.active.all.map{|a| a.id}
    # add error unless the employee_id in question is in active_employee_ids
    unless active_employee_ids.include?(self.employee_id)
      errors.add(:employee, "is not an active employee in the database")
      return false   # not necessary, but I like to add it ...
    end
    return true  # also not strictly necessary ...
  end

  # Callback code
  # -----------------------------
    # Update and terminate any previous assignments before  before saving to db
    # def end_previous_assignment
    #   self.employee.current_assignment.update_attributes(:end_date)
    # end

end
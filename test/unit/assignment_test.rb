require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase

# Validate relationships...
	should belong_to(:store)
	should belong_to(:employee)

# Validating presences...
	should validate_presence_of(:store_id)
	should validate_presence_of(:employee_id)

# # Validating start_date...
# 	should allow_value(1.second.ago.to_date).for(:start_date)
# 	should allow_value(1.year.ago.to_date).for(:start_date)

# 	should_not allow_value(1.day.from_now).for(:start_date)
# 	should_not allow_value("bad").for(:start_date)
#   should_not allow_value(nil).for(:start_date)

# # Validating end_date...
# 	should allow_value(1.second.ago.to_date).for(:end_date)
# 	should allow_value(1.year.ago.to_date).for(:end_date)
# 	should allow_value(nil).for(:end_date)

# 	should_not allow_value(1.day.from_now).for(:end_date)
# 	should_not allow_value("bad").for(:end_date)

# Validating pay_level...
	should allow_value(1).for(:pay_level)
	should allow_value(3).for(:pay_level)
	should allow_value(6).for(:pay_level)

	should_not allow_value(0).for(:pay_level)
	should_not allow_value(7).for(:pay_level)
	#should_not allow_value("1").for(:pay_level)
	should_not allow_value("bad").for(:pay_level)
	should_not allow_value("").for(:pay_level)
	should_not allow_value(nil).for(:pay_level)


# ---------------------------------
  # Testing other methods with a context
  context "Creating employees and stores connected by assignments" do
    # create the objects I want with factories
    setup do 
      @alex = Factory.create(:employee, :first_name => "alex")
      @brandon = Factory.create(:employee, :first_name => "brandon")
      @cynthia = Factory.create(:employee, :first_name => "cynthia")

	    @store1 = Factory.create(:store, :name => "store1")
      @store2 = Factory.create(:store, :name => "store2")
      @store3 = Factory.create(:store, :name => "store3")
      
      @assignment4 = Factory.create(:assignment, :store => @store3, :employee => @alex)
      @assignment1 = Factory.create(:assignment, :start_date => 1.week.ago.to_date, :end_date => nil, :store => @store1, :employee => @alex, :pay_level => 2)
      @assignment2 = Factory.create(:assignment, :end_date => Date.current, :store => @store2, :employee => @brandon, :pay_level => 2)
      @assignment3 = Factory.create(:assignment, :end_date => nil, :store => @store1, :employee => @cynthia)
    end
    
    # and provide a teardown method as well
    teardown do
      @alex.destroy
      @brandon.destroy
      @cynthia.destroy
      @store1.destroy
      @store2.destroy
      @store3.destroy
      @assignment1.destroy
      @assignment2.destroy
      @assignment3.destroy
      @assignment4.destroy
    end

    # test the scope 'current'
    should "have all current assignments accounted for" do
      assert_equal 2, Assignment.current.size 
    end

    # test the scope 'for_store'
    should "have a scope for_store that works" do
      assert_equal 2, Assignment.for_store(@store1.id).size
      assert_equal 1, Assignment.for_store(@store2.id).size
    end

    # test the scope 'for_employee'
    should "have a scope for_employee that works" do
      assert_equal 2, Assignment.for_employee(@alex).size
      assert_equal 1, Assignment.for_store(@cynthia).size
    end

    # test the scope 'for_pay_level'
    should "have a scope for_pay_level that works" do
      assert_equal 2, Assignment.for_pay_level(1).size
      assert_equal 2, Assignment.for_pay_level(2).size
      assert_equal 2, Assignment.for_pay_level(2).first.pay_level
    end

    # test the scope 'by_pay_level'
    should "have a scope by_pay_level that works" do
      assert_equal 4, Assignment.by_pay_level.size
      assert_equal 4, Assignment.by_pay_level.size
      assert_equal 1, Assignment.by_pay_level.first.pay_level
    end

    # test the scope 'by_store'
    should "have a scope by_store that works" do
      assert_equal 4, Assignment.by_store.size
      assert_equal 4, Assignment.by_store.size
    end     
    
    # test the custom validation 'store_in_assignments'
    should "identify an assignment linked to an inactive store as invalid" do
    	@store4 = Factory.build(:store, :name => "store4", :active => false)	
		  assignment5 = Factory.build(:assignment, :store => @store4)
    	assert (not assignment5.valid?)
    end

    # test the custom validation 'employee_in_assignments'
    should "identify an assignment linked to an inactive employee as invalid" do
    	@darren = Factory.build(:employee, :first_name => "darren", :active => false)	
		  assignment5 = Factory.build(:assignment, :employee => @darren)
    	assert (not assignment5.valid?)
    end

    # test the method 'end_previous_assignment'
    should "update and terminate old assignments upon the creation of a new, current assignment" do
      assignment5 = Factory.create(:assignment, :start_date => Date.current, :employee => @alex, :store => @store1, :pay_level => 3, :end_date => nil)
      # Get fresh data from the database
      assert_equal Date.current, Assignment.find(@assignment1.id).end_date
      assignment5.destroy
    end

  end

end

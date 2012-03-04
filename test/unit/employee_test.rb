require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase

# Relationship macros...
  should have_many(:assignments)
  should have_many(:stores).through(:assignments)

# Validating first_name...
  should allow_value("Zach").for(:first_name)
  should allow_value("zach").for(:first_name)
  should allow_value("ZACH").for(:first_name)
  
  should_not allow_value("1").for(:first_name)
  should_not allow_value("123").for(:first_name)
  should_not allow_value("Zach1").for(:first_name)
  
# Validating last_name...
  should allow_value("Zach").for(:last_name)
  should allow_value("zach").for(:last_name)
  should allow_value("ZACH").for(:last_name)
  
  should_not allow_value("1").for(:last_name)
  should_not allow_value("123").for(:last_name)
  should_not allow_value("Zach1").for(:last_name)

  # Validating phone...
  should allow_value("4122683259").for(:phone)
  should allow_value("412-268-3259").for(:phone)
  should allow_value("").for(:phone)
  
  should_not allow_value("412.268.3259").for(:phone)
  should_not allow_value("(412) 268-3259").for(:phone)
  should_not allow_value("(412)-268-3259").for(:phone)
  should_not allow_value("(412)268-3259").for(:phone)
  should_not allow_value("2683259").for(:phone)
  should_not allow_value("4122683259x224").for(:phone)
  should_not allow_value("800-EAT-FOOD").for(:phone)
  should_not allow_value("412/268/3259").for(:phone)
  should_not allow_value("412-2683-259").for(:phone)

  # Validating ssn...
  should allow_value("123456789").for(:ssn)
  should allow_value("123-45-6789").for(:ssn)
  should allow_value("123 45 6789").for(:ssn)
  should allow_value("123-45 6789").for(:ssn)
  should allow_value("123-456789").for(:ssn)

  should_not allow_value("1-23456789").for(:ssn)
  should_not allow_value("0123456789").for(:ssn)
  should_not allow_value("abcdefghij").for(:ssn)
  should_not allow_value("12345678a").for(:ssn)
  should_not allow_value(nil).for(:ssn)

  # Validating date_of_birth
  should allow_value(14.years.ago.to_date).for(:date_of_birth)
  should allow_value(15.years.ago.to_date).for(:date_of_birth)
  
  should_not allow_value(13.years.ago.to_date).for(:date_of_birth)
  should_not allow_value(1.week.from_now).for(:date_of_birth)
  should_not allow_value("bad").for(:date_of_birth)
  should_not allow_value(nil).for(:date_of_birth)

  # Validating role...
  should allow_value("admin").for(:role)
  should allow_value("manager").for(:role)
  should allow_value("employee").for(:role)

  should_not allow_value("bad").for(:role)
  should_not allow_value(10).for(:role)
  should_not allow_value("").for(:role)

 # Testing other methods with a context
  context "Creating three employees" do
  # Create the objects I want with factories
  setup do 
      @a = Factory.create(:employee, :last_name => "a", :date_of_birth => 16.years.ago.to_date)
      @b = Factory.create(:employee, :last_name => "b", :active => false, :role => "manager")
      @c = Factory.create(:employee, :last_name => "c", :phone => "412-268-8211", :ssn => "123-45 6789", :role => "admin")
    end

  # and provide a teardown method as well
    teardown do
      @a.destroy
      @b.destroy
      @c.destroy
    end

  # test the scope 'alphabetical'
    should "show that there are three employees in alphabetical order" do
      assert_equal ["a", "b", "c"], Employee.alphabetical.map{|x| x.last_name}
    end

  # test the scope 'active'
    should "show that there are two active employees" do
      assert_equal 2, Employee.active.size
      assert_equal ["a", "c"], Employee.active.alphabetical.map{|x| x.last_name}
    end

    # test the scope 'inactive'
    should "show that there is one inactive employee" do
      assert_equal 1, Employee.inactive.size
      assert_equal ["b"], Employee.inactive.map{|x| x.last_name}
    end

    # test the callback is working 'reformat_phone'
    should "shows that the employee's phone number and ssn are stripped of non-digits" do
      assert_equal "4122688211", @c.phone
      assert_equal "123456789", @c.ssn
    end

     # test the scope 'younger_than_18'
    should "show that there is one employee who is younger than 18" do
      assert_equal 1, Employee.younger_than_18.size
      assert_equal ["a"], Employee.younger_than_18.map{|x| x.last_name}
    end   

    # test the scope 'older_than_18'
    should "show that there are two employees who are older than 18" do
      assert_equal 2, Employee.older_than_18.size
      assert_equal ["b", "c"], Employee.older_than_18.alphabetical.map{|x| x.last_name}
    end

    # test the scope 'regulars'
    should "show that there is one employee who is a regular" do
      assert_equal 1, Employee.regulars.size
      assert_equal ["a"], Employee.regulars.map{|x| x.last_name}
    end

    # test the scope 'managers'
    should "show that there is one employee who is a manager" do
      assert_equal 1, Employee.managers.size
      assert_equal ["b"], Employee.managers.map{|x| x.last_name}
    end

    # test the scope 'admins'
    should "show that there is one employee who is an admin" do
      assert_equal 1, Employee.admins.size
      assert_equal ["c"], Employee.admins.map{|x| x.last_name}
    end      

  end

end

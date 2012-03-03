require 'test_helper'

class StoreTest < ActiveSupport::TestCase


  def new_store(attributes = {})
    attributes[:name] ||= 'foo'
    attributes[:street] ||= 'foo street'
    attributes[:zip] ||= '12345'
    store = Store.new(attributes)
    store.valid? # run validations
    store
  end

  # Relationship macros...
  should have_many(:assignments)
  should have_many(:employees).through(:assignments)

  # Validation macros
  should validate_presence_of(:name)
  should validate_presence_of(:street)
  should validate_presence_of(:zip)

 # Validating phone...
  should allow_value("4122683259").for(:phone)
  should allow_value("412-268-3259").for(:phone)
  should allow_value("").for(:phone)
  
  should_not allow_value("412.268.3259").for(:phone)
  should_not allow_value("(412) 268-3259").for(:phone)
  should_not allow_value("2683259").for(:phone)
  should_not allow_value("4122683259x224").for(:phone)
  should_not allow_value("800-EAT-FOOD").for(:phone)
  should_not allow_value("412/268/3259").for(:phone)
  should_not allow_value("412-2683-259").for(:phone)

  # Validating zip...
  should allow_value("03431").for(:zip)
  should allow_value("15217").for(:zip)
  should allow_value("15090").for(:zip)
  
  should_not allow_value("fred").for(:zip)
  should_not allow_value("3431").for(:zip)
  should_not allow_value("15213-9843").for(:zip)
  should_not allow_value("15d32").for(:zip)
  should_not allow_value("").for(:zip)
  
  # Validating state...
  should allow_value("PA").for(:state)
  should allow_value("WV").for(:state)
  should allow_value("OH").for(:state)
  should allow_value("").for(:state)

  should_not allow_value("bad").for(:state)
  should_not allow_value(10).for(:state)
  should_not allow_value("CA").for(:state)

  # Testing other methods with a context
  context "Creating three owners" do
  # Create the objects I want with factories
  setup do 
      @store1 = Factory.create(:store, :name => "store1")
      @store2 = Factory.create(:store, :name => "store2", :active => false)
      @store3 = Factory.create(:store, :name => "store3", :phone => "412-268-8211")
    end

  # and provide a teardown method as well
    teardown do
      @store1.destroy
      @store2.destroy
      @store3.destroy
    end

  # test the scope 'alphabetical'
    should "show that there are three stores in in alphabetical order" do
      assert_equal ["store1", "store2", "store3"], Store.alphabetical.map{|x| x.name}
    end

  # test the scope 'active'
    should "show that there are two active stores" do
      assert_equal 2, Store.active.size
      assert_equal ["store1", "store3"], Store.active.alphabetical.map{|x| x.name}
    end

    # test the scope 'inactive'
    should "show that there is one inactive store" do
      assert_equal 1, Store.inactive.size
      assert_equal ["store2"], Store.inactive.map{|x| x.name}
    end   

  end

  def test_validate_uniqueness_of_username
    new_store(:name => 'uniquename').save!
    assert_equal ["has already been taken"], new_store(:name => 'uniquename').errors[:name]
  end

end

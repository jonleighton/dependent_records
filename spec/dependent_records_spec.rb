require File.dirname(__FILE__) + "/spec_helper"

class House
  include DependentRecords
end

describe House, "which has a dependent join association called ownerships, " + 
                "a non-dependent through association called owners, " +
                "a dependent has_many association called external_windows with a class name of 'Window', " + 
                "a dependent has_many association called rooms, " +
                "and a dependent belongs_to association called garden" do
  before do
    @house = House.new
    House.stubs(:reflect_on_all_associations).returns([
      stub_everything(:name => :ownerships,       :class_name => "Ownership", :options => { :dependent => :destroy  }, :macro => :has_many),
      stub_everything(:name => :owners,           :class_name => "Owner",     :options => { :through => :ownerships }, :macro => :has_many),
      stub_everything(:name => :external_windows, :class_name => "Window",    :options => { :dependent => :destroy  }, :macro => :has_many),
      stub_everything(:name => :rooms,            :class_name => "Room",      :options => { :dependent => :destroy  }, :macro => :has_many),
      stub_everything(:name => :garden,           :class_name => "Garden",    :options => { :dependent => :destroy  }, :macro => :belongs_to)
    ])
    
    [:ownerships, :owners, :external_windows, :rooms, :garden].each do |assoc|
      item = instance_variable_set("@#{assoc}", stub_everything(:blank? => true))
      @house.stubs(assoc).returns(item)
    end
  end
  
  describe "with ownerships, owners, external_windows, rooms and a garden" do
    before do
      [:ownerships, :owners, :external_windows, :rooms, :garden].each do |assoc|
        @house.send(assoc).stubs(:blank?).returns(false)
      end
    end
    
    it "should return a hash with 'window' and 'room' as the keys and their records as the value, when asked for the dependent records" do
      @house.dependent_records.should == { "window" => @external_windows, "room" => @rooms }
    end
  end
  
  describe "with ownerships, no windows, rooms and a garden" do
    before do
      @house.ownerships.stubs(:blank?).returns(false)
      @house.rooms.stubs(:blank?).returns(false)
      @house.garden.stubs(:blank?).returns(false)
    end
    
    it "should return a one item hash with 'room' as the key and its record as the value, when asked for the dependent records" do
      @house.dependent_records.should == { "room" => @rooms }
    end
  end
  
  describe "with no ownerships, owners, windows or rooms, and no garden" do
    it "should return a empty hash when asked for the dependent records" do
      @house.dependent_records.should == { }
    end
  end
end

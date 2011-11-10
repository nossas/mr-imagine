require 'spec_helper'

describe Category do
  
  it "should be valid from factory" do
    o = Factory(:category)
    o.should be_valid
  end
  
  it "should have a name" do
    o = Factory.build(:category, :name => nil)
    o.should_not be_valid
  end
  
  it "should have a badge" do
    o = Factory.build(:category, :badge => nil)
    o.should_not be_valid
  end
  
  it "should have an unique name" do
    o = Factory(:category, :name => "foo")
    o.should be_valid
    o2 = Factory.build(:category, :name => "foo")
    o2.should_not be_valid
    o3 = Factory.build(:category, :name => "bar")
    o3.should be_valid
  end
  
end


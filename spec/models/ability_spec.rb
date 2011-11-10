require 'spec_helper'
require "cancan/matchers"

describe Category do

  it "should enable root user to manage everything" do
    user = Factory.build(:user, :admin => true)
    user2 = Factory.build(:user)
    category = Factory.build(:category)
    ability = Ability.new(user)
    ability.should be_able_to(:manage, :all)
    ability.should be_able_to(:manage, category)
    ability.should be_able_to(:manage, user2)
    ability.should be_able_to(:manage, Configuration)
  end

  it "should not enable ordinary users to manage categories and other's ideas" do
    user1 = Factory.build(:user)
    user2 = Factory.build(:user)
    user1.save
    user2.save
    idea1 = Factory.build(:idea, :user => user1)
    idea2 = Factory.build(:idea, :user => user2)
    ability = Ability.new(user1)
    
    ability.should_not be_able_to(:manage, user2)
    ability.should_not be_able_to(:manage, idea2)
    ability.should be_able_to(:manage, user1)
    ability.should be_able_to(:manage, idea1)
  end

  it "should enable users to merge others ideas derived from his work into the original" do
    user1 = Factory.build(:user)
    user2 = Factory.build(:user)
    idea1 = Factory.build(:idea, :user => user1)
    idea2 = idea1.create_fork(user2)
    ability = Ability.new(user1)
    ability.should be_able_to(:merge, idea1)
  end

  it "shouldn't enable users to merge others ideas derived from his work into the original" do
    user1 = Factory.build(:user)
    user2 = Factory.build(:user)
    idea1 = Factory.build(:idea, :user => user1)
    idea2 = idea1.create_fork(user2)
    ability = Ability.new(user2)
    ability.should_not be_able_to(:merge, idea1)
  end

  it "shouldn't be able to fork his own idea" do
    user1 = Factory.build(:user)
    user1.save
    idea1 = Factory.build(:idea, :user => user1)
    idea1.save
    ability = Ability.new(user1)
    ability.should_not be_able_to(:create_fork, idea1)
  end

end
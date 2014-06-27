#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../../spec_helper'

class BaseTest < Cobbler::Base
    cobbler_field :name
    cobbler_field :locked_field, :locked => true
    cobbler_field :saveable_field
end

class Unremovable < Cobbler::Base
    cobbler_lifecycle :remove => false
end

class Unsaveable1 < Cobbler::Base
    cobbler_lifecycle :handle => false
end

class Unsaveable2 < Cobbler::Base
    cobbler_lifecycle :modify => false
end

class Unsaveable3 < Cobbler::Base
    cobbler_lifecycle :new => false, :save => false
end

class CollTest1 < Cobbler::Base
    cobbler_field :name
    cobbler_collection :coll1
end
class CollTest2 < Cobbler::Base
    cobbler_field :name
    cobbler_collection :coll2, :store => :store_coll2
    
    def store_coll2
        coll2.to_a.each do |item|
            #do something
        end
    end
end

describe Cobbler::Base do
    
    [:remove, :save, :copy ].each do |method|
        it "should provide a method to #{method} the item" do
            test = BaseTest.new
            test.should respond_to(method)
        end
    end
    
    describe "when initializing" do
        it "should add the fields to the user fields" do
            test = BaseTest.new({'name' => 1, 'b' => 2})
            test.definitions.keys.should be_empty
            test.user_definitions.keys.should_not be_empty
            test.user_definitions.keys.should include('name')
            test.user_definitions.keys.should include('b')
            test.name.should == 1
        end
        
        it "should add the fields to the old definitions if it's an old record" do
            test = BaseTest.new({:a => 1, :b => 2},false)
            test.definitions.keys.should_not be_empty
            test.definitions.keys.should include(:a)
            test.definitions.keys.should include(:b)
            test.user_definitions.keys.should be_empty
        end
    end
    
    describe "when removing an item" do
        it "should raise an exception if we have no api_method to remove the item" do
            lambda { Unremovable.new.remove }.should raise_error(Exception)
        end
        
        it "should call the remove api_method for the item" do
            test = BaseTest.new({'name' => 'foo'})
            test.name.should == 'foo'
            connection = Object.new
            BaseTest.expects(:login).returns('muh')
            BaseTest.expects(:logout)
            BaseTest.expects(:connect).returns(connection)
            BaseTest.expects(:make_call).with(test.api_methods[:remove],test.name,'muh')
            test.remove
        end
    end

    describe "when trying to save an item" do
        it "should raise an exception if we have no api_method to save and/or update the item" do
            [Unsaveable1,Unsaveable2,Unsaveable3].each do |klass|
                lambda { klass.new.save }.should raise_error(Exception)
            end
        end
    end
    describe "when saving an existing item" do
        before(:each) do
            @test1 = BaseTest.new({'name' => 'foo','locked_field' => '1', 'saveable_field' => 2},false)
            BaseTest.expects(:connect).returns(Object.new)
            BaseTest.expects(:login).returns('muh')
            BaseTest.expects(:logout)
            BaseTest.expects(:find_one).with('foo').returns('entry')
            BaseTest.expects(:make_call).with('get_base_test_handle','foo','muh').returns('id')
            BaseTest.expects(:make_call).with('save_base_test','id','muh')
        end
        it "should store no fields on a unchanged record" do
            [:name,:locked_field,:saveable_field].each do |field|
                BaseTest.expects(:make_call).with('modify_base_test','id',"#{field}",@test1.send(field),'muh').never
            end
            @test1.save
        end
        
        it "should only store changed fields" do
            @test1.saveable_field = 3
            [:name,:locked_field].each do |field|
                BaseTest.expects(:make_call).with('modify_base_test','id',"#{field}",@test1.send(field),'muh').never
            end
            BaseTest.expects(:make_call).with('modify_base_test','id',"saveable_field",3,'muh')
            @test1.save
        end
        
        it "should store no locked fields" do
            @test1.locked_field = 'foobar'
            [:name,:locked_field,:saveable_field].each do |field|
                BaseTest.expects(:make_call).with('modify_base_test','id',"#{field}",@test1.send(field),'muh').never
            end
            @test1.save            
        end
    end
    
    describe "when saving a not yet existing item" do
        before(:each) do
            @test1 = BaseTest.new({'name' => 'foo','locked_field' => '1', 'saveable_field' => 2},false)
            BaseTest.expects(:connect).returns(Object.new)
            BaseTest.expects(:find_one).with('foo').returns(nil)
            BaseTest.expects(:login).returns('muh')
            BaseTest.expects(:logout)
            BaseTest.expects(:make_call).with('new_base_test','muh').returns('id')
            BaseTest.expects(:make_call).with('modify_base_test','id',"name",@test1.name,'muh')
            BaseTest.expects(:make_call).with('save_base_test','id','muh')
        end
        it "should store no fields on a unchanged record" do
            [:name,:locked_field,:saveable_field].each do |field|
                BaseTest.expects(:make_call).with('modify_base_test','id',"#{field}",@test1.send(field),'muh').never
            end
            @test1.save
        end
        
        it "should only store changed fields" do
            @test1.saveable_field = 3
            [:name,:locked_field].each do |field|
                BaseTest.expects(:make_call).with('modify_base_test','id',"#{field}",@test1.send(field),'muh').never
            end
            BaseTest.expects(:make_call).with('modify_base_test','id',"saveable_field",3,'muh')
            @test1.save
        end
        
        it "should store no locked fields" do
            @test1.locked_field = 'foobar'
            [:name,:locked_field,:saveable_field].each do |field|
                BaseTest.expects(:make_call).with('modify_base_test','id',"#{field}",@test1.send(field),'muh').never
            end
            @test1.save            
        end        
    end
    
    describe "when saving an item with collections" do
        it "should store a normal collection as a normal field" do
            @test1 = CollTest1.new({'name' => 'foo'},false)
            @test1.coll1 = [1,2]
            CollTest1.expects(:connect).returns(Object.new)
            CollTest1.expects(:find_one).with('foo').returns(nil)
            CollTest1.expects(:login).returns('muh')
            CollTest1.expects(:logout)
            CollTest1.expects(:make_call).with('new_coll_test1','muh').returns('id')
            CollTest1.expects(:make_call).with('modify_coll_test1','id',"name",@test1.name,'muh')
            CollTest1.expects(:make_call).with('modify_coll_test1','id',"coll1",[1,2],'muh')
            CollTest1.expects(:make_call).with('save_coll_test1','id','muh')
            @test1.save
        end
        
        it "should call the store methods for a special storeable field" do
            @test1 = CollTest2.new({'name' => 'foo'},false)
            @test1.coll2 = [1,2]
            CollTest2.expects(:connect).returns(Object.new)
            CollTest2.expects(:find_one).with('foo').returns(nil)
            CollTest2.expects(:login).returns('muh')
            CollTest2.expects(:logout)
            CollTest2.expects(:make_call).with('new_coll_test2','muh').returns('id')
            CollTest2.expects(:make_call).with('modify_coll_test2','id',"name",@test1.name,'muh')
            @test1.expects(:store_coll2)
            CollTest2.expects(:make_call).with('save_coll_test2','id','muh')
            @test1.save
        end
    end
    
end

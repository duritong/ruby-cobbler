require File.dirname(__FILE__) + '/../../../spec_helper'

class TestLifecycle
    
    def initialize(a=nil,b=nil)
        @definitions = Hash.new(a)
    end
    
    include Cobbler::Common::Debug
    include Cobbler::Connection::Handling
    include Cobbler::Common::Lifecycle
    
    cobbler_field :name
    cobbler_field :foo, :locked => true
    cobbler_field :findme, :findable => 'find_me'
    cobbler_field :super_field, :locked => true, :findable => 'find_super'
    
    cobbler_fields :foo1, :foo2
    
    cobbler_collection :coll1
    cobbler_collection :coll2, :packing => Hash
    cobbler_collection :coll3, :store => :foobar
end

class TestLifecycle2
    def initialize(a,b); end
    include Cobbler::Common::Debug    
    include Cobbler::Connection::Handling
    include Cobbler::Common::Lifecycle
    cobbler_field :name, :locked => false, :findable => false
    cobbler_lifecycle :find_all => 'foobar', :find_one => false
end

describe Cobbler::Common::Lifecycle do
    
    it "should provide a bunch of api_methods for that object" do
        TestLifecycle.api_methods.keys.should_not be_empty
    end
    
    [ :find_all, :find_one, :handle, :remove, :save, :new, :modify].each do |method|
        it "should provide an api_method for #{method} and be derived from the classname" do
            TestLifecycle.api_methods[method].should_not be_nil
            TestLifecycle.api_methods[method].should =~ /test_lifecycle/
        end
    end
    
    describe "defining lifecycle" do
        it "should provide a way to define a lifecycle" do
            TestLifecycle.should respond_to(:cobbler_lifecycle)
        end
        
        it "should set the api_method according to the one we defined" do
            TestLifecycle2.api_methods[:find_all].should == 'foobar'
            TestLifecycle2.api_methods[:find_one].should be_false
        end
        
        [ :handle, :remove, :save, :new, :modify].each do |method|
            it "should define method #{method}" do
                TestLifecycle2.api_methods[method].should_not be_nil
                TestLifecycle2.api_methods[method].should =~ /test_lifecycle/
            end
            
        end
    end
    
    describe "define a cobbler field" do
        it "should provide a way to define a cobbler field" do
            TestLifecycle.should respond_to(:cobbler_field)
        end
        
        it "should provide a way to define multiple cobbler fields" do
            TestLifecycle.should respond_to(:cobbler_fields)
        end
        
        it "should add this field to the record fields" do
            TestLifecycle.cobbler_record_fields.should include(:name)
        end
        
        it "should add the name field as findable" do
            TestLifecycle.should respond_to(:find_by_name)
        end

        it "should lock the name field" do
            TestLifecycle.locked_fields.should include(:name)
        end

        it "should not add the name field as findable if we mark it" do
            TestLifecycle2.should_not respond_to(:find_by_name)
        end

        it "should lock the name field" do
            TestLifecycle2.locked_fields.should_not include(:name)
        end        
        
        it "should be available as getter and setter on an instance" do
            test = TestLifecycle.new
            test.should respond_to(:name)
            test.should respond_to(:name=)
        end
        
        it "should handle cobbler_fields over to cobbler_field" do
            test = TestLifecycle.new
            [:foo1,:foo2].each do |field|
                test.should respond_to(field)
                test.should respond_to(:"#{field}=")
                TestLifecycle.cobbler_record_fields.should include(field)
            end
        end
        
        it "should be possible to mark that field as locked" do
            TestLifecycle.locked_fields.should include(:foo)
            TestLifecycle.locked_fields.should include(:super_field)
        end
        
        it "should be possible to mark a field as findable" do
            TestLifecycle.should respond_to(:find_by_findme)
            TestLifecycle.should respond_to(:find_by_super_field)
        end
        
        describe "which is findable" do
            before(:each) do
                connection = Object.new
                TestLifecycle.expects(:connect).returns(connection)
            end

            it "should lookup that field" do
                TestLifecycle.expects(:make_call).with('get_test_lifecycle','foo').returns('a')
                item = TestLifecycle.find_by_name('foo')
                item.should be_a(TestLifecycle)
            end
            it "should lookup the field with the appropriate api method" do
                TestLifecycle.expects(:make_call).with('find_super','foo').returns('a')
                item = TestLifecycle.find_by_super_field('foo')
                item.should be_a(TestLifecycle)
            end
            
            it "should return nil if nothing is found" do
                TestLifecycle.expects(:make_call).with('get_test_lifecycle','foo').returns(nil)
                TestLifecycle.find_by_name('foo').should be_nil
            end
        end
    end
    describe "define a cobbler collection" do
        it "should provide a way to define a cobbler collection" do
            TestLifecycle.should respond_to(:cobbler_collection)
        end
        
        it "should provide accessor and setter for a collection" do
            TestLifecycle.new.should respond_to(:coll1)
            TestLifecycle.new.should respond_to(:coll1=)
        end
        
        it "should add the collection to the fields" do
            TestLifecycle.cobbler_record_fields.should include(:coll1)
            TestLifecycle.cobbler_record_fields.should include(:coll2)
        end
        
        it "should set a default type to be an array" do
            TestLifecycle.new.coll1.should be_a(Array)
        end

        it "should be possible to set packing as Hash" do
            TestLifecycle.new.coll2.should be_a(Hash)
        end
        
        it "should be possible to define a special store callback" do
            TestLifecycle.cobbler_record_fields.should_not include(:coll3)
            TestLifecycle.cobbler_collections_store_callbacks.should include(:foobar)
        end
    end
    
    describe "assigning new values" do
        it "should not be added to the original definitions" do
            test = TestLifecycle.new
            test.name = 'foo'
            test.name.should == 'foo'
            test.definitions['name'].should_not == 'foo'
            test.user_definitions['name'].should == 'foo'
        end
        
        it "should always be added to the user_definitions if it as collection" do
            test = TestLifecycle.new
            test.coll1.should == []
            test.coll1 = [1,2]
            test.coll1.should == [1,2]
            test.user_definitions['coll1'].should == [1,2]
            test.coll1 << 3
            test.coll1 == [1,2,3]
        end
    end
    
end
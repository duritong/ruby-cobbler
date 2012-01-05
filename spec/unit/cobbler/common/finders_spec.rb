#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../../../spec_helper'

class TestFinder
    
    def initialize(a,b)
        
    end
    
    include Cobbler::Common::Debug
    include Cobbler::Connection::Handling
    include Cobbler::Common::Lifecycle    
    include Cobbler::Common::Finders
end

describe Cobbler::Common::Finders do
    it "should provide a way to find all" do
        TestFinder.should respond_to(:find)
    end
    it "should provide a way to find one" do
        TestFinder.should respond_to(:find_one)
    end
    
    describe "lookup" do
        it "should raise an exception if we don't know how to lookup all" do
            api_methods = Object.new
            api_methods.stubs(:[]).with(:find_all).returns(nil)
            TestFinder.stubs(:api_methods).returns(api_methods)
            lambda{ TestFinder.find_all }.should raise_error(Exception)
        end
        
        it "should raise an exception if we don't know how to lookup an item" do
            api_methods = Object.new
            api_methods.stubs(:[]).with(:find_one).returns(nil)
            TestFinder.stubs(:api_methods).returns(api_methods)
            lambda{ TestFinder.find_one('foo') }.should raise_error(Exception)
        end
        
        it "should use the :find_one api_method to lookup an item" do
            TestFinder.api_methods[:find_one] = 'find_one'
            connection = Object.new
            TestFinder.expects(:connect).returns(connection)
            TestFinder.stubs(:make_call).with('find_one','foo').returns({})
            item = TestFinder.find_one('foo')
            item.should be_nil
        end
        
        it "should return nil if api returns '~'" do
            TestFinder.api_methods[:find_one] = 'find_one'
            connection = Object.new
            TestFinder.expects(:connect).returns(connection)
            TestFinder.stubs(:make_call).with('find_one','foo').returns('~')
            item = TestFinder.find_one('foo')
            item.should be_nil
        end        
        
        describe "is unsuccessful" do
            it "should return an empty array if nothing is found" do
                TestFinder.stubs(:in_transaction).returns([])
                TestFinder.find.should be_empty
            end
            it "should return nil if nothing is found" do
                TestFinder.stubs(:in_transaction).returns({})
                TestFinder.find_one('foo').should be_nil
            end
        end
        
        describe "successfully all items" do
            before(:each) do
                TestFinder.stubs(:in_transaction).returns([1,2])
            end
            it "should return an array of Objects of itself if something is found" do
                items = TestFinder.find
                items.should have(2).items
                items.first.should be_a(TestFinder)
                items.last.should be_a(TestFinder)
            end
            
            it "should pass each found item to the passed block but return the found items" do
                items = TestFinder.find do |item|
                    item.should be_a(TestFinder)
                end
                items.should have(2).items
                items.first.should be_a(TestFinder)
                items.last.should be_a(TestFinder)                
            end
        end
        
        describe "successfully one item" do
            it "should return an item" do
                TestFinder.stubs(:in_transaction).returns({:a => 1})
                TestFinder.find_one('foo').should be_a(TestFinder)
            end
            
            it "should return nil if nothing is found" do
                TestFinder.stubs(:in_transaction).returns({})
                TestFinder.find_one('foo').should be_nil
            end
        end
    end
end
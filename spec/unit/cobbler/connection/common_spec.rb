#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../../../spec_helper'

class TestConnection
    include Cobbler::Common::Debug
    include Cobbler::Connection::Handling
    include Cobbler::Connection::Common
end

describe Cobbler::Connection::Common do
    it "should provide a method to test a connection" do
        TestConnection.should respond_to(:test_connection)
    end
    
    it "should provide a method to start a sync" do
        TestConnection.should respond_to(:sync)
    end
    
    describe "testing a connection" do
        
        before(:each) do
            connection = Object.new
            TestConnection.expects(:connect).returns(connection)
        end
        
        it "should return false if login fails" do
            TestConnection.expects(:login).returns(nil)
            TestConnection.test_connection.should be_false
        end
        it "should return true if login succeeds and logout" do
            TestConnection.expects(:login).returns("true")
            TestConnection.expects(:logout)
            TestConnection.test_connection.should be_true
        end
    end
    
    with_real_cobbler(TestConnection) do |cobbler_yml|
        describe "testing a real connection" do
            before(:each) do
                TestConnection.hostname = yml['hostname']
                TestConnection.username = yml['username']
                TestConnection.password = yml['password']
                TestConnection.timeout = yml['timeout']
            end
            
            it "should "
        end
    end
    
    describe "syncing a cobbler" do
        it "should send the sync command" do
            connection = 
            TestConnection.expects(:connect).returns(Object.new)
            TestConnection.expects(:login).returns('foobar')
            TestConnection.expects(:logout)
            TestConnection.expects(:make_call).with('sync','foobar')
            TestConnection.sync
        end
    end
end

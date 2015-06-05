#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../../../spec_helper'

class TestConnection
    include Cobbler::Common::Debug
    include Cobbler::Connection::Handling
end

describe Cobbler::Connection::Handling do
    [:hostname, :username, :password, :timeout].each do |field|
        it "should provide getters and setters for #{field}" do
            TestConnection.should respond_to(field)
            TestConnection.should respond_to("#{field}=".to_sym)
        end
    end

    it "should provide a way to query the version of the cobbler server" do
        TestConnection.should respond_to(:remote_version)
    end

    describe "querying remote version" do
        before(:each) do
            connection = Object.new
            TestConnection.expects(:connect).returns(connection)
            TestConnection.expects(:connection).returns(nil)
        end

        it "should return the version" do
            TestConnection.expects(:make_call).with('version').returns("2.0")
            TestConnection.remote_version.should == "2.0"
        end
    end

    it "should provide a way to login to the cobbler server" do
        TestConnection.should respond_to(:login)
    end

    describe "logging into cobbler server" do

        it "should call the login server" do
            TestConnection.username = 'foobar'
            TestConnection.password = 'password'
            TestConnection.expects(:make_call).with('login','foobar','password')
            TestConnection.login
        end

        it "should not relogin if we are still logged in" do
            TestConnection.username = 'foobar'
            TestConnection.password = 'password'
            TestConnection.expects(:make_call).with('login','foobar','password').returns("token")
            TestConnection.login

            TestConnection.username = 'foobar2'
            TestConnection.password = 'password2'
            TestConnection.expects(:make_call).with('login','foobar2','password2').never
            TestConnection.login
        end
    end

    it "should connect to the cobbler server" do
        TestConnection.hostname = 'localhost'
        @connection = Object.new
        XMLRPC::Client.expects(:new2).with('http://localhost/cobbler_api',nil,nil).returns(@connection)
        TestConnection.send(:connect)
    end

    describe "making a call" do
        it "should raise an exception if no connection have been established so far" do
            TestConnection.expects(:connection).returns(nil)
            lambda { TestConnection.make_call('foobar') }.should raise_error(Exception)
        end

        it "should pass all arguments to the connection and return the resul" do
            connection = Object.new
            connection.expects(:call).with('foo','bar').returns('juhu')
            TestConnection.expects(:connection).twice.returns(connection)
            TestConnection.make_call('foo','bar')
        end
    end

    describe "handling transactions" do
        it "should initialze and end a connection" do
            TestConnection.expects(:begin_transaction)
            TestConnection.expects(:end_transaction)
            TestConnection.send(:in_transaction) do
               #
            end
        end

        it "should cleanup the connection" do
            TestConnection.expects(:connect).returns('foobar')
            TestConnection.in_transaction do
                #
            end
            TestConnection.send(:connection).should be_nil
        end

        it "should login if you want a login and pass the token into the transaction and logout" do
            connection = Object.new
            TestConnection.expects(:login).returns('token')
            TestConnection.expects(:logout)
            TestConnection.expects(:connect).returns('foobar')
            TestConnection.in_transaction(true) do |token|
               token.should == 'token'
            end
        end

        it "should ensure that the connection is cleaned up" do
            TestConnection.expects(:connect).returns('foobar')
            lambda { TestConnection.in_transaction do
                raise "foobar"
            end }.should raise_error(Exception)
            TestConnection.send(:connection).should be_nil
        end
    end
end

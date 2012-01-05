#! /usr/bin/env ruby
require File.dirname(__FILE__) + '/../../spec_helper'

describe Cobbler::System do
    
    it "should define a method to store network interfaces" do
        Cobbler::System.new.should respond_to(:store_interfaces)
    end
    
    describe "when saving" do
        it "should store all interfaces" do
            @test1 = Cobbler::System.new({'name' => 'foo'},false)
            @test1.interfaces = { 'eth0' => { 'ipaddress' => '192.168.1.1' },
                                  'eth1' => { 'ipaddress' => '192.168.2.1' }
            }
            Cobbler::System.expects(:login).returns('muh')
            Cobbler::System.expects(:logout)
            Cobbler::System.expects(:find_one).with('foo').returns('entry')
            Cobbler::System.expects(:connect).returns(Object.new)
            Cobbler::System.expects(:make_call).with('get_system_handle','foo','muh').returns('id')
            Cobbler::System.expects(:make_call).with('save_system','id','muh')
            Cobbler::System.expects(:make_call).with('modify_system','id','modify_interface',{"ipaddress-eth0" => '192.168.1.1'},'muh')
            Cobbler::System.expects(:make_call).with('modify_system','id','modify_interface',{"ipaddress-eth1" => '192.168.2.1'},'muh')
            @test1.save
        end
    end
end
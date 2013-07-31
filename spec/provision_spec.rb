require_relative "spec_helper"
require "provisioner"
describe Provisioner::Provision do

  before do
    @command = nil
    Provisioner::Provision.start
    Provisioner::Provision.class_eval do
      private
      def shellout(command)
        raise "HERE"
        @command = command
      end
    end
  end

  context "commands" do
    before do
      @args = %W[#{ARGV[0]} --type memcached-sessions --environment test]
    end

    xit "should show usage message" do
      @command.should_not be_nil
      puts @command
    end

  end
end
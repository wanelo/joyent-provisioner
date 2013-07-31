require_relative "spec_helper"
require "provisioner"

describe Provisioner::Configuration do

  before do
    @config = Provisioner::Configuration.new("config/test.yml")
  end

  it "should return host configuration" do
    @config.for_host("sample-cluster").should_not be_nil
    @config.for_host("sample-cluster")["image"].should == '9ec5c0c-a941-11e2-a7dc-57a6b041988f'
  end
  it "should return environment" do
    @config.environment.should_not be_nil
  end
  it "should return cluster_names" do
    @config.host_suffix.should_not be_nil
  end
  it "should return host configuration" do
    @config.cluster_names.should_not be_nil
    @config.cluster_names.should =~ ["sample-cluster"]
  end
end
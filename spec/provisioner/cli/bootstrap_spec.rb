require 'spec_helper'

describe 'provision bootstrap cli' do
  let(:provision_path) { 'bin' }

  def execute(command)
    `#{provision_path}/#{command} --dry-run`.strip
  end

  describe 'host number is provided' do
  end
end
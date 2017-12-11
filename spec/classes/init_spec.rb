require 'spec_helper'
describe 'neb0t_motd' do
  context 'with default values for all parameters' do
    it { should contain_class('neb0t_motd') }
  end
end

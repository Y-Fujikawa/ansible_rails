require 'spec_helper'

describe package('mysql') do
  it { should be_installed }
end

describe package('mysql-server') do
  it { should be_installed }
end

describe package('MySQL-python') do
  it { should be_installed }
end

describe service('mysqld') do
  it { should be_enabled   }
  it { should be_running   }
end

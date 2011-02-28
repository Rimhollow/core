SYSTEM_ACCOUNT_ID = 'SYSTEM'
OPERATIONS_ACCOUNT_ID = 'OPERATIONS'

class Account
  include DataMapper::Resource

  property :id, String, :key => true
  property :description, Text
  property :report_email, String

  has 1..n, :projects, :constraint => :destroy
  has n, :agents

  def default_project
    projects.first :id => DEFAULT_PROJECT_ID or raise "default project missing for #{id}"
  end

end

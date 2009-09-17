require 'rack'

# echo the status back to the requestor
require 'sinatra/base'

class StatusEcho < Sinatra::Base
  
  get '/code/:code' do |code|
    
    if code.to_i == 200
      'all good'
    else
      halt code, 'you asked for it'
    end
    
  end
  
end

TS_DIR = File.join File.dirname(__FILE__), '..', 'test-stack'


def test_stack

  # validation & provenance
  validation_dir = File.join TS_DIR, 'validation'
  $:.unshift File.join(validation_dir, 'lib')
  require File.join(validation_dir, 'validation')
  require File.join(validation_dir, 'provenance')

  # description
  description_dir = File.join TS_DIR, 'description'
  $:.unshift File.join(description_dir, 'lib')
  require File.join(description_dir, 'describe')

  # actionplan
  actionplan_dir = File.join TS_DIR, 'actionplan'
  $:.unshift File.join(actionplan_dir, 'lib')
  require File.join(actionplan_dir, 'app')

  # transformation
  ENV["PATH"] = "/Applications/ffmpegX.app/Contents/Resources:#{ENV["PATH"]}"
  transformation_dir = File.join TS_DIR, 'transformation'
  $:.unshift File.join(transformation_dir, 'lib')
  require File.join(transformation_dir, 'transform')

  # storage
  storage_dir = File.join TS_DIR, 'simplestorage'
  $:.unshift File.join(storage_dir, 'lib')
  require File.join(storage_dir, 'app')

  
  Rack::Builder.new do

     use Rack::CommonLogger
     use Rack::ShowExceptions
     use Rack::Lint

     map "/validation" do
       run Validation.new
     end

     map "/provenance" do
       run Provenance.new
     end

     map "/description" do
       run Describe.new
     end

     map "/actionplan" do
       run ActionPlanD.new
     end

     map "/transformation" do
       run Transform.new
     end

     map "/silo" do
       run SimpleStorage::App.new(SILO_SANDBOX)
     end

  end
  
end

def nuke_silo_sandbox
  FileUtils::rm_rf SILO_SANDBOX
  FileUtils::mkdir_p SILO_SANDBOX
end

def run_test_stack
  httpd = Rack::Handler::Thin
  httpd.run test_stack, :Port => 7000
end

# test stack dir

namespace :ts do
  
  desc "fetch the test stack"
  task :fetch do

    FileUtils::mkdir_p TS_DIR

    vc_urls = {
      'description' => "svn://tupelo.fcla.edu/daitss2/describe/trunk",
      #'storage' => "svn://tupelo.fcla.edu/daitss2/store/trunk",
      'simplestorage' => "ssh://sake/var/git/simplestorage.git",
      'actionplan' => "svn://tupelo.fcla.edu/daitss2/actionplan/trunk",
      'validation' => "svn://tupelo/shades/validate-service",
      'transformation' => "svn://tupelo.fcla.edu/daitss2/transform/trunk"
    }

    Dir.chdir TS_DIR do
      vc_urls.each do |name, url|
        print "fetching #{name} ... "
        
        if File.exist? name
          puts "already here"
          next
        else

          if url =~ %r{^svn://}
            `svn export #{url} #{name}`  
          else
            `git archive --remote='#{url}' --format=tar --prefix='simplestorage/' master | tar xf -`
          end

          raise "error retrieving #{name}" unless $? == 0
          puts 'done'
        end
        
      end
      
    end

  end
  
  desc "nuke the test stack"
  task :clobber do
    FileUtils::rm_rf TS_DIR
  end
  
  desc "run the test stack"
  task :run do

    SERVICE_URLS = {
      "actionplan" => "http://localhost:7000/actionplan/instructions", 
      "validation" => "http://localhost:7000/validation/results", 
      "provenance" => "http://localhost:7000/provenance", 
      "storage" => "http://localhost:7000/silo", 
      "description" => "http://localhost:7000/description/describe"
    }

    # nuke the storage stuff
    SILO_SANDBOX = '/tmp/silo_sandbox'
    require 'spec/help/test_stack'
    nuke_silo_sandbox
    run_test_stack
  end

  
end

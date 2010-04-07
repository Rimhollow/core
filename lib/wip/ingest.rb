require 'wip'
require 'wip/step'
#require 'datafile/virus'
require 'wip/preserve'
require 'template/premis'
require 'descriptor'
require 'db/aip'
require 'db/aip/wip'

class Wip

  def ingest!

    #original_datafiles.each do |df|
      #step("virus-check-#{df.id}") { df.virus_check! }
    #end

    preserve!

    step('write-ingest-event') do
      spec = {
        :id => "#{uri}/event/ingest",
        :type => 'ingest',
        :outcome => 'success',
        :linking_objects => [ uri ],
        :linking_agents => [ "info:fcla/daitss/ingest" ]
      }
      metadata['ingest-event'] = event spec
    end

    step('write-ingest-agent') do
      spec = {
        :id => "info:fcla/daitss/ingest",
        :name => 'daitss ingest',
        :type => 'software'
      }
      metadata['ingest-agent'] = agent spec
    end

    step('make-aip-descriptor') do
      metadata['aip-descriptor'] = descriptor
    end

    step('make-aip') { Aip::new_from_wip self }
  end

end

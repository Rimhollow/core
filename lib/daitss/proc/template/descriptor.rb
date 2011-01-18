require 'daitss/proc/datafile/obsolete'
require 'daitss/proc/metadata'
require 'daitss/proc/template'
require 'daitss/proc/wip/dmd'

module Daitss

  # Helpers for generating the aip descriptor
  class Wip

    def make_aip_descriptor
      @id_map = Hash.new { |hash, key| hash[key] = "0" }
      @admid_map = Hash.new { |hash, key| hash[key] = [] }
      XML.default_keep_blanks = false

      s = template_by_name('aip/descriptor').result(binding)
      puts s
      descriptor = XML::Document.string s
      save_aip_descriptor descriptor.to_s
    end

    def validate_aip_descriptor
      rs = validate_xml aip_descriptor_file

      rs.reject! { |r|
        r[:level] == :warning ||
          r[:message] =~ %r{(tcf|aes)\:} ||
          r[:message] =~ %r{agentNote}
      }

      unless rs.empty?
        es = rs.map { |r| r[:line].to_s + ' ' + r[:message] }.join "\n"
        raise "descriptor fails daitss aip xml validation (#{rs.size} errors)\n#{es}"
      end

    end

    def uri
      package.uri
    end

    private

    def agreement_info
      template_by_name('aip/agreement_info').result(binding)
    end

    def next_id md_type, *things
      n = @id_map[md_type].next!
      new_id = "#{md_type}-#{n}"
      things.each { |t| @admid_map[t] << new_id } unless things.empty?
      new_id
    end

    # return a list of ids associated with
    def admids_for id
      @admid_map[id]
    end

    def tag_start name, attributes={}
      attr_string = attributes.map { |(a_name, a_value)| "#{a_name.id2name}=\"#{a_value}\"" }.join ' '
      "<#{name} #{attr_string}>"
    end

    def tag_end name
      "</#{name}>"
    end

    def tag_single name, attributes={}
      attr_string = attributes.map { |(name, value)| "#{name.id2name}=\"#{value}\"" }.join ' '
      "<#{name} #{attr_string}/>"
    end

    def file_element df
      template_by_name('aip/file_element').result binding
    end

    def intellectual_entity_object
      template_by_name('aip/intellectual_entity_object').result binding
    end

    def rep_name_map
      {
        'original' => original_representation,
        'current' => current_representation,
        'normalized' => normalized_representation
      }.reject { |k,v| v.empty? }
    end

    def representation_object rep, options={}
      template_by_name('aip/representation_object').result binding
    end

    def representation_struct_map rep, options={}
      template_by_name('aip/representation_struct_map').result binding
    end

    def md_section doc, options={}
      options[:md_type] ||= 'PREMIS'
      template_by_name('aip/md_section').result binding
    end

    def digiprov_events
      new_events = metadata_for 'submit-event', 'validate-event', 'ingest-event', 'disseminate-event', 'd1migrate-event'
      new_events + old_events.map { |e| e.root.to_s }
    end

    def digiprov_agents
      new_agents = metadata_for 'submit-agent', 'submit-agent-account', 'validate-agent', 'ingest-agent', 'disseminate-agent', 'd1migrate-agent'
      new_agents + old_agents.map { |a| a.root.to_s }
    end

    def datafile_agents
      h = Hash.new { |hash, key| hash[key] = [] }

      all_datafiles.each do |df|

        df.digiprov_agents.map(&:strip).each do |agent|
          h[agent] << df
          h[agent].uniq!
        end

      end

      h
    end

  end

  class DataFile

    DIGIPROV_KEYS = %w[describe actionplan migrate normalize obsolete xml-resolution virus-check redup]

    def digiprov_events
      new_events = metadata_for *DIGIPROV_KEYS.map { |k| k + '-event' }
      new_events + old_events.map { |e| e.root.to_s }
    end

    def digiprov_agents
      new_agents = metadata_for *DIGIPROV_KEYS.map { |k| k + '-agent' }
      new_agents + old_agents.map { |a| a.root.to_s }
    end

  end

end

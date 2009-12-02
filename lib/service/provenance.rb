require 'cgi'
require 'libxml'
require "service/error"

include LibXML

module Service
  
  module Provenance
  
    def provenance_retrieved?
      md_for_event? "External Provenance Extraction"    
    end

    def retrieve_provenance!
      s_url = "#{Config::Service['provenance']}/events?location=#{CGI::escape @url.to_s}"
      response = Net::HTTP.get_response URI.parse(s_url)
      case response
      when Net::HTTPSuccess
        extp_doc = XML::Parser.string(response.body).parse
        dp_id = add_md :digiprov, extp_doc
        add_div_md_link dp_id        
      when Net::HTTPNotFound
        # XXX do nothing, no rxp data here, possibly want to write we tried
      else
        raise ServiceError, "cannot retrieve RXP provenance: #{response.code} #{response.msg}: #{response.body}"
      end    
        
    end
  
    def rxp_provenance_retrieved?
      File.exist? rxp_md_file
    end

    def retrieve_rxp_provenance!
      s_url = "#{Config::Service['provenance']}/rxp?location=#{CGI::escape @url.to_s}"    
      response = Net::HTTP.get_response URI.parse(s_url)

      case response
      when Net::HTTPSuccess
        rxp_doc = XML::Parser.string(response.body).parse
        dp_id = add_rxp_md rxp_doc
        add_div_md_link dp_id                
        
      when Net::HTTPNotFound
        # XXX do nothing, no rxp data here, possibly want to write we tried
      else
        raise ServiceError, "cannot retrieve RXP provenance: #{response.code} #{response.msg}: #{response.body}"
      end    

    end
  
    def representations_retrieved?
      md_for_event? "Representation Retrieval"    
    end
  
    def retrieve_representations!
    
      s_url = "http://localhost:7000/provenance/representations?location=#{CGI::escape to_s }"
      premis_doc = open(s_url) { |resp| XML::Parser.io(resp).parse }

      # objects
      obj_doc = XML::Document.new
      obj_doc.root = XML::Node.new 'premis'
      obj_doc.root.namespaces.namespace = premis_doc.root.namespaces.namespace

      premis_doc.find("//premis:object", NS_MAP).each do |node|
        obj_doc.root << obj_doc.import(node)
      end

      tech_id = add_md :tech, obj_doc
      add_div_md_link tech_id

      # events & agents
      dp_doc = XML::Document.new
      dp_doc.root = XML::Node.new 'premis'
      dp_doc.root.namespaces.namespace = premis_doc.root.namespaces.namespace

      premis_doc.find("//premis:event", NS_MAP).each do |node|
        dp_doc.root << dp_doc.import(node)
      end

      premis_doc.find("//premis:agent", NS_MAP).each do |node|
        dp_doc.root << dp_doc.import(node)
      end
      
      dp_doc.fix_premis_ids! self
      
      add_md :digiprov, dp_doc
    
    end
  
  end

end

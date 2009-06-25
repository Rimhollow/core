require 'namespace'

module Describe

  def described?
    type = "Format Description"

    md_for(:digiprov).any? do |doc|
      doc.find_first("//premis:event[premis:eventType[normalize-space(.)='#{type}']]", NS_MAP)
    end

  end
  
  def describe
    s_url = "http://localhost:7000/description/describe?location=#{CGI::escape to_s }"
    response = Net::HTTP.get_response URI.parse(s_url)
    
    premis_doc = case response
    when Net::HTTPSuccess
      XML::Parser.string(response.body).parse
    else
      raise ServiceError, "cannot describe file: #{response.code} #{response.msg}: #{response.body}"
    end

    # objects
    obj_doc = XML::Document.new
    obj_doc.root = XML::Node.new 'premis'
    obj_doc.root.namespaces.namespace = premis_doc.root.namespaces.namespace

    premis_doc.find("//premis:object", NS_MAP).each do |node|
      obj_doc.root << obj_doc.import(node)
    end

    add_md :tech, obj_doc

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

    add_md :digiprov, dp_doc
  end
  
  def format_known?
    
    not md_for(:tech).any? do |doc|
      doc.find_first("//premis:formatName[normalize-space(.)='unknown']", NS_MAP)
    end
    
  end
  
end
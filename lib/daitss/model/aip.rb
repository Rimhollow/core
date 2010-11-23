require "data_mapper"

require 'libxml'
require 'schematron'
require 'net/http'
require 'daitss/proc/xmlvalidation'
require 'daitss/archive'
require 'daitss/model/copy'

include LibXML
XML.default_line_numbers = true

stron_file = File.join File.dirname(__FILE__), 'aip', 'aip.stron'
stron_doc = open(stron_file) { |io| XML::Document.io io }
AIP_DESCRIPTOR_SCHEMATRON = Schematron::Schema.new stron_doc

module Daitss

  class Aip
    include DataMapper::Resource

    XML_SIZE = 2**32-1

    property :id, Serial
    property :xml, Text, :required => true, :length => XML_SIZE
    property :datafile_count, Integer, :min => 1 # uncomment after all d1 packages are migrated, :required => true

    belongs_to :package
    has 0..1, :copy # 0 if package has been withdrawn, otherwise, 1

    # @return [Boolean] true if Aip instance and associated fast access data were saved
    def save_and_populate

      self.raise_on_save_failure = true

      begin

        Aip.transaction do
          self.save
          AIPInPremis.new.process self.package, XML::Document.string(self.xml)
        end

        true
      rescue
        false
      end

    end


    # skip validation for daitss 1 package not yet migrated
    # validates_with_method :xml, :validate_against_xmlschema, :if => lambda { |t| t.datafile_count }
    # validates_with_method :xml, :validate_against_schematron

    def validate_against_xmlschema
      #doc = XML::Document.string xml
      # skip validation is this is a daitss1 package not yet migrated to daitss2
      # return true if doc.root.name == 'daitss1'

      #results = XML_SCHEMA_VALIDATOR.validate doc
      #combined_results = results[:fatals] + results[:errors]

      tf = Tempfile.new 'xmlvalidation'
      tf.write xml
      tf.flush
      rs = validate_xml tf.path
      tf.close!
      rs.reject! { |r| r[:message] =~ /(tcf|aes)\:/ }
      rs.reject! { |r| r[:message] =~ /agentNote/ }

      unless rs.empty?
        rs.each { |r| puts r[:line].to_s + ' ' + r[:message] }
        [false, "descriptor fails daitss aip xml validation (#{rs.size} errors)"]
      else
        true
      end

    end

    # SMELL ditch this
    def validate_against_schematron
      doc = XML::Document.string xml
      results = AIP_DESCRIPTOR_SCHEMATRON.validate doc
      errors = results.reject { |e| e[:rule_type] == 'report' }

      unless errors.empty?
        errors.each { |r| puts r[:line].to_s + ' ' + r[:message] }
        [false, "descriptor fails daitss aip schematron validation (#{errors.size} errors)"]
      else
        true
      end

    end

  end

end
 
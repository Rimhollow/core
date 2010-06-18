require 'db/pobject'

class Bitstream < Pobject
  include DataMapper::Resource
  property :id, String, :key => true, :length => 100
  property :size, Integer

  belongs_to :datafile # a bitstream is belong to a datafile

  has 0..n, :documents, :constraint => :destroy
  has 0..n, :texts, :constraint => :destroy
  has 0..n, :audios, :constraint => :destroy
  has 0..n, :images, :constraint => :destroy

  has n, :object_format, :constraint => :destroy # a bitstream may have 0-n file_formats

  def fromPremis(premis, formats)
    attribute_set(:id, premis.find_first("premis:objectIdentifier/premis:objectIdentifierValue", NAMESPACES).content)

    # process premis ObjectCharacteristicExtension
    node = premis.find_first("premis:objectCharacteristics/premis:objectCharacteristicsExtension", NAMESPACES)
       if (node)
         processObjectCharacteristicExtension(self, node)
         @object.datafile_id = :null
       end

    # process format information
    processFormats(self, premis, formats)
  end

  # delete this bitstream record and all its children from the database
  before :destroy do
     # delete all metadata associated with this datafile
     # texts = Text.all(:bitstream_id => @id)
     #   texts.each {|text| text.destroy}
     #   audios = Audio.all(:bitstream_id => @id)
     #   audios.each {|audio| audio.destroy}
     #   images = Image.all(:bitstream_id => @id)
     #   images.each {|image| image.destroy}
     #   docs = Document.all(:bitstream_id => @id)
     #   docs.each {|doc| doc.destroy}
   end

 after :save do
 	puts "#{self.errors.to_a} error encountered while saving #{self.inspect} " unless valid?

    # need to call valid? prior to getting the datamapper validation errors, otherwise, datamapper always return empty error
	documents.map &:valid?
	texts.map &:valid?
	audios.map &:valid?
	images.map &:valid?
	
	documents.each {|b| puts b.errors.to_a }
	texts.each {|b| puts b.errors.to_a }
	audios.each {|b| puts b.errors.to_a }
    images.each {|b| puts b.errors.to_a }

  end
end

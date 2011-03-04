module Daitss

  # define arrays used for validating controlled vocabularies
  PRIMARY = "primary"
  SECONDARY = "secondary"
  Object_Type = [PRIMARY, SECONDARY]


  class ObjectFormat
    include DataMapper::Resource
    property :id, Serial, :key => true
    property :type, String, :length => 10, :required => true # :default => :primary # indicate if this format is perceived to be
    # the primary or secondary format for this data file
    property :datafile_id, String, :length => 100, :default => :null
    property :bitstream_id, String, :length => 100, :default => :null
    property :note, String, :length => 50

    belongs_to :format # the format of the datafile or bitstream.
    #belongs_to :datafile, :required => false # The data file which may exibit the specific format
    #belongs_to :bitstream, :required => false # The data file which may exibit the specific format

    def setPrimary
      attribute_set(:type, PRIMARY)
    end

    def setSecondary
      attribute_set(:type, SECONDARY)
    end

    def check_errors
      unless valid? 
        raise "format should not be nil" if format.nil?
        raise "invalid format #{format}" unless format.valid?    
        raise "#{self.errors.to_a}, error encountered while saving #{@datafile_id}, #{@bitstream_id} " 
      end
    end
  end

end

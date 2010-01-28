class Audio
  include DataMapper::Resource
  property :id, Serial, :key => true
  property :encoding, String
    # the audio encoding scheme
  property :sampling_frequency, Float
    # the number of audio samples that are recorded per second (in Hertz, i.e. cycles per second)
  property :bit_depth, Integer # TODO positive int
    # the number of bits used each second to represent the audio signal
  property :channels, Integer # TODO positive int
    # the number of channels that are part of the audio stream
  property :duration, Integer
    # the length of the audio recording, described in seconds
  property :channel_map, String
    # channel mapping, mono, stereo, etc, TBD
    
  belongs_to :datafile, :index => true  # Audio may be associated with a Datafile, 
    # null if the audio is associated with a bitstream
  belongs_to :bitstream, :index => true  # Audio may be associated with a bitstream, 
    # null if the audio is associated with a datafile
  # TODO: need to make sure either dfid or bsid is not null.
  
  def setDFID dfid
    attribute_set(:datafile_id, dfid)
  end

  def setBFID bsid
    attribute_set(:bitstream_id, bsid)
  end
    
  def fromPremis premis
    attribute_set(:encoding, premis.find_first("aes:audioDataEncoding", NAMESPACES).content)
    attribute_set(:sampling_frequency, premis.find_first("aes:formatList/aes:formatRegion/aes:sampleRate", NAMESPACES).content)
    attribute_set(:bit_depth, premis.find_first("aes:formatList/aes:formatRegion/aes:bitDepth", NAMESPACES).content)
    attribute_set(:channels, premis.find_first("aes:face/aes:region/aes:numChannels", NAMESPACES).content)  

    # calculate the duration in number of seconds
    hours = premis.find_first("aes:face/aes:timeline/tcf:duration/tcf:hours", NAMESPACES).content
    minutes = premis.find_first("aes:face/aes:timeline/tcf:duration/tcf:minutes", NAMESPACES).content
    seconds = premis.find_first("aes:face/aes:timeline/tcf:duration/tcf:seconds", NAMESPACES).content  
    durationInS = seconds.to_i + minutes.to_i * 60 + hours.to_i * 3600
    attribute_set(:duration, durationInS)
    channelMap = premis.find_first("//@mapLocation", NAMESPACES).value 
    attribute_set(:channel_map, channelMap)
  end
  
end
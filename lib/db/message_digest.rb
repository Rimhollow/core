DIGEST_CODES = { 
  "MD5" => :md5, # MD5 message digest algorithm, 128 bits
  "SHA-1" => :sha1, # Secure Hash Algorithm 1, 160 bits    
  "CRC32" => :crc32
}
class MessageDigest
  include DataMapper::Resource
  property :id, Serial, :key => true
  # property :dfid, String, :length => 16, :key => true # :unique_index => :u1 
  property :code, Enum[:md5, :sha1, :crc32] #, :key=>true, :unique_index => :u1 
  property :value,  String, :required => true, :length => 255
  
  belongs_to :datafile #, :key => true#, :unique_index => :u1  the associated Datafile

  def fromPremis(premis)
    code = premis.find_first("premis:objectCharacteristics/premis:fixity/premis:messageDigestAlgorithm", NAMESPACES).content
    attribute_set(:code, DIGEST_CODES[code])
    attribute_set(:value, premis.find_first("premis:objectCharacteristics/premis:fixity/premis:messageDigest", NAMESPACES).content)
  end  
  
end
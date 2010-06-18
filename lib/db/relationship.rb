# the relationship table only describe derivative relationship.  Whole-part relationship is denoted
# by the has and belongs_to associations.  Describing whole-part relationship using Relationship class
# is currently restricted to 1-to-1 derivative relationship.

# note: we may need relationships among representations, ex. shapefiles may be grouped into 
# a reprensentation, and thus if the shapefiles representation is migrated to another collection 
# of files, a relationship among representation would be needed. ** further analysis is needed.

Relationship_Type = ["migrated to", "normalized to", "include", "unknown"]
Relationship_Map = { 
  "normalize" => "normalized to",
  "migrate" => "migrated_to"
}

class Relationship
  include DataMapper::Resource
  property :id, Serial, :key => true  
  property :object1, String, :index => true, :length => 100
  property :type, String, :length => 20, :required => true #:default => :unknown
  property :object2, String, :index => true, :length => 100
  property :event_id, String, :length => 100
  belongs_to :event
 
  def fromPremis(toObj, event_type, premis)
    attribute_set(:object1, premis.find_first("premis:relatedObjectIdentification/premis:relatedObjectIdentifierValue", NAMESPACES).content)
    attribute_set(:type, Relationship_Map[event_type])
    attribute_set(:object2, toObj)
    attribute_set(:event_id, premis.find_first("premis:relatedEventIdentification/premis:relatedEventIdentifierValue", NAMESPACES).content)
  end
end




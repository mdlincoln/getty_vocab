require "mongo"
require "json"

AAT = Mongo::MongoClient.new["getty"]["aat_triples"]
OUTPUT_PATH = "process/aat-hierarchy.json"
ROOT = "http://vocab.getty.edu/aat/300010358" # "Material"

# Useful URIs
GETTY_PREF_LABEL = "http://vocab.getty.edu/ontology#prefLabelGVP"
GETTY_LABEL_LITERAL = "http://vocab.getty.edu/ontology#term"
SKOS_NARROWER = "http://www.w3.org/2004/02/skos/core#narrower"

# Get the literal name of a Getty term
def get_label(object_uri)
	label_triple = AAT.find_one({
		"subject.value" => object_uri,
		"predicate.value" => GETTY_PREF_LABEL
		})["object"]["value"]
	literal_label = AAT.find_one({
		"subject.value" => label_triple,
		"predicate.value" => GETTY_LABEL_LITERAL
		})["object"]["value"]
	return literal_label
end

# Recursive method to find narrower
def get_children(parent,array)
	children = AAT.find({
		"subject.value" => parent,
		"predicate.value" => SKOS_NARROWER
		})

	# Return nil if no children
	if children.count == 0
		return array
	else
		children.each do |child|
			array << get_hash(child)
		end
		return array
	end
end

def get_hash(object_uri)
	label = get_label(object_uri)
	puts "#{label}, getting children"
	children_array = get_children(object_uri,[])
	if children_array.count == 0
		object_hash = {
			:name => label,
		}
	else
		object_hash = {
			:name => label,
			:children => children_array
		}
	end
	return object_hash
end

puts "Starting from #{ROOT}"
aat_hash = get_hash(ROOT)
print "Writing JSON..."
File.open(OUTPUT_PATH,"w") do |f|
	f.write(aat_hash.to_json)
end
puts "done."

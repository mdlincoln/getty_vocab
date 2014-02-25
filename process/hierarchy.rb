#######
#
# Create a hierarchical JSON file from a given AAT root
#
#######

require "mongo"
require "json"

AAT = Mongo::MongoClient.new["getty"]["aat_triples"]
puts "Creating subject/predicate compound index. This may take a while..."
AAT.ensure_index([
	["s",Mongo::ASCENDING],
	["p",Mongo::ASCENDING]
	])

# Useful URIs
BASE_URL = "http://vocab.getty.edu/aat/"
GETTY_PREF_LABEL = "http://vocab.getty.edu/ontology#prefLabelGVP"
GETTY_LABEL_LITERAL = "http://www.w3.org/2008/05/skos-xl#literalForm"
GETTY_NARROWER = "http://vocab.getty.edu/ontology#narrower"

$names = []

# Get the literal name of a Getty term
def get_label(object_uri)
	label_triple = AAT.find_one({
		"s" => object_uri,
		"p" => GETTY_PREF_LABEL
		})["o"]
	literal_label = AAT.find_one({
		"s" => label_triple,
		"p" => GETTY_LABEL_LITERAL
		})["o"]
	return literal_label
end

# Recursive method to find narrower
def get_children(parent,array)
	children = AAT.find({
		"s" => parent,
		"p" => GETTY_NARROWER
		})

	# Return nil if no children
	if children.count == 0
		return array
	else
		children.each do |child|
			child_uri = child["o"]
			# Avoid recursion loop by checking if object_uri has already been called
			if $names.include?(child_uri)
				return array
			else
				array << get_hash(child_uri)
			end
		end
		return array
	end
end

def get_hash(object_uri)
	$names << object_uri
	label = get_label(object_uri)
	puts "#{label}, getting children"
	children_array = get_children(object_uri,[])
	# If a given node has no children, only add its label to the hash
	if children_array.count == 0
		object_hash = {
			:name => label,
		}
	# If a given node has children, add them to an array
	else
		object_hash = {
			:name => label,
			:children => children_array
		}
	end
	return object_hash
end

def get_tree(root)
	puts "Starting from #{root}"
	return get_hash("#{BASE_URL}#{root}")
end

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
	["subject.value",Mongo::ASCENDING],
	["predicate.value",Mongo::ASCENDING]
	])

# Useful URIs
BASE_URL = "http://vocab.getty.edu/aat/"
GETTY_PREF_LABEL = "http://vocab.getty.edu/ontology#prefLabelGVP"
GETTY_LABEL_LITERAL = "http://www.w3.org/2008/05/skos-xl#literalForm"
GETTY_NARROWER = "http://vocab.getty.edu/ontology#narrower"

$names = []
ERROR_LOG_PATH = "import/error_log.txt"

# Helper method for writing erros
def log_error(string)
	line = "#{Time.now}: #{string}"
	File.open(ERROR_LOG_PATH, "a") { |f| f.puts line }
end

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
		"predicate.value" => GETTY_NARROWER
		})

	# Return nil if no children
	if children.count == 0
		return array
	else
		children.each do |child|
			child_uri = child["object"]["value"]
			# Avoid recursion loop by checking if object_uri has already been called
			if $names.include?(child_uri)
				log_error("At #{parent}; child #{child['object']['value']} has already been assigned")
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

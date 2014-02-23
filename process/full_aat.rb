require "JSON"
load "process/hierarchy.rb"

OUTPUT_PATH = "process/aat-hierarchy.json"
GETTY_NODES = {
	300264086 => "Associated Concepts Facet",
	300264087 => "Physical Attributes Facet",
	300264088 => "Styles and Periods Facet",
	300264089 => "Agents Facet",
	300264090 => "Activities Facet",
	300264091 => "Materials Facet",
	300264092 => "Objects Facet",
	300343372 => "Brand Names (Facet)"
}

full_aat = {
	:name => "AAT",
	:children => []
}

GETTY_NODES.each do |k,v|
	full_aat[:children] << get_tree(k)
end

print "Writing JSON..."
File.open(OUTPUT_PATH,"w") do |f|
	f.write(JSON.pretty_generate(full_aat))
end

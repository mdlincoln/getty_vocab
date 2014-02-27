#######
#
# Script for importing AAT NT dump (found at 
# http://vocab.getty.edu/) to MongoDB
#
#######


require "mongo"
require "ruby-progressbar"
require "rdf"

# Helper method for determining RDF statement type
module RDF::Value
	def is_type
		if self.uri?
			return :uri
		elsif self.literal?
			return :literal
		else
			return :resource
		end
	end
end

class RDF::Statement
	def literal_hash()
		return {
			:s => self.subject.to_s,
			:st => self.subject.is_type,
			:p => self.predicate.to_s,
			:pt => self.predicate.is_type,
			:o => self.object.to_s,
			:ot => self.object.is_type
		}
	end
end

DUMP_PATH = "full/"
FILES = Dir.glob("#{DUMP_PATH}*.nt")
database = Mongo::MongoClient.new["getty"]["aat_triples"]
SIZE = `wc -l #{DUMP_PATH}*.nt`.split("\n").last.split.first.to_i

prog_bar = ProgressBar.create(:title => "Records imported", :starting_at => 0, :total => SIZE, :format => '%c |%b>>%i| %p%% %e')	# => Create a progress bar

FILES.each do |file|
RDF::NTriples::Reader.open(file) do |reader|
	reader.each_statement do |statement|
		database.insert(statement.literal_hash)
		prog_bar.increment
	end
end
end

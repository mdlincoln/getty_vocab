require "mongo"
require "ruby-progressbar"
require "rdf"

module RDF::Value
	def is_type
		if self.uri?
			return "uri"
		elsif self.literal?
			return "literal"
		else
			return "resource"
		end
	end
end

FILE = "AATOut_Full.nt"
SIZE = 11613807
database = Mongo::MongoClient.new["getty"]["aat_triples"]

prog_bar = ProgressBar.create(:title => "Records imported", :starting_at => 0, :total => SIZE, :format => '%c |%b>>%i| %p%% %e')	# => Create a progress bar


RDF::NTriples::Reader.open(FILE) do |reader|
	reader.each_statement do |statement|
		object = {
				:subject => { :value => statement.subject.to_s, :type => statement.subject.is_type },
				:predicate => { :value => statement.predicate.to_s, :type => statement.predicate.is_type},
				:object => { :value => statement.object.to_s, :type => statement.object.is_type },
			}
		database.insert(object)
		prog_bar.increment
	end
end

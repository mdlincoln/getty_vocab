getty_vocab
============

Tools for storing facets of the Getty's LOD vocabularies in MongoDB.

`import/aat.rb` imports RDF statements from the [full RDF dump](http://vocab.getty.edu/dataset/aat/full.zip) supplied by the Getty.

`process/full_aat.rb` recursively queries the statement database to produce a JSON representation of nodes and their children.
See [this blog post](http://matthewlincoln.net/projects/aat-dendrogram.html) for one visualization using these data.

****
[Matthew Lincoln](http://matthewlincoln.net) | University of Maryland, College Park

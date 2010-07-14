$:.unshift File.dirname(__FILE__) + "/../lib/"

require 'rdf'
require 'rdf/spec/repository'
require 'rdf/4store'

describe RDF::FourStore::Repository do
  context "4store" do
    before :each do
      @repository = RDF::FourStore::Repository.new('http://localhost:10008')
    end
   
    after :each do
      @repository.clear
    end

    # @see lib/rdf/spec/repository.rb in RDF-spec
    it_should_behave_like RDF_Repository
  end

end


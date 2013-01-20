$:.unshift File.dirname(__FILE__) + "/../lib/"

require 'rdf'
require 'rdf/spec/repository'
require 'rdf/4store'

describe RDF::FourStore::Repository do
  before :each do
    @repository = RDF::FourStore::Repository.new('http://localhost:10008')
  end

  after :each do
    @repository.clear
  end

  include RDF_Repository
end


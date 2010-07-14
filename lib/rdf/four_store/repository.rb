require 'net/http'
require 'uri'
require 'open-uri'
require 'enumerator'
require 'rdf'
require 'sparql/client'
require 'nokogiri'

module RDF::FourStore

  ##
  # RDF::Repository backend for 4store
  #
  # @see http://4store.org
  # @see 
  class Repository < ::SPARQL::Client::Repository

    attr_reader :endpointURI, :dataURI, :updateURI, :statusURI, :sizeURI

    DEFAULT_CONTEXT = "local:".freeze

    ##
    # Constructor of RDF::FourStore::Repository
    #
    # @param [String] uri
    # @param [Hash] options
    # @return [RDF::FourStore::Repository]
    # @example
    #    RDF::FourStore::Respository.new('http://localhost:8080')
    #
    def initialize(uri_or_options = {})
      case uri_or_options
      when String
        @options = {}
        @uri = uri_or_options.to_s
      when Hash
        @options = uri_or_options.dup
        @uri = @options.delete([:uri])
      else
        raise ArgumentError, "expected String or Hash, but got #{uri_or_options.inspect}"
      end
      @uri.sub!(/\/$/, '')
      @endpointURI = @uri + "/sparql/"
      @dataURI = @uri + "/data/"
      @updateURI = @uri + "/update/"
      @statusURI = @uri + "/status/"
      @sizeURI = @statusURI + "size/"

      super(@endpointURI, options)
    end

    ##
    # Returns the number of statements in this repository.
    # @see RDF::Repository#count
    # @return [Integer]
    def count
      c = 0
      doc = Nokogiri::HTML(open(@sizeURI))
      doc.search('tr').each do |tr|
        td = tr.search('td')
        c = td[0].content if td[0]
      end
      c.to_i # the last one is the total number
    end
    alias_method :size, :count
    alias_method :length, :count

    ##
    # @private
    # @see RDF::Enumerable#has_triple?
    def has_triple?(triple)
      has_statement?(RDF::Statement.from(triple))
    end

    ##
    # @private
    # @see RDF::Enumerable#has_quad?
    def has_quad?(quad)
      has_statement?(RDF::Statement.new(quad[0], quad[1], quad[2], :context => quad[3]))
    end

    ##
    # @private
    # @see RDF::Enumerable#has_statement?
    def has_statement?(statement)
      context = statement.context || DEFAULT_CONTEXT
      dump = dump_statement(statement)
      @client.query("ASK { GRAPH <#{context}> { #{dump} } } ")
    end


    ##
    # @see RDF::Mutable#insert_statement
    # @private
    def insert_statement(statement)
      #TODO: save the given RDF::Statement.  Don't save duplicates.
      #
      #unless has_statement?(statement)
        dump = dump_statement(statement)
        post_data(dump, statement.context)
      #end
    end

    ##
    # @see RDF::Mutable#delete_statement
    # @private
    def delete_statement(statement)
      if has_statement?(statement)
        context = statement.context || DEFAULT_CONTEXT
        dump = dump_statement(statement)
        q = "DELETE DATA { GRAPH <#{context}> { #{dump} } }"
        post_update(q, context)
      end
    end

    ##
    # @private
    # @see RDF::Mutable#clear
    def clear_statements
      q = "SELECT ?g WHERE { GRAPH ?g { ?s ?p ?o . } FILTER (?g != <#{DEFAULT_CONTEXT}>) }"
      @client.query(q).each do |solution|
        post_update("CLEAR GRAPH <#{solution[:g]}>") 
      end
      post_update("CLEAR GRAPH <#{DEFAULT_CONTEXT}>") 
    end

    ##
    # Queries `self` for RDF statements matching the given `pattern`.
    #
    # @param  [Query, Statement, Array(Value), Hash] pattern
    # @yield  [statement]
    # @yieldparam [Statement]
    # @return [Enumerable<Statement>]
    def query(pattern, &block)
      case pattern
      when RDF::Statement
        h = {}
        h[:subject] = pattern.subject || :s
        h[:predicate] = pattern.predicate || :p
        h[:object] = pattern.object || :o
        h[:context] = pattern.context
        super(RDF::Query::Pattern.new(h), &block)
      when Hash
        pattern[:subject] ||= :s
        pattern[:predicate] ||= :p
        pattern[:object] ||= :o
        super(RDF::Query::Pattern.new(pattern), &block)
      else
        super(pattern, &block)
      end
    end

    def query_pattern(pattern, &block)
      context = pattern.context || DEFAULT_CONTEXT
      str = pattern.to_s
      q = "CONSTRUCT { #{str} } WHERE { GRAPH <#{context}> { #{str} } } "
      result = @client.query(q)
      if block_given?
        result.each_statement(&block)
      else
        result
      end
    end

    def dump_statement(statement)
      dump_statements([statement])
    end
    
    def dump_statements(statements)
      graph = RDF::Graph.new
      graph.insert_statements(statements)
      RDF::Writer.for(:ntriples).dump(graph)
    end
 
    def post_data(content, context = nil)
      context ||= DEFAULT_CONTEXT
      uri = URI.parse(@dataURI)

      req = Net::HTTP::Post.new(uri.path)
      req.form_data = {
        'data' => content,
        'graph' => context,
        'mime-type' => 'application/x-turtle'
      }

      Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req)
      end
    end

    def post_update(content, context = nil)
      context ||= DEFAULT_CONTEXT
      uri = URI.parse(@updateURI)

      req = Net::HTTP::Post.new(uri.path)
      req.form_data = {
        'update' => content,
        'graph' => context,
        'content-type' => 'triples',
      }

      Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req)
      end
    end

    ## 
    # @private
    # @see RDF::Writable#writable?
    # @return [Boolean]
    def writable?
      true
    end

    ## 
    # @private
    # @see RDF::Durable#durable?
    # @return [Boolean]
    def durable?
      true
    end
    
    ## 
    # @private
    # @see RDF::Countable#empty?
    # @return [Boolean]
    def empty?
      count.zero?
    end

  end
end

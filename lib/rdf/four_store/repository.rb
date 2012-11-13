require 'sparql/client'
require 'rdf/four_store/client'
require 'rdf/four_store/query'

module RDF
  module FourStore
    ##
    # RDF::Repository backend for 4store
    #
    # @see http://4store.org
    # @see
    class Repository < ::SPARQL::Client::Repository

      DEFAULT_CONTEXT = "default:".freeze

      def initialize endpoint, options = {}
        @options = options.dup
        @client = Client.new endpoint, options
      end

      ##
      # Loads RDF statements from the given file or URL into `self`.
      #
      # @see RDF::Mutable#load
      # @param  [String, #to_s]          filename
      # @param  [Hash{Symbol => Object}] options
      # @return [void]
      def load filename, options = {}
        @client.load filename, options
      end

      alias_method :load!, :load

      ##
      # Returns the number of statements in this repository.
      #
      # @return [Integer]
      # @see    RDF::Repository#count?
      def count
        binding = client.query("SELECT (COUNT(*) AS ?no) { ?s ?p ?o  }").first.to_hash
        binding[binding.keys.first].value.to_i
      end

      alias_method :size, :count

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
        context = statement.context
        dump = dump_statement(statement)
        if context
          @client.query("ASK { GRAPH <#{context}> { #{dump} } } ")
        else
          @client.query("ASK { #{dump} } ")
        end
      end

      ##
      # @see RDF::Mutable#insert_statement
      # @private
      def insert_statement(statement)
        unless has_statement?(statement)
          dump = dump_statement(statement)
          @client.add(dump, statement.context || DEFAULT_CONTEXT)
        end
      end

      ##
      # @see RDF::Mutable#delete_statement
      # @private
      def delete_statement(statement)
        if has_statement?(statement)
          context = statement.context || DEFAULT_CONTEXT
          dump = dump_statement(statement)
          q = "DELETE DATA { GRAPH <#{context}> { #{dump} } }"
          @client.set(q, context)
        end
      end

      ##
      # @private
      # @see RDF::Mutable#clear
      def clear_statements
        q = "SELECT ?g WHERE { GRAPH ?g { ?s ?p ?o . } FILTER (?g != <#{DEFAULT_CONTEXT}>) }"
        @client.query(q).each do |solution|
          @client.set("CLEAR GRAPH <#{solution[:g]}>", DEFAULT_CONTEXT) 
        end
        @client.set("CLEAR GRAPH <#{DEFAULT_CONTEXT}>", DEFAULT_CONTEXT) 
      end

      ##
      # Makes a RDF string from a RDF Statement
      #
      # @param [RDF::Statement] statement
      # @return [String]
      def dump_statement(statement)
        dump_statements([statement])
      end

      ##
      # Makes a RDF string from RDF Statements
      # Blank nodes are quoted to be used as constants in queries
      #
      # @param [Array(RDF::Statement)] statements
      # @return [String]
      # @see http://4store.org/presentations/bbc-2009-09-21/slides.html#(38)
      def dump_statements(statements)
        graph = RDF::Graph.new
        graph.insert_statements(statements)
        dump = RDF::Writer.for(:ntriples).dump(graph)
        dump.gsub(/(_:\w+?) /, "<#{DEFAULT_CONTEXT}\\1> ")
      end

      def supports?(feature)
        case feature.to_sym
          when :context   then true   # statement contexts / named graphs
          when :inference then false  # forward-chaining inference
          else false
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
end

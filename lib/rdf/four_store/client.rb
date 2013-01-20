module RDF
  module FourStore
    class Client < ::SPARQL::Client

      def sparql_uri
        "/sparql/"
      end

      def data_uri
        "/data/"
      end

      def update_uri
        "/update/"
      end

      def status_uri
        "/status/"
      end

      def request query, headers = {}, &block
        request = Net::HTTP::Post.new sparql_uri, @headers.merge(headers)
        request.set_form_data({
          'query' => query.to_s,
          'soft-limit' => @options[:softlimit].nil? ? nil : @options[:softlimit]
        })
        handle_response request, &block
      end

      def add content, context
        raise ArgumentError, "Context required" if context.nil?
        request = Net::HTTP::Post.new data_uri
        request.set_form_data({
          'data' => content,
          'graph' => context,
          'mime-type' => 'application/x-turtle'
        })
        handle_response request
      end

      def set query, context
        raise ArgumentError, "Context required" if context.nil?
        request = Net::HTTP::Post.new update_uri
        request.set_form_data({
          'update' => query,
          'graph' => context,
          'mime-type' => 'application/x-turtle'
        })
        handle_response request
      end

      def load filename, options = {}
        if options[:context]
          uri = data_uri + options[:context]
        else
          uri = data_uri + 'file://' + File.expand_path(filename)
        end
        content = open(filename).read
        request = Net::HTTP::Put.new uri
        request.body = content
        request.content_type = 'multipart/form-data'
        handle_response request
      end

      protected

      def handle_response request, &block
        response = @http.request @url, request
        if block_given?
          block.call response
        else
          response
        end
      end
    end
  end
end

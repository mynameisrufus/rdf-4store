# 4store Storage Adapter for RDF.rb

This is an [RDF.rb][] storage adapter that allows you to use the [4store][] RDF Database.

See <http://blog.datagraph.org/2010/04/rdf-repository-howto> for an overview.

## Status

This is still in alpha status, don't use in production environment.

## Requirements

This plugin depends on the unsafe mode of 4s-httpd. 

    $ 4s-backend demo
    $ 4s-httpd -U -s -1 demo

## Resources

 * <http://rdf.rubyforge.org> - RDF.rb's home page
 * <http://rdf.rubyforge.org/RDF/Repository.html> - RDF.rb's Repository documentation
 * <http://4store.org> - 4store's home page
 * <http://github.com/fumi/rdf-4store>

### Support

Please post questions or feedback to the [W3C-ruby-rdf mailing list][].

### Author

 * Fumihiro Kato <fumi@fumi.me> | <http://github.com/fumi> | <http://fumi.me>

### 'License'

This is free and unemcumbered software released into the public domain.  For
more information, see the accompanying UNLICENSE file.

If you're unfamiliar with public domain, that means it's perfectly fine to
start with this skeleton and code away, later relicensing as you see fit.

[RDF.rb]: http://rdf.rubyforge.org/
[4store]: http://4store.org/
[W3C-ruby-rdf mailing list]:        http://lists.w3.org/Archives/Public/public-rdf-ruby/

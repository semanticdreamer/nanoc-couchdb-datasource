# encoding: utf-8

module Nanoc::DataSources

  # Provides functionality to load pages from CouchDB data source.
  class Couchdb < Nanoc::DataSource
    
    identifier :couchdb
    
    attr_accessor :db
    
    # See {Nanoc::DataSource#up}.
    def up
    end

    # See {Nanoc::DataSource#down}.
    def down
    end
     
    # See {Nanoc::DataSource#setup}.
    def setup
    end
    
    # See {Nanoc::DataSource#items}.
    def items
      load_documents()
    end
    
    # See {Nanoc::DataSource#create_item}.
    def create_item(content, attributes, identifier, params={})
      # not_implemented('create_item')
      create_object(content, attributes, identifier, params)
    end
    
    private

      # Creates a new item (document) in the CouchDB according to
      # the given identifier. The file will have its attributes taken from the
      # attributes hash argument and its content from the content argument.
      def create_object(content, attributes, identifier, params={})
        
        # Check whether item is unique
        item = @db.get(identifier) rescue nil
        if !item.nil?
          $stderr.puts "An item already exists at #{identifier}. Please " +
                       "pick a unique name for the item you are creating."
          exit 1    
        end
        
        @db.save_doc({
          '_id' => sanitize_to_filename(identifier),
          :body => content.strip
        }.merge(attributes))
      end
      
      def load_documents()
        @item ||= begin
      
          require 'rubygems'
          require 'couchrest'
      
          # Check configuration
          if self.config[:couch].nil?
            raise RuntimeError, "CouchDB data source requires a server url in the data source configuration."
          end
          if self.config[:db].nil?
            raise RuntimeError, "CouchDB data source requires a db name in the data source configuration."
          end
      
          # Get field names
          title_field = self.config[:fields][:item_title] || 'title'
          name_field = self.config[:fields][:item_name] || 'name'
          content_field = self.config[:fields][:item_content] || 'body'
          type_field = self.config[:fields][:item_type] || 'type'
          
          # Get views (map/ reduce)
          all_items_map = self.config[:views][:all_items][:map] || 'function(doc) {emit(doc._id, doc);}'
          
          all_items = {
            :map => all_items_map
          }
      
          # Connect to CouchDB
          couch = CouchRest.new(URI.escape(self.config[:couch]))
          @db = couch.database(URI.escape(self.config[:db]))
          
          @db.delete_doc @db.get('_design/nanoc') rescue nil
          
          @db.save_doc({
            '_id' => '_design/nanoc',
            :views => {
              :items => all_items
            }
          })
          
          #docs = db.all_docs({'include_docs' => true})
          docs = @db.view('nanoc/items', {})
                  
          # Convert to items
          docs['rows'].enum_with_index.map do |row, i|
                                
            content = row['value'][content_field]
            # attributes = {
            #   :title       => row['value'][title_field],
            #   :filename    => row['value'][name_field]
            # }
            attributes = row['value']
            identifier = sanitize_to_filename("#{row['value']['_id']}")
            mtime = nil
      
            # Build item
            Nanoc::Item.new(content, attributes, identifier, mtime)
          end
        end
      end

      # make document title safe for a filesystem
      def sanitize_to_filename(doc_title)
        doc_title.gsub(/[^\w\s_-]+/, '').
          gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2').
          gsub(/\s/, '_').downcase
      end
    
      def not_implemented(name)
        raise NotImplementedError.new(
          "#{self.class} does not implement ##{name}"
        )
      end
    
  end

end

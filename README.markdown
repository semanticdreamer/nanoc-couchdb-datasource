# CouchDB Data Source for the Ruby web publishing system nanoc

A `Nanoc::DataSource` for loading site data items from a [CouchDB][couchdb] server.

## Features

- Creates a new item (document) in the CouchDB according to the given identifier:

  `nanoc create_item identifier`

- Loads documents from a CouchDB, creating nanoc items (with attributes).

- Configuration options (in site's `config.yaml`):

  - The Url of the CouchDB server.

  - The CouchDB database name.

  - Mapping of CouchDB document field names to default nanoc item attributes: `title`, `body`

  - Allow for custom nanoc identifier by providing document field `identifier`, defaults to document `_id`. 

  - Views used for querying the CouchDB documents.

##  RubyGems Dependencies

- [CouchRest][couchrest], a RESTful CouchDB client based on Heroku's RestClient and Couch.js:
  
    `sudo gem install couchrest`

## Usage

Copy the file `lib/couchdb.rb` into your site's `lib` folder.

## Configuration

Example configuration for section `data_sources` in site's `config.yaml`:

    data_sources:
      -
        # A data source for loading site data items from CouchDB server.
        type: couchdb
        config:
          # The url of the CouchDB server.
          couch: 'http://admin:admin@127.0.0.1:5984/'
          # The CouchDB database name.
          db: 'example_com_prelive'
          # Mapping of CouchDB document field names to nanoc item attributes.
          fields:
            item_title: 'title'
            item_content: 'body'
          # Views used for querying the CouchDB documents.
          views:
            all_items:
              map: >
                function(doc) {
                  // if (doc.type == "page") {
                    emit(doc._id, doc);
                  // }
                }
    

[couchdb]: http://couchdb.org "CouchDB"
[nanoc]: http://nanoc.stoneship.org/ "nanoc"
[couchrest]: https://github.com/couchrest/couchrest "CouchRest"
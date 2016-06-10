# Utilisation de Bitly

Bitly sert à faire des petits liens à partir des grandes url, il est utilisé notamment par Twitter.

Voici un script type qui permet de produire de façon récurrente des adresses bitly en les enregistrant dans une table. Il s'agit des citations.

~~~ruby

# Requérir les deux librairies pour la base et bitly
require 'sqlite3'
require 'bitly'
dbpath = '/Users/philippeperret/Sites/WriterToolbox/database/data/site_cold.db'

# Les méthodes pour configurer Bitly
def configure_bitly
  Bitly.use_api_version_3
  Bitly.configure do |config|
    config.api_version  = 3
    config.access_token = configuration_data[:generic_access_token]
  end
end
def configuration_data
  @configuration_data ||= begin
    require '/Users/philippeperret/Sites/WriterToolbox/data/secret/data_bitly.rb'
    DATA_BITLY
  end
end

begin
  configure_bitly
  db = SQLite3::Database.new(dbpath)
  db.execute('SELECT id FROM citations').each do |acitation|
    cit = acitation[0]
    puts "Citation ##{cit}"
    long_url = "http://www.laboiteaoutilsdelauteur.fr/citation/#{cit}/show"
    bitly = Bitly.client.shorten(long_url)
    puts "New bitly ? #{bitly.new_hash? ? 'OUI' : 'NON' }"
    puts "-> #{bitly.short_url}"
    if bitly.new_hash?
      db.execute("UPDATE citations SET bitly = ? WHERE id = ?", [bitly.short_url, cit])
    end
  end
  db.close; db = nil
rescue Exception => e
  puts "# ERREUR : #{e.message}"
  puts e.backtrace.join("\n")
ensure
  db.close if db
end
~~~

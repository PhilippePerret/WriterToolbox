# Utilisation de Bitly

Bitly sert à faire des petits liens à partir des grandes url, il est utilisé notamment par Twitter.

Voici un script type qui permet de produire de façon récurrente des adresses bitly en les enregistrant dans une table. Il s'agit des citations.

À REFAIRE AVEC MYSQL

~~~ruby

# Requérir les deux librairies pour la base et bitly
require 'bitly'

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
end
~~~

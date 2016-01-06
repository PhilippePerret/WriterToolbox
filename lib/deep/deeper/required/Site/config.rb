# encoding: UTF-8
=begin
Méthodes qui gèrent la configuration du site
=end
class SiteHtml

  # ---------------------------------------------------------------------
  #   Propriétés configurables
  #  ---------------------------------------------------------------------

  # Désignation officielle du site, pour les factures et mails
  # officiels
  attr_accessor :official_designation

  # HOST local et distant qui permettront de déterminer les propriétés
  # méthodes `local_url` et `distant_url`
  # {String} Host Local (par exemple 'localhost/AlwaysData/Icare_AD')
  attr_accessor :local_host
  # {String} Host Distant (p.e. 'www.atelier-icare.net')
  attr_accessor :distant_host

  # Prix de l'abonnement au site, s'il est unique
  attr_accessor :tarif

  # ---------------------------------------------------------------------
  #   Méthode de chargement des configurations
  # ---------------------------------------------------------------------
  def require_config
    config_file.require if config_file.exist?
  end
  def config_file
    @path_config_file ||= begin
      site.folder_objet + 'site/config.rb'
    end
  end
end

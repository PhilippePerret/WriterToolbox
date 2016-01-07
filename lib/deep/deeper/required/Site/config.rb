# encoding: UTF-8
=begin
Méthodes qui gèrent la configuration du site
=end
class SiteHtml

  # ---------------------------------------------------------------------
  #   Propriétés configurables
  #  ---------------------------------------------------------------------

  # Nom du site (ou son titre) pour affichage
  # Note : le "title", affiché dans la page, sera calculé selon
  # ce nom, capitalisé
  attr_accessor :name

  # Désignation officielle du site, pour les factures et mails
  # officiels
  attr_accessor :official_designation

  # Mail de l'administrateur du site.
  # Définir `site.mail = "adresse@chez.moi"` dans le fichier de
  # configuration
  attr_accessor :mail

  # À ajouter au sujet du mail
  attr_accessor :mail_before_subject
  # La signature de tous les mails (au format HTML)
  attr_accessor :mail_signature

  # HOST local et distant qui permettront de déterminer les propriétés
  # méthodes `local_url` et `distant_url`
  # {String} Host Local (par exemple 'localhost/AlwaysData/Icare_AD')
  attr_accessor :local_host
  # {String} Host Distant (p.e. 'www.atelier-icare.net')
  attr_accessor :distant_host

  # Prix de l'abonnement au site, s'il est unique
  attr_accessor :tarif

  # Séparateur des unités avec les décimales, particulièrement
  # dans un tarif
  def separateur_decimal; @separateur_decimal ||= "," end
  def separateur_decimal= value
    @separateur_decimal = value
    ::Float::separateur_decimal= value
  end

  # Devise de la monnaie
  # def devise; self.devise || "€" end
  def devise; @devise ||= "€" end
  def devise= value
    @devise = value
    ::Float::devise= value
  end

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

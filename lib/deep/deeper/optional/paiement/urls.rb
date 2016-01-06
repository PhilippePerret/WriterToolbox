# encoding: UTF-8
=begin

Méthodes-propriétés pour les URL

=end
class SiteHtml
  class Paiement
    class << self

      # URL de l'adresse de retour quand OK, c'est-à-dire quand
      # l'user a payé le module.
      # Noter que `base_url` ci-dessous est la base_url du paiement,
      # qui dépend de sandbox? ou pas sandbox?, pas le base_url du site
      # qui dépend de ONLINE ou OFFLINE.
      def url_retour_ok
        @url_retour_ok ||= "#{base_url}?pres=1"
      end
      def url_retour_cancel
        @url_retour_cancel ||= "#{base_url}?pres=0"
      end

      def base_url
        @base_url ||= ( sandbox? ? local_url : distant_url )
      end

      # Adresse locale pour le paiement (sandbox)
      def local_url
        @local_url ||= "#{site.local_url}/user/paiement"
      end
      # URL distant pour le paiement (non sandbox)
      def distant_url
        @distant_url ||= "#{site.distant_url}/user/paiement"
      end


    end # / self
  end # /Paiement
end # /SiteHtml

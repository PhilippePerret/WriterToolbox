# encoding: UTF-8
class SiteHtml

  # Le paiement courant
  # @usage : site.paiement.<méthode>
  def paiement
    @paiement ||= Paiement::new
  end

  class Paiement
    class << self

      # Pour savoir si c'est un test ou en live
      # TODO À DÉFINIR
      def sandbox?
        true
      end

      # Table dans la base de données users
      def table_paiements
        @table_paiements ||= site.db.create_table_if_needed('users', 'paiements')
      end

      # Les données Paypal
      # ------------------
      # C'est un fichier qui doit se trouver dans un dossier
      # secret, sauf indication contraire.
      # Note : après avoir utilisé `data` une première fois,
      # on peut aussi utiliser PAYPAL dans le programme.
      def data
        @data ||= begin
          path_data_file.require
          PAYPAL
        end
      end
      def path_data_file
        @path_data_file ||= ( site.folder_data_secret + 'paypal.rb')
      end
    end # << self Paiement
  end # /Paiement
end # /SiteHtml

# Pour forcer le chargement des données
SiteHtml::Paiement::data

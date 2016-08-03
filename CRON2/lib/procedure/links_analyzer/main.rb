# encoding: UTF-8
=begin

  Module du LINKS ANALYZER
  Une fois par jour, à 1 heure du matin, on lance l'analyseur de liens
  qui va vérifier toutes les pages et renvoyer les erreurs s'il y en a

=end
class CRON2

  # Méthode principale appelée par le cron
  def links_analyzer
    if Time.now.hour == 11
      LinksAnalyzer.new.check
    end
  end

  class LinksAnalyzer
    include MethodesProcedure

    def check
      log "*** Vérification de tous les liens/pages"

      # Il faut détruire le rapport qui peut exister
      File.exist?(rapport_path) && File.unlink(rapport_path)

      resultat = `cd #{module_folder}; ruby main.rb -o 2>&1`
      log "Retour de LINKS ANALYZER : #{resultat.inspect}"

      File.exist?(rapport_path) || raise('Le rapport n’a pas été produit…')


      site.send_mail_to_admin(
        subject: 'Rapport de LINKS ANALYZER',
        message: code_rapport
      )

      log "=== Vérification de tous les liens/pages opérée avec succès"
      superlog 'Vérification des liens et pages OK (Links Analyzer)'
      # TODO Ajouter la ligne d'historique
    rescue Exception => e
      superlog( "ERREUR AU COURS DE L'ANALYSE DES LIENS/PAGES : #{e.message}", error: true)
    end

    def code_rapport
      @code_rapport ||= begin
        File.open(rapport_path, 'rb'){|f| f.read.force_encoding('utf-8')}
      end
    end
    def rapport_path
      @rapport_path ||= File.join(module_folder, 'output', 'report_ONLINE.html')
    end
    def module_folder
      @module_folder ||= './lib/deep/deeper/module/links_analyse'
    end
  end #/LinksAnalyzer
end #/CRON2

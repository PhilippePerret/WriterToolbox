# encoding: UTF-8
#
# Module-procédure qui requiert tout le site pour pouvoir utiliser
# tous les outils.
#
class CRON2

    # Cette méthode se charge juste de tout charger en une ligne...
    def require_all_site

        require './lib/required'

        # On aura toujours besoin des mails
        site.require_module 'mail'

    end

end#/CRON2

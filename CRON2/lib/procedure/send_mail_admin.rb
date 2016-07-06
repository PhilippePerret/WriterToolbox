# encoding: UTF-8
#
# Envoi du mail final à l'administrateur, s'il le faut vraiment.

class CRON2

    SEND_MAIL = true

    # La méthode principale qui envoie le mail final à l'administrateur
    # si c'est nécessaire, c'est-à-dire si la constante SEND_MAIL est à
    # true et/ou qu'il s'est produit des erreurs au cours du cron
    def send_mail_admin
    end
end

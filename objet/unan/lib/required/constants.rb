# encoding: UTF-8
=begin

Quelques constantes utiles

=end

# Le rythme moyen par défaut pour suivre le programme. C'est à ce
# rythme qu'on met 1 an pour développer son script
RYTHME_STANDARD = 5

# Le nombre de jours d'une année virtuelle
# Lorsqu'on divise ce nombre par le rythme, on obtient 365, le nombre
# de jours d'une année réelle.
DUREE_ANNEE_VIRTUELLE   = 365 * RYTHME_STANDARD
DUREE_SEMAINE_VIRTUELLE = DUREE_ANNEE_VIRTUELLE / 7

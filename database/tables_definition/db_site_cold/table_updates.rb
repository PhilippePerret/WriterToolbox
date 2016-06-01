# encoding: UTF-8
=begin
  Table pour les updates

=end
def schema_table_site_cold_updates
  @schema_table_site_cold_updateds ||= {
    # Note : la propriété ID est automatiquement ajoutée

    # Le message humain de l'actualisation
    message:    {type:"VARCHAR(255)", constraint:"NOT NULL"},

    # La route conduisant à la page concernée
    # Noter qu'elle peut ne pas exister
    route:    {type:"VARCHAR(255)"},

    # Le type de l'actualisation
    # cf. TYPES dans ./objet/site/lib/module/updates/contantes.rb
    type:      {type:"INTEGER"},

    # Annonce
    # -------
    # Détermine si une annonce a été ou doit être faite et à qui
    # La valeur peut être :
    #   0: pas d'annonce
    #   1: Aux inscrits
    #   2: Seulement aux abonnés
    #
    annonce:    {type:"INTEGER(1)"},

    # Options
    # -------
    # À déterminer
    options:    {type:"VARCHAR(32)"},


    # Date de cette actualisation
    created_at:  {type:"INTEGER(10)", constraint:"NOT NULL"}

  }
end

# encoding: UTF-8
=begin
Table pour les archives des tâches
=end
def schema_table_site_cold_todolist
  @schema_table_site_cold_todolist ||= {
    # Note : la propriété ID est automatiquement ajoutée
    # La tache en une ligne
    tache:        {type:"VARCHAR(255)", constraint:"NOT NULL"},
    # L'administrateur assigné à cette tâche. Par défaut,
    # celui qui la crée.
    admin_id:     {type:"INTEGER"},
    description:  {type:"TEXT"},
    created_at:   {type:"INTEGER(10)", constraint:"NOT NULL"},
    # Date d'actualisation
    # Sert aussi de date de fin quand le statut est 9 (state)
    ended_at:   {type:"INTEGER(10)", constraint:"NOT NULL"}
  }
end

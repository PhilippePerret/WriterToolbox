# encoding: UTF-8
def schema_table_site_hot_todolist
  @schema_table_site_hot_todolist ||= {
    # Note : la propriété ID est automatiquement ajoutée
    # La tache en une ligne
    tache:        {type:"VARCHAR(255)", constraint:"NOT NULL"},
    # L'administrateur assigné à cette tâche. Par défaut,
    # celui qui la crée.
    admin_id:     {type:"INTEGER"},
    description:  {type:"TEXT"},
    echeance:     {type:"INTEGER(10)"},
    state:        {type:"INTEGER(1)", constraint:"NOT NULL", default:"0"},
    created_at:   {type:"INTEGER(10)", constraint:"NOT NULL"},
    # Date d'actualisation
    # Sert aussi de date de fin quand le statut est 9 (state)
    updated_at:   {type:"INTEGER(10)", constraint:"NOT NULL"}
  }
end

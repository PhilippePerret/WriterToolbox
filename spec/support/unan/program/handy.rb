# encoding: UTF-8

# Retourne n'importe quel programme en activité
def get_any_program options = nil
  options ||= Hash::new
  options[:colonnes]  ||= [:id]
  options[:where]     ||= "options LIKE '1%'"
  @program_id = Unan::table_programs.select(options).keys.first
  Unan::Program::new @program_id
end

# encoding: UTF-8

# Vide le dossier des mails envoyés en local
def reset_mails
  folder_mails_temp.remove if folder_mails_temp.exist?
end
# Retourne un {Array} de tous les mails envoyés en local
def get_mails
  Dir["#{folder_mails_temp}/*.msh"].collect do |path|
    File.open(path, 'r'){ |f| Marshal.load(f) }
  end
end
def folder_mails_temp
  @folder_mails_temp ||= begin
    d = site.folder_tmp + 'mails'
    d.build unless d.exist?
    d
  end
end

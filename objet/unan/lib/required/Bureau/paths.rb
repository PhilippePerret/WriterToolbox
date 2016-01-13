# encoding: UTF-8
class Unan
class Bureau


  def folder_panneaux
    @folder_panneaux ||= folder_view + 'panneau'
  end

  def folder_view
    @folder_view ||= site.folder_objet + 'unan/bureau'
  end
end #/Bureau
end #/Unan

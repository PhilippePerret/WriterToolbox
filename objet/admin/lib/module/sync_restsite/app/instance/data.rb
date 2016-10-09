# encoding: UTF-8
class SyncRestsite
class App

  # Les données dans SyncRestsite::APPLICATION
  attr_reader :data

  def name
    @name ||= data[:hname]
  end

  def path
    @path ||= SuperFile.new(data[:path])
  end

  # Le fichier marshal où les données seront enregistrées
  # quand l'application est la source
  def file_data_marshal
    @file_data_marshal ||= self.path + 'tmp/desync_file.msh'
  end

  def folders_in
    @folders_in ||= data[:folders_in] || Array.new
  end
  def folders_out
    @folders_out ||= data[:folders_out] || Array.new
  end
  def files_in
    @files_in ||= data[:files_in] || Array.new
  end
  def files_out
    @files_out ||= data[:files_out] || Array.new
  end

  def relative_folders
    @relative_folders ||= begin
      Dir["#{path}/*"].collect do |p|
        p.sub(/^#{data[:path]}\//,'')
      end
    end
  end

end #/App
end #/SyncRestsite

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

  def folders_out
    @folders_out ||= data[:folders_out] || Array.new
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

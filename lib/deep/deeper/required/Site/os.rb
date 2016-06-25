# encoding: UTF-8
=begin

  Extension de la classe SiteHtml pour gérer l'operating system
  de l'user et notamment savoir s'il est sur windows ou sur Mac
  ou sur Unix

=end
class SiteHtml

  def os_path arr
    arr.join(os_delimiter)
  end

  def os_delimiter
    @delimiter_by_os ||= begin
      case true
      when apple?, unix? then '/'
      when windows? then '\\'
      end
    end
  end
  alias :os_delimiteur :os_delimiter
  alias :os_delimitor :os_delimiter
  
  def os_folder_documents
    @os_folder_documents ||= begin
      case true
      when apple?   then 'Documents'
      when windows? then 'C:\Mes Documents'
      when unix?    then 'Documents'
      end
    end
  end

  def windows?
    true
  end

  def apple?
    false
  end
  alias :mac? :apple?

  def unix?
    false
  end

  def os
    @os ||= begin
      case true
      when windows? then 'Windows'
      when apple?   then 'Apple'
      when unix?    then 'Unix'
      end
    end
  end
end

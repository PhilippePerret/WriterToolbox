# encoding: UTF-8
=begin

  Instance SiteHtml::TestSuite::TestBase::TestTable::Row
  ------------------------------------------------------
  Une rangée de table

=end
class SiteHtml
class TestSuite
class TestBase
class TestTable
class Row

  # Raccourcis pour utiliser par exemple `row(...).has(...)`
  def has h, opts      ; data.has(h, opts)       end
  def has_not h, opts  ; data.has_not(h, opts)   end
  def has? h, opts     ; data.has?(h, opts)      end
  def has_not? h, opts ; data.has_not?(h, opts)  end

  def exists?
    data != nil
  end
  alias :exist? :exists?

end #/Row
end #/TestTable
end #/TestBase
end #/TestSuite
end #/SiteHtml

# encoding: UTF-8
=begin
Traitement de la console.
=end
raise_unless_admin
site.require_module 'console'

def console
  @console ||= SiteHtml::Admin::Console::current
end

console.execute_code if console.has_code?

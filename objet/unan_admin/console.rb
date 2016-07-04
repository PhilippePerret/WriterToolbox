# encoding: UTF-8
UnanAdmin.require_module 'console'
def console
  @console ||= Console.instance
end

if param(:console)
  console.run
end

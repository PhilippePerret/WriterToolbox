# encoding: UTF-8

require './lib/required'

folder_mails = SuperFile::new('./tmp/mails')

Dir["#{folder_mails}/*.msh"].each do |path|
  path = SuperFile::new(path)
  data_mail = Marshal.load(path.read)
  puts data_mail.pretty_inspect
end

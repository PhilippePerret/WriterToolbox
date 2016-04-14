# encoding: UTF-8
def groupes_checkups
  pfile = ENV['TM_FILEPATH']
  arr = Array::new
  pref_folder = nil
  pfile.split('/').each do |folder|
    arr << folder
    break if pref_folder == 'cnarration'
    pref_folder = folder
  end
  book_folder = File.join(arr)

  # gcmd = "grep -r [^_]CHECKUP\\[(.+)\\|(.+)\\] #{book_folder}"
  gcmd = "grep -r -E '(PRINT_)?CHECKUP\\[(.+)\\]' #{book_folder}"
  # puts gcmd
  res  = `#{gcmd}`
  res = res.force_encoding('utf-8')
  # puts "res = #{res.inspect}"
  groupes = Array::new
  res.split("\n").each do |found|
    found.scan(/(PRINT_)?CHECKUP\[(.+?)\]/).each do |arr_found|
      printed, attrs = arr_found
      if printed.nil?
        question, groupe = attrs.split('|')
        next if groupe.nil?
      else
        groupe = attrs
      end
      groupes << groupe unless groupes.include?( groupe )
    end
  end
  groupes << "__autres__"
  
  return groupes
end

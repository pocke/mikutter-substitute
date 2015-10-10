Plugin.create(:mikutter_substutite) do
  on_mention do |s, msgs|
    msgs.each do |msg|
      begin
        next unless msg.user.me?

        match = %r!^\@[a-zA-Z0-9_]+\s+s/(.*?)/(.*?)(/[gximn]*)?$!.match(msg.body)
        next unless match

        re_str   = match[1]
        after    = match[2]
        flag_str = match[3] || ""
        puts "re_str: #{re_str}, after: #{after}, flag_str: #{flag_str}"

        flag = 0
        flag |= Regexp::EXTENDED   if flag_str.include?('x')
        flag |= Regexp::IGNORECASE if flag_str.include?('i')
        flag |= Regexp::MULTILINE  if flag_str.include?('m')
        flag |= Regexp::NOENCODING if flag_str.include?('n')
        re = Regexp.new(re_str, flag)

        recieved_msg = msg.receive_message(true)
        next unless recieved_msg

        text =
          if flag_str.include?('g')
            recieved_msg.body.gsub(re, after)
          else
            recieved_msg.body.sub(re, after)
          end

        Service.primary.update(message: text)
      rescue => ex
        error ex
      end
    end
  end
end

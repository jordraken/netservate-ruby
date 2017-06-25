class HTMLUpdater
  def intialize
  end

  def append_result(result)
    begin
      html = "\n<tr><td>#{result[:server]}</td><td>#{result[:download]}</td>"\
        "<td>#{result[:upload]}</td><td>#{result[:time]}</td></tr>"
      file = File.open('./public/log/log.html', 'a')
      file.write(html)
      file.close
    rescue => error
      puts "ERROR: " + error
    end
  end
end

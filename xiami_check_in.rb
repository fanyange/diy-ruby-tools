require 'mechanize'

agent = Mechanize.new { |a| a.user_agent_alias = "Mac Safari" }

login_page = agent.get "http://www.xiami.com/member/login"

login_form = login_page.form

login_form.email = "EMAIL@EXAMPLE.COM"
login_form.password = "PASSWORD"

main_page = agent.submit(login_form, login_form.button)

unless main_page.link_with(text: /已连续签到/)
  
  if main_page.link_with(text: /签到/)
    begin
      agent.post("http://www.xiami.com/task/signin")
    rescue
      puts "[#{Time.now.getlocal('+08:00')}]: failed to post the check_in request"
    else
      puts "[#{Time.now.getlocal('+08:00')}]: check in succeed!"
    end
    
  else
    puts "You username / password is invalid."
  end
  
else
  puts "[#{Time.now.getlocal('+08:00')}]: You have checked! Wait for a while."
end
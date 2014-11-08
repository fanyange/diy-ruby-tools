require "mechanize"

# Configurations
USER_NAME = "YOUR_USER_NAME"
PASSWORD = "YOUR_PASSWORD"
COOKIE_FILE_PATH = "v2ex_cookies_for_#{USER_NAME}.yaml"

a = Mechanize.new
a.user_agent_alias = 'Mac Safari'

# Load cookies saved before.
a.cookie_jar.load COOKIE_FILE_PATH rescue puts "cookies file not found."

# Visit get-redeem page
a.get "http://www.v2ex.com/"

# If login using cookies failed, relogin manually:
if a.page.link_with(text: USER_NAME)
  puts "login succeed using cookies"
else
  a.get '/signin'
  login_form = a.page.form_with(action: "/signin")
  login_form.u = USER_NAME
  login_form.p = PASSWORD
  a.submit(login_form)

  if a.page.link_with(text: USER_NAME)
    a.cookie_jar.save COOKIE_FILE_PATH
    puts "Manual login succeed!"
  else
    puts "Manual Login failed!"
    exit(1)
  end
end


# Find the redeem link
a.get "/mission/daily"

# If already got before next time:
if a.page.parser.content.include? "已领取"
  puts "时辰未到"
# Otherwise, get the redeem!
else
  # Get redeem path
  redeem_path = a.page.at("input[onclick]")[:onclick].match(/'(.+)'/)[1]
  # Access the path
  a.get redeem_path

  # Test if it succeed
  if a.page.at("//span[contains(text(), '已领取')]")
    puts "领取成功！"
  else
    puts "领取失败！"
    exit(1)
  end
end

puts a.page.at("//div[contains(text(), '已连续登录')]").text

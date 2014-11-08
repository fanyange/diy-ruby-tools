require 'selenium-webdriver'

driver = Selenium::WebDriver.for :chrome
wait = Selenium::WebDriver::Wait.new(:timeout => 0.5) # seconds

driver.get "http://118.122.113.77:6888/login"

# Login
u = driver.find_element(:id, "username")
p = driver.find_element(:id, "passwordDisplay")
b = driver.find_element(:id, "login")

u.send_keys "511800"
p.send_keys "8" * 6
b.click

## remember original window handle
# tab1 = driver.window_handle

# index page
driver.find_element(:link, "项目月报").click
driver.find_elements(:link, "月报项目列表")[0].click

driver.find_element(:id, "reportStatusName").click
sleep 0.5
driver.find_element(:id, "reportStatusTree_2_span").click
driver.find_element(:xpath, "//input[@value='检索']").click

driver.find_element(:xpath, "//div[@id='_center']/ul[2]/li[3]/input").send_keys([:backspace, "2"])
driver.find_element(:css, "body").click

loop do
  items = driver.find_elements(:css, "input[name=proId]")
  items.each { |i| i.click }
  driver.find_element(:link, "确认下级报送月报").click
  sleep 0.5
  driver.find_element(:id, "btnConfirm").click
  sleep 0.5
  driver.find_element(:link, "下一页").click
end

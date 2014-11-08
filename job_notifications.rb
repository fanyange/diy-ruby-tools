require 'open-uri'
require 'nokogiri'
require 'mail'
require 'logger'
require 'timeout'


Mail.defaults do
  delivery_method :smtp, { 
    :address => 'smtp.gmail.com',
    :port => '587',
    :user_name => 'FROM@EXAMPLE.COM',
    :password => 'PASSWORD',
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end

logger = Logger.new('log.txt')

loop do
  page = ""
  logger.info "This turn begin..."

  begin
    Timeout::timeout(10) do
      page = Nokogiri::HTML(open('http://www.yapta.gov.cn/NewsList.aspx?ID=1&categoryID=7').read, nil, 'utf-8')
    end
  rescue Timeout::Error
    logger.error "Open this url timeout. Wait for 1 minute and retry"
    sleep 60
    retry
  end

  first_link = page.css('.border_Info_all a').first

  start_time = Time.now
  if first_link.text =~ /公务员/
    mail = Mail.new do
      from 'FROM@EXAMPLE.COM'
      to 'TO@EXAMPLE.COM'
      subject '通知来了！'
      html_part do
        content_type 'text/html; charset=UTF-8'
        body %{<a href="http://www.yapta.gov.cn/#{first_link['href']}">#{first_link.text}</a>}
      end
    end
    mail.deliver!

    logger.info "Success!"
    break
  else
    logger.warn "Failed. Wait for 10 minutes and retry..."
  end
  sleep 600
end

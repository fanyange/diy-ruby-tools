require "nokogiri"
require "open-uri"
require "json"

BASE_URL = "TIEBA_POST_URL"

doc = Nokogiri::HTML(open(BASE_URL, "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.52 Safari/537.36"))
title = doc.title

last_page_n = doc.at_xpath("//a[text()='尾页']")[:href][/\d+$/]

page = ""

def publish_date_from(section)
  data_parent = section.parent.parent.parent.parent["data-field"]
  date =  JSON.parse(data_parent)["content"]["date"]
  "<div style='float:right;font-size: 61.8%;line-height: 40px;'>#{date}</div>"
end

(1..last_page_n.to_i).each do |page_num|
  doc = Nokogiri::HTML(open("#{BASE_URL}&pn=#{page_num}"))
  sections = doc.css('div.d_post_content')
  sections.each do |section|
    # Firstly, get the publish date of this section.
    date_secion = publish_date_from(section)
    # Then we parse every section's content.
    # tag the start line.
    start = true
    # unless section.text =~ /第.+章/ # only if it is a chapter section.
    section.children.inject(page) do |result, node|
      result << case(node.name)
      when "br"
        "\n\n"
      when "text"
        t = node.text.strip
        ## uncomment when the post is splited to chapters
        # if t =~ /^第.+章/
        #   start = false
        #   '## ' + t + date_secion
        # else
        #   if start
        #     start = false
        #     '## 弦外音' + date_secion + "\n\n" + t
        #   else
        #     t
        #   end
        # end
      when 'img'
        "![](#{node[:src]})"
      else
        node.text
      end
    end
    page << "\n\n------------------------------\n\n"
  end
end

File.write(Dir.home + "/Desktop/tiebalive-#{title}.md", page)

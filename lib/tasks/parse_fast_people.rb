require 'mechanize'

class ParseFastPeople
  BASE_URL = "https://www.fastpeoplesearch.com/mary-anne-rabon_id_G-6962601656597233420"

  def initialize
    @mechanize = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
      agent.set_proxy '72.13.91.43', 1212
    }
    @page = nil
  end

  def execute
    @page = @mechanize.get(BASE_URL)
    get_age
    get_phones
    get_emails
  end

  private
  def get_age
    age = @page.search(".//h1/span")
    age = age.text.squish if age.present?
    return age.split(" ").dig(1) if age.present?
    nil
  end

  def get_phones
    phones = @page.search(".//div[@class='detail-box-phone']")
    binding.pry
  end

  def get_emails
    emails = @page.search(".//div[@class='detail-box-email']")
    binding.pry
  end

end

class Identity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :uid, :provider
  validates_uniqueness_of :uid, scope: :provider

  def self.find_for_oauth(auth)
    first_name = ''
    last_name = ''
    email = ''
    company_name = ''
    
    if auth.provider.present?
      if auth.provider.eql?('linkedin')
        first_name = auth.info.first_name
        last_name = auth.info.last_name
        email = auth.info.email
        client = LinkedIn::Client.new
        client.authorize_from_access(auth.extra.access_token.token, auth.extra.access_token.secret)
        profile = client.profile(:fields => %w(positions))
        companies = profile.positions.each.map{|t| t.company}
        company_name = companies.first.name if companies.present?
        full_name = "#{first_name} #{last_name}" if first_name.present? && last_name.present?
      end
      
      if auth.provider.eql?('facebook')
        full_name = auth.info.name
        first_name = auth.info.first_name
        last_name = auth.info.last_name
      end
    end
    identity = find_by(provider: auth.provider, uid: auth.uid)
    if identity.nil?
      identity = create(uid: auth.uid, provider: auth.provider, full_name: full_name, first_name: first_name, last_name: last_name, company_name: company_name)
    end
    identity
  end
  
  def scrape_linkedin
    #todo
  end
end

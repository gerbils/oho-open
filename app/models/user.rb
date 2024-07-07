class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :access_grants, dependent: :delete_all

  def oauth_payload
    _hash = {
      provider: 'sso',
      id: self.id,
      info: {
         email: self.email,
         name: self.email, # TODO for you: Handle name and pass the data here
      },
      extra: {
        first_name: "TODO", # TODO for you: To pass the relevant data here
        last_name: "TODO", # TODO for you: To pass the relevant data here
        mobile_number: "123456789", # TODO for you: To pass the relevant data here
      }
    }
    return _hash
  end

end

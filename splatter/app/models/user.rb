class User
  include Mongoid::Document
  field :name, type: String
  field :password, type: String
  field :blurb, type: String
end

class User < ApplicationRecord
  LIMIT_USERS = 1000
  def self.export_to_excel?
    User.where(export_excel: nil).order(created_at: :desc).size > LIMIT_USERS
  end

  def self.user_excel_limit
    User.where(export_excel: nil).order(created_at: :desc).limit(LIMIT_USERS)
  end
end

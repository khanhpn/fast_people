class RawDatum < ApplicationRecord
  has_one_attached :raw_url
  has_one_attached :proxy_url
end

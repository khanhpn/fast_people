class Array
  def get_values(key)
    self.map{|x| x[key]}
  end
end

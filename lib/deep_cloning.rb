# DeepCloning

module DeepCloning
  def self.included(base)
    base.alias_method_chain :clone, :deep_cloning
  end
  
  def clone_with_deep_cloning options = {}
    clone_without_deep_cloning
  end
end
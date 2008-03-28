# DeepCloning

module DeepCloning
  def self.included(base) #:nodoc:
    base.alias_method_chain :clone, :deep_cloning
  end

  # clones an ActiveRecord model. 
  # if passed the :include option, it will deep clone the given associations
  # if passed the :except option, it won't clone the given attributes
  #
  # === Usage:
  # 
  # ==== Cloning a model without an attribute
  #   pirate.clone :except => :name
  # 
  # ==== Cloning a model without multiple attributes
  #   pirate.clone :except => [:name, :nick_name]
  # ==== Cloning one single association
  #   pirate.clone :include => :mateys
  #
  # ==== Cloning multiple associations
  #   pirate.clone :include => [:mateys, :treasures]
  #
  # ==== Cloning really deep
  #   pirate.clone :include => {:treasures => :gold_pieces}
  # 
  def clone_with_deep_cloning options = {}
    kopy = clone_without_deep_cloning
    
    if options[:except]
      # Object#to_a is deprecated and safe_to_array is a private class methods
      [*options[:except]].each do |attribute|
        column = kopy.class.columns.detect {|c| c.name.to_sym == attribute.to_sym}
        kopy.write_attribute(attribute, column.default)
      end
    end
    
    if options[:include]
      [*options[:include]].each do |association, deep_associations|
        opts = deep_associations.blank? ? {} : {:include => deep_associations}
        self.send("#{association}=", kopy.send(association).collect {|i| i.clone(opts) })
      end
    end

    return kopy
  end
end

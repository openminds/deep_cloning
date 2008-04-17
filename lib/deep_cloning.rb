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
  # ==== Cloning really deep with multiple associations
  #   pirate.clone :include => [:mateys, {:treasures => :gold_pieces}]
  # 
  def clone_with_deep_cloning options = {}
    kopy = clone_without_deep_cloning
    
    if options[:except]
      Array(options[:except]).each do |attribute|
        kopy.write_attribute(attribute, attributes_from_column_definition[attribute.to_s])
      end
    end
    
    if options[:include]
      Array(options[:include]).each do |association, deep_associations|
        if (association.kind_of? Hash)
          deep_associations = association[association.keys.first]
          association = association.keys.first
        end
        opts = deep_associations.blank? ? {} : {:include => deep_associations}
        kopy.send("#{association}=", self.send(association).collect {|i| i.clone(opts) })
      end
    end

    return kopy
  end
end

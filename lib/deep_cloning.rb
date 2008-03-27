# DeepCloning

module DeepCloning
  # :nodoc:
  def self.included(base)
    base.alias_method_chain :clone, :deep_cloning
  end
  
  # clones an ActiveRecord model. 
  # if passed the :include option, it will deep clone the given associations
  # if passed the :except option, it won't clone the given attributes
  #
  # == Usage:
  # 
  # === Cloning a model without an attribute
  #   pirate.clone :exclude => :name
  # 
  # === Cloning a model without multiple attributes
  #   pirate.clone :exclude => [:name, :nick_name]
  # === Cloning one single association
  #   pirate.clone :include => :mateys
  #
  # === Cloning multiple associations
  #   pirate.clone :include => [:mateys, :treasures]
  #
  # === Cloning really deep
  #   pirate.clone :include => {:treasures => :gold_pieces}
  # 
  def clone_with_deep_cloning options = {}
    kopy = clone_without_deep_cloning
    if (exceptions = options[:except])
      case exceptions
      when String, Symbol
        kopy.set_default_attribute exceptions
      when Array
        exceptions.each {|e| kopy.set_default_attribute e }
      end
    end
    if (associations = options[:include])
      case associations
      when String, Symbol
        kopy.clone_association(self, associations)
      when Array
        associations.each {|a| kopy.clone_association(self, a)}
      when Hash
        associations.each { |a, deep_associations| kopy.clone_association(self, a, deep_associations) }
      end
    end
    
    return kopy
  end
  
  # :nodoc:
  def clone_association source, association, deep_associations = nil
    options = deep_associations ? {:include => deep_associations} : {}
    self.send("#{association}=", source.send(association).collect {|i| i.clone(options) })
  end
  
  def set_default_attribute attribute
    column = self.class.columns.detect {|c| c.name.to_sym == attribute.to_sym}
    self.write_attribute(attribute, column.default)
  end
end

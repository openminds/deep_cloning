require 'deep_cloning'

ActiveRecord::Base.send(:include, DeepCloning)
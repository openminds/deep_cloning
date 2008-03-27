class Treasure < ActiveRecord::Base
  belongs_to :pirate
  
  has_many :gold_pieces
end
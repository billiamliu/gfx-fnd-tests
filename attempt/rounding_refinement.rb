module RoundingRefinement
  refine Float do

    alias :__old_round__ :round

    def round
      # this keeps pixels at the top left when split between two options
      self >= 0 ? ( self - 0.5 ).ceil : ( self + 0.5).floor
    end

  end

end

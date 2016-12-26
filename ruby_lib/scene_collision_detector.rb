class CollisionDetector

  def self.call camera, walls
  end

  def initialize camera, walls
    @camera, @walls = camera, walls
  end

  def collisions
    hot @camera, @walls
  end

  private

  def camera_theta c
    c.theta
  end

  def intersect l1, l2
    l1.intersect( l2 ).distance
  end

  def hot camera, walls
    walls.map do |w|
      [ camera_theta( camera ), intersect( camera, w ), w ]
    end
  end

  # testing with arrays instead of PointVectors
  def null camera, walls
    # TODO
  end

end

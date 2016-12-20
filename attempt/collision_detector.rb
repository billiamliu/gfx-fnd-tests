require_relative 'line_like'

class CollisionDetector

  def self.build
    new do |instance|
      instance.logic = hot
    end
  end

  def self.configure receiver
    receiver.collision_detector = build
  end

  def walls= walls
    @walls = walls
  end

  def rays= rays
    @rays = rays
  end

  def collisions
    @logic ||= hot
  end

  private

  def distance wall, ray
    LineLike.intercept_distance_between wall, ray
  end

  def null
    puts "CollisionDetector run in null mode"
    Hash.new { |h, k| h[k] = [] }
  end

  def hot
    throw "need an array of ray(s)<#LineLike::Ray> to calculate collision" unless rays
    throw "need an array of wall(s)<#LineLike::Wall> to calculate collision" unless walls

    ret = null

    rays.map do |ray|
      walls.map do |wall|

        distance = distance( wall, ray )

        ret[ ray.rotation ] << [ distance, wall ] unless distance == Float::INFINITY
      end
    end

    ret
  end

end


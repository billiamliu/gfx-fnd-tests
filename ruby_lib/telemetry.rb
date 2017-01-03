class Telemetry

  attr_accessor :sink

  def self.call( msg = nil )
    instance = build
    instance.( msg )
  end

  def self.configure( receiver )
    instance = build
    if receiver.telemetry then throw ArgumentError, "receiver: #{ receiver } already has telemetry" end
    receiver.telemetry = instance
    instance
  end

  def self.build
    new.tap { |ins| ins.sink = [] }
  end

  # returns and does not alter data, so this method can act as middleware
  def record( action, data = nil )
    sink << make_frame( action, data )
    data
  end

  def include?( *args )
    args.length > 1 ? include_many( args ) : include_one( args[0] )
  end

  def clear_sink!
    @sink.slice! 0..@sink.length
  end

  def call( msg )
    record :telemetry_called, msg
    self
  end

  def sink
    @sink ||= []
  end

  private

  def include_one( action )
    @sink.any? { |frame| frame.action == action }
  end

  def include_many( actions )
    res = actions.reject { |action| include_one( action ) == true }
    res.length == 0
  end

  Frame = Struct.new :action, :data

  def make_frame( action, data )
    Frame.new( action, data )
  end

end

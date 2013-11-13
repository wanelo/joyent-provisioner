module ArubaHelpers
  def self.history
    @history ||= ArubaDoubles::History.new(File.join(ArubaDoubles::Double.bindir, ArubaDoubles::HISTORY_FILE))
  end
end

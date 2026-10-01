module Pkgr
  class Cron
    # the source, in /usr/share/app-name/crons/...
    attr_reader :source
    # the destination, most likely in /etc/cron.d/...
    attr_reader :destination

    def initialize(source, destination)
      @source, @destination = source, destination
    end
  end
end

class UpstreamCheckNginxModule < Formula
  VERSION="0.4.0"
  desc "Nginx health check with the upstream servers module"
  homepage "https://github.com/yaoweibin/nginx_upstream_check_module"
  url "https://github.com/yaoweibin/nginx_upstream_check_module/archive/refs/tags/v#{VERSION}.tar.gz"
  sha256 "41059b5a703ccc45cd404b345e5a77c6d6bc92f6b5d41865a9a6ce92291cd57b"
  head "https://github.com/yaoweibin/nginx_upstream_check_module.git", branch: "master"

  def install
    pkgshare.install Dir["*"]
  end
end

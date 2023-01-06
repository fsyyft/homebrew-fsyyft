class Openresty < Formula
  desc "Scalable Web Platform by Extending NGINX with Lua"
  homepage "https://openresty.org"
  VERSION = "1.21.4.1".freeze
  url "https://openresty.org/download/openresty-#{VERSION}.tar.gz"
  sha256 "0c5093b64f7821e85065c99e5d4e6cc31820cfd7f37b9a0dec84209d87a2af99"
  revision 1

  option "with-debug", "Compile with support for debug logging"
  option "with-postgresql", "Compile with ngx_http_postgres_module"
  option "with-iconv", "Compile with ngx_http_iconv_module"
  option "with-slice", "Compile with ngx_http_slice_module"

  patch do
    url "https://raw.githubusercontent.com/fsyyft/homebrew-fsyyft/a79171e84e83bfd95ee55f69b31214bf4036eced/patches/nginx_upstream_check_1.20.1%2B.patch"
    sha256 "ea9dab1d33fe4e3aee99ff15a2d4cc902408c5b5f752ad90090581d1b16a60f7"
  end
  

  # 使用 openresty-openssl 替换 openssl 的原因：https://github.com/denji/homebrew-nginx/pull/244。
  # 在 Ubuntu 下无法编译通过，调整回使用 openssl@1.1，会失去部分 openssl 的高级特性。
  on_linux do
    depends_on "openssl@1.1"
  end
  on_macos do
    depends_on "fsyyft/fsyyft/openresty-openssl"
  end
  depends_on "fsyyft/fsyyft/vts-nginx-module"
  depends_on "fsyyft/fsyyft/upstream-check-nginx-module"
  depends_on "geoip"
  depends_on "pcre"
  depends_on "postgresql" => :optional

  skip_clean "site"
  skip_clean "pod"
  skip_clean "nginx"
  skip_clean "luajit"

  def install
    # Configure
    cc_opt = "-I#{HOMEBREW_PREFIX}/include -I#{Formula["pcre"].opt_include}"
    ld_opt = "-L#{HOMEBREW_PREFIX}/lib -L#{Formula["pcre"].opt_lib}"

    on_linux do
      cc_opt += " -I#{Formula["openssl@1.1"].opt_include}"
      ld_opt += " -L#{Formula["openssl@1.1"].opt_lib}"
    end

    on_macos do
      cc_opt += " -I#{Formula["fsyyft/fsyyft/openresty-openssl"].opt_include}"
      ld_opt += " -L#{Formula["fsyyft/fsyyft/openresty-openssl"].opt_lib}"
    end

    args = ["-j#{ENV.make_jobs}",
            "--prefix=#{prefix}",
            "--pid-path=#{var}/run/openresty.pid",
            "--lock-path=#{var}/run/openresty.lock",
            "--conf-path=#{etc}/openresty/nginx.conf",
            "--http-log-path=#{var}/log/nginx/access.log",
            "--error-log-path=#{var}/log/nginx/error.log",
            "--with-cc-opt=#{cc_opt}",
            "--with-ld-opt=#{ld_opt}",
            "--with-pcre-jit",
            "--without-http_rds_json_module",
            "--without-http_rds_csv_module",
            "--without-lua_rds_parser",
            "--with-ipv6",
            "--with-stream",
            "--with-stream_ssl_module",
            "--with-stream_ssl_preread_module",
            "--with-http_v2_module",
            "--without-mail_pop3_module",
            "--without-mail_imap_module",
            "--without-mail_smtp_module",
            "--with-http_stub_status_module",
            "--with-http_realip_module",
            "--with-http_addition_module",
            "--with-http_auth_request_module",
            "--with-http_secure_link_module",
            "--with-http_random_index_module",
            "--with-http_geoip_module",
            "--with-http_gzip_static_module",
            "--with-http_sub_module",
            "--with-http_dav_module",
            "--with-http_flv_module",
            "--with-http_mp4_module",
            "--with-http_gunzip_module",
            "--with-threads",
            "--with-luajit-xcflags=-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT -fno-stack-check",
            "--add-module=#{HOMEBREW_PREFIX}/opt/vts-nginx-module/share/vts-nginx-module",
            "--add-module=#{HOMEBREW_PREFIX}/opt/upstream-check-nginx-module/share/upstream-check-nginx-module"
    ]

    args << "--with-http_postgres_module" if build.with? "postgresql"
    args << "--with-http_iconv_module" if build.with? "iconv"
    args << "--with-http_slice_module" if build.with? "slice"
    args << "--with-debug" if build.with? "debug"
    
    system "./configure", *args

    # Install
    system "make"
    system "make", "install"
  end

  plist_options manual: "openresty"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <false/>
          <key>ProgramArguments</key>
          <array>
            <string>#{opt_prefix}/bin/openresty</string>
            <string>-g</string>
            <string>daemon off;</string>
          </array>
          <key>WorkingDirectory</key>
          <string>#{HOMEBREW_PREFIX}</string>
        </dict>
      </plist>
    EOS
  end

  test do
    system "#{bin}/openresty", "-V"
  end
end

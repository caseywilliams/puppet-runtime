component 'curl' do |pkg, settings, platform|
  pkg.version '7.58.0'
  pkg.md5sum '7e9e9d5405c61148d53035426f162b0a'
  pkg.url "https://curl.haxx.se/download/curl-#{pkg.get_version}.tar.gz"
  pkg.mirror "#{settings[:buildsources_url]}/curl-#{pkg.get_version}.tar.gz"

  if platform.is_aix?
    # Patch to disable _ALL_SOURCE when including select.h from multi.c. See patch for details.
    pkg.apply_patch 'resources/patches/curl/curl-7.55.1-aix-poll.patch'
  end

  if settings[:vendor_openssl]
    pkg.build_requires 'openssl'
  else
    pkg.build_requires 'openssl-devel'
  end

  pkg.build_requires "puppet-ca-bundle"

  if platform.is_cross_compiled_linux?
    pkg.build_requires "runtime-#{settings[:runtime_project]}"
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$(PATH):#{settings[:bindir]}"
    pkg.environment "PKG_CONFIG_PATH" => "/opt/puppetlabs/puppet/lib/pkgconfig"
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$(PATH)"
  elsif platform.is_windows?
    pkg.build_requires "runtime-#{settings[:runtime_project]}"
    pkg.environment "PATH" => "$(shell cygpath -u #{settings[:gcc_bindir]}):$(PATH)"
    pkg.environment "CYGWIN" => settings[:cygwin]
  else
    pkg.environment "PATH" => "/opt/pl-build-tools/bin:$(PATH):#{settings[:bindir]}"
  end

  pkg.configure do
    ["CPPFLAGS='#{settings[:cppflags]}' \
      LDFLAGS='#{settings[:ldflags]}' \
     ./configure --prefix=#{settings[:prefix]} \
        --with-ssl=#{settings[:prefix]} \
        --enable-threaded-resolver \
        --disable-ldap \
        --disable-ldaps \
        --with-ca-bundle=#{settings[:prefix]}/ssl/cert.pem \
        #{settings[:host]}"]
  end

  pkg.build do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    # Do not need curl binaries, delete after install
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install",
     "rm -f #{settings[:prefix]}/bin/curl",
     "rm -f #{settings[:prefix]}/bin/curl-config"
    ]
  end
end

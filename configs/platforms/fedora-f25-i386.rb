platform "fedora-f25-i386" do |plat|
  plat.servicedir "/usr/lib/systemd/system"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "systemd"

  plat.add_build_repository "http://pl-build-tools.delivery.puppetlabs.net/yum/pl-build-tools-release-#{plat.get_os_name}-25.noarch.rpm"
  packages = [
    "autoconf",
    "automake",
    "gcc",
    "libselinux-devel",
    "libsepol",
    "libsepol-devel",
    "make",
    "pl-gcc",
    "rpm-libs",
    "rpmdevtools",
    "rsync",
    "swig",
  ]
  plat.provision_with("/usr/bin/dnf install -y --best --allowerasing #{packages.join(' ')}")
  plat.install_build_dependencies_with "/usr/bin/dnf install -y --best --allowerasing"
  plat.vmpooler_template "fedora-25-i386"
end

define arbitrary_dpkg( $package, $version, $subdir, $deps) {
  $mirror = "http://mirrors.kernel.org"
  $source_path = "${mirror}/ubuntu/pool/universe/${subdir}"
  $filename = "${package}_${version}.deb"

  exec { 
    $package: 
       command => "/usr/bin/wget ${source_path}/${filename}",
       creates => "/tmp/${filename}",
       cwd => "/tmp";
  }

  package { 
      $package: 
        ensure => present,
				source => "/tmp/${filename}",
				provider => dpkg,
				require => $deps;
  }


}
class rubygems {
class install {
  include $operatingsystem

  class ubuntu { 

    
    package { 
      'ruby1.8':          ensure => installed;
      'rdoc1.8':          ensure => installed;
      'wget':             ensure => installed;
      'ruby1.8-dev':      ensure => installed;
      'build-essential':  ensure => installed;

    }

    file { 
      "profile.d entry":
        path => "/etc/profile.d/rubygems.sh",
        content => '#!/bin/bash
export GEM_HOME=/var/lib/gems/1.8
export GEM_PATH=/var/lib/gems/1.8
PATH=${PATH}:${GEM_HOME}/bin
',
        mode => 0755,
        owner => root,
        group => root,
        ensure => present;
    }
    exec {
    "gem alternative":
       command => "/usr/sbin/update-alternatives --set gem /usr/bin/gem1.8",
       unless => "/usr/sbin/update-alternatives --list gem | grep -v 'gem1.8";
   }

  }
  
  class debian {
    # older versions of facter report Ubuntu as debian
    include ubuntu
  }

  class darwin {
    info("we don't do darwin yet")
  }
  arbitrary_dpkg {"another gem ": 
    package => "rubygems1.8", 
    version => "1.3.5-1ubuntu2_all", 
    subdir => "libg/libgems-ruby", 
    deps => [Package["ruby1.8"],Package["rdoc1.8"]]}

  arbitrary_dpkg {"a gem ": 
    package => "rubygems", 
    version => "1.3.5-1ubuntu2_all",
    subdir => "libg/libgems-ruby",
    deps => Package['rubygems1.8']}

}}


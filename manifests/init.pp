# 
# Installs Artifactory based on setup provided.
# 
# params:
# conf - default configuration of instance
# base_directory - folder for artifactory
# instance_name - name of folder where artifactory will reside
# hosting_user - user to own and run artifactory
# hosting_group - group to own and run artifactory
# work_dir - folder to store temporary data to, in case drivers, artifactory tarball provided as url,
#            they will be downloaded here
#  
# artifactory::conf - setup in hiera specific to host
# 'hostname':
#   artifactory::conf:
#     instance_name: artifactory
#     tarball_location_url: <http>
#     tarball_location_file: <path>
#     license: <license_key>
#     db:
#        DB_TYPE=mysql
#        DB_DRIVER=com.mysql.jdbc.Driver
#        DB_URL="jdbc:mysql://localhost:3306/artdb?characterEncoding=UTF-8&elideSetAutoCommits=true"
#        DB_USER=artifactory
#        DB_PASS=artifactory
#        PROVIDER_FILESYSTEM_DIR=/data/artifactory/filestore
#      drivers:
#              location_url:
#              location_path:
#               - '/etc/puppet/mysql-connector-java-5.1.22-bin.jar'
#      java_flags:              
#              JVM_MINIMUM_MEMORY:  '512m'
#              JVM_MAXIMUM_MEMORY: '1024m'
#              JIRA_MAX_PERM_SIZE: '256m'

class artifactory(
  $instance_name     = 'artifactory',
  $base_directory    = '/opt',
  $share_directory   = '/usr/share/avst-app',
  $hosting_user      = 'artifactory',
  $hosting_group     = 'artifactory',
  $work_dir          = '/tmp',
  $conf = {},
){

  class { 'artifactory::dependencies': } ->
  Class['artifactory']

  # merge custom configuration with defaults
  if $::host != undef {
    $custom_conf = $host["${name}::conf"]
    $config = $custom_conf ? {
        undef => $conf,
        default => merge($conf, $custom_conf),
    }
  } else {
    $config = $conf
  }

  # make sure that basedir exists
  file { [$base_directory, $share_directory] :
          ensure => directory,
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
  }

  #make sure avst-app file exists and holds basedir and baseuser 
  file { '/etc/default/avst-app' :
    ensure  => file,
    content => template("${module_name}/etc/default/avst-app.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  $instance_dir = "${base_directory}/${instance_name}"
  
  # Create base directory structure
  file { $instance_dir :# , "${instance_dir}/home", "${instance_dir}/install"] :
    ensure => directory,
    owner  => $hosting_user,
    group  => $hosting_group,
  }

  # TODO: validate presence and required parameters
  $tarball_location_file = $config['tarball_location_file']
  $tarball_location_url = $config['tarball_location_url']
  $drivers = $config['drivers']
  $db = $config['db']
  $java_flags = $config['java_flags']
  $custom = $config['custom']
  $license = $config['license']

  # in case url provided for product tar download it and place to /tmp
  if ( $tarball_location_file ) {
    $product_tarball = $tarball_location_file
  } else {
    if ( $tarball_location_url ) {
      $tarball_location_splitted = split($tarball_location_url, '/')
      $tarball_file_name = $tarball_location_splitted[-1]
      exec { "Retrieve ${tarball_location_url}" :
                cwd     => $work_dir,
                command => "wget ${tarball_location_url}",
                creates => "${work_dir}/${tarball_file_name}",
                before  => File["${instance_dir}/avst-app.cfg.sh"],
      }
      $product_tarball = "${work_dir}/${tarball_file_name}"
    } else {
      fail('You must provide tarball_location_file or tarball_location_url')
    }
  }

  # in case url provided for drivers download it
  if ( $drivers ) {
    if ( $drivers["location_url"] ) {
      artifactory::download_tar_file { $drivers["location_url"]:
        work_dir => $work_dir,
        before   => File["${instance_dir}/avst-app.cfg.sh"],
      }
    }
  }

  # Prepare config for artifactory
  file { "${instance_dir}/avst-app.cfg.sh" :
    ensure  => file,
    content => template("${module_name}/avst-app.cfg.sh.erb"),
    owner   => $hosting_user,
    group   => $hosting_group,
    mode    => '0644',
    require => File[$instance_dir],
    notify  => Exec['modify_artifactory_with_avstapp'],
  }

  # get avst-app from repo
  package { 'avst-app-artifactory' :
          ensure  => installed,
          require => [ File["${instance_dir}/avst-app.cfg.sh"], Class['oracle_java'] ],
  }
  
  # run avst-app install with tarball passed
  exec {
      'install_artifactory_with_avstapp':
          command => "avst-app --debug ${instance_name} install ${product_tarball}",
          cwd     => $instance_dir,
          creates => "${instance_dir}/.state",
          require => [File["${instance_dir}/avst-app.cfg.sh"], Package['avst-app-artifactory']],
  }

  # run avst-app modify
  exec {
      'modify_artifactory_with_avstapp':
          command => "avst-app --debug ${instance_name} modify",
          cwd     => $instance_dir,
          unless  => '[ grep "installed" .state ]',
          require => Exec['install_artifactory_with_avstapp'],
  }

  # run avst-app install-service
  exec {
      'install_service_artifactory_with_avstapp':
          command => "avst-app --debug ${instance_name} install-service",
          cwd     => $instance_dir,
          unless  => '[ grep "modified" .state ]',
          require => Exec['modify_artifactory_with_avstapp'],
  }
  # celebrate
  service { $instance_name :
    ensure    => running,
    enable    => true,
    subscribe => Exec['modify_artifactory_with_avstapp'],
    require   => Exec['install_service_artifactory_with_avstapp'],
  }
}


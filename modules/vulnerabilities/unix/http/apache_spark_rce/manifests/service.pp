# Class: apache_spark_rce::service
# Service to start spark-shell
#
class apache_spark_rce::service {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $user = $secgen_parameters['unix_username'][0]
  $master_url = "spark://${::ipaddress}:7077"

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  exec { 'set-port':
    command => "sed -i 's/8080/${port}/' /usr/local/spark/sbin/start-master.sh",
  }
  -> file { '/etc/systemd/system/spark.service':
    content => template('apache_spark_rce/spark.service.erb'),
    owner   => 'root',
    mode    => '0777',
  }
  -> exec { 'stop-spark-master':
    command => "/usr/local/spark/sbin/stop-master.sh",
    user    => 'spark',
    onlyif      => '/bin/ps aux | /bin/grep -v grep | /bin/grep "org.apache.spark.deploy.master.Master"',
  }
  -> exec { 'start-spark-master':
    command => "/usr/local/spark/sbin/start-master.sh --host 0.0.0.0 --properties-file /usr/local/spark/conf/spark-defaults.conf",
    user    => 'spark',
  }
  -> exec { 'start-spark-worker':
    command => "/usr/local/spark/sbin/start-worker.sh ${master_url}",
    user    => 'spark',
    require => Exec['start-spark-master'],
  }
}

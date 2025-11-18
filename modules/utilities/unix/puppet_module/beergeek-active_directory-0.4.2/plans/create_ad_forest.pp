#
plan active_directory::active_directory (
  TargetSpec  $node,
  String      $new_hostname,
  String      $new_domain_name,
  String      $netbios_domain_name,
  String      $safemode_admin_password,
  Array       $new_groups,
  Array       $new_users,
) {

  run_task('active_directory::set_hostname',$node, new_hostname => $new_hostname, new_domain_name => $new_domain_name)
  ctrl::do_until() || {
    ctrl::sleep(30)
    $output = run_task('active_directory::make_active_directory', $node, domain_name => $new_domain_name,
    safe_password => $safemode_admin_password, netbios_domain_name => $netbios_domain_name, _catch_errors => true)
  }
  $new_groups.each |Hash $group_data| {
    run_task('active_directory::create_group', $node, $group_data)
  }
}


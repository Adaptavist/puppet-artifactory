define artifactory::download_tar_file(
    $work_dir = '/tmp',
  ){
  exec { $name :
                cwd     => $work_dir,
                command => "wget ${name}",
                timeout => 3600,
      }
}


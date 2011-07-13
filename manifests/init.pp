class vhosts { 


	file {
#		"/tmp/vhost":
#                	ensure => present;
		
		 "/var/vhosts":
                        owner => root,
                        group => root,
                        mode => 755,
                        ensure => directory;

        	}

}
# TODO Fix Removed for Debian 
define vhosts::removed  ( $ip = "*", $port = "80" , $serveradmin = "root@localhost", $documentroot = '' , $servername = 'localhost' , $createroot = 'yes', $serveralias ) {


    	file { "/etc/httpd/vhosts.d/$servername.conf":
  		name => $operatingsystem ? {
                        /Debian|Ubuntu/ => '/etc/apache2/sites-enabled/$servername.conf',
                        /Centos|Fedora/ => '/etc/httpd/vhosts.d/$servername.conf',
                },
		 	ensure => absent;
	  	"/var/log/httpd/$servername/":
                        ensure => absent,
    			recurse => true, purge => true, force => true;
                "/var/log/httpd/$servername/access.log":
                        ensure => absent;
                "/var/log/httpd/$servername/error.log":
                        ensure => absent;
	}


   	if $createroot =='yes' {
                # Recurse apparently doesn't work
                  file { "$documentroot":
                       ensure => absent ,
    			purge => true, force => true,
                        recurse => true;
                        }
		}

}



define vhosts::host  ( $ip = "*", $port = "80" , $serveradmin = "root@localhost", $documentroot = '' , $servername = 'localhost' , $createroot = 'yes', $serveralias ) {

  if  ($operatingsystem in ['Debian', 'Ubuntu']) 
                { $baselogdir = "/var/log/apache2" 
                  $apacheuser = "root"
                  $apachegroup = "root" 
		

		file {"000-$servername":
			name => "/etc/apache2/sites-enabled/000-$servername",
			target => "/etc/apache2/sites-available/$servername",
			ensure =>  "link";
			}

		 }
        if  ($operatingsystem in ['Centos', 'Fedora']) 
                { $baselogdir = "/var/log/httpd" 
                  $apacheuser = "apache" 
                  $apachegroup = "apache" }




    	file { "/etc/httpd/vhosts.d/$servername.conf":
		name => $operatingsystem ? {
			/Debian|Ubuntu/ => "/etc/apache2/sites-available/$servername",
			/Centos|Fedora/ => "/etc/httpd/vhosts.d/$servername.conf",
		},
       		 mode    => 0644,
  	#	 notify => Service["httpd"],
        	 content => template("vhosts/vhost.conf.erb");
		}
	
      
	# Create directories here 

	if $createroot == 'yes' {
		# Recurse apparently doesn't work 

		exec{"/bin/mkdir -p $documentroot":
  			unless => "/usr/bin/test -d $documentroot",
		}
			
		
  		file { "$documentroot":
               	  owner => $apacheuser,
                  group => $apachegroup,
                  ensure => directory ,
                  recurse => true;
        	}

	}		
	


		


	file { 
		"$baselogdir/$servername/":
			ensure => directory,
			recurse => true,
			owner => $apacheuser,
			group => $apachegroup;
		"$baselogdir/$servername/access.log":
			group => $apacheugroup,
			owner => $apacheuser;
		"$baselogdir/$servername/error.log":
			group => $apachegroup,
			owner => $apacheuser;
	}
}

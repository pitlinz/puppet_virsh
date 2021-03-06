/**
 * defines a upstream
 */
define pitlinz_virsh::nginx::conf_upstream (
	$upport		= 80,
	$lport		= 80,
	$nodeids	= [],
	$nodeips	= [],
	$timeout	= "900",
	$uppath		= "/",
	$moniturl	= "/",
	$prio		= 10,

) {
    if $::pitlinz_virsh::hostid < 10 {
        $hostid = "0$::pitlinz_virsh::hostid"
    } else {
        $hostid = "$::pitlinz_virsh::hostid"
    }

    $confFile = "/etc/nginx/sites-available/upstream_${name}_${lport}.conf"

	if !defined(Concat["${confFile}"]) {
		concat{"${confFile}":
		    ensure 	=> $ensure,
		    require	=> Package["nginx"],
		}
	}

    concat::fragment{"${confFile}_${upport}_upstream":
        target 	=> "${confFile}",
		content => template("pitlinz_virsh/nginx/upstream.erb"),
		order	=> "0",
	}

	if $ensure != absent {
	    $_ensure = link
	} else {
	    $_ensure = absent
	}

	file {"/etc/nginx/sites-enabled/0${prio}_location_${name}_${lport}.conf":
		ensure 	=> $_ensure,
		target	=> $confFile,
		require	=> Concat["${confFile}"],
		notify	=> Service["nginx"],
	}

}

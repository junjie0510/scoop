# Usage: scoop cache show|rm [app]
# Summary: Show or clear the download cache
# Help: Scoop caches downloads so you don't need to download the same files
# when you uninstall and re-install the same version of an app.
#
# You can use
#     scoop cache show
# to see what's in the cache, and
#     scoop cache rm <app> to remove downloads for a specific app.
param($cmd, $app)

. "$psscriptroot\..\lib\help.ps1"

reset_aliases

function cacheinfo($file) {
    $app, $version, $url = $file.name -split '#'
    $size = filesize $file.length
    return new-object psobject -prop @{ app=$app; version=$version; url=$url; size=$size }
}

switch($cmd) {
    'rm' {
        if(!$app) { 'ERROR: <app> missing'; my_usage; exit 1 }
        rm "$scoopdir\cache\$app#*"
    }
    'show' {
        $files = @(gci "$scoopdir\cache" | ? { $_.name -match "^$app" })
        $total_length = ($files | measure length -sum).sum -as [double]

        $f_app  = @{ expression={"$($_.app) ($($_.version))" }}
        $f_url  = @{ expression={$_.url};alignment='right'}
        $f_size = @{ expression={$_.size}; alignment='right'}


        $files | % { cacheinfo $_ } | ft $f_size, $f_app, $f_url -auto -hide

        "total: $($files.length) $(pluralize $files.length 'file' 'files'), $(filesize $total_length)"
    }
    default {
        "cache '$cmd' not supported"; my_usage; exit 1
    }
}

exit 0
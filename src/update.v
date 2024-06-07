import os
import json
import arrays
import v.pref
import net.http

struct Release {
	tag_name   string
	prerelease bool
	assets     []Asset
}

struct Asset {
	browser_download_url string
}

fn update() ! {
	install_path := os.find_abs_path_of_executable('vzit') or {
		return error('failed to find `vzit` install path: ${err}')
	}

	resp := http.get('https://api.github.com/repos/ttytm/vzit/releases')!
	if resp.status_code != 200 {
		return error('failed get success status when fetching V-WebUI releases: ${resp}')
	}

	releases := json.decode([]Release, resp.body)!
	latest_release := arrays.find_first(releases, fn (it Release) bool {
		return !it.prerelease
	}) or { return error('failed to find vzit release') }

	if latest_release.tag_name.trim_left('v') == manifest.version {
		println('Already up to date.')
		return
	}

	println('New version available: v${manifest.version} -> ${latest_release.tag_name}')
	println('Updating ${install_path}...')

	host_os := pref.get_host_os()
	host_arch := pref.get_host_arch()
	asset := arrays.find_first(latest_release.assets, fn [host_os, host_arch] (it Asset) bool {
		return it.browser_download_url.ends_with('-${host_os}-${host_arch}'.to_lower())
	}) or { return error('failed to find vzit release for ${host_os}-${host_arch}') }

	os.mv(install_path, os.join_path(tmp_dir, 'vzit.old'))!
	http.download_file(asset.browser_download_url, install_path)!
	os.chmod(install_path, 0o755)!

	println('Successfully updated!')
}

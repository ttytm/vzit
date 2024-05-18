import os
import time
import v.util.diff

const vzit_exe = os.join_path(@VMODROOT, 'vzit')
const zig_exe = os.find_abs_path_of_executable('zig') or { panic('failed to find `zig`') }
const zig_tmod = os.join_path(@VMODROOT, 'tests', 'basic')
const tmp_tmod = os.join_path(os.temp_dir(), 'vzit', 'tests', 'basic')

fn testsuite_begin() {
	os.mkdir_all(tmp_tmod) or {}
	if !os.exists(vzit_exe) {
		os.chdir(@VMODROOT)!
		os.execute_opt('${@VEXE} -o vzit .')!
	}
}

fn testsuite_end() {
	os.rmdir_all(tmp_tmod) or {}
}

fn test_basic() {
	os.cp_all(zig_tmod, tmp_tmod, true)!

	// Should list all .zig files in the module as unformatted.
	list_res := os.execute('${vzit_exe} -l ${tmp_tmod}')
	list_res_lines := list_res.output.split_into_lines()
	assert list_res_lines == os.walk_ext(tmp_tmod, '.zig').filter(!it.contains('zig-cache'))

	// Should modify a file when specifying -w with an unformatted file.
	tfile_path1 := os.join_path(tmp_tmod, 'build.zig')
	mtime_pre_fmt1 := os.file_last_mod_unix(tfile_path1)
	time.sleep(time.second * 1)
	os.execute('${vzit_exe} -w ${tfile_path1}')
	mtime_post_fmt1 := os.file_last_mod_unix(tfile_path1)
	assert mtime_post_fmt1 > mtime_pre_fmt1

	// Should NOT modify an already formatted file again.
	os.execute('${vzit_exe} -w ${tfile_path1}')
	time.sleep(time.second * 1)
	assert mtime_post_fmt1 == os.file_last_mod_unix(tfile_path1)

	// Should print a shorter list after files have been formatted.
	list_res2 := os.execute('${vzit_exe} -l ${tmp_tmod}')
	list_res2_lines := list_res2.output.split_into_lines()
	assert list_res2_lines.len == list_res_lines.len - 1
	assert tfile_path1 !in list_res2_lines

	// Should work with multiple paths.
	tfile_path2 := os.join_path(tmp_tmod, 'src', 'root.zig')
	mtime_pre_fmt2 := os.file_last_mod_unix(tfile_path2)
	os.execute('${vzit_exe} -w ${tfile_path1} ${tfile_path2}')
	time.sleep(time.second * 1)
	assert os.file_last_mod_unix(tfile_path2) > mtime_pre_fmt2
	list_res3 := os.execute('${vzit_exe} -l ${tmp_tmod}')
	list_res3_lines := list_res3.output.split_into_lines()
	assert list_res3.exit_code == 1
	assert list_res3_lines.len == list_res_lines.len - 2
	assert list_res3_lines.len > 0

	// Should format all files in a directory.
	os.execute('${vzit_exe} -w ${tmp_tmod}')
	list_res4 := os.execute('${vzit_exe} -l ${tmp_tmod}')
	assert list_res4.exit_code == 0
	assert list_res4.output == ''

	// Should have the expected result for formatted files.
	mut has_err := false
	for path in os.walk_ext(tmp_tmod, '.zig') {
		if path.contains('zig-cache') || path.contains('dependencies.zig') {
			continue
		}
		formatted_res := os.read_file(path)!.replace('\r\n', '\n')
		formatted_exp := os.read_file(path + '.expect')!.replace('\r\n', '\n')
		diff_ := diff.compare_text(formatted_res, formatted_exp)!
		if diff_ != '' {
			println(diff_)
			has_err = true
		}
	}
	assert !has_err

	// Should build and run a formatted module.
	os.chdir(tmp_tmod)!
	output := os.execute('${zig_exe} build run').output
	assert output.contains('All your codebase are belong to us.'), output
}

fn test_exit_codes() {
	os.cp_all(zig_tmod, tmp_tmod, true)!

	default_res_pre_fmt := os.execute('${vzit_exe} ${tmp_tmod}')
	assert default_res_pre_fmt.exit_code == 0
	list_res_pre_fmt := os.execute('${vzit_exe} -l ${tmp_tmod}')
	assert list_res_pre_fmt.exit_code == 1
	diff_res_pre_fmt := os.execute('${vzit_exe} -d ${tmp_tmod}')
	assert diff_res_pre_fmt.exit_code == 1
	write_res_pre_fmt := os.execute('${vzit_exe} -w ${tmp_tmod}')
	assert write_res_pre_fmt.exit_code == 0

	default_res_post_fmt := os.execute('${vzit_exe} ${tmp_tmod}')
	assert default_res_post_fmt.exit_code == 0
	list_res_post_fmt := os.execute('${vzit_exe} -l ${tmp_tmod}')
	assert list_res_post_fmt.exit_code == 0
	diff_res_post_fmt := os.execute('${vzit_exe} -d ${tmp_tmod}')
	assert diff_res_post_fmt.exit_code == 0
}

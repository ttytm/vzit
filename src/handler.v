import os
import v.util.diff

const space_num = 4
const space_indent = ' '.repeat(space_num)

fn format(input string, input_after_zig_fmt string) !string {
	mut res := []string{}
	for l in input_after_zig_fmt.split_into_lines() {
		mut indent_level := 0
		for l[indent_level * space_num..].starts_with(space_indent) {
			indent_level++
		}
		if indent_level > 0 {
			res << '${'\t'.repeat(indent_level)}${l[indent_level * space_num..]}'
		} else {
			res << l
		}
	}
	return res.join_lines() + '\n'
}

// Detect indentation style.
fn has_space_indent(input string) bool {
	input_lines := input.split_into_lines()
	for l in input_lines#[..50] {
		if l != '' {
			match l[0] {
				` ` { return true }
				`\t` { return false }
				else { continue }
			}
		}
	}
	return true
}

fn (mut v Vzit) handle(path string) ! {
	input := os.read_file(path)!

	tmp_path := os.join_path(tmp_dir, os.file_name(path))
	os.write_file(tmp_path, input)!
	os.execute_opt('zig fmt ${tmp_path}')!
	input_after_zig_fmt := os.read_file(tmp_path)!

	res := if v.indentation != .tabs && has_space_indent(input) {
		// Until support for spaces is extended to include features like viewing diffs,
		// just zig fmt when a space-indented file is encountered without using the force flag.
		input_after_zig_fmt
	} else {
		format(input, input_after_zig_fmt)!
	}

	if !v.write && !v.diff && !v.list {
		print(res)
		flush_stdout()
	}
	if input == res {
		return
	}
	v.has_diff = true
	if v.diff || v.write {
		res_tmp_path := os.join_path(tmp_dir, os.file_name(path))
		os.write_file(res_tmp_path, res)!
		if v.diff {
			println(diff.compare_files(path, res_tmp_path, env_overwrite_var: env_diff_tool)!)
		}
		if v.write {
			os.mv(res_tmp_path, path)!
		}
	}
	if v.list {
		println(path)
	}
}

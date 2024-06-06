import os
import cli
import term
import v.vmod

const manifest = vmod.decode(@VMOD_FILE) or { panic(err) }
const tmp_dir = os.join_path(os.temp_dir(), 'vzit')
const env_diff_tool = 'VZIT_DIFF_CMD'

struct Vzit {
	write bool
	list  bool
	diff  bool
	style Style
mut:
	has_diff bool
}

enum Style {
	tabs
	smart
	spaces
}

fn main() {
	mut app := cli.Command{
		name: manifest.name
		usage: '<path>

${manifest.description}
By default, formatted output is written to stdout.'
		version: '${manifest.version}@${@VMODHASH}'
		posix_mode: true
		pre_execute: verify
		execute: run
		defaults: struct {
			man: false
			help: cli.CommandFlag{true, true}
			version: cli.CommandFlag{true, true}
		}
		flags: [
			cli.Flag{
				flag: .bool
				name: 'write'
				abbrev: 'w'
				description: 'Modifies non-conforming files in-place.'
			},
			cli.Flag{
				flag: .bool
				name: 'list'
				abbrev: 'l'
				description: 'Prints paths of non-conforming files. Exits with an error if any are found.'
			},
			cli.Flag{
				flag: .bool
				name: 'diff'
				abbrev: 'd'
				description: 'Prints differences of non-conforming files. Exits with an error if any are found.'
			},
			cli.Flag{
				flag: .string
				name: 'style'
				description: "[possible values: 'tabs', 'smart', '<num>'(spaces)].\n- tabs: used by default.\n- smart: detects the indentation style.\n- <num>: [TODO] currently, passing a number uses the default zig fmt indentation of 4 spaces."
			},
		]
		commands: [
			cli.Command{
				name: 'update'
				description: 'Updates vizit to the latest version.'
				execute: update
			},
		]
	}
	app.parse(os.args)
}

fn run(cmd cli.Command) ! {
	mut v := Vzit{
		write: cmd.flags.get_bool('write')!
		list: cmd.flags.get_bool('list')!
		diff: cmd.flags.get_bool('diff')!
		style: parse_style(cmd.flags.get_string('style')!)
	}
	for path in cmd.args {
		if os.is_dir(path) {
			for file in os.walk_ext(path, '.zig') {
				v.handle(file) or {
					print_err(err.msg())
					continue
				}
			}
		} else {
			v.handle(path) or {
				print_err(err.msg())
				continue
			}
		}
	}
	if v.has_diff && (v.list || v.diff) {
		exit(1)
	}
}

fn parse_style(raw_style string) Style {
	if raw_style == '' {
		return .tabs
	}
	return match true {
		raw_style == 'tabs' { .tabs }
		raw_style == 'smart' { .smart }
		raw_style.int() != 0 { .spaces }
		else { print_err_and_exit('invalid style `${raw_style}`') }
	}
}

fn verify(cmd cli.Command) ! {
	os.find_abs_path_of_executable('zig') or { print_err_and_exit('failed to find `zig`') }
	if cmd.args.len == 0 {
		cmd.execute_help()
		exit(2)
	}
	mut has_invalid_path := false
	for path in cmd.args {
		if !os.exists(path) {
			print_err('failed to find path `${path}`')
			has_invalid_path = true
		}
	}
	if has_invalid_path {
		exit(2)
	}
	if !os.exists(tmp_dir) {
		os.mkdir(tmp_dir) or { print_err_and_exit(err.msg()) }
	}
}

fn print_err(msg string) {
	eprintln(term.ecolorize(term.red, 'error: ') + msg)
}

@[noreturn]
fn print_err_and_exit(msg string) {
	eprintln(term.ecolorize(term.red, 'error: ') + msg)
	exit(2)
}

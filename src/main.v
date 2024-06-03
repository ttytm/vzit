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
mut:
	has_diff bool
}

fn main() {
	mut app := cli.Command{
		name: manifest.name
		usage: '<path>

${manifest.description}
By default, formatted output is written to stdout.'
		version: '${manifest.version}@${@VMODHASH}'
		pre_execute: verify
		execute: run
		posix_mode: true
		defaults: struct {
			man: false
			help: cli.CommandFlag{false, true}
			version: cli.CommandFlag{false, true}
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
				flag: .bool
				name: 'use-spaces'
				description: '[TODO] Allows usage when kept in custody in a space-indented codebase.'
			},
		]
		commands: [
			cli.Command{
				name: 'update'
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

fn verify(cmd cli.Command) ! {
	os.find_abs_path_of_executable('zig') or { print_err_and_exit('failed to find `zig`') }
	if cmd.args.len == 0 {
		cmd.execute_help()
		exit(2)
	}
	if cmd.flags.get_bool('use-spaces')! {
		print_err_and_exit('Usage of vzit with space-indented files is yet to be implemented.

Visit its repository to support the project and to show interest in new features:
${term.ecolorize(term.italic,
			'https://github.com/ttytm/vzit')}')
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

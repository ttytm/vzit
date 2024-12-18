import os
import cli
import term
import v.vmod

const manifest = vmod.decode(@VMOD_FILE) or { panic(err) }
const tmp_dir = os.join_path(os.temp_dir(), 'vzit')
const env_diff_tool = 'VZIT_DIFF_CMD'

struct Vzit {
	write       bool
	list        bool
	diff        bool
	indentation Indentation
mut:
	has_diff bool
}

type Indentation = IndentationStyle | u8

enum IndentationStyle {
	tabs
	smart
}

fn main() {
	mut app := cli.Command{
		name:        manifest.name
		usage:       '<path>

${manifest.description}
By default, formatted output is written to stdout.'
		version:     '${manifest.version}@${@VMODHASH}'
		posix_mode:  true
		pre_execute: verify
		execute:     run
		defaults:    struct {
			man:     false
			help:    cli.CommandFlag{true, true}
			version: cli.CommandFlag{true, true}
		}
		flags:       [
			cli.Flag{
				flag:        .bool
				name:        'write'
				abbrev:      'w'
				description: 'Modifies non-conforming files in-place.'
			},
			cli.Flag{
				flag:        .bool
				name:        'list'
				abbrev:      'l'
				description: 'Prints paths of non-conforming files. Exits with an error if any are found.'
			},
			cli.Flag{
				flag:        .bool
				name:        'diff'
				abbrev:      'd'
				description: "Prints differences of non-conforming files. Exits with an error if any are found.\n- The '${env_diff_tool}' environment variable allows setting a custom diff command."
			},
			cli.Flag{
				flag:        .string
				name:        'indentation'
				abbrev:      'i'
				description: "Sets the indentation used [possible values: 'tabs', 'smart', '<num>'(spaces)].\n- tabs: used by default.\n- smart: based on the initial indentations in a file.\n- <num>: number of spaces."
			},
		]
		commands:    [
			cli.Command{
				name:        'update'
				description: 'Updates vizit to the latest version.'
				execute:     fn (_ cli.Command) ! {
					update() or { print_err_and_exit(err.msg()) }
				}
			},
		]
	}
	app.parse(os.args)
}

fn run(cmd cli.Command) ! {
	mut v := Vzit{
		write:       cmd.flags.get_bool('write')!
		list:        cmd.flags.get_bool('list')!
		diff:        cmd.flags.get_bool('diff')!
		indentation: parse_indentation(cmd.flags.get_string('indentation')!)
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

fn parse_indentation(raw_style string) Indentation {
	if raw_style == '' {
		return IndentationStyle.tabs
	}
	return match true {
		raw_style == 'tabs' { IndentationStyle.tabs }
		raw_style == 'smart' { IndentationStyle.smart }
		raw_style.u8() != 0 { raw_style.u8() }
		else { print_err_and_exit('invalid indentation value `${raw_style}`') }
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
	print_err(msg)
	exit(2)
}

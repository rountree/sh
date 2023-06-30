# Workflow
#
# 1. "make templates" to generate a nop.xxd file
# 2. Rename template.xxc to my_project_name.xxc
# 		The convention is that xxc files can contain comments while xxd
# 		files are stripped of comments.
# 3. Edit the xxc file.
#		Any line beginning with # will be treated as a comment and removed.
#		Any text beyond the four bytes of hexidecimal data will be ignored.
# 4. "make my_project_name" will create a my_project_name.xxd file, an executable
# 		binary named my_project_name, and a my_project_name.objdump that
# 		contains the results of objdump --disassemble my_project_name.
# 		The binary permissions will be set to 700.
# 5. After further edits to my_project_name.xxc, run "make clean" before
# 		re-running "make my_project_name".
#
# Note that a binary created from the nop.c file will fail in some unspecififed
# way due based on the rest of the environment.
#
#
# Use "make versions" for debugging help.
#

template: nop.c
	gcc -o nop -nostdlib nop.c
	xxd -c4 nop > template.xxc
	rm -f nop

versions:
	rm -f VERSIONS
	for d in xxd gcc objdump make bash gdb ; do \
		$$d --version >> VERSIONS 2>&1 ; \
		echo >> VERSIONS ; \
	done
	uname -a >> VERSIONS 2>&1

clean:
	find . -maxdepth 1 -executable -type f -delete
	rm -f *.xxd *.objdump

%:
	sed "/^#/d" $@.xxc > $@.xxd					# Remove comments from binary dump
	xxd -c4 -r $@.xxd $@						# Creates binary from binary dump
	objdump --disassemble $@ > $@.objdump 2>&1	# Nice sanity check
	chmod 700 $@								# Makes the binary executable


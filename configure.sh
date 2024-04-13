#!/bin/bash

function errmsg {
	echo $1
	exit
}

makefile_keys=("PROJ_COMPILER" \
	"PROJ_ARCH" \
	"PROJ_SYSROOT" \
	"PROJ_NAME")

declare -A tab_makefile_arch
tab_makefile_arch["aarch64"]="aarch64-none-linux-android23"
tab_makefile_arch["armv7a"]="armv7a-linux-androideabi23"
tab_makefile_arch["amd64"]="x86_64-pc-linux-gnu"

declare -A tab_makefile_variable

function line_parser {
	key=`echo $1 | cut -d'=' -f1`
	value=`echo $1 | cut -d'=' -f2`

	# echo "parsed result"
	# echo $key
	# echo $value
	tab_makefile_variable[$key]=$value
}

function mk_cce_makefile {
	cat << EOF > Makefile
CC = ${tab_makefile_variable["PROJ_COMPILER"]}
CFLAGS = -c \
--target=${tab_makefile_arch[${tab_makefile_variable["PROJ_ARCH"]}]} \
--sysroot=${tab_makefile_variable["PROJ_SYSROOT"]}
LDFLAGS = --target=${tab_makefile_arch[${tab_makefile_variable["PROJ_ARCH"]}]} 
EXENAME = ${tab_makefile_variable["PROJ_NAME"]}
SOURCES := \$(wildcard *.c)
OBJS = \${SOURCES:.c=.o}

all: \${OBJS}
	\$(CC) $^ \$(LDFLAGS) -o \$(EXENAME)

.c.o:
	\$(CC) \$(CFLAGS) \$^

clean:
	rm -f \${OBJS} \$(EXENAME)
EOF

}

function mk_non_cce_makefile {
	cat << EOF > Makefile
CC = ${tab_makefile_variable["PROJ_COMPILER"]}
CFLAGS = -c \
--target=${tab_makefile_arch[${tab_makefile_variable["PROJ_ARCH"]}]}
LDFLAGS = --target=${tab_makefile_arch[${tab_makefile_variable["PROJ_ARCH"]}]} 
EXENAME = ${tab_makefile_variable["PROJ_NAME"]}
SOURCES := \$(wildcard *.c)
OBJS = \${SOURCES:.c=.o}

all: \${OBJS}
	\$(CC) $^ \$(LDFLAGS) -o \$(EXENAME)

.c.o:
	\$(CC) \$(CFLAGS) \$^

clean:
	rm -f \${OBJS} \$(EXENAME)
EOF

}

function mk_makefile {
	if [ "${tab_makefile_variable["PROJ_ARCH"]}" = "amd64" ]; then
		mk_non_cce_makefile
	else
		mk_cce_makefile
	fi
}

function main {
	if [ ! -f ./config ]; then
		errmsg "config file not found..\n"
	fi

	while IFS= read -r line; do
		# echo ${line:0:1}

		if [ -z "$line" ]; then
			# echo "empty"
			continue
		fi

		if [ "${line:0:1}" = "#" ]; then
			# echo "comment $line"
			continue
		fi

		line_parser $line
	done < ./config

	for key in ${makefile_keys[*]}; do
		echo ${tab_makefile_variable[$key]}
	done

	mk_makefile
}

main

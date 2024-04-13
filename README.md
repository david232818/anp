# anp

## Build
First, you have to set some values in the config file. These are descriped below.

 - `PROJ_COMPILER`: Path of a compiler that is used for building
 - `PROJ_ARCH`: Target architecture of the project: aarch64, armv7a, amd64
 - `PROJ_SYSROOT`: Path of target headers and etc for cross compiling
 - `PROJ_NAME`: Project name which will be a name of a generated executable

When above variables are setted correctly, execute configure.sh script to generate Makefile like the following.

```Bash
chmod +x ./configure.sh && ./configure.sh
```

After the execution, a Makefile will appear in your working directory. Then execute make to build your C project.

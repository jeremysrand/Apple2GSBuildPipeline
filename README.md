Apple2GSBuildPipeline
=====================

A build pipeline for making Apple IIgs software on macOS.

Features:
---------

This project was built using a similar approach as the one I created for [8-bit Apple //'s](https://github.com/jeremysrand/Apple2BuildPipeline).  I used cc65 in the 8-bit tools but this build environment uses the [ORCA languages](https://juiced.gs/store/opus-ii-software/) and [Golden Gate](http://golden-gate.ksherlock.com) from Kelvin Sherlock.  You can also use [Merlin32](https://www.brutaldeluxe.fr/products/crossdevtools/merlin/) from Brutal Deluxe.  Note that you still need ORCA and GoldenGate for Merlin targets because of how disk images are created in the build and the ORCA resource compiler is used for Merlin targets.

Features of this build environment include:

   * Attempts to hide all of the infrastructure which you don't need to modify in a make directory.
   * Supports linking together multiple ORCA/C and ORCA/M assembly files.  To add a new file to the project, just create a new *.c or *.s file in the project directory.
   * Supports a single resource file in your project.  Any files included in your resource files are detected in the build and if you change the header, the resource file will rebuild automatically.
   * Supports putting your source files in multiple directories.  Just make sure to add those directories to the SRCDIRS variable in the root Makefile.  Once you add the source directory to the build, any source files in that directory will automatically be built and linked into your executable.
   * If you change a header file, the right source files will rebuild automatically.  Header file dependencies are generated during the build.
   * If you change a macro file used by one or more assembly source files, the right files will be re-assembled automatically.  Assembly file dependencies are generated during the build.
   * Supports project types like ORCA or GNO shell executable, GUI executable, new desk accessory, classic desk accessory and control panel.  In Xcode, when you create a project, you will see options for each of these project types.  Select one and you will have a skeleton project which includes enough code to give you a basic "hello world" style application of that type.
   * For shell targets, when you build and run, the shell command is executed right in Xcode itself using Golden Gate.  You can edit your run scheme configuration in Xcode to customize the arguments passed to your shell command.
   * Creates a bootable disk image from a template as part of the build for non-shell targets.  If your target is a CDA, NDA or CDev, the executable is copied to the appropriate place in the System folder.
   * Creates a distribution disk image with your build products on it.  Also, it creates a ShrinkIt archive of your distribution as part of the build.
   * Automatically launches an Apple //gs emulator when you select build and run so you can go from coding to testing your latest build as quickly as possible.  GSPort, GSPlus and mame are the supported emulators.  It boots to the bootable disk image created and the distribution disk image is open in the Finder when the emulatoed machine boots.
   * Write documenation for your project in markdown in Xcode and commit the markdown files into git.  At build time, these markdown files can be optionally converted to a Teach text file format and copied into your distribution.  That way, you can write your documentation in a form that is easy to manage on the "modern" side and have that converted to something usable on a GS.
   * C source and header files (including ORCA system includes) are indexed by Xcode.  By doing this, code completion and other features of Xcode should work.  That means, if you are coding in C and type "NewW", Xcode will suggest the toolbox calls NewWindow() and NewWindow2().  Select the one you want and Xcode fills it in, including the arguments that the toolbox call expects.
   * There is an optional code generation phase in the build.  If you want to write some scripts which generate C source files, C header files or assembly files which are then compiled/assembled in later phases of the build, this would let you do exactly that.
   * You can copy a directory of files onto the disk image beyond just the executable.  This is useful if you have other files you need to generate and/or distribute in your project.
   * Syntax highlighting and better editor support for ORCA/M assembly, Merlin assembly and resource files.  Keywords are completed and highlighted.  Indentation between start/end and data/end tokens for assembly and inside braces for resource files should be automatic.
   * Errors returned by the ORCA/C compiler, the ORCA/M assembler, the resource compiler and the Merlin assembler are now understood by Xcode.  The error will be visible in the editor itself and Xcode will jump to the line reported by the compiler to contain the error.


MacOS  Versions:
----------------

I have tested these build tools under MacOS 11 (Big Sur) and things do seem to work for me.  However, most of my development is still done under MacOS 10.15 so it could be that there are some unknown issues on the latest OS.  I plan to update my main machine to MacOS 11 soon so hopefully I will find any remaining issues then.  In the meantime, if you are trying to use these tools on MacOS 11 right now and are having problems, please contact me and I will try to help.

And when it comes to Apple silicon, I have no specific plans right now to purchase new hardware so I cannot do any testing.  However, there are no binaries in this package itself since it is just makefiles, scripts and Xcode configuration files.  Assuming that Golden Gate and Fuse work on Apple silicon, I don't expect any specific issues with these scripts when run on Apple silicon.  But again, I have no ability to test that right now so I cannot make any guarantees.


MacOS  Installation:
--------------------

In order to use this infrastructure from macOS, follow these instructions:
   1. Install [Xcode from Apple](https://itunes.apple.com/us/app/xcode/id497799835?mt=12&uo=4).  Xcode is generally the most popular app in the Mac App Store in the "Developer Tools" category.  Xcode is free and you do not need to be a registered Apple developer to download and use it, especially if you are building Apple II programs.
   2. You need to have Orca/C or Orca/M.  If you have purchased these development tools for the Apple IIgs in the past, you should be able to use what you have.  If you don't have access to these tools, Juiced.GS sells all of the tools as [Opus II: The Software](https://juiced.gs/store/opus-ii-software/) from their store for a reasonable price.
   3. You also need [Golden Gate](https://juiced.gs/store/golden-gate/) which is also available for a reasonable price from the Juiced.GS store.  Golden Gate allows the Orca tools to execute from a modern Mac (or Windows and Linux system also).  Follow the installation instructions for Golden Gate.  If you want to convert markdown files to Teach files, you need a version of Golden Gate greater than 2.0.5.  There is a beta build called "rwrez-1" which has the necessary support at this time.  A future version of Golden Gate should have this functionality built-in but for now, this beta version is required for markdown to Teach conversion.
   4. Install [FUSE for macOS](https://osxfuse.github.io).  FUSE is required for ProFuse which you will install next.
   5. Install ProFUSE.  It is distributed with Golden Gate.  When you purchase Golden Gate, you should be given access to a GitLab repository.  Among the projects there is ProFUSE which allows your Mac to mount ProDOS volumes.  This is used by the build environment to create the bootable disk images.
   5. Install the [Apple IIgs project template](https://github.com/jeremysrand/Apple2GSBuildPipeline/releases/download/3.0/Apple2GSXcodeTemplate.pkg).  Note that the next time you launch Xcode, you will be asked whether to load the OrcaM.ideplugin.  This is part of the project template and will provide better syntax highlighting for assembly and resource files.  Select the "Load Bundle" option in the dialog that Xcode shows you.
   6. Install and setup the [GSPlus](https://apple2.gs/plus/) emulator, the [GSPort](http://gsport.sourceforge.net) emulator and or the mame emulator which is easiest to install using [Ample](https://github.com/ksherlock/ample).  Each emulator should work.  No matter which you choose, make sure you put a copy of your Apple //gs' ROM into a file called ~/Library/GSPort/ROM (where ~ represents your user's home directory).  Unfortunately, the Finder by default hides the Library folder from you so the easiest way to accomplish this is probably from the Terminal.
   7. If you plan to use Merlin32 based projects, install the [Merlin32 binaries and libraries](https://www.brutaldeluxe.fr/products/crossdevtools/merlin/). By default, the build system assumes you have installed the Merlin32 binary in /usr/local/bin and put the library macro files in /usr/local/lib/Merlin. If you installed them somewhere else, you can override these location in your projects.  Note that in the distribution, the macro files in the library had CR/LF line endings and did not work until I converted them to have LF line endings.


Your First Project:
-------------------

Everything you need is now installed.  To create a new Apple //gs project in Xcode:
   1. Start Xcode and create a new project by using File->New->Project...
   2. In the dialog, you will see a "Cross-platform" tab at the top.  Select that and you will see a section for Apple //gs projects.  Select the project type you want to create and click "Next".
   3. A dialog box with a few text fields will appear.  In product name, put in the name of the Apple //gs executable you want to build.  Organization Name and Organization Identifier can be anything you want it to be.  Leave Build Tool set to "/usr/bin/make".  Click "Next".
   4. Xcode now prompts you where you want to save your project.  The name of the project will be the product name you already gave.  Pick a good directory for your project.  Your Documents folder is a reasonable option.  Click "Create".
   5. Your project is now ready for you.  If you select Product->Build, it will build.  To see the resulting executable, right click on the Makefile file in the left pane and select "Show in Finder".  You should see the executable in the Finder window that just opened.
   6. If you click the button on the upper left which looks like a play button or hit Command-R, your project will be built and run.  If you have a shell target, your build will execute in Xcode itself.  For desktop applications, CDAs, NDAs and CDEVs, your emulator will be launched with your executable on the boot disk.
   7. Review the Makefile and set any options you want.  The file has lots of comments to help you understand the configuration options.
   8. Change main.c (or main.s if you created an assembly project) and write more code in new C or assembly files until you have the program you always wanted to build.  To add new files, select File->New->File.  In the dialog, you will see an Apple //gs option in the macOS section.  Select that and in there, you will see options to create a new "C File", new "Assembly File" or new "Resource File".  Select the one you want to add the file to your project.  Put the new file in the same directory as Makefile.  You can add assembly files in a C project or add C files in an assembly project.  The only difference between them is the type of the default source file in the project template.


Common Problems:
----------------

There are some known issues which can crop up:
   * If you are using APFS (the latest filesystem) on High Sierra, you may have a problem with resources.  Make sure you have the latest version of Golden Gate.  The latest version has fixed these issues.
   * If you aren't seeing the "ORCA Assembly" or "ORCA Resources" options under Editor->Syntax Coloring, you may be having an Xcode compatibility problem.  These syntax colouring files are provided as part of an Xcode plugin and plugins must advertize their compatibility.  During install, the plugin is set to be compatible with the version of Xcode you have.  If you upgrade Xcode, the plugin will be assumed to be incompatible and will not be loaded.  To workaround this, we force the plugin to be marked as compatiable on every build of a Apple //gs target.  So, you should do a build and then quit and re-launch Xcode.  You should see a warning asking if you want to load the plugin and if you allow the plugin to load, you should see the ORCA syntax colouring options.
   * If you get an error like "make: getcwd: Operation not permitted" when you do a build or build and run from Xcode, you may need to grant full disk access to make.  Go to System Preferences, then Security & Privacy and then the Privacy tab.  In there, you should see a section for "Full Disk Access".  Click the lock button if necessary to authenticate.  In a terminal, type "open /usr/bin".  A Finder window should open and you can find the make executable in there.  Drag and drop the make executable into the "Full Disk Access" section and ensure that the entry for it is selected to grant that access.  That should fix the problem.

If these suggestions do not help or you are having some other problem, please contact me and I will try to help you out.


UNIX Installation:
------------------

This build infrastructure can be used in a non-Mac environment.  The Makefile infrastructure should work on any UNIX-y platform.  You will still need Golden Gate and the ORCA tools setup on your machine.  Just add the Makefile and the contents of the make directory to your project.  Modify the Makefile as appropriate and you should have a build environment which you can use with the make command.

Thanks to [xandark](https://github.com/xandark) who has done some testing of the build scripts under Linux.  Thanks to that work and the issues raised, I have more confidence that these build scripts should work on non-MacOS platforms.  Feel free to submit issues if you find problems.


Possible Future Improvements:
-----------------------------

   * Support Hypercard XCMDs and Hyperstudio new button action project templates
   * Support Finder Extra project templates
   * Support other ORCA languages like Pascal, Modula-2 or Basic.
   * Allow multiple resource files and concatenate the resources together into the final executable.


Acknowledgements:
-----------------

Thanks to Mike Westerfield for the ORCA environment and languages and Kelvin Sherlock for Golden Gate which allows us to use those tools under modern systems making this build environment possible.  Thanks to Brutal Deluxe for Merlin32.

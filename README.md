Apple2GSBuildPipeline
=====================

A build pipeline for making Apple IIgs software on OS X.

Features:
=========

This project was built using a similar approach as the one I created for [8-bit Apple //'s](https://github.com/jeremysrand/Apple2BuildPipeline).  I used cc65 in the 8-bit tools but this build environment uses the [ORCA languages](https://juiced.gs/store/opus-ii-software/) and [Golden Gate](http://golden-gate.ksherlock.com) from Kelvin Sherlock.

Features of this build environment include:

   * Attempts to hide all of the infrastructure which you don't need to modify in a make directory.
   * Supports linking together multiple C and assembly files.  To add a new file to the project, just create a new *.c or *.s file in the project directory.
   * Supports a single resource file in your project.  Any files included in your resource files are detected in the build and if you change the header, the resource file will rebuild automatically.
   * Supports putting your source files in multiple directories.  Just make sure to add those directories to the SRCDIRS variable in the root Makefile.  Once you add the source directory to the build, any source files in that directory will automatically be build and linked into your executable.
   * If you change a header file, the right source files will rebuild automatically.  Header file dependencies are generated during the build.
   * If you change a macro file used by one or more assembly source files, the right files will be re-assembled automatically.  Assembly file dependencies are generated during the build.
   * Supports projects types like ORCA shell executable, GUI executable, new desk accessory, classic desk accessory and control panel.  In Xcode, when you create a project, you will see options for each of these project types.  Select one and you will have a skeleton project which includes enough code to give you a basic "hello world" style application of that type.
   * Creates a disk image with your executable as part of the build.
   * Automatically launch your application in an Apple //gs emulator on build and run so you can go from coding to testing your latest build as quickly as possible.
   * C source and header files (including system includes) are indexed.  By doing this, code completion and other features of Xcode should work.  In other words, you can code complete to a toolbox call for example!
   * There is an optional code generation phase in the build.  If you want to write some scripts which generate C source files, C header files or assembly files which are then compiled/assembled in later phases of the build, this would let you do exactly that.
   * You can copy a directory of files onto the disk image other than just the executable.  This is useful if you have other files you need to generate and/or distribute in your project.
   * Syntax highlighting and better editor support for ORCA/M assembly files.

Other features which I am considering but may never deliver include:

   * Support Hypercard XCMDs and Hyperstudio new button action project templates
   * Provide assembly project templates for all project types.  Today, I only provide an assembly project template for the shell target.
   * Support other ORCA languages like Pascal, Modula-2 or Basic.
   * Allow multiple resource files and concatenate the resources together into the final executable.
   * Add support for Merlin32 based assembly projects in Xcode.  This is the other major cross compilation/assembly tool available today for Apple //gs coding.

Mac OS X Installation:
----------------------

I am not at what I would call a version 1.0 yet so I am not distributing a installable package.  But you can make your own if you really don't want to wait.  You need to have ORCA and Golden Gate already installed on your machine for any of this to work.

To build the installable package, execute "make createPackage" in the root directory of this repository.  If you do this, you should see a file called "Apple2GSXcodeTemplate.pkg" in the root directory.  Install that and you should see that you have the Xcode project templates now.

In the future, I will distribute a signed installable package but not yet.

Your First Project:
-------------------

Everything you need is now installed.  To create a new Apple //gs project in Xcode:
   1. Start Xcode and create a new project by using File->New->Project...
   2. In the dialog, you will see a "Cross-platform" tab at the top.  Select that and you will see a section for Apple //gs projects.  Select the project type you want to create and click "Next".
   3. A dialog box with a few text fields will appear.  In product name, put in the name of the Apple //gs executable you want to build.  Organization Name and Organization Identifier can be anything you want it to be.  Leave Build Tool set to "/usr/bin/make".  Click "Next".
   4. Xcode now prompts you where you want to save your project.  The name of the project will be the product name you already gave.  Pick a good directory for your project.  Your Documents folder is a reasonable option.  Click "Create".
   5. Your project is now ready for you.  If you select Product->Build, it will build.  To see the resulting executable, right click on the Makefile file in the left pane and select "Show in Finder".  You should see the executable in the Finder window that just opened.
   6. At this point, you can start Sweet16 or some other Apple //gs emulator.  With Sweet16, you can drag the executable into the //gs Finder and the emulator should copy it for you.  Once copied, you should be able to launch it (depending on the target type, double click may or may not launch it).
   7. Review the Makefile and set any options you want.  The file has lots of comments to help you understand the configuration options.
   8. Change main.c (or main.s if you created an assembly project) and write more code in new C or assembly files until you have the program you always wanted to build.  To add new files, select File->New->File.  In the dialog, you will see an Apple //gs option in the OS X section.  Select that and in there, you will see options to create a new C file or a new Assembly File.  Select the one you want to add the file to your project.  Put the new file in the same directory as Makefile.  You can add assembly files in a C project or add C files in an assembly project.  The only difference between them is the type of the default source file in the project template.

UNIX Installation:
------------------

This build infrastructure can be used in a non-Mac environment.  The Makefile infrastructure should work on any UNIX-y platform.  You will still need Golden Gate and the ORCA tools setup on your machine.  Just add the Makefile and the contents of the make directory to your project.  Modify the Makefile as appropriate and you should have a build environment which you can use with the make command.

That said, I haven't tested this on any other platform to show this is actually true.

Acknowledgements:
-----------------

Thanks to Mike Westerfield for the ORCA environment and languages and Kelvin Sherlock for Golden Gate which allows us to use those tools under modern systems making this build environment possible.

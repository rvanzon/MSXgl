:: ____________________________
:: ██▀▀█▀▀██▀▀▀▀▀▀▀█▀▀█        │  ▄▄▄       ▄  ▄▄    ▄▄   ▄▄▄▄           ▄▄
:: ██  ▀  █▄  ▀██▄ ▀ ▄█ ▄▀▀ █  │  ██▄▀ ██ █ ▄  ██   ▄██    ██  ▄█▀▄ ▄█▀▄ ██
:: █  █ █  ▀▀  ▄█  █  █ ▀▄█ █▄ │  ██▄▀ ▀█▄█ ██ ▀█▄ ▀▄██    ██  ▀█▄▀ ▀█▄▀ ▀█▄
:: ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀────────┘  
::  by Guillaume 'Aoineko' Blanchard under CC BY-SA license
::─────────────────────────────────────────────────────────────────────────────
@echo off

::─────────────────────────────────────────────────────────────────────────────
:: Build Tool default configuration
::─────────────────────────────────────────────────────────────────────────────

::*****************************************************************************
:: DIRECTORIES SETTINGS
::*****************************************************************************

set ProjDir=.
set FullProjDir=%~d1%~p1
set OutDir=%ProjDir%\out
set LibDir=%ProjDir%\..\..\engine
set ToolsDir=%ProjDir%\..\..\tools

::*****************************************************************************
:: TOOLS SETTINGS
::*****************************************************************************

set Compiler=%ToolsDir%\sdcc\bin\sdcc.exe
set Assembler=%ToolsDir%\sdcc\bin\sdasz80.exe
set Linker=%ToolsDir%\sdcc\bin\sdcc.exe
set MakeLib=%ToolsDir%\sdcc\bin\sdar.exe
set Hex2Bin=%ToolsDir%\MSXtk\bin\MSXhex.exe
set MSXDOS=%ToolsDir%\build\DOS
set DskTool=%ToolsDir%\build\DskTool\dsktool.exe
set Emulator=
REM set Emulator=%ToolsDir%\OpenMSX\openmsx.exe
REM set Emulator=%ToolsDir%\Emulicious\Emulicious.exe
REM set Emulator=%ToolsDir%\BlueMSX\blueMSX.exe
REM set Emulator=%ToolsDir%\MEISEI\meisei.exe
REM set Emulator=%ToolsDir%\fMSX\fMSX.exe
REM set Emulator=%ToolsDir%\RuMSX\MSX.exe
set Debugger=
REM set Debugger=%ToolsDir%\OpenMSX\Debugger\openmsx-debugger.exe

::*****************************************************************************
:: PROJECT SETTINGS
::*****************************************************************************

:: Project name (will be use for output filename)
set ProjName=

:: Project modules to build (use ProjName if not defined)
set ProjModules=

:: Project segments base name (use ProjName if not defined)
set ProjSegments=

:: List of library modules to build
set LibModules=system,bios,vdp,print,input,memory

:: Additional sources
set AddSources=

:: MSX machine version:
:: - 1		MSX 1
:: - 2		MSX 2
:: - 12		MSX 1 or 2 (dual support)
:: - 2K		Korean MSX 2 (SC9 support)
:: - 2P		MSX 2+
:: - TR		MSX Turbo-R
:: - 3		MSX 3 (reserved)
set Machine=1

:: Program media target:
:: - BIN			.bin	BASIC binary program (8000h~)
:: - BIN_USR		.bin	BASIC USR binary driver (C000h~)
:: - ROM_8K			.rom	8KB ROM in page 1 (4000h ~ 5FFFh)
:: - ROM_8K_P2		.rom	8KB ROM in page 2 (8000h ~ 9FFFh)
:: - ROM_16K		.rom	16KB ROM in page 1 (4000h ~ 7FFFh)
:: - ROM_16K_P2		.rom	16KB ROM in page 2 (8000h ~ BFFFh)
:: - ROM_32K		.rom	32KB ROM in page 1-2 (4000h ~ BFFFh)
:: - ROM_48K		.rom	48KB ROM in page 0-2 (0000h ~ BFFFh). Pages 1-2 visible at start
:: - ROM_48K_ISR	.rom	48KB ROM in page 0-2 (0000h ~ BFFFh). Pages 0-2 visible at start
:: - ROM_64K		.rom	64KB ROM in page 0-3 (0000h ~ FFFFh). Pages 1-2 visible at start
:: - ROM_64K_ISR	.rom	64KB ROM in page 0-3 (0000h ~ FFFFh). Pages 0-2 visible at start
:: - ROM_ASCII8		.rom	128KB ROM using ASCII-8 mapper
:: - ROM_ASCII16	.rom	128KB ROM using ASCII-16 mapper
:: - ROM_KONAMI		.rom	128KB ROM using Konami mapper (8KB segments)
:: - ROM_KONAMI_SCC	.rom	128KB ROM using Konami SCC mapper (8KB segments)
:: - DOS1			.com	MSX-DOS 1 program (0100h~) No direct acces to Main-ROM
:: - DOS2			.com	MSX-DOS 2 program (0100h~) No direct acces to Main-ROM
:: - DOS2_ARG		.com	[WIP] MSX-DOS 2 program (using command line arguments ; 0100h~) No direct acces to Main-ROM. 
set Target=ROM_32K

:: ROM mapper size (from 64 to 4096). Must be a multiple of 8 or 16 depending on the mapper type
set ROMSize=

:: Postpone the ROM startup to let the other ROMs initialize (BDOS for example) (0=false, 1=true)
set ROMDelayBoot=0

:: Set RAM in slot 0 and install ISR there (0=false, 1=true)
set InstallRAMISR=0

:: Type of custom ISR (for RAM or ROM)
:: - VBLANK		V-blank handler
:: - VHBLANK	V-blank and h-blank handler (V9938 or V9958)
:: - V9990		v-blank, h-blank and command end handler (V9990)
set CustomISR=VBLANK

:: Use banked call and trampoline functions (0=false, 1=true)
set BankedCall=0

:: Overwrite RAM starting address (e.g. 0xE0000 for 8K RAM machine)
set ForceRamAddr=

:: Data to copy to disk (comma separated list)
set DiskFiles=

:: Add application signature to binary data (0=false, 1=true)
set AppSignature=0

:: Application company
set AppCompany="GL"

:: Application ID (0~65535)
set AppID=0

:: Application extra data (comma-separated bytes starting with data size)
REM set AppExtra=

::*******************************************************************************
:: MAKE SETTINGS
::*******************************************************************************

:: Generate MSXgl static library (0=false, 1=true)
set BuildLibrary=1

:: Generate debug data (0=false, 1=true)
set Debug=0

:: Move debug symbols do binary folder (0=false, 1=true)
set DebugSymbols=0

:: Assembler code optimizer
:: - None
:: - PeepHole	SDCC otpimizer
:: - MDL		MDL z80 otpimizer
set AsmOptim=None

:: Optim:
:: - Default
:: - Speed
:: - Size
set Optim=Speed

:: Additionnal compilation flag
set CompileOpt=

:: Skip file if compile data is newer than the (0=false, 1=true)
set CompileSkipOld=0

:: Compile verbose mode (0=false, 1=true)
set Verbose=0

:: Additionnal link flag
set LinkOpt=

:: Update build version header file
set BuildVersion=0

::*******************************************************************************
:: EMULATOR SETINGS
::*******************************************************************************

:: Emulator options: 0 or 1
set EmulMachine=1
set Emul60Hz=0
set EmulFullScreen=0
set EmulMute=0
set EmulDebug=0

:: Emulator extensions: 0 or 1
set EmulSCC=0
set EmulMSXMusic=0
set EmulMSXAudio=0
set EmulPSG2=0
set EmulV9990=0

:: Emulator port: joystick, mouse, keyboard (fake joystick)
set EmulPortA=
set EmulPortB=

:: Emulator extra parameters to be add to command-line (emulator sotfware specific)
set EmulExtraParam=

::*******************************************************************************
:: BUILD STEPS
::*******************************************************************************

set DoClean=0
set DoCompile=1
set DoMake=1
set DoPackage=1
set DoDeploy=1
set DoRun=0
# Haxe.io

The new home of the Haxe Roundups.

## Installation

Using Haxe Compiler `3.1.3 git build a21691a`.

You will need to install the following libraries

1. detox - `haxelib install detox`
2. selecthxml - `haxelib install selecthxml`
3. tjson - `haxelib install tjson`
4. hxparse - `haxelib install hxparse`

You will need to install the following libraries through `haxelib git <name> <url>
<branch> <folder>` or clone them locally and run `haxelib local <zip>`

1. [uhu]: 
	+ git - `haxelib git uhu https://github.com/skial/uhu experimental src`
	+ zip:
		* download - `https://github.com/skial/uhu/archive/experimental.zip`
		* install - `haxelib local experimental.zip`
2. [klas]:
	+ git - `haxelib git klas https://github.com/skial/klas master src`
	+ zip:
		* download - `https://github.com/skial/klas/archive/master.zip`
		* install - `haxelib local master.zip`
3. [mo]:
	+ git - `haxelib git mo https://github.com/skial/mo master src`
	+ zip:
		* download - `https://github.com/skial/mo/archive/master.zip`
		* install - `haxelib local master.zip`
4. [tuli]:
	+ git - `haxelib git tuli https://github.com/skial/tuli master src`
	+ zip:
		* download - `https://github.com/skial/tuli/archive/master.zip`
		* install - `haxelib local master.zip`
		
You will also need some programs due to the macro system not being able to load
ndlls and other reasons.

1. tidy - `http://w3c.github.io/tidy-html5/`
2. curl - `http://curl.haxx.se/`
	
## Setup

None, if you have all the libraries and programs installed and available from
PATH, then compiling `haxe.io.hxml` should _work_.

If not, open an [issue]. I might have missed something!?!

[uhu]: http://github.com/skial/uhu/tree/experimental "The Uhu/Uhx Collection"
[klas]: http://github.com/skial/klas "The Ordered Macro Builder"
[mo]: http://github.com/skial/mo "Syntax highlighter"
[tuli]: http://github.com/skial/tuli "Static site generator"
[issue]: http://github.com/skial/haxe.io/issues "Haxe.io Issues"
[_template]: ../../templates/roundup.html
[“”]: a ""
# C++ Magic by Hugh Sanderson

![youtube 100%x100%](k2rw7-uL6RU)

[Hugh][tw4] introduces _“C++ Magic”_ which gives low-level libraries access to
platform specific functions.

![wwx 2014 haxe cpp magic](/img/wwx/2014/hugh-magic.jpg "Haxe C++ Magic")

The most basic level of manipulation is to add paths and libraries to your `build.xml`
file. Hugh classes this as nothing more than a conjurer of cheap tricks. You can
control the build tool through the use of environment variables by using compiler 
defines or by toolchains which are usually part of a haxelib library.

Hugh goes onto to explain that `untyped` _“skips most type checking but still needs
valid syntax”_ to work. If you want to interface between Haxe and external code you
need to use `__global__` and `__cpp__` along with `untyped`.

`untyped __global__.MessageBox(0, "Hello", "Title", 0)` gives you access to global 
scope which is useful because Haxe doesn't have one. On the other hand 
`untyped __cpp__('printF("Hello")')` parses as a local function call. In both cases `"Hello"`
is autocast from a Haxe string to a native string.

Hugh has also introduced the `cpp.*` package which contains `NativeArray`, `String`,
`Float32`, and `UInt8` which are to be used as [static extensions][l20].

He then ramps up the magic to include metadata. He provides metadata for classes
and functions. For classes you have the following:

* `@:headerClassCode(...)` which injects member variables and inline functions.
* `@:headerCode(...)` which includes external headers.
* `@:headerNamespaceCode(...)` which allows you to add to the global namespace.
* `@:cppFileCode(...)` which allows you to include external headers only in C++ files.
* `@:cppNamespaceCode(...)` which implements static variables.
* `@:buildXml(...)` which allows you to add to the `build.xml` file.

For function metadata you get the following:
	
* `@:functionCode(...)`
* `@:functionTailCode(...)`

Hugh states these are largely redundant as you should use `untyped __cpp_(...)` 
instead.

The next section is on `extern` magic. As far as I'm aware the C++ target has never supported
extern classes like the other targets, until now. This is now possible because of 
all the new features introduced above. Here is an example from Hugh's slides.

```
// Avoids generating dynamic accessors.
@:unreflective
// Marks an extern class as using struct access(".") not pointer("->").
@:structAccess
@:include("string")
@:native("std::string")
extern class StdString {
	@:native("new std::string")
	public static function create(inString:String):cpp:Pointer<StdString>;
	public function size():Int;
	public function find(str:String):Int;
}

class Main {
	
	public static function main() {
		var std = StdString.create("my std::string");
		trace( std.value.size() );
		std.destroy();
	}
}
```

Before Hugh shows off his demo, he goes into his future plans for the C++ target.
This includes more native integration, a fully native Int64 implementation, a 
possible concurrent GC and fake classes and interfaces.

![wwx 2014 haxe cpp magic demo](/img/wwx/2014/cpp_demo.jpg "C++ Magic Demo")

If you want to run the demo yourself, download the binary either for [OSX][l21] or
[Windows][l22]. You will need a webcam for it to work. If you want to attempt to
build it yourself head over to Hugh's website for [instructions][l23].
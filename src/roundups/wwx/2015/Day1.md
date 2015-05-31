[_template]: ../templates/roundup.html
[date]: / "2015-05-31 09:15:00"
[modified]: / "2015-05-31 09:15:00"
[published]: / "2015-05-31 09:15:00"
[“”]: a ""
# WWX2015 Day 1 Recap

This is a rough recap of WWX2015's first day as I couldnt watch the entire
live stream.

## 10 Years of ~~haXe~~ Haxe

![wwx haxe 10 years Nicolas Cannasse](/img/wwx/2015/10years.jpg "10 Years of Haxe")



## FlashDevelop

![wwx flashdevelop apple](/img/wwx/2015/flashdevelop1.jpg "“Flash this is your death!”")

## GameDuell

![wwx gameduell duelltool](/img/wwx/2015/gameduell.jpg "Cross-platform game development with GameDuell DuellTool")

## Go Libraries in Haxe

![wwx golang transpiler](/img/wwx/2015/golang.jpg "Golang program transpiled to Haxe")

## Haxe for the Web



## TiVo Activity HaxeLib

![wwx activity tivo](/img/wwx/2015/activity.jpg "TiVo's Activity HaxeLib")

## Jive - Aswing reborn

## Kha

[Robert Konrad][tw1] talked about one of the more unknown frameworks in Haxe,
[Kha][l1]. Robert covered the history leading up to the creation of Kha, formerly
called Kje and being a Java framework.

A difference Robert pointed out about is that Kha generates target specific source code,
so generally resulting in a faster build time as its doesnt rely on cross compiling `ndll`
files, _I think I got that right_.

Like most Haxe frameworks, Kha also generates IDE project files for you, allowing
easy debugger intergration. But Kha comes with alot of other tools, [Krafix][l2] 
and [Kraffiti][l4] are just a couple.

[Krafix][l2] allows you to compile GLSL to HLSL, AGAL, Metal and Vulcan's SPIV-R 
and works with [Nicolas Cannasse's][tw2] [hxsl][l3] language, which of course is
all cross-platform.

[Kraffiti][l4] takes your image assets and convert them to the best performing
format for your target.

Robert also had to mentioned [ZBlend][l5], by [Lubos Lenco][tw3], with combines
the Kha framework and all its tools to integrate into Blender to offer a
complete game making package.

Robert finished off demonstrating two new additions to Kha, targeting Oculus Rift,
Samsung Gear VR and Google Cardboard and generating the source code and 
running [Mampf Monster][l6] through Unity3D, gaining Unity's 21 platforms
to target.

## Isomorphic Haxe - Ufront

## Drakarnage - Slapping data from your web server to your GPU

[tw3]: https://twitter.com/luboslenco "@luboslenco"
[tw2]: https://twitter.com/ncannasse "@ncannasse"
[tw1]: https://twitter.com/robdangerous "@robdangerous"
	
[l6]: https://github.com/KTXSoftware/MampfMonster "MampfMonster on GitHub"
[l5]: http://zblend.org/docs/ "ZBlend | Kha + Blender == ZBlend"
[l4]: https://github.com/KTXSoftware/kraffiti "Kraffiti on GitHub"
[l3]: https://github.com/ncannasse/hxsl "hxsl on GitHub"
[l2]: https://github.com/KTXSoftware/krafix "Krafix on GitHub"
[l1]: http://kha.technology "The Kha Framework"
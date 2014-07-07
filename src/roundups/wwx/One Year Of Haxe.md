[_template]: ../../templates/roundup.html
[“”]: a ""
# One Year Of Haxe by Nicolas Cannasse

![youtube](u2k08FIiGqI)

## Overview

[Nicolas][tw1] opened the conference by going over what has changed in the
[last year][l1], the various releases, new features, additional syntax and further 
speed improvements.

He continues by explaining the future plans for Haxe `3.2`. This includes
completing the `haxe.io.Bytes` API by adding additional accessors and using 
Typed Arrays on the JavaScript target which will provide a huge speed
improvement. Simon Krajewski's [hxparse][l2] library might provide a hint of what's to
come as it includes its own [byte][l3] class which uses the best underlying object
on each platform to get the best speed available.

The next feature planned is full Unicode support by providing `haxe.Ucs2`,
`haxe.Utf8` and `haxe.Utf16` which can automatically convert between each
other, full cross-platform conformity and the best performance available
for the underlying platform.

A few other features are also planned, to improve macro support, additional improvements
to `Date` by adding UTC support, moving SPOD to `haxe.db` and continue to improve
the Python target.

Nicolas goes onto describing who makes up the Haxe Foundation and what they do. The
Haxe Foundation have sponsored a handful of projects, from HIDE, WWX, UFront and
the new [Haxe][l4] website created by [Jason O'Neil][tw2] who's also handling 
the development of UFront.

![wwx 2014 haxe new website](/img/wwx/2014/new-haxe-site.jpg "The New Haxe Website")

The new site uses [UFront], but without a database, instead relying on GitHub for all its
content. Clicking any `contribute` link at the bottom of a page will take you to the
relevant GitHub page. This is to encourage community contribution and make it easy to
review changes and additions to the site.

## Part 2

![youtube](YZDsQNtq4OM)

## Part 3

![youtube](NjXRMM3FQPk)

## Part 4

![youtube](7rhFjotSa48)

[tw1]: https://twitter.com/ncannasse "@ncannasse"
[tw2]: https://twitter.com/jayoneil "@jayoneil"
	
[l1]: https://ncannasse.github.io/hxslides/www/wwx2014.html#1 "One Year of Haxe"
[l2]: https://github.com/Simn/hxparse/ "HxParse on GitHub"
[l3]: https://github.com/Simn/hxparse/tree/development/src/byte "HxParse byte.ByteData Class"
[l4]: http://haxe.org "The New Haxe Website"
	
[ufront]: https://github.com/ufront "UFront on GitHub"
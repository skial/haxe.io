[_template]: ../../templates/wwx/video.html
[“”]: a ""
# One Year of Haxe _by_ Nicolas Cannasse

> [Silex Labs] originally posted the article [WWX 2014 Speech: Nicolas Cannasse One
> Year of Haxe][sl1] which links to the YouTube videos, Nicolas's slides and a brief
> synopsis of the talk. Below are the videos and my own overview of the talk.

![youtube](u2k08FIiGqI)

## Overview

[Nicolas][tw1] opened the conference by going over what has changed in the
[last year][l1], the various releases, new features, additional syntax and further 
speed improvements.

He continues by explaining the future plans for Haxe `3.2`. This includes
completing the `haxe.io.Bytes` API by adding additional assessors and using 
[Typed Arrays] on the JavaScript target which will provide a huge speed
improvement. 

Simon Krajewski's [hxparse][l2] library might provide a hint of what's to
come as it includes its own [byte][l3] class which uses the optimal underlying method
on each platform to get the best speed available.

The next feature planned is full Unicode support by providing a `haxe.Ucs2`,
`haxe.Utf8` and `haxe.Utf16` abstract classes which can automatically convert
between each other, full cross-platform conformity and the best performance available
on the underlying platform.

A few other features are also planned, to improve macro support, additional improvements
to the `Date` class by adding UTC support, moving SPOD to the `haxe.db` package and 
continuing to improve the Python target.

Nicolas continues by describing who makes up the Haxe Foundation and what they do. The
Haxe Foundation have sponsored a handful of projects, from HIDE, WWX, UFront and
the new [Haxe][l4] website created by [Jason O'Neil][tw2] who's also leading 
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
[typed arrays]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Typed_arrays "JavaScript Typed Arrays"
[silex labs]: http://www.silexlabs.org/ "Silex Labs"
[sl1]: http://www.silexlabs.org/202725/the-blog/wwx2014-speech-nicolas-cannasse-one-year-of-haxe/ "WWX 2014 Speech: Nicolas Cannasse One Year of Haxe"
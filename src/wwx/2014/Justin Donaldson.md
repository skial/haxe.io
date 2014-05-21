[_template]: ../../interview.html
[_author]: https://twitter.com/omgjjd "@omgjjd"

# Justin Donaldson

![Justin Donaldson WWX 2014 skip-lb social](/img/jjd-sailing.png "Justin Donaldson")

I'm constantly learning: programming languages, data science, machine learning,
music.  You see that sailing pic?  I have no idea what I'm doing there.  But,
I haven't drowned yet, or wrecked the boat.  So it goes with learning... 


## What hardware do you use?

My beloved macbook air and pro.  I have a number of workstations, both real 
and cloud based, but my macbooks generally run the show.

## What software do you use?

You can see my entire collection of software, tools, knives, and lint in my
[dotfiles repo][dotfiles].

In terms of editors, I'm a somewhat recent vim convert, and use it for Haxe.
I've caught up with it pretty quickly, and have even written a nice Haxe plugin
for it called "[vaxe]".  I like the ideas and apis behind git and bitcoin as
well.  Great opportunities to do some hacking.


## Where do you get your inspiration?

Most of programming is "gradient descent".  You can iteratively improve things,
but eventually you run out of cheap/intuitive gains.  To move beyond that,
I always look to nature and cognition: fractals, graph theory, information
theroy, and dimensional scaling.  Most of my work involves dealing with
data, so I tend to draw more from the "data science" side of things.

## Which creatives/developers/artists do you admire most?  

There's a few folks that I follow ahead of topical interests.  That means, if
they do something, I'll check it out even if I'm not interested in the subject.
To that end, [Mike Bostock][ocks] is a pretty amazing combination of coding data
science, and aesthetics.  His d3 library is great.   

[Tim Pope][tpope] has some wonderful vim tools that I didn't even
realize that I needed.  [Hadley Wickham][co], likewise, has some
wonderful data manipulation tools that have made certain aspects of my work much
easier. 

## What contributions are you proud of?

I've done a lot of things I'm proud of with Haxe, but I'm not always able to
share it as I wished.  I've contributed to some of Franco's work with thx, and
contributed a lot of plugins for the editors I've used over the years, including
textmate and vim.  

## Did your contributions bring you work opportunities?

Not really, but I haven't tried very hard with my Haxe work. 

## Do you use them in your projects?

Of course!


## How did you get started with Haxe?

I wanted to do some front end work that called for flash.  But, I quickly
learned that I hated flash.  Haxe was an easy switch. 

## What problem does Haxe solve for you?

Haxe solves problems by letting me solve problems the way I wish.  Do I want to
use functional programming?  Easy with Haxe.  Structural typing?  Done.  Front
end in javascript?  Of course.  Back end in Java?  Not a problem.  Whoops... I
wanted that back end in nodejs.  Fine... just convert things to use callbacks.
etc...

## What tips or resources would you recommend to a new Haxe user?

The language itself is simple if you have any experience with statically typed
langauges.  I put together a 15 minute guide [here][learnxinyminutes] that links
on to some other useful resources.  

However, you can wind up in the weeds quickly once you start working with
different frameworks and targets.  Don't panic, proceed directly to [IRC][haxe]
or to our beloved [mailing list][google].

I ended up learning a lot from that mailing list. There's a ton of bright,
accessible people there doing things I never thought was possible. Haxe ties
together a lot of programming techniques from different languages and
platforms.  You may have to "unlearn" some things from other languages, but
once you do a unified picture of web development becomes much clearer.

I would also recommend [thx] and [polygonal ds][polygonal-ds]
for folks wanting to see how to write "idiomatic Haxe" to solve familiar data
structure and algorithm problems.
I'd also recommend [tink][tink_core] for folks wanting to move beyond that.

## What Haxe libraries are you impressed by?

[OpenFL][openfl]/[Lime][lime]/[NME][nme] are pretty amazing. I'm also a fan of
the ideas in [Tink][tink_core].  I also have good experiences with Franco's
[thx] and [dhx] libraries.  Great stuff!


## What problem would you like to see solved by a new or existing Haxe library?

Haxe has the capability to do some pretty amazing data/orm configuration thanks
to its powerful macro functionality.  I'm working on this a bit with
[postgrehx], but don't have anything killer yet.  The [Mongo
driver][mongo-haxe-driver] from Matt Tuttle looks promising too.

I also think we need a solid cross-platform UI framework.  It would also be
great if the library provided the ability to utilize native UI where it was
possible. Most mobile phone apps these days are just variations on the different
UI sensibilities that exist in native Android/iPhone/etc.  Most of the current
crop of UI frameworks try to recreate the same UI on every platform.  That's
understandable, but not what most users on those platforms expect. 

## What is the best use of Haxe you've come across?

Some of the games have been amazing.  [Papers, Please][papersplea] was a great
use of Haxe. Perhaps Haxe just lets the creativity of the author shine
through. 

## What do you see for the future for Haxe/OpenFL?

A cross platform IDE suite for Haxe is about 75% there.  We're missing good ways
of refactoring, and some other common IDE utilities that rely on deep compiler
integration. After that I'll be completely happy. 

I also think we'll see some great test/deployment functionality.  Andy Li has
already done Haxe a great service by setting up a testing profile for Haxe on
[travis-ci].

Once we have all that, I think we will see Haxe developer working together more
easily in business contexts, and a whole different side of Haxe will emerge.

## Sell your wwx2014 session!

I'll be talking about [promhx], a promise and functional reactive programming
library for Haxe.  The library provides a way of dealing with asynchronous
operations with values, rather than callbacks.

There's a couple of solid benefits to this approach. The results of an
asynchronous operation are separated from the operations that rely on it.  This
lets developers avoid binding all of the logic for a conventional asynchronous
operation inside a single callback.  The second benefit is an error handling
mechanism that allows for flexible error management, a common pain point in
asynchronous programming.  Finally, a full suite of utilities and methods enable
developers to reason about asynchronous workflows without getting bogged down in
syntax and callback indentation.

## What is the best part of wwx for you?

I get to meet all these European Haxe folks that I've known only through e-mail
handles.

[co]: http://had.co.nz/
[dhx]: https://github.com/fponticelli/dhx
[dotfiles]: https://github.com/jdonaldson/dotfiles
[tpope]: https://github.com/tpope
[google]: https://groups.google.com/forum/?hl=en#!forum/haxelang
[haxe]: http://haxe.org/com/meeting/irc?lang=en
[learnxinyminutes]: http://learnxinyminutes.com/docs/haxe/
[lime]: https://github.com/openfl/lime
[mongo-haxe-driver]: https://github.com/MattTuttle/mongo-haxe-driver
[nme]: https://github.com/haxenme/nme
[ocks]: http://bost.ocks.org/mike/
[openfl]: http://www.openfl.org/
[papersplea]: http://papersplea.se/
[polygonal-ds]: https://github.com/polygonal/ds
[postgrehx]: https://github.com/jdonaldson/postgrehx
[promhx]: https://github.com/jdonaldson/promhx
[thx]: https://github.com/fponticelli/thx
[tink_core]: https://github.com/haxetink/tink_core
[travis-ci]: https://travis-ci.org/HaxeFoundation/haxe
[vaxe]: https://github.com/jdonaldson/vaxe

[template]: ../../templates/interview.html
[author]: https://twitter.com/GameHaxe "@gamehaxe"
[date]: / "2016-05-26"
[modified]: / "2016-05-26"

![profile hugh sanderson](/img/wwx/2016/Hugh-Sanderson/profile.jpeg "Hugh Sanderson")

I've been programming for about 35 years now. I started by typing in basic programs from a book, and never left the computer since.

I work mainly with C++ doing video processing algorithms. Haxe does not form part of my job, but I use it for scripting in my day-to-day work.

## Out of the various Haxe IDE's available, which one(s) do you use?

I'm old-school vim. I'm too old and lazy to switch.

## What other software do you find vital while working with Haxe?

The CI that has been integrated with GitHub has proved wonderful when developing the HXCPP backend.

## What hardware you do you use?

I have a windows PC, windows laptop, a macbook air that I can get out and a mac-mini running as a build-server.

## What problem does Haxe solve for you?

For me, its all about the cross-platform capabilities. Particularly for apps/gaming.

## What compiler targets do you use?

CPP, Neko, interp and a little JavaScript.

## What platforms to do deploy to?

Desktop/mobile

## What would you like to see added to the Haxe compiler?

There are a few things - dynamic properties, a "if-null" shorthand, overloaded operators without abstracts. I would also like to see the GPL removed. But these are just minor preferences, not overpowering convictions.

## What tips or resources would you recommend to a new Haxe user?

It has been so long since I was a new Haxe user, I could not say.

## What Haxe libraries and/or frameworks are you impressed by and use?

I'm interested to see where the HaxeUI project is going to end up.

## What is the best use of Haxe you've come across?

That would have to be my [Acadnme](https://play.google.com/store/apps/details?id=com.acadnme.launcher&hl=en_GB) Android app :)

## What do you think of the Haxe Foundation?

I think it is a pretty tricky thing they are doing. Managing volunteers is not simple, and I think they have done well in getting people to do some of the less-glamorous things. One issue I think we face is that it is a pretty homogeneous kind of group of developers. We don't have a bunch of extroverts who want to go around promoting stuff - we all just want to get down and do it.

I'm not sure the HF can easily do anything about this - it is easy to make sweeping statements like _“we need to be more diverse”_, but without specific suggestions, complaining is pretty meaningless.

## Where do you get your inspiration?

I generally mess around with little projects, thinking _“wouldn't it be cool if…”_ and then 2 months before the next Haxe release madly try to put it into the compiler.

I like Vernor Vinge's _“Deepness in the Sky”_, with the concept of _“programmer archaeologists”_, which is how I feel sometimes looking over the early HXCPP OCaml code.

## What contributions are you proud of?

I'm still pretty happy with HXCPP backend and build system. I like that more people are expanding its usage into native integration.

## What use case does Cppia solve?

There are few use cases for [cppia](https://haxe.io/roundups/wwx/2015/#cppia):
 - As a Neko replacement. Neko is actually pretty good and I use it a lot, but cppia lets you generate a scripting host as a single exe, free of GPL.
 - As a scripting system for your HXCPP game. Since the integration with HXCPP is very tight and it is the Haxe compiler that does the compiling and checking you get something that is easy, fast and strongly typed.
 - As a complete _“player”_ similar to the Flash player. This is the concept with [Acadnme](https://play.google.com/store/apps/details?id=com.acadnme.launcher&hl=en_GB) - you can compile your code with only Haxe installed, and then deploy to android without needing C++, Java or any other tools.

## What do you think of Sven's work on [linc](http://snowkit.org/2015/08/24/announcing-linc/)?

I think being able to distribute native libraries without having to ship binaries _(HXCPP supports about a dozen binary formats)_ is fantastic. After installing a whole bunch of crap _(Python, scons, cmake, make, Java, ant, gradle, cygwin, node…)_ just to check if one file is newer than another and look up the appropriate build flag, I find the HXCPP build-system hugely satisfying. It is great to see it put to really good use with a set of core libraries that I think will interest a lot of developers.

## Areas that you think linc could be improved?
 
Personally, I would like to see the [linc](http://snowkit.org/2015/08/24/announcing-linc/) libraries get proper `haxelib` releases so you can match up with other libraries.

## How does the upcoming [`MainLoop`](https://github.com/HaxeFoundation/haxe/blob/7b01092f344adb05b1781d60bf487e9754c7d6c5/std/haxe/MainLoop.hx) feature improve Haxe?

It will allow command line apps to work more like Flash/JavaScript, in that if you set a timer to wake you up in 8 hours by printing _“WAKE UP”_ in all-caps, it will now work.
Also, it gives a meaningful way for async-io to interact with GUI apps. This means that you can use something like `haxe.http` in JavaScript inside a browser and the same code will work in NME, without blocking the render thread. Functions written against MainLoop will then work in the various GUI/gaming frameworks that are around now.

## Tell us a little about your WWX talk?

My talk is designed to stimulate conversation about the HXCPP backend. I will go over what has happened this year, and future direction. I'm also open to ideas and I think the conference is a great place to put in your requests or suggestions.

## What is the best part of WWX for you/are you looking forward too?

I've gone to quite a few now, so I will be looking to catch up with the people I've met over the years.

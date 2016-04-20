[_template]: ../../templates/interview.html

## Tell us about yourself?

1. _How did you get started in programming?_ and/or _How did you get started in your specific field?_

I've been programming for about 35 years now. I started by typing in basic programs from a book, and never left the computer since.

2. _What is your job?_

I work mainly with c++ doing video processing algorithms. Haxe does not form part of my job, but I use it for scripting in my day-to-day work.

## Out of the various Haxe IDE's available, which one(s) do you use?
I'm old-school vim. I too old/lazy to switch.

## What other software do you find vital while working with Haxe?
The CI that has been integrated with github has proved wonderful when developing the hxcpp backend.

## What hardware you do you use?
I have a windows PC, windows laptop, a macbook air that I can get out and a mac-mini running as a build-server.

## What problem does Haxe solve for you?
For me, its all about the cross-platform capabilities. Particularly for apps/gaming.

## What compiler targets do you use?
c++, neko, interp and a little js

## What platforms to do deploy to?
Desktop/mobile

## What would you like to see added to the Haxe compiler?
There are a few things - dynamic properties, a "if-null" shorthand, overloaded operators without abstracts.  I would also like to see the GPL removed.  But these are just minor preferences, not overpowering convictions.

## What tips or resources would you recommend to a new Haxe user?
It has been so long since I was a new Haxe user, I could not say.

## What Haxe libraries and/or frameworks are you impressed by and use?
I'm interested to see where the HaxeUi project is going to end up.

## What problem would you like to see solved by a new or existing Haxe library?

## What is the best use of Haxe you've come across?
That would have to be my Acadnme android app :)

## What do you think of the Haxe Foundation?
I think it is a pretty tricky thing they are doing. Managing volunteers is not simple, and I think they have done well in getting people to do some of the less-glamorous things. One issue I think we face is that it is a pretty homogeneous kind of group of developers. We don't have a bunch of extroverts who want to go around promoting stuff - we all just want to get down and do it.
I'm not sure the HF can easily do anything about this - it is easy to make sweeping statements like "we need to be more diverse", but without specific suggestions, complaining is pretty meaningless.

## Where do you get your inspiration?
I generally mess around with little projects, thinking "wouldn't it be cool if..." and then 2 months before the next haxe release madly try to put it into the compiler.

I like Vernor Vinge's "Deepness in the Sky", with the concept of "programmer archaeologists", which is how I feel sometimes looking over the early hxcpp ocaml code.

## What contributions are you proud of?
Still pretty happy with hxcpp backend and build system. I like that more people are expanding its usage into native integration.

## Tell us about your WWX talk?

My talk is designed to stimulate conversation about the hxcpp backend. I will go over what has happened this year, and future direction.  I'm also open to ideas and I think the conference is a great place to put in your requests or suggestions.

## What is the best part of WWX for you/are you looking forward too?

I've gone to quite a few now, so I will be looking to catch up with the people I've met over the years.


# Questions for Hugh

1 _What use case does Cppia solve?_ 

There are few use cases for cppia:
  * as a neko replacement. Neko is actually pretty good, and I use it a lot, but cppia lets you generate a scripting host as a single exe, free of GPL.
  * As a scripting system for your hxcpp game. Since the integration with hxcpp is very tight, and it is the haxe compiler that does the compiling and checking you get something that is easy, fast and strongly typed.
  * As a complete "player" similar to the flash player. This is the concept with Acadnme - you can compile your code with only haxe installed, and then deploy to android without needing c++, java or any other tools.

_2 What do you think of Sven's work on linc?_

I think being about to distribute native libraries without having to ship binaries (hxcpp supports about a dozen binary formats) is fantastic. After installing a whole bunch of crap (python, scons, cmake, make, java, ant, gradle, cygwin, node...) just to check if one file is newer than another and look up the appropriate build flag, I find the hxcpp build-system hugely satisfying. It is great to see it put to really good use with a set of core libraries that I think will interest a lot of developers.

* Areas that could/need to be improved?
 
Personally, I would like to see the linc libraries get proper haxelib releases so you can match up with other libraries.

_3 How does the upcoming `MainLoop` feature improve Haxe?_

It will allow command line apps to work more like flash/js, in that if you set a timer to wake you up in 8 hours by printing "WAKE UP" in all-caps, it will now work.
Also, it gives a meaningful way for async-io to interact with gui apps. This means that you can use something like haxe.http in js inside a browser and the same code will work in NME, without blocking the render thread. Functions written against MainLoop will then work in the various gui/gaming frameworks that are around now.

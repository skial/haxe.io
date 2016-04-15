[_template]: ../../templates/interview.html

Tell us about yourself?
How did you get started in programming? and/or How did you get started in your specific field?
I grew up in a small sized town in the midwest of the US.  Computers were my way of connecting to like minded people, and learning new things in a relatively isolated hometown.  I've also done a lot of graduate work, and was one of the first PhDs from Indiana University's new Informatics School (Computer Science, BioInformatics, HCI, Cybersecurity, etc.).   

What is your job?
My official title is Lead Data Scientist or Machine Learning engineer, but I still specialize in being able to make engineering changes necessary for Machine Learning to be possible on large systems.  So, it's a combination of coding and computational statistics.
 
Who do you work for?
Salesforce.com 
Do you use Haxe at work?
No, or at least on very rare occasions :(
If you do, how?
If not, are there any areas you want and/or can see Haxe fitting in perfectly?

There are plenty of in-house frameworks where we're trying to formalize javascript to make it amenable for giant multi-team efforts on client side apps.  Haxe is a good fit in many ways for that, but is an unlikely choice for a giant enterprise software company that intends to stick with what it perceives as a safe choice.  It doesn't stop me from trying to pitch Haxe there though :)
 
Out of the various Haxe IDE's available, which one(s) do you use?

I use my own vaxe plugin for vim exclusively 
If you use more than one, why?
What other software do you find vital while working with Haxe?

Besides standard browsers, I rarely use much else.  In some rare cases I might use wireshark or some special network tools to develop wire protocols for databases, etc.
Do you integrate any cloud based services while working with Haxe?
I use Github and Travis pretty heavily.  They've improved the quality of my code and workflow tremendously.
 
And what problem do they solve for you?
Github is the social life blood for an open source project.  Previously only large scale projects could expect to see contributions from random people.  Now it feels like anyone can contribute anywhere, which is incredible.  Having a well organized github project is a great sign of its quality.  Having a travis test suite for the library is another great sign, and it makes a lot of cross-platform dev transparent and sane.
 
What hardware you do you use?

Mostly mac laptops.  I have several.
 
What problem does Haxe solve for you?

Haxe helps me compose solutions to problems consistently, using a range of OOP, functional, and dynamic approaches.  The compiler takes over a wide range of type checking and internal consistency checks without requiring a burden of verbose code.  It's wonderful to have the extra bandwidth back for my brain. 
What features of Haxe helped win you over?
The compilation speed is probably #1, and  close second is the fact that I feel that the compiler is actually trying to help me do things correctly, rather than just telling me I'm wrong (suggesting spelling corrections, etc).  This is relatively rare for compilers.  It's by far the most positive strictly-typed programming experience I've had.
 
Did you consider any other languages?
I use a lot of Java, Python, R, and they're good for certain situations.
 
Why didn't you choose them?
Java is way too opinionated and verbose, Python is slow, but pretty decent for small-to-mid sized tasks.  R is very domain specific. 
What ticks you off about Haxe, if anything? Lack of feature? Something else?
Nothing really.  My main complaint has always been the lack of good tutorials and documentation, but that's all been addressed now imho.
 
How could they be fixed?
What compiler targets do you use?
If you only use one target, why? 
If you use more than one, for what reason?

Javascript is good for client dev.  I use javascript sometimes for node development, but I'll also use python, c++, or neko depending on what I'm doing.   I'm starting to use the new lua target for some general editor utility projects too.
As a complete stack?
As separate, target specific libraries?
Anything else?
N/A
 
What platforms to do deploy to?
Mobile, browser, embedded, server, etc

Browser, server, editor plugin
 
What would you like to see added to the Haxe compiler?
A new target?
A new feature?
More consistency of sys level features would be great (networking, etc.) 
Any feature from another language?
I'd like some sort of primitive multiple-return support for languages that use it (python, lua).  It would make writing externs for those languages a lot more clear.  I'm trying to do something about this right now, as a matter of fact.
 
What tips or resources would you recommend to a new Haxe user?

The community is great, and one of the big reasons I stick around.  The demo site try.haxe.org is also a great way of getting a feel for how Haxe generates code.
 
What Haxe libraries and/or frameworks are you impressed by and use?

Franco's thx libraries and Juraj's tink libraries are great for extensions of core datatypes and methods, and for getting more out of the haxe compiler in general. The OpenFL and NME projects are also very impressive, although I don't use them as often.
 
What problem would you like to see solved by a new or existing Haxe library?

I think we need consistent cross platform https support wherever possible
 
What is the best use of Haxe you've come across?

My favorite haxe project is still "Papers Please".  I still play it from time to time.
 
What do you think of the Haxe Foundation?
Where have they excelled?
I'm happy that Haxe has a foundation, and am increasingly impressed at how it has improved communication and coordination over the years with limited resources.

Areas you think they could improve?
I'd just say "stick to your guns".  Grow organically and keep the spirit that makes Haxe special.
 
Where do you get your inspiration?
Music?
I listen to music constantly, too much to list here... 
Any specific books you strongly recommend?
I still like old fashioned books like "Pragmatic Programmer" by Hunt and Thomas, and for interface design "Don't Make Me Think (revisited)" by Krug is great.  I'm a "keep it simple" kind of guy for just about anything. 
In general 
From or for your specific field
Which creatives/developers/artists (do you admire most? and/or impress you)?

You'll have to hear me rattle on about this during the happy hour :)
 
What contributions are you proud of?

I'm happy that vaxe and promhx still have a following, and that some of my older deprecated libraries have been recomposed as part of larger more general libraries.   This new Lua target is by far my biggest contribution.
Do you use them in your projects? Which?
I use vaxe and promhx all the time.
 
Did your contributions bring you work opportunities?
Yes!  Although sadly I couldn't take advantage of some recent ones, so I won't mention specifics.
 
Tell us about your WWX talk?

I'm going to talk about the new Lua target for Haxe.  If you've been around the Haxe community for a while, you'll know that this is not the first attempt at Lua, and that several efforts fell by the wayside over the years.  I'll talk a bit about why Lua is such a tricky language for Haxe, but also what makes it such a compelling Haxe target.

 
What is the best part of WWX for you/are you looking forward too?

There's always one or two presentations that are fantastic, and get me thinking.  I think I started thinking and talking about Lua at the 2014 WWX as I recall.  I like seeing old faces and new faces.  Also, hopefully Franco will arm wrestle someone again.
 
Questions for all previous speakers/attendee's
Since your last WWX conference as a speaker or attendee, what developments are you impressed by?

The new docs and cookbooks... they're great!
 
What disappoints you, if anything?
There's still not more US-side Haxe developers, especially in Seattle where I live.
 
Questions for Justin
At the WWX2014 conference you spoke about promhx, whats changed in the last two years?
There's been some relatively minor improvements and updates.  I've had several positive but time consuming life changes recently (I have a new 1.5 year old!).  That coupled with the new Lua work has not left me much time to focus on some of my older libraries.
 
While creating the Lua target, whats your experience been like working with the compiler?
OCaml is strikingly different than just about any language I've used.  I'm still a beginner with it, and my code is not very elegant.  However, I appreciate it more as I use it, and I definitely see precursors to some of my favorite Haxe features there (ADT, helpful typo messages, etc.).  The compiler is comprised of several layers, and I believe the core team has laid out these modules in a sensible fashion.  I don't want to go into too many specifics, but one thing I personally would do differently now would be to rewrite unsupported target expressions where possible, instead of emitting source code directly (as js and lua do currently).  Hopefully that won't bite me to badly with support moving forward.

Biggest challenge?
I didn't know OCaml or Lua when I started out.  So, this project has been a bit like trying to start translating Dothraki into Klingon after only watching a couple of shows.  I wouldn't say that I was particularly efficient in making progress, as it is over a year since I started.  However, I did take pretty good notes on my thought process along the way.  They outline the challenges that I faced as I uncovered them.  You can find these now in the commit messages for the Haxe compiler... just look for commits prefixed with "Lua". I plan on scraping these and publishing them somewhere.  I hope they'll help someone else learn!

The biggest challenge overall has been how limited the Lua target is.  It lacks boolean operators, integers, and uses a shared convention for arrays and hash tables.  It indexes from 1, and scopes variables to functions, but does not auto-hoist them.  It also is incredibly fragmented, having significant incompatibilities between lua 5.2, luajit 5.2, and lua 5.3.  I'm trying to get 5.2 right (for lua and luajit) before tackling 5.3. So, only 5.2 is supported for now. 

What has it been like working with the core team?
The core team has been very supportive, but I tried hard not to add Lua specific problems to their burden for a release.  Only recently after crushing some particularly tricky bugs did I feel confident enough for general bug handling duties.

Simn deserves special thanks, as he was the core team member that was the most active in discussions and development.  Nadako also gave a lot of good input.  I also wanted to thank PeyTy from the Haxe Community, who collaborated with me pretty heavily at the critical early phases.   

What use case does the Lua target solve?
Lua is particularly in vogue right now as a light weight scripting layer for more complex app logic.  The Haxe Lua target is designed to go everywhere that the Lua target can go.  From the speedy Luajit compiler, to the Torch machine learning framework, to the 
LÖVE game engine, to the Corona cross-platform 2d mobile graphics SDK, to the WoW scripting client, to enumerable other editor and game plugin libraries,  the Haxe Lua target extends Haxe's flexible and powerful language features to those areas.

I would be quick to add that Lua also provides safe means of sandboxing third party code.  For this reason, not all Haxe standard modules (e.g. sys/net) may be available in a given context due to platform limitations (e.g. WoW scripting).  In addition, many of these sys modules rely on third party lib support.  Accordingly, Lua is not as "batteries included" as many other Haxe targets, and may require some specific configuration that may or may not be possible. This is still an active area of development for the Lua target, and most of the current work for Lua involves development on these areas.  Stay tuned for more details!

In closing, I wanted to say finishing the Lua target has been particularly satisfying. I came away more impressed with Nicholas, Hugh, Cauê, Simn, Franco, Frabbit, and the core target developers during the process.  In many ways they've tackled problems that were even more daunting than Lua.  I'm happy to have done something that puts me in that group.

[template]: ../../templates/interview.html
[author]: https://twitter.com/omgjjd "@omgjjd"
[date]: / "2016-05-24"
[modified]: / "2016-05-24"

## How did you get started in programming? and/or How did you get started in your specific field?

I grew up in a small sized town in the midwest of the US. Computers were my way of connecting to like minded people, and learning new things in a relatively isolated hometown. I've also done a lot of graduate work, and was one of the first PhDs from Indiana University's new Informatics School _(Computer Science, BioInformatics, HCI, Cybersecurity, etc)_.

## What is your job?

My official title is Lead Data Scientist or Machine Learning engineer at [Salesforce.com](https://www.salesforce.com/), but I still specialize in being able to make engineering changes necessary for Machine Learning to be possible on large systems. So, it's a combination of coding and computational statistics.

## Do you use Haxe at work?

No, or at least on very rare occasions :(
	
## Are there any areas you want or can see Haxe fitting in perfectly?

There are plenty of in-house frameworks where we're trying to formalize JavaScript to make it amenable for giant multi-team efforts on client side apps. Haxe is a good fit in many ways for that, but is an unlikely choice for a giant enterprise software company that intends to stick with what it perceives as a safe choice. It doesn't stop me from trying to pitch Haxe there though :)
 
## Out of the various Haxe IDE's available, which one(s) do you use?

I use my own [vaxe plugin](https://github.com/jdonaldson/vaxe) for vim exclusively 

## What other software do you find vital while working with Haxe?

Besides standard browsers, I rarely use much else. In some rare cases I might use [wireshark](https://www.wireshark.org/) or some special network tools to develop wire 
protocols for databases, etc.

## Do you integrate any cloud based services while working with Haxe?

I use Github and Travis pretty heavily. They've improved the quality of my code and workflow tremendously.
 
## And what problem do they solve for you?

Github is the social life blood for an open source project. Previously only large scale projects could expect to see contributions from random people. Now it feels like anyone can contribute anywhere, which is incredible. Having a well organized Github project is a great sign of its quality. Having a Travis test suite for the library is another great sign, and it makes a lot of cross-platform dev transparent and sane.

## Definitely, [Andy Li's](https://twitter.com/andy_li) efforts in this area have been a great help for the community.
 
## Out of interest, what hardware you do you use?

Mostly mac laptops. I have several.

## Do you have a use for these _several_ laptops, for example testing across different OSX versions or has it turned into a _“collection”_?

It's mostly work and various home laptops. I don't have a whole lot of structure to their use. I try to reuse outdated laptops in different ways when they get too old. One of my old laptops is a backup server for instance.
 
## What problem does Haxe solve for you?

Haxe helps me compose solutions to problems consistently, using a range of OOP, functional, and dynamic approaches. The compiler takes over a wide range of type checking and internal consistency checks without requiring a burden of verbose code. It's wonderful to have the extra bandwidth back for my brain. 

## Thats a great way of describing Haxe.

## Now your a _“core”_ dev who has a greater understanding of the compiler's internals, are there any new features you have been thinking about that could be added to Haxe? Maybe from other statically typed languages?

## Your currently [discussing adding multi returns](https://github.com/HaxeFoundation/haxe/issues/5114) for externs, is there anyway of it becoming a core Haxe feature?

I haven't put much thought into new core features yet. Most of my wish list right now includes better tooling support, detecting unused imports and the like. Some of that might involve compiler support though, since really only the compiler knows exactly where a given type came from, and where it was used in the current file.

I see multi returns as being a special case for a few targets that support them _(e.g. Lua and Python)_. For that reason, I don't think multi returns will become a core feature. For targets that didn't support multi-returns natively, there would be no performance gain, and I don't believe multi-returns would add clarity or convenience to the type information for a given function.

## While reading through the discussion that was my concern.

Multi returns are important for externs in a few cases though, so I think it's worth tackling as an extern-only feature.

## There has definitely been more focus across targets improving their extern support, which is great.

## What features of Haxe helped win you over?

The compilation speed is probably `#1`, and  close second is the fact that I feel that the compiler is actually trying to help me do things correctly, rather than just telling me I'm wrong _(suggesting spelling corrections, etc)_. This is relatively rare for compilers. It's by far the most positive strictly typed programming experience I've had.
 
## Did you consider any other languages?

I use a lot of Java, Python, R, and they're good for certain situations.
 
## Why didn't you choose them?

Java is way too opinionated and verbose, Python is slow, but pretty decent for small-to-mid sized tasks. R is very domain specific. 

## What ticks you off about Haxe, if anything? Lack of feature? Something else?

Nothing really. My main complaint has always been the lack of good tutorials and documentation, but that's all been addressed now imho.
 
## What compiler targets do you use? And if you use more than one, for what reason?

JavaScript is good for client dev. I use JavaScript sometimes for node development, but I'll also use Python, C++, or Neko depending on what I'm doing. I'm starting to use the new Lua target for some general editor utility projects too.
 
## What platforms to do deploy to?

Mobile, browser, embedded, server, etc and browser, server, editor plugins.
 
## What would you like to see added to the Haxe compiler?

More consistency of system level features would be great _(networking, etc)_. 

## Any feature from another language?

I'd like some sort of primitive multiple-return support for languages that use it _(Python, Lua)_. It would make writing externs for those languages a lot more clear. I'm trying to do something about this right now, as a matter of fact.
 
## What tips or resources would you recommend to a new Haxe user?

The community is great, and one of the big reasons I stick around. The demo site [try.haxe.org](http://try.haxe.org/) is also a great way of getting a feel for how Haxe generates code.
 
## What Haxe libraries or frameworks are you impressed by and possibly use?

Franco's [`thx`](http://thx-lib.org/) libraries and Juraj's [`tink`](https://github.com/haxetink/) libraries are great for extensions of core data-types and methods, and for getting more out of the Haxe compiler in general. The OpenFL and NME projects are also very impressive, although I don't use them as often.

## Definitely agree.
 
## What problem would you like to see solved by a new or existing Haxe library?

I think we need consistent cross platform `https` support wherever possible.
 
## What is the best use of Haxe you've come across?

My favorite Haxe project is still [Papers Please](http://papersplea.se/).  I still play it from time to time.
 
## What do you think of the Haxe Foundation?

I'm happy that Haxe has a foundation, and am increasingly impressed at how it has improved communication and coordination over the years with limited resources.

## Areas you think they could improve?

I'd just say _“stick to your guns”_.  Grow organically and keep the spirit that makes Haxe special.
 
## Where do you get your inspiration? Music?

I listen to music constantly, too much to list here... 

## Any specific books you strongly recommend?

I still like old fashioned books like _“Pragmatic Programmer”_ by Hunt and Thomas, and for interface design _“Don't Make Me Think (revisited)”_ by Krug is great. I'm a _“keep it simple”_ kind of guy for just about anything. 

## Which creatives/developers/artists do you admire most or impress you?

You'll have to hear me rattle on about this during the happy hour :)
 
## What contributions are you proud of?

I'm happy that [`vaxe`](https://github.com/jdonaldson/vaxe) and [`promhx`](https://github.com/jdonaldson/promhx) still have a following, and that some of my older deprecated libraries have been recomposed as part of larger more general libraries. This new Lua target is by far my biggest contribution.
 
## Did your contributions bring you work opportunities?

Yes! Although sadly I couldn't take advantage of some recent ones, so I won't mention specifics.
 
## Tell us a little about your WWX talk?

I'm going to talk about the new Lua target for Haxe. If you've been around the Haxe community for a while, you'll know that this is not the first attempt at Lua, and that several efforts fell by the wayside over the years. I'll talk a bit about why Lua is such a tricky language for Haxe, but also what makes it such a compelling Haxe target.

## What is the best part of WWX for you?

There's always one or two presentations that are fantastic, and get me thinking. I think I started thinking and talking about Lua at the 2014 WWX as I recall. I like seeing old faces and new faces. Also, hopefully Franco will arm wrestle someone again.

## Since your last WWX conference as a speaker or attendee, what developments are you impressed by?

The new docs and cookbooks… they're great!
 
## What disappoints you, if anything?

There's still not more US-side Haxe developers, especially in Seattle where I live.
 
## At the WWX2014 conference you spoke about `promhx`, what's changed in the last two years?

There's been some relatively minor improvements and updates. I've had several positive but time consuming life changes recently (I have a new 1.5 year old!). That coupled with the new Lua work has not left me much time to focus on some of my older libraries.
 
## While creating the Lua target, what has your experience been like working on the compiler source?

OCaml is strikingly different than just about any language I've used. I'm still a beginner with it, and my code is not very elegant. However, I appreciate it more as I use it, and I definitely see precursors to some of my favorite Haxe features there _(ADT, helpful typo messages, etc)_. The compiler is comprised of several layers, and I believe the core team has laid out these modules in a sensible fashion. 

I don't want to go into too many specifics, but one thing I personally would do differently now would be to rewrite unsupported target expressions where possible, instead of emitting source code directly _(as JavaScript and Lua do currently)_. Hopefully that won't bite me to badly with support moving forward.

## Is this similar to Hugh's work on cppast?

When I say rewrite expressions, I mean when the `genlua.ml` code encounters an expression that can't be translated directly to Lua, it should create a new expression and generate code for that. What I'm doing now is basically just inlining Lua code directly that works around the issue on a case-by-case basis. The problem there is that it involves a lot of duplication and inconsistency in some cases.

## What was your biggest challenge working on `genlau.ml`?

I didn't know OCaml or Lua when I started out. So, this project has been a bit like trying to start translating Dothraki into Klingon after only watching a couple of shows. I wouldn't say that I was particularly efficient in making progress, as it is over a year since I started. 

However, I did take pretty good notes on my thought process along the way. They outline the challenges that I faced as I uncovered them. You can find these now in the commit messages for the Haxe compiler… just look for commits prefixed with _“Lua”_. I plan on scraping these and publishing them somewhere. I hope they'll help someone else learn!

The biggest challenge overall has been how limited the Lua target is. It lacks boolean operators, integers, and uses a shared convention for arrays and hash tables. It indexes from 1, and scopes variables to functions, but does not auto-hoist them. It also is incredibly fragmented, having significant incompatibilities between `lua 5.2`, `luajit 5.2`, and `lua 5.3`. I'm trying to get `5.2` right (for lua and luajit) before tackling `5.3`. So, only `5.2` is supported for now. 

## Wow.

## What has it been like working with the core team?

The core team has been very supportive, but I tried hard not to add Lua specific problems to their burden for a release. Only recently after crushing some particularly tricky bugs did I feel confident enough for general bug handling duties.

[Simn](https://github.com/simn) deserves special thanks, as he was the core team member that was the most active in discussions and development. [Daniel](https://github.com/nadako) also gave a lot of good input. I also wanted to thank [PeyTy](https://twitter.com/PeyTyPeyTy) from the Haxe Community, who collaborated with me pretty heavily at the critical early phases.   

## What use case does the new Lua target solve?

Lua is particularly in vogue right now as a lightweight scripting layer for more complex app logic. The Haxe Lua target is designed to go everywhere that the Lua target can go. From the speedy Luajit compiler, to the [Torch](http://torch.ch/) machine learning framework, to the [LÖVE](https://love2d.org/) game engine, to the [Corona](https://coronalabs.com/) cross-platform 2d mobile graphics SDK, to the WoW scripting client, to enumerable other editor and game plugin libraries, the Haxe Lua target extends Haxe's flexible and powerful language features to those areas.

I would be quick to add that Lua also provides safe means of sandboxing third party code. For this reason, not all Haxe standard modules _(e.g. sys/net)_ may be available in a given context due to platform limitations _(e.g. WoW scripting)_. In addition, many of these sys modules rely on third party lib support. Accordingly, Lua is not as _“batteries included”_ as many other Haxe targets, and may require some specific configuration that may or may not be possible. This is still an active area of development for the Lua target, and most of the current work for Lua involves development on these areas. Stay tuned for more details!

In closing, I wanted to say finishing the Lua target has been particularly satisfying. I came away more impressed with [Nicolas](https://twitter.com/ncannasse), [Hugh](https://twitter.com/GameHaxe), [Cauê](https://twitter.com/cwaneck), [Simn](https://github.com/simn), [Franco](https://twitter.com/fponticelli), [Frabbit](https://github.com/frabbit), and the core target developers during the process. In many ways they've tackled problems that were even more daunting than Lua. I'm happy to have done something that puts me in that group.

## Thanks for adding the **10th** target, another target to investigate and compile too! It would be interesting to hear more from the core developers, maybe a _“core”_ dev interview series or something…

I'd be all for a core dev interview series. It's a great group, and I think the range of personalities, nationalities, and interests is incredibly diverse. I think the trick there would be to get them talking about the things they're passionate about, Haxe related or not.

That said, there's plenty of other folks that haven't made core compiler contributions but are still big parts of the community. In many ways their stories are just as important, if not more so than the core dev team.

## I agree, there are plenty of people throughout the community I can think of who would be great to interview. I think I should pull my finger out and start something.

I'll close out by saying thanks for taking the time to blog on the Haxe community. It's a relatively small group, but I read every last bit of info on the mailing list or on your roundups. I'll look forward to whatever you do next!

## Cheers!

Ok first of all, sorry about my english (not my native language).
 
About our discussion: it's all *great* work, but something needs to be done about
this fragmentation. OpenFL might be the worst in this regard. I get the need for
all all these different repos, but doing a simple patch is an absolute nightmare
because of all the sync and pull request you need to make to add a single simple
feature. 

Like for example I wanted to add a better support for ArrayBufferView and
the likes (missing functions and types from the base reference) and... Well, I did it,
sort of, but pushing to all of these repos was so annoying that I choose not to, 
reverted my changes and made my own small framework on top of the existing one to 
fill the voids. Meh.
 
OpenFL really needs to focus on fixing all cross platform inconsistencies as well 
before adding yet-another-dead-in-the-water-target or some fancy niche feature. It's 
easy to say, I know... Believe me when I say I love OpenFL, it really is an amazing 
piece of tech, but it's still very rough on the edges.
 
And yeah I get why you forked hxcpp (from regular chat sessions with Sven) and I'm 
all for it. I get the NME fork as well and everything. I'm just saying, right now 
the landscape is a mess and scary for anyone picking up Haxe. Way too much confusion, 
maybe some ego battle as well, [hint]. 

And most important of all : not enough QA 
(yes, it's an open source project made by an open source community, I know that). 
Every time I update OpenFL or lime, something breaks. I have to dig the forums, 
lists or find a single line of text hidden in the blog to figure out why it broke. 

Communication needs some work I think. I can't offer solutions (although a clean 
extensive changelog would be a good start), I'm just saying (which make me looks 
like an asshole, but I'd rather talk than shut up). Documentation is another issue 
but I know it's coming.
 
tl;dr the Haxe ecosystem is fraking promising, works somewhat ok but need some 
cleanup and QA to make it perfect and worthy of its name and promises.

[hint]: https://groups.google.com/forum/#!msg/haxelang/lYsI-hf2NEQ/eLXPbJcxsf8J
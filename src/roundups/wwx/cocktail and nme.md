[_template]: ../../templates/wwx/video.html
[“”]: a ""

# Development Workflow with Cocktail and NME by Thomas Fétiveau

> [Silex Labs] originally posted the article [WWX 2014 Speech: Thomas Fétiveau : Development workflow with Cocktail and NME][sl1]
> which links to the YouTube videos, Thomas's slides and a brief
> synopsis of the talk. Below are the videos and my own overview of the talk.

![youtube 100%x100%](-iKEMzPWpbo)

## Overview

[Thomas][tw3] shares his knowledge of using [Cocktail][l5], a HTML and CSS rendering
engine by SilexLabs the hosts of WWX. He starts off with the development workflow that
he uses, starting off by targeting any browser and once everything is working, compile
using Cocktail to the Flash player to see if anything needs fixing. 

Finally he compiles
using Cocktail and NME to target mobile platforms. These three steps appear deceivingly
simple, but the Cocktail team have written HTML and CSS parsers which are attempting
to be W3C compatible and work on *__any__* Haxe target.

Thomas then goes onto show projects he has used Cocktail in, [EBuzzing][l6] Buzz player, [TF1][l7]
connect app which targets Adobe AIR, displaying live streams, real time comments, votes and 
interactions on Twitter and Facebook, the [TF1][l7] X player which compiles to HTML5, Flash, native
iOS and Android and available as a native app fragment. With each project, Cocktail has
been improved with new features and bug fixes.

But it does have its limitations like any library. It currently doesn't have full CSS support,
missing some HTML elements. Its best to checkout Cocktails HTML and CSS [status][l8] page. But
it is great for apps that need to target web and native with no compromise on performance and
compatibility.

I'm continually impressed by this library and this talk just reinforces that fact for me.

## Slides

![slideshare](35076396)

## Demo

Thomas [published][l9] the source for the demo which appeared in his talk, available
from GitHub.

[silex labs]: http://www.silexlabs.org/ "Silex Labs"
[sl1]: http://www.silexlabs.org/wwx2014-speech-thomas-fetiveau-development-workflow-with-cocktail-and-nme/ "WWX 2014 Speech: Thomas Fétiveau : Development workflow with Cocktail and NME"

[tw3]: https://twitter.com/zab0jad "@zab0jad"

[l5]: https://github.com/silexlabs/Cocktail "Cocktail the HTML & CSS rendering engine on GitHub"
[l6]: http://www.ebuzzing.com/ "Ebuzzing Video Advertising"
[l7]: http://www.tf1.fr/ "MyTF1"
[l8]: https://docs.google.com/spreadsheet/ccc?key=0AoCymbuV0hQfdFZNVmc0bnZmRGZHTWlpemszMUd6THc#gid=0 "Cocktail HTML & CSS Status"
[l9]: https://github.com/zabojad/wwx2014-cocktail-nme "Demo App for WWX 2014 talk on Development workflow with Cocktail and NME"
Testing different image hashing methods
=======================================

We need to recognize images we've seen before. These are a bunch of tests to figure out the best speed-accuracy-size compromise.

I tried a bunch of different approaches for the hashing: colored and b&w, average color, brightness, most common colors, etc. 

MTG card detection
------------------

In corner-detection.rb I tried to code a fast and effective way to detect a MTG card in a picture. 

Fabio ended up using some of the things I tested out in these scripts in an iOS app. Check out http://noopcode.com/posts/iOS-Image-Recognition for details.
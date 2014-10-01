Twitter
=======

use Twitter APIs build a data visualizer for Twitter, based on the location of the most recent tweets that have geolocation information. In particular, you will use the Twitter framework to get the most recent tweets within a 1-mile radius of the user’s current location and display it on a map.1 Be sure to make network requests asynchronously; synchronous requests will lock up the user interface until the request is completed!
But let's make this a little more interesting: the app will continuously poll for new tweets, and display them on the map when they are received.3 Once 100 pins have been placed on the map, the 10 oldest tweets should be removed. If the app gets data for more than 100 tweets, it should display the most recent 100. Displaying too many pins on the map can slow down the event handling on the UI. 
If the user taps on one of the pins, a small view should display some information about the tweet, and a button to take them to a separate view that displays more information about the tweet (user’s twitter handle, the tweet’s text, timestamp, user’s avatar, etc.). On this separate view, the user should have the option of favoriting or retweeting that particular tweet (this can also be accomplished using the Twitter Framework). 
Criteria of interest 
1.	User Experience 
		*Flow of the user experience, *Negligible latency in user interaction, *Error Handling 
2.	Efficient use of network calls and available information 
*Asynchronous calls, *Requesting only necessary data, *Resourceful reuse of information 
3.	Code quality and style 

Copyright (c) 2015 Austin Zelenka

DEMO NOTES


SYSTEM REQUIREMENTS
- Mac running OS X El Capitan 10.11.1 (or later)
- Xcode 7.2 beta 4 (or later)
- 4th Generation Apple TV running tvOS 9.1 beta 3 (or later)


DEMO NOTES
- No server-side changes were required. All content is loaded directly from http://tv.jw.org and http://mediator.jw.org and referenced URLs.
- JW Broadcast app can play content in 78 differnet langauges, using the same localized strings and content hosted on tv.jw.org
- NOTE: 
- For maximum performance 'JW Broadcasing' app is entirely in Swift. 
- Although it's functional, this app is still a work in progress. Lots of code clean up and comments remain to be done.



DEMO TIPS
- Place the JW Broadcasting app in the Top Shelf in the Apple TV home screen. The JW Broadcasting Top Shelf logo should appear when the app is in focus.
- Select one of the Featured Presentations. After playing for awhile, push the Siri button and say "Fast Forward 5 minutes" or "Rewind 5 minutes"
- Change langauge to American Sign Language. Play a Sing to Jehovah Audio song and watch video.


HOME

Featured Items
- Top row displays Featured Presentations, and auto rotates ever 10 seconds.
- You can swipe left or right infinitely in the Featured Items. (Swiping left is a little jumpy.)
- Text overlays the image, in the users selected language.
- Selecting any Featured Presentation changes the background image visual.
- Custom Marquee code scrolls through the text so you can read it all even in languages like German with long text. (Does not support RTL Languages)

Streaming
- The 12 streaming channels are displayed. 
- Focusing on a Streaming channel displays a preview of what's currently playing on that channel (audio off). Select to play.
- Selecting a streaming channel puts the image into focus and changes text from dark gray to white.
- NOTE: Siri voice commands are disabled in Streaming channels.
- Custom Marquee code scrolls through the text so you can read it all even in languages like German with long text. (Does not support RTL Languages)

Latest Videos
- The latest videos are automatically highlighted.
- Selecting a video puts the image into focus and changes text from dark gray to white.
- Long titles are truncated with "..." Plan to implement scrolling text when time allows.
- Custom Marquee code scrolls through the text so you can read it all even in languages like German with long text. (Does not support RTL Languages)


STREAMING
- Loads the currently streamed video in 720p.
- NOTE: Siri voice commands are disabled in Streaming channels.


VIDEO ON DEMAND
- Content is automatically organzied. First items displayed are Featured followed by other custom categorizations. 
- 'From Our Studio' uses custom code to remove 'JW Broadcasting—" and add "Braodcast" to the end of the title name for easier reading. This is hardcoded and only works in English but other languages can easily be added.
- Not all images displayed are ideally sized, so an ordered list is used to select correct size, starting with images types of 'wss', 'cvr', 'lss', 'wsr', 'pss', and psn'


AUDIO
- Content is auto organized. 
- NOTE: Investigating new UI for the 'Audio' tab to take into account the unique UI needs of finding and playing music, e.g. large quantity of items, lots to swipe through, No 'Play All' or 'Shuffle' buttons, etc.


LANGUAGE
- Select from amoung 78 differnet supported language types, including English, Danish, ASL, Chinese and Arabic.
- Languages are displayed in the local vernacular so you can always tell what language is your language.
- NOTE: Code is in place to keep you on the page while new content in the selected language is loaded.
- Apple TV does not incldue a font for Myanmar, so JW Broadcast app included an open source font called Myanmar3.
- DEMO TIP: Try changing to other languages (e.g. Chinese, ASL, Russian, Arabic, etc.)


FUTURE ENHANCEMENTS & INVESTIGATINS
- Search tab
- Siri support
- Interstitial screen to display  video detail (length, langauges, etc.) pressing Play.
- Abiltiy to resume videos where you left off.
- INVESTIGATE: New layout for Video on Demand screen. 
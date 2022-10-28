# techChallenge

## Key points to answer

### What architectural design pattern did you use and why?

While working on the tech challenge I chose Apple's propagated MVC Cocoa design pattern.
There's a built-in support in terms of classic UIViewController's.
For the test app, and for time reasons I find this pattern suits well.

### What would you improve if you had more time?

When it comes to architectural point, I'd spend more time to elaborate current solution
by moving out part of business logic which still lives in ViewController(View) layer outside.
Regarding PhotoKit and Vision frameworks, the API isn't really intuitive,
but really powerful. To achieve the desired result more affectively, you need
to find it out by yourself by testing methods with different parameters. Besides that,
there're also several distinct flows while working with those frameworks to handle
(eg. fetch photos from local storage or from cloud services.)

### What would you like to highlight in the code?

I'd like to highlight parts of the code which handle working with fetching images from
PHAsset objects. There's elaborate caching logic which could be tuned up with different
parameters. I'd also like to mention animation details view logic.
There's a workaround to properly handle the case with animated `contentMode` property changes.

## Used resources

- https://developer.apple.com/documentation/photokit/phasset
- https://developer.apple.com/documentation/photokit/phcachingimagemanager
- https://developer.apple.com/videos/play/wwdc2019/222/
- https://developer.apple.com/documentation/vision/vngenerateattentionbasedsaliencyimagerequest

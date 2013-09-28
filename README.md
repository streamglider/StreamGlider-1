# ![StreamGlider](https://github.com/streamglider/images/blob/master/StreamGlider Logo Small.png?raw=true) StreamGlider

***By [StreamGlider Inc.](http://streamglider.com/)***

StreamGlider is a personal news and information delivery app. StreamGlider lets users build streams of information sources. Streams are mixtures or mashups of frames containing RSS feeds, Twitter, Facebook, YouTube or other information sources. Each frame in a stream can contain news or information from one of these sources, filtered by search criteria. Any number of streams can be built by the user and any number of pages (groupings) of streams can be built. Or, the administrator can limit the number and/or provide locked-in, pre-built streams.

Three modes of viewing are supported in StreamGlider. Grid mode is a lean-forward, grid view of the streams [[VIDEO]](http://www.youtube.com/watch?v=i8xJh0ZhrKc). Slideshow mode is a lean-back, full-screen view [[VIDEO]](http://www.youtube.com/watch?v=2kc3swNEfWE). Magazine mode is a page layout viewing mode for streams and frames, with larger areas devoted to each frame of a stream [[VIDEO]](http://www.youtube.com/watch?v=wxreVOVsbIM).

## Key benefits

The benefits of using StreamGlider over other news and information platforms are many:

* Configurability: users and/or administrators can create a custom focus and look to the news and information they display [[VIDEO]](http://www.youtube.com/watch?v=1__UEi_TJp4)
* Brandable: StreamGlider can be white-labeled with branding assets or private-labeled with more extensive cusomizations [[VIDEO]](http://www.youtube.com/watch?v=NCz01u3UNOE)
* Heterogeneity: streams pertaining to a single subject can be built with diverse sources all filtered for that subject
* Timeliness: StreamGlider selects the most current stories, postings, or uploads that match its user-defined selection criteria
* Stewardship: because StreamGlider can be branded by the administrator, it can be used as an enterprise-specific application, with general or restricted availability
* Event displays: when connected to a big screen, StreamGlider is ideal for displays at conferences, trade shows, and other events [[VIDEO]](http://www.youtube.com/watch?v=7xqv2NIjyiI)

StreamGlider consists of an API server (for managing streams, directories of available streams, users, etc.) and the iPad app itself.

A full list of features is available here: https://github.com/streamglider/streamglider/wiki/Feature-List

## StreamGlider API server setup

The StreamGlider API Server requires Ruby 1.8.7 or higher and Ruby on Rails 3.0.3.

Before the server can be deployed, the following configuration options should be provided:

* In the "config/environment.rb" file, please provide your StreamGlider API server host name, "HOST_NAME = '<TODO: add your host name here>'"
* In the "config/environments/production.rb" file, please configure 'config.action_mailer.smtp_settings'
* Please generate new 'hash_secret' and 'secret_token' in the "config/initializers/paperclip_defaults.rb" and "config/initializers/secret_token.rb" files
* Provide a server name, e.g. "Acme Corporation API Server" in the "config/initializers/server_name.rb" file

**Note**: all places where changes are to be made can be found with a simple search for the 'TODO:' string.

More details are available here: https://github.com/streamglider/streamglider/wiki/Server-Installation-Guide

## StreamGlider iPad app setup

There are several things to take care of before an iPad app can be published.

### StreamGlider API server configuration

In the "Other Sources/StreamCastServerConfig.m" file, please provide 'API_V2_URL', a URL to your StreamGlider API server host name.

### StreamGlider app settings

In "Other Sources/StreamCastConstants.m", please provide 'APP_NAME', 'RELEASE_DATE', 'TAG_LINE' and 'SITE_URL'. 'SITE_URL' is a separate URL from the StreamGlider API server host name, usually used for marketing-related information. 

In StreamGlider target editor, 'Bundle identifier' and 'Bundle display name' should be changed. 

More information on text changes for configuring the app are available here: https://github.com/streamglider/streamglider/wiki/Text-Changes

### Social networks integration

"Other Sources/StreamCastServiceKeys.m" file contains social network-related configurations. Twitter, Facebook, flickr and YouTube are currently supported. Applications should be registered with social networks in order to get the necessary client/consumer IDs and secrets.

### Proxy support

Proxy can be enabled and configured using the "Other Sources/StreamCastProxyConfig.m" file.

### Graphic resources 

StreamGlider iPad app contains several branded images that should be replaced before publishing. All of the images reside in "Resources" folder, please see the file names listed below:

- "iTunesArtwork.png"
- "Default-Landscape.png"
- "Default-Portrait.png"
- "AppIcon_72x72.png"
- "AboutImage.png"
- "Email Capture/banner.png"
- "Email Capture/email_background.png"
- "Streams View/motif.png"
- "Launch-Card.png"

More information on these graphics is available here: https://github.com/streamglider/streamglider/wiki/Graphic-Assets

## Additional Information 

### Maintainers

* [wdmcdaniel](https://github.com/wdmcdaniel) (code, documentation)
* [johnbreslin](https://github.com/johnbreslin) (documentation)

### License

This program is distributed for non-commercial use under the BSD 4-clause license. Commercial-use licensing is available by contacting [info@streamglider.com](mailto:info@streamglider.com). A copy of the license is included with this distribution in the "StreamGlider Licenses.txt" file which must accompany any distribution of the code.

### Third-party components

StreamGlider makes use of a number of third-party components, all of which are open source with no restrictions on their use or redistribution apart from attribution in some cases. More information on these component licenses are available here: https://github.com/streamglider/streamglider/wiki/Third-Party-Components

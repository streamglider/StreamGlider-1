# StreamGlider

By [StreamGlider](http://streamglider.com/).

StreamGlider is a personal news and information delivery app. StreamGlider lets users build streams of information sources. Streams are mixtures or mashups of Frames containing RSS feeds, Twitter, Facebook, Youtube or other information sources. Each Frame in a stream can contain news or information from one of these sources, filtered by search criteria. Any number of streams can be built by the user and any number of pages of streams can be built. Or, the administration can limit the number and/or provide locked in, pre-built streams.

Three modes of viewing are supported in StreamGlider. Grid mode is a lean forward, gridded view of the streams. Slideshow mode is a lean back, full screen view. Magazine mode is a page layout viewing mode of streams and frames, with larger areas devoted to each fame of a stream.

## Key Benefits

The benefits of using SG over other News and Information platforms are many:
- Configurability - Users and/or administrators can create a custom focus and look to the news and information they display
- Brandable - StreamGlider can be White labeled with branding assets or private labeled with more extensive cusomizations
- Heterogeneity - Streams pertaining to a single subject can be built with diverse sources all filtered for that subject
- Timeliness - StreamGlider selects the most current stories, postings, or uploads that match its user-defined selection criteria
- Stewardship - because StreamGlider can be branded by the administration, it can be used as an enterprise specific ap[plication, with general or restricted availability

## StreamGlider server setup

Server app (sg_server) requires Ruby 1.8.7 or higher and Ruby on Rails 3.0.3

Before the server can be deployed, the following configuration options should be provided:

- In "config/environment.rb" please provide your SG API server host name, `HOST_NAME = '<TODO: add your host name here>'`

- In "config/environments/production.rb" please configure `"config.action_mailer.smtp_settings"`

- Please generate new `hash_secret` and `secret_token` in "config/initializers/paperclip_defaults.rb" and "config/initializers/secret_token.rb"

- Provide a server name, e.g. "StreamGlider API Sever" in "config/initializers/server_name.rb"

**Note**: all the places where changes are to be made can be found with a simple search for "TODO:" string.

## StreamGlider iPad app setup

There are several things to take care of before iPad app can be published.

### StreamGlider API server configuration

In "Other Sources/StreamCastServerConfig.m" file please provide `API_V2_URL`, a URL to your SG API server host. 

### StreamGlider app settings

In "Other Sources/StreamCastConstants.m" please provide `APP_NAME`, `RELEASE_DATE`, `TAG_LINE` and 'SITE_URL'. `SITE_URL` can be a separate from SG API server host with marketing related information. 

In StreamGlider target editor, `Bundle identifier` and `Bundle display name` should be changed. 

### Social networks integration

"Other Sources/StreamCastServiceKeys.m" file contains social networks related configuration. Twitter, Facebook, Flickr and YouTube are currently supported. Applications should be registered with social networks in order to get necessary client/consumer IDs and secrets.

### Proxy support

Proxy can be enabled and configured using "Other Sources/StreamCastProxyConfig.m" file.

### Graphic resources 

StreamGlider iPad app contains several branded images that should be replaced before publishing. All of the images reside in "Resources" folder, please see file names listed below:

- "iTunesArtwork.png"
- "Default-Landscape.png"
- "Default-Portrait.png"
- "AppIcon_72x72.png"
- "AboutImage.png"
- "Email Capture/banner.png"
- "Email Capture/email_background.png"
- "Streams View/motif.png"
- "Launch-Card.png"

## Additional Information 

### Maintainers
TODO: Add a list of maintainers

### License
This program is distributed for non-commercial use under the BSD 4-clause license. Commercial use licending is available by contacting info@streamglider.com. A copy of the license is included with this distribution in the "StreamGlider Licenses.txt" which must accompany any distribution of the code.
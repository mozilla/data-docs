There are two [Content delivery networks (CDNs)](https://en.wikipedia.org/wiki/Content_delivery_network) Mozilla utilizes for delivery of its products: AWS Cloudfront, and Akamai.

* Stub Installers are downloaded from download-installer.cdn.mozilla.net (Cloudfront)
* Full Installer downloads initiated by stub for V60+ download from download-installer.cdn.mozilla.net (Cloudfront)
* Full Installers initiated by stub for pre-V60 download from download.cdn.mozilla.net (Cloudfront)
* FTP hosted by Cloudfront 

| FTP                               | http://ftp.stage.mozaws.net        | Cloudfront          |
|-----------------------------------|------------------------------------|---------------------|
| stub                              | download-installer.cdn.mozilla.net | Cloudfront          |
| Full initiated by stub (post V60)  | download-installer.cdn.mozilla.net | Cloudfront          |
| Full initiated by stub (pre V60)   | download.cdn.mozilla.net           | Cloudfront /Akamai |

Before version 60, the full installer were downloaded through Akamai (e.g., download.cdn.mozilla.net). After version 60, the stub initiated full installers go through Cloudfront (e.g., download-installer.cdn.net).

For a thorough description of Mozilla’s product delivery architecture, see this [Mana page](https://mana.mozilla.org/wiki/pages/viewpage.action?spaceKey=SVCOPS&title=Product+Delivery).
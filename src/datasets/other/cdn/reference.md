# Content Delivery Network

<!-- toc -->

# Introduction

{{#include ./intro.md}}

# AWS Cloudfront
The Cloudfront CDN is where stub and full installer downloads occur. 

The installer logs can be queried on STMO, under the under the Athena Download Installer Cloudfront group. The following fields are contained in the cloudfront.download_installer table.

Due to the installer logs containing IP information, access is limited and requires [submitting a bug](https://bugzilla.mozilla.org/show_bug.cgi?id=1532449).

Records for the following product downloads are available:
* Firefox
* Thunderbird
* Mobile
* Webtools
* Seamonkey
* Camino
* Spidermonkey
* Android
* Firebird

Example uses of the Cloudfront data
* [Quantifying full installer downloads](https://docs.google.com/document/d/1pjFqAA_NkbkWlGBgRZpdFxYvJHmeD-X8vLnzaWsMsHg/edit#)
* [Request IP Full Installer Distribution](https://metrics.mozilla.com/protected/cdowhygelund/requestip_full_installer_analysis.html)
* [Cloudfront Downloads dashboard](https://sql.telemetry.mozilla.org/dashboard/cloundfront-downloads-full-installers) ([requires access](https://bugzilla.mozilla.org/show_bug.cgi?id=1532449))

# Akamai
Akamai contains data from pre-60 Full initiated by stub installers. 

To gain access to Akamai CDN, submit a [bug request](https://bugzilla.mozilla.org/show_bug.cgi?id=1529057). Akamai data is accessed through the Luna Control Center. 

To gain access to the log data once logged in:
1. Click on the hamburger menu on the upper-left. 
2. Select Common Services &#8594; Traffic Reports. 
3. Select  the relevant CP code (download.cdn.mozilla.net)







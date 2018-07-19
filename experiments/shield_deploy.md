# Deployment: Path to 100% of Release.

**Important**[^flux]:  (2018/08/16) These processes are in flux and subjects to change, as this path gets solidified.

The Shield Program is a Go Faster program.  Deploying via "Shield" (the Delivery Console) is in cooperation with Release Management, Firefox Engineering, and the PI group.

Deploying "via Shield" is not a way of circumventing [Release Management and the Trains][trains].  

To get to 100% of Release, your code / coniguration must eventually ride the trains.  

You will need to prove that your code has low Technical Risk and low User Acceptance Risk.  Opportunity Risk (market deadlines, contracts) may change that risk calculus.

**Good news**: However, for Probes that measure User Acceptance risk, Shield helps you gather that information faster.

**Good news**:  [Surveys][surveys] are really fast.

## Permanent code and configuration changes

Changes following this path are expect to have answer questions of Technical Risk using usual Train process for PI, QA, Testing, Peer Review.  

This flow ensures that if there are *unexpected* user impacts, the change can be 'rolled back'.  

1.  [Ride Trains][trains], possilby hidden behind a preference.
2.  **Optional** [Uplift][uplift] to enter Release faster.
3.  In Delivery Console, enable the Feature / configuration change to 1-99% of Release users to collect user impact data.  Enables special Telemetry tracking of the feature for faster analysis of the controlled rollout.
4.  (Evaluate impact for as long as necessary). 
5.  **Optional**.  Backout / disable if warranted.
6.  Finalize the change using a patch, released in the next Firefox release.  


## Temporary Data Collection tools, including Shield Study Addons, probes, and configuration changes.

**Shield gains quicker access to User Acceptance Evidence in exchange for never being permanent or going to wide audiences.**

All assumptions of 'lowered risk review' rely on managing risk through minimizing exposure.  

Important note: this path will not affect more than 1% of Release.

1.  [Tell S+I you exist, so we can help.][contact]
2.  Review prior research, Survey results.  If these answer the question

    - kill / pivot the feature 
    - follow the permanent path previously described

3.  Create PHD, and get preliminary review
4.  Create Code to implement PHD Design

    - either as part of the [Tree][train] (telemetry probes, gated Features, enabling utility code.  Secure [uplift][uplift] if appropriate.
    - [a webExtension or webExtension experiment][engineering]

5.  Pass the 1% (Shield) Firefox Peer review and PI/QA processes.
6.  Notify Release Management
7.  Delivery Console recipe targeting, up to 1% of Release, per PhD and RelMan emails.
8.  (Evaluate impact for as long as necessary). 
9.  **Optional**.  Backout / disable if warranted.
10. Decide on outcome. Pivot, kill, or follow 'Permanent Change' path above.


## Surveys and User Feedback Tools (Heartbeat)

Heartbeat (Firefox Users)

1.  [Tell S+I you exist, so we can help.][contact]
2.  Write the Survey / User Messaging Tool
3.  In Delivery Console, use the Heartbeat action to launch your 'message and a link' Study.
4.  See collected data and make a decision.

General Population or other target panels.

1.  [Tell S+I you exist, so we can help.][contact]
2.  Write the Survey / User Messaging Tool
3.  Deploy using whatever panel recruitment tool.
4.  See collected data and make a decision.


- **Technical Risk**: 

  - Code doesn't work as described
  - Code interacts badly with other Firefox code on performance or crashes.
  
  Remediation
  - Usual train process: ride the trains, or get [uplifted][uplift]
  - unit and function tests
  - crash reports
  - code review by Firefox Peers


- User Acceptance Risk (Product-Market fit)

  - Surveys, prototypes
  - Shield studies
  - hidden behind prefs.



---
  
[^flux]:  Important: This is written from the perspective of a Shield Experiments lead. Release Management, Engineering, and PI are the authorities here.

[engineering]:  https://github.com/mozilla/shield-study-addon-utils/docs/
[contact]: shield_help.md
[surveys]: shield_surveys.md
[trains]: https://wiki.mozilla.org/Release_Management/Release_Process
[uplift]:  https://wiki.mozilla.org/Release_Management/Uplift_rules


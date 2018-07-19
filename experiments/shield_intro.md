# Getting Started With Shield

## "Shield" Means Different Things in Different Contexts

"Shield" conflates several overlapping concepts.

  * Feature Experimentation using Shield
  * Off-Train Deployment of code, messages, configuration using **Delivery Console**
  * Shield Study Addons (`webExtensionExperiments`)
  * `shield-studies` and `shield-studies-addons` Telemetry Pings / Data Set

We think of Shield as the culmination of the Go Faster program.

## Facts you should know about Shield

1. **Shield is Mozilla's program for gathering evidence to make better decisions**.  

    All policies, processes, and engineering choices serve that goal.

2. **[Tell us you exist, so we can help your project](./shield_help.md)**.  

    If we don't know about your project, we can't offer any help.  Early notice prevents over-building and mistakes.  We can help you get better data for your decision faster.
    
    Nothing is too small to ask!

3.  **[Shield is not about skipping the trains][deployment]**.  Code that goes to Release is peer reviewed and QA tested.  Launching into (small subsets) of Release is about getting questions, probes, code and configuration to the right populations.

    - Ideas should be risky, not code.
    - Small populations mitigate Technical Risk
    - Release Management, Engineering, PI, and QA (among others) assess questions of risk.
    - Some things make sense to be on the trains.

4.  [The **Risk Profile** of your decision determines your project design][design] &ndash; the **evidence you need** and **what to build**.
    
    - if **User Acceptance** is your main risk:  do surveys, then get data in release (using Shield or Delivery Console).
    - if **Technical Risk** is your risk: ride the trains, collect crashes, and widen slowly to new locales and hardware.
    - if **User Impact Risk** is your main risk, then you probably want to ride the Trains, and un-throttle using Delivery Console.  Delivery Console instruments provisional changes, and allows Release Managers to turn them off.
    - if **Opportunity (Market Timing) Risk** (missing a ship date / partner contract date) is your main risk, you may have accept higher Technical, User Acceptance, and User Impact risk. Release off-train with approval, hotfix, point releases and other "high touch" solutions might be needed.


5. [**Code is expensive.  Surveys (and other user Feedback) are cheap**][surveys].  

    As an engineer, it is tempting to use code as the first solution to problems.   

    You might not need to.  In particular, you might not need a Shield Study (Addon).  
    
    User feedback about UI, messaging, and product-market fit also manages User Acceptance Risk, and are much faster than deploying instrumented code.



6.  **[Shield Study Addon engineering is complex][engineering]**.

    The Goal of Shield Study Engineering is to get probes to the right users, so that you can gather analyzable evidence to make decisions.
    
    - Building an addon should be your last resort for gathering evidence.
    - All the problems of building addons and a feature and variations and probes.
    - All the testing problems of Firefox code *and* the problems of debugging probes and variations.
    - Surveys can get lots of useful info, even from Release users or users of other browsers
    - A pure webExtension might be enough to ideate.
    - Only some webExtensionExperiment code needs the [`shield-study-addon-utils`][ssau].
    - [Shield Study (Addon) Engineering hints here][engineering].


[deployment]:  ./shield_deploy.md
[design]: ./shield_design_process.md
[engineering]:  https://github.com/mozilla/shield-studies-addon-utils/tree/master/docs
[ssau]: https://github.com/mozilla/shield-study-addon-utils
[surveys]: ./shield_surveys.md

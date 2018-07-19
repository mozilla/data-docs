# Collecting Evidence to Make Decisions:  The Mozilla Shield Program

The Mozilla Shield Program exists to help make decisions using evidence.


## Shield Decision Design Process

Note: the answers to this though process guide:

- [Deployment][deploy]
- [PhD Process][phd]

Steps:

1. Define The Decision
2. Target Appropriate Users
3. Deploy Evidence Gathering Probes
4. In a 'Good Enough' Context
5. Collect Evidence
6. Analyze the Evidence
7. Make (Better) Decisions about existing and potential product features.

**Hint:** Please [Contact Us][contact] during Stage 1: Define The Decision. 

### 1. Defining the Decision

The Decision to be made determines the evidence to collect, the deployment mechanism, and all engineering decisions.

**Decisions** fall into four main classes:

0.  **Should I invest in it?** 
    
    - Surveys (Attitudinal research) are cheap.
    - quality instrumented code is wildly expensive

1. **It is built.  Is it good enough to launch in Firefox?**  

    Implies this flow:
    
    -   Launch
    -   Watch for problems (crashes, bug reports) 
    -   Measure / ensure expected success
    -   Rollback if not there.

    Examples:
    
    - make a pref into default
    - turn on a feature hidden behind a pref 
    - change a security setting

    Methods for Deployment:
    
    - on-train deployment: all or nothing.  Advance by channels
    - off-train deployment: targeting, preference rollout

2. **Choose a "best option"**.

    - Create variations
    - instrument
    - launch and record
    - recall / tear down
    - make decision

    Examples:
    
    - which icon to use for thing
    - which language (messaging) to use
    - will users actually use the thing?
    - do users understand a thing?
    - what should we call a thing?

    Methods:
    
    - market research
    - hallway testing
    - surveys
    - prototypes
    - study extensions
    - pref-controlled features

    **Hint:** Collect the cheapest, dirtiest evidence possible that will influence the decision.

3.  **I think it works, but I have vague un-ease that I haven't anticipated all the ways it will go wrong in the field**

    Examples:
    
    - Graphics things might crash on cheap card
    - Security changes affecting major hard-to-see classes of sites (intranets, certain countries)
    - An 'innocuous' change somehow affects user perception and harms overall usage.

    Method:
    
    - Gated feature, slow rollout with measurement.
    - Permanent change in some some future point or full release.

### 2. Targeting Correct Users

Correct probes from inappropriate users leads to incorrect decisions.

Be as cheap as possible.

- Existing Market Research
- User Testing
- Survey Panels
- Firefox Users

Related:

- Delivery Console
- On-train / Off Train / AMO / Panel deployment

### 3. Instrument with Directive Probes

Good probes yield directive evidence.

- directive: different data implies different decisions
- efficient: doesn't require many events
- engineerable:  relates directly to user action and attitudes 
- analyzable:  transmitted in a form such that simple counts, means, maxes and other 'stats 101' techniques will give a useful answer.  Plays well with existing tooling and automation.
    * Heuristic:  can I make decisions with the result of `count`, `group by` in a SQL query on the table of collected data?

### 4.  The "Good Enough" Context

To minimize engineering time and risk, use the lowest fidelity context you can to deploy the probes.

Be cheap:

- text 
- drawings 
- designs 
- engineering in js 
- engineering in C++ / Rust

Deployment is expensive.

QA is expensive.

Analysis is expensive.

Release is expensive.


#### Do 'just enough' to support the probes

- If showing people a screenshot is enough, do that.
- If a survey is enough, do that.
- If making 'just a button' in the ui is enough, do that.
- If a 'feature flag' that is pref-controlled is enough, do that
- If landing in nightly is enough, do that.
- If the 'real' system would have a server, bundle data instead.
- Don't translate
- Consider 'windows-only' or 'osx-only'
- Ignore edge cases
- Do 'just enough' to support the probes.

### 5. Collect Evidence

- Surveys and other tasks build this in.
- Firefox feature Telemetry

### 6. Analyze The Data

- Surveys have this build in
- See the rest of this book for Telemetry based analysis

### 7. Make the Decision

You have data from your deployment.

It will not be perfect.  The analysis may raise new questions.

Make decision, and move to the next iteration.

If you are not happy with the decision:

- generate new choices
- collect more (expensive, or better targeted) evidence
- return to step 1:  Define the Decision.


[contact]: ./shield_help.md
[deploy]: ./shield_deploy.md
[phd]:  https://mana.mozilla.org/wiki/display/strategyandinsights/Shield

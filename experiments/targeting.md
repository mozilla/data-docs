# Targeting for Shield Programs

**All Delivery Console[^dc] actions (Surveys[^surveys], Preference Studies, Addon Studies)** can target **existing Firefox users** on any combination of:

- Channel
- Country (based on client IP)
- Locale
- Preference values
- New profile (Age of profile)
- Existence of other webExtensions
- Most things in Telemetry Main Ping
- Sample percentage (percentage of matching users)
- Re-using samples from previous studies
- [Full list of filters][filters]

**Surveys** can also use paid panels to target:

- Users of other Browsers
- Census-balanced samples
- (other more esoteric demographics)


Negation, exclusion and more sophiticated expressions are also possible.

## Get Help

- [Contact S+I][contact] for help.
- [Delivery Console (Normandy)][normandy]


---

[^dc]:  **Delivery Console** targets and delivers code and configuration to users.  This powers Shield and Heartbeat.
[^surveys]:  [Surveys, Attitudinal Measures, and other User Tasks](./shield_surveys.md).


[contact]:  ./shield_help.md
[normandy]: https://normandy.readthedocs.io/en/stable/user/index.html
[filters]: https://normandy.readthedocs.io/en/stable/user/filters.html

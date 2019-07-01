# Firefox Account Funnels

There are two primary "funnels" that users step through when authenticating with FxA. The **registration** funnel reflects the steps required for a **new** FxA user (or more precisely, email address) to create an account. The **login** funnel reflects the steps necessary for an **existing** FxA user to sign into their account.

We are also in the process of developing funnels for paying subscribers. We will add documentation on that once the work is is closer to complete.

## Registration Funnel

While there are some variations, the typical registration funnel is comprised of the steps described in the chart below. Except where noted, these events are emitted by the FxA content server.

|Step|Amplitude Event|Flow Event|Description|
|---|---|---|---|
|1|`fxa_email_first - view`|`flow.enter-email.view`|View (impression) of the form that the user enters their email address into to start the process. Note that this form can be hosted by FxA, or hosted by the relying party. In the latter case, the relier is responsible for handing the user's email address off to the FxA funnel. See "counting top of funnel events" below.|
|2|`fxa_reg - view`|`flow.signup.view`|View of the registration form. If the user got to this step via step 1, FxA has detected that their email address is not present in the DB, and thus a new account can be created. The user creates their password and enters their age.|
|3|`fxa_reg - engage`|`flow.signup.engage`|A user focuses/clicks on one of the registration form fields.|
|4|`fxa_reg - submit`|`flow.signup.submit`|A user submits the registration form (could be unsuccessfully).|
|5|`fxa_reg - created`|`account.created`|This event is emitted by the auth server. It indicates that user has entered a valid email address and password, and that their account has been created and added to the DB. However, the account is still "unverified" at this point and therefore not accessible by the user.|
|6|`fxa_email - sent` (`email_type` = `registration`)|`email.verification.sent`|An email is sent to the user to verify their new account. Depending on the service, it either contains a verification link or a verification code that the user enters into the registration form to verify their email address.|
|7|`fxa_email - click`| `email.verify_code.clicked`  |A user has clicked on the verification link contained in the email sent in step 6. Note this only applies to cases where a clickable link is sent; for reliers that use activation codes, this event will not be emitted (so be aware of this when constructing your funnels).|
|8|`fxa_reg - email_confirmed`|`account.verified`|This event is emitted by the auth server. A user has successfully verified their account. They should now be able to use it.|
|9|`fxa_reg - complete`|`flow.complete`|The account registration process is complete. Note there are NO actions required of the user to advance from step 8 to step 9; there should be virtually no drop-off there. The flow event is identical for registration and login.|

See [this chart](https://analytics.amplitude.com/mozilla-corp/chart/a9yjkzf) for an example of how this funnel can be constructed for the firstrun (about:welcome) page in amplitude. [Here](https://sql.telemetry.mozilla.org/queries/62595#160701) is a version in re:dash using the flow events.

The chart above provides the most detailed version of the registration funnel that can currently be constructed. However, it should not be considered the "canonical" version of the funnel - depending on the question it may make sense to omit some of the steps. For example, at the time of writing some browser entrypoints (e.g. `menupanel`) link directly to step 2 and skip the initial email form. Having both steps 7 and 8 may also be redundant in some cases, etc.

## Login Funnel

The login funnel describes the steps required for an existing FxA user to login to their account. With some exceptions, most of the steps here are parallel to the registration funnel (but named differently).

Users must confirm their login via email in the following cases:

1. A user is logging into sync with an account that is more than 4 hours old.
2. A user is logging into an oauth relier that uses encryption keys (e.g., Firefox send), if the user had not logged into their account in the previous 72? (check this) hours.

|Step|Amplitude Event|Flow Event|Description|
|---|---|---|---|
|1|`fxa_email_first - view`|`flow.enter-email.view`|Similar to the registration funnel, a view (impression) of the form that the user enters their email address into to start the process. Note that this form can be hosted by FxA, or hosted by the relying party. In the latter case, the relier is responsible for handing the user's email address off to the FxA funnel. See "counting top of funnel events" below.|
|2|`fxa_login - view`|`flow.signin.view`|View of the login form. If the user got to this step via step 1, FxA has detected that their email address IS present in the DB, and thus an existing account can be logged into. The user enters their password on this form.|
|3|`fxa_login - engage`|`flow.signup.engage`|A user focuses/clicks on the login form field|
|4|`fxa_login - submit`|`flow.signup.submit`|A user submits the login form (could be unsuccessfully).|
|5|`fxa_login - success`|`account.login`|This event is emitted by the auth server. It indicates that user has submitted the correct password. However, in some cases the user may still have to confirm their login via email (see above).|
|6|`fxa_email - sent` (`email_type` = `login`)|`email.confirmation.sent`|An email is sent to the user to confirm the login. Depending on the service, it either contains a confirmation link or a verification code that the user enters into the login form.|
|7|`fxa_email - click`| `email.verify_code.clicked`  |A user has clicked on the confirmation link contained in the email sent in step 6. Note this only applies to cases where a clickable link is sent; for reliers that use confirmation codes, this event will not be emitted (so be aware of this when constructing your funnels). Note that this event is identical to its counterpart in the registration funnel.|
|8|`fxa_login - email_confirmed`|`account.confirmed`|This event is emitted by the auth server. A user has successfully confirmed the login via email.|
|9|`fxa_login - complete`|`flow.complete`|The account registration process is complete. Note there are NO actions required of the user to advance from step 8 to step 9; there should be virtually no drop-off there. The flow event is identical for registration and login.|

See [this chart](https://analytics.amplitude.com/mozilla-corp/chart/53dqtlo) for an example of how this funnel can be constructed for the firstrun (about:welcome) page. [Here](https://sql.telemetry.mozilla.org/queries/63048#161676) is a version in re:dash using the flow events.

Note again that you may want to check whether the service you are analyzing requires email confirmation on login.

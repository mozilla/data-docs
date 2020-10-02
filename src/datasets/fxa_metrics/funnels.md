# Firefox Account Funnels

## Table of Contents

<!-- toc -->

## Introduction

There are two primary "funnels" that users step through when authenticating with FxA. The **registration** funnel reflects the steps required for a **new** FxA user (or more precisely, email address) to create an account. The **login** funnel reflects the steps necessary for an **existing** FxA user to sign into their account.

We are also in the process of developing funnels for paying subscribers. We will add documentation on that once the work is is closer to complete.

## Registration Funnel

While there are some variations, the typical registration funnel is comprised of the steps described in the chart below. Except where noted, these events are emitted by the FxA content server.

| Step | Amplitude Event                                    | Flow Event                             | Description                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ---- | -------------------------------------------------- | -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `fxa_email_first - view`                           | `flow.enter-email.view`                | View (impression) of the form that the user enters their email address into to start the process. Note that this form can be hosted by FxA, or hosted by the relying party. In the latter case, the relier is responsible for handing the user's email address off to the FxA funnel. See "counting top of funnel events" below.                                                                                                |
| 2    | `fxa_reg - view`                                   | `flow.signup.view`                     | View of the registration form. If the user got to this step via step 1, FxA has detected that their email address is not present in the DB, and thus a new account can be created. The user creates their password and enters their age.                                                                                                                                                                                        |
| 3    | `fxa_reg - engage`                                 | `flow.signup.engage`                   | A user focuses/clicks on one of the registration form fields.                                                                                                                                                                                                                                                                                                                                                                   |
| 4    | `fxa_reg - submit`                                 | `flow.signup.submit`                   | A user submits the registration form (could be unsuccessfully).                                                                                                                                                                                                                                                                                                                                                                 |
| 5    | `fxa_reg - created`                                | `account.created`                      | This event is emitted by the auth server. It indicates that user has entered a valid email address and password, and that their account has been created and added to the DB. However, the account is still "unverified" at this point and therefore not accessible by the user.                                                                                                                                                |
| 6    | `fxa_email - sent` (`email_type` = `registration`) | `email.verification.sent`              | An email is sent to the user to verify their new account. Depending on the service, it either contains a verification link or a verification code that the user enters into the registration form to verify their email address.                                                                                                                                                                                                |
| 7    | `fxa_reg - cwts_view`                              | `flow.signup.choose-what-to-sync.view` | User views the "choose what to sync" screen which allows the users to select what types of browser data they want to synchronize. **Note that the user is not required to submit this page** - if they do not take any action then all the data types will be synced by default. Thus you may not want to include this (and the following two events) in your funnel analysis if you do not care about the user's actions here. |
| 8    | `fxa_reg - cwts_engage`                            | Not Implemented                        | User clicks on the "choose what to sync" screen.                                                                                                                                                                                                                                                                                                                                                                                |
| 9    | `fxa_reg - cwts_submit`                            | Not Implemented                        | User submits the "choose what to sync" screen. See also the amplitude user property `sync_engines` which stores which data types the user selected.                                                                                                                                                                                                                                                                             |
| 10   | `fxa_email - click`                                | `email.verify_code.clicked`            | A user has clicked on the verification link contained in the email sent in step 6. Note this only applies to cases where a clickable link is sent; for reliers that use activation codes, this event will not be emitted (so be aware of this when constructing your funnels).                                                                                                                                                  |
| 11   | `fxa_reg - email_confirmed`                        | `account.verified`                     | This event is emitted by the auth server. A user has successfully verified their account. They should now be able to use it.                                                                                                                                                                                                                                                                                                    |
| 12   | `fxa_reg - complete`                               | `flow.complete`                        | The account registration process is complete. Note there are NO actions required of the user to advance from step 8 to step 9; there should be virtually no drop-off there. The flow event is identical for registration and login.                                                                                                                                                                                             |

See [this chart](https://analytics.amplitude.com/mozilla-corp/chart/a9yjkzf) for an example of how this funnel can be constructed for the `firstrun` (about:welcome) page in amplitude. [Here](https://sql.telemetry.mozilla.org/queries/62595#160701) is a version in STMO using the flow events.

The chart above provides the most detailed version of the registration funnel that can currently be constructed. However, it should not be considered the "canonical" version of the funnel - depending on the question it may make sense to omit some of the steps. For example, at the time of writing some browser entrypoints (e.g. `menupanel`) link directly to step 2 and skip the initial email form. Having both steps 7 and 8 may also be redundant in some cases, etc. Also, as noted above, you may want to omit the "choose what to sync" steps if you do not care about the users' actions there.

## Login Funnel

The login funnel describes the steps required for an existing FxA user to login to their account. With some exceptions, most of the steps here are parallel to the registration funnel (but named differently).

Users must confirm their login via email in the following cases:

1. A user is logging into sync with an account that is more than 4 hours old.
2. A user is logging into an oauth relier that uses encryption keys (e.g., Firefox send), if the user had not logged into their account in the previous 72? (check this) hours.

| Step | Amplitude Event                             | Flow Event                  | Description                                                                                                                                                                                                                                                                                                                                                            |
| ---- | ------------------------------------------- | --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `fxa_email_first - view`                    | `flow.enter-email.view`     | Similar to the registration funnel, a view (impression) of the form that the user enters their email address into to start the process. Note that this form can be hosted by FxA, or hosted by the relying party. In the latter case, the relier is responsible for handing the user's email address off to the FxA funnel. See "counting top of funnel events" below. |
| 2    | `fxa_login - view`                          | `flow.signin.view`          | View of the login form. If the user got to this step via step 1, FxA has detected that their email address IS present in the DB, and thus an existing account can be logged into. The user enters their password on this form.                                                                                                                                         |
| 3    | `fxa_login - engage`                        | `flow.signup.engage`        | A user focuses/clicks on the login form field                                                                                                                                                                                                                                                                                                                          |
| 4    | `fxa_login - submit`                        | `flow.signup.submit`        | A user submits the login form (could be unsuccessfully).                                                                                                                                                                                                                                                                                                               |
| 5    | `fxa_login - success`                       | `account.login`             | This event is emitted by the auth server. It indicates that user has submitted the correct password. However, in some cases the user may still have to confirm their login via email (see above).                                                                                                                                                                      |
| 6    | `fxa_email - sent` (`email_type` = `login`) | `email.confirmation.sent`   | An email is sent to the user to confirm the login. Depending on the service, it either contains a confirmation link or a verification code that the user enters into the login form.                                                                                                                                                                                   |
| 7    | `fxa_email - click`                         | `email.verify_code.clicked` | A user has clicked on the confirmation link contained in the email sent in step 6. Note this only applies to cases where a clickable link is sent; for reliers that use confirmation codes, this event will not be emitted (so be aware of this when constructing your funnels). Note that this event is identical to its counterpart in the registration funnel.      |
| 8    | `fxa_login - email_confirmed`               | `account.confirmed`         | This event is emitted by the auth server. A user has successfully confirmed the login via email.                                                                                                                                                                                                                                                                       |
| 9    | `fxa_login - complete`                      | `flow.complete`             | The account registration process is complete. Note there are NO actions required of the user to advance from step 8 to step 9; there should be virtually no drop-off there. The flow event is identical for registration and login.                                                                                                                                    |

See [this chart](https://analytics.amplitude.com/mozilla-corp/chart/53dqtlo) for an example of how this funnel can be constructed for the `firstrun` (about:welcome) page. [Here](https://sql.telemetry.mozilla.org/queries/63048#161676) is a version in STMO using the flow events.

Note again that you may want to check whether the service you are analyzing requires email confirmation on login.

## Branches off the Login Funnel: Password Reset, Account Recovery, 2FA.

Some additional funnels are "branches" off the main login funnel above:

1. The password reset funnel

- Optionally - the user resets their password with a recovery key

2. Login with 2FA (TOTP)

- Optionally - user uses a 2FA recovery code to login to their 2FA-enabled account (e.g. if they misplace their second factor.)

### Password Reset and Recovery Codes

Users can click "Forgot Password?" during sign-in to begin the password reset process. The funnel is described in the chart below.

**An important "FYI" here**: passwords are used to encrypt accounts' sync data. This implies a **bad scenario** where a change of password can lead to loss of sync data, if there are no longer any devices that can connect to the account and re-upload/restore the data after the reset occurs. This would happen, for example, if you only had one device connected to sync, lost the device, then tried to login to a new device to access your synced data. If you do a password reset while logging into the second device, the remote copy of your sync data will be overwritten (with whatever happens to be on the second device).

Thus the recovery codes. If a user (1) sets up recovery codes via settings (and stores them somewhere accessible) (2) tries to reset their password and (3) enters a valid recovery code during the password reset process, sync data can be restored without risking the "bad scenario" above.

#### Password Reset Funnel Without Recovery Key

_Note: There may be other places where a user can initiate the password reset process, but I think that its most common during login. In any case, the steps starting at 2 should all be the same._

| Step | Amplitude Event                                              | Flow Event                                                   | Description                                                                                         |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ | --------------------------------------------------------------------------------------------------- |
| 1    | `fxa_login - view`                                           | `flow.signin.view`                                           | View of the login form, which contains the "Forgot Password" Link.                                  |
| 2    | `fxa_login - forgot_password`                                | `flow.signin.forgot-password`                                | User clicks on the "Forgot Password" Link.                                                          |
| 3    | Not Implemented                                              | `flow.reset-password.view`                                   | View of the form asking the user to confirm that they want to reset.                                |
| 4    | `fxa_login - forgot_submit`                                  | `flow.reset-password.engage`, `flow.reset-password.submit`   | User clicks on the button confirming that they want to reset.                                       |
| 5    | `fxa_email - delivered` (`email_template` = `recoveryEmail`) | `email.recoveryEmail.delivered`                              | Delivery of the PW reset link to the user via email.                                                |
| 5-a  | Not Implemented                                              | `flow.confirm-reset-password.view`                           | View of the screen telling the user to confirm the reset via email.                                 |
| 6    | Not Implemented                                              | `flow.complete-reset-password.view`                          | User views the form to create a new password. (viewable after clicking the link in the email above) |
| 7    | Not Implemented                                              | `flow.complete-reset-password.engage`                        | User clicks on the form to create a new password.                                                   |
| 8    | Not Implemented                                              | `flow.complete-reset-password.submit`                        | User submits the form to create a new password.                                                     |
| 9    | `fxa_login - forgot_complete`                                | `flow.complete` (the auth server also emits `account.reset`) | User has completed the password reset funnel.                                                       |

#### Password Reset Funnel With Recovery Key

_Note we still need to implement amplitude events for the recovery code part of this funnel. The funnel is identical to the one above up until step 6._

| Step | Amplitude Event                                              | Flow Event                                                                                            | Description                                                                                                    |
| ---- | ------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| 1    | `fxa_login - view`                                           | `flow.signin.view`                                                                                    | View of the login form, which contains the "Forgot Password" Link.                                             |
| 2    | `fxa_login - forgot_password`                                | `flow.signin.forgot-password`                                                                         | User clicks on the "Forgot Password" Link.                                                                     |
| 3    | Not Implemented                                              | `flow.reset-password.view`                                                                            | View of the form asking the user to confirm that they want to reset.                                           |
| 4    | `fxa_login - forgot_submit`                                  | `flow.reset-password.engage`, `flow.reset-password.submit`                                            | User clicks on the button confirming that they want to reset.                                                  |
| 5    | `fxa_email - delivered` (`email_template` = `recoveryEmail`) | `email.recoveryEmail.delivered`                                                                       | Delivery of the PW reset link to the user via email.                                                           |
| 5-a  | Not Implemented                                              | `flow.confirm-reset-password.view`                                                                    | View of the screen telling the user to confirm the reset via email.                                            |
| 6    | Not Implemented                                              | `flow.account-recovery-confirm-key.view`                                                              | User views the form to enter their account recovery key. (viewable after clicking the link in the email above) |
| 7    | Not Implemented                                              | `flow.account-recovery-confirm-key.engage`                                                            | User clicks on the form to enter their account recovery key.                                                   |
| 8    | Not Implemented                                              | `flow.account-recovery-confirm-key.submit`                                                            | User submits the form to enter their account recovery key.                                                     |
| 9    | Not Implemented                                              | `flow.account-recovery-confirm-key.success` or `flow.account-recovery-confirm-key.invalidRecoveryKey` | User submitted a valid (success) or invalid recovery key.                                                      |
| 10   | Not Implemented                                              | `flow.account-recovery-reset-password.view`                                                           | User views the form to change their password after submitting a valid recovery key.                            |
| 11   | Not Implemented                                              | `flow.account-recovery-reset-password.view`                                                           | User clicks on the form to change their password after submitting a valid recovery key.                        |
| 12   | Not Implemented                                              | `flow.account-recovery-reset-password.view`                                                           | User submits the form to change their password after submitting a valid recovery key.                          |
| 13   | `fxa_login - forgot_complete`                                | `flow.complete` (the auth server also emits `account.reset`)                                          | User has completed the password reset funnel.                                                                  |

### Login with 2FA (TOTP)

Users can setup two factor authentication (2FA) on account login. 2FA is implemented via time-based one-time password (TOTP). If a user has set up 2FA (via settings), they will be required to enter a pass code generated by their second factor whenever they login to their account.

Users are also provisioned a set of recovery codes as part of the 2FA setup process. These are one-time use codes that can be used to login to an account if a user loses access to their second factor. **Note that these 2FA recovery codes are different than the account recovery keys described above**.

#### Login with 2FA/TOTP Funnel (No Recovery Code)

_This funnel starts after the `fxa_login - success` / `account.login` step of the login funnel_

| Step | Amplitude Event                 | Flow Event                      | Description                                                                         |
| ---- | ------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------- |
| 1    | `fxa_login - totp_code_view`    | `flow.signin-totp-code.view`    | View of the TOTP form.                                                              |
| 2    | `fxa_login - totp_code_engage`  | `flow.signin-totp-code.engage`  | Click on the TOTP form.                                                             |
| 3    | `fxa_login - totp_code_submit`  | `flow.signin-totp-code.submit`  | Submission of the TOTP form.                                                        |
| 4    | `fxa_login - totp_code_success` | `flow.signin-totp-code.success` | Successful submission of the TOTP form. Auth server also emits `totpToken.verified` |

#### Login with 2FA/TOTP Funnel w/ Recovery Code

_This funnel starts after user clicks to use a recovery code during the TOTP funnel._

| Step | Amplitude Event              | Flow Event                            | Description                           |
| ---- | ---------------------------- | ------------------------------------- | ------------------------------------- |
| 1    | `fxa_login - totp_code_view` | `flow.signin-totp-code.view`          | View of the TOTP form.                |
| 2    | Not Implemented              | `flow.sign_in_recovery_code.view`     | View of the TOTP recovery code form.  |
| 3    | Not Implemented              | `recoveryCode.verified` (auth server) | User submitted a valid recovery code. |

## Connect Another Device / SMS

Sync is most valuable to users who have multiple devices connected to their account. Thus after a user completes a sync login or registration funnel, they are shown the "connect another device" form. This Call to Action contains a form for a phone number, as well as links to the Google Play and Apple stores where users can download mobile versions of Firefox. If a user submits a valid phone number (associated with a country that our service supports), then we send them an SMS message with links to their mobile phone's app store.

At one point, at least for iOS, the SMS message contained a deep link that pre-filled the user's email address on the sign-in form once they installed the mobile browser. There is some uncertainty about whether this still works...

### SMS Funnel

_This funnel begins either (1) after a user has completed the login or registration funnel, or (2) if they click on "connect another device" from the FxA toolbar menu within the desktop browser (provided they are signed in). In the latter case the `signin` segment of the flow event will be omitted._

| Step | Amplitude Event                                               | Flow Event                  | Description                                                     |
| ---- | ------------------------------------------------------------- | --------------------------- | --------------------------------------------------------------- |
| 1    | `fxa_connect_device - view` (`connect_device_flow` = `sms`)   | `flow.signin.sms.view`      | User viewed the SMS form.                                       |
| 2    | `fxa_connect_device - engage` (`connect_device_flow` = `sms`) | `flow.signin.sms.engage`    | User clicked somewhere on the SMS form.                         |
| 3    | `fxa_connect_device - submit` (`connect_device_flow` = `sms`) | `flow.signin.sms.submit`    | User submitted the SMS form.                                    |
| 4    | Not Implemented                                               | `sms.region.{country_code}` | An SMS was sent to a number with the two letter `country_code`. |
| 5    | Not Implemented                                               | `flow.sms.sent.view`        | User views the message confirming that the SMS has been sent.   |

The SMS form also contains app store links. If they are clicked, flow events `flow.signin.sms.link.app-store.android` or `flow.signin.sms.link.app-store.ios` will be logged.

### Connect Another Device Funnel (Non-SMS)

| Step | Amplitude Event                                             | Flow Event                                                         | Description                                                                                                                                                  |
| ---- | ----------------------------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1    | `fxa_connect_device - view` (`connect_device_flow` = `cad`) | `flow.signin.connect-another-device.view`                          | User viewed the CAD form.                                                                                                                                    |
| 2    | `fxa_connect_device - view` (`connect_device_flow` = `cad`) | `flow.signin.connect-another-device.link.app-store.(android\|ios)` | User clicked on either the android or iOS app store button. In amplitude, use the event property `connect_device_os` to disambiguate which link was clicked. |

## Settings

A variety of metrics are logged that reflect user interaction with the settings page (https://accounts.firefox.com/settings). The chart below outlines some of these events (this may not be an exhaustive list).

| Amplitude Event                                                     | Flow Event                                                             | Description                                                                                                                                                          |
| ------------------------------------------------------------------- | ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `fxa_pref - view`                                                   | `flow.settings.view`                                                   | User viewed the settings page.                                                                                                                                       |
| `fxa_pref - engage`                                                 | `flow.settings.*.engage`                                               | User clicked somewhere on the settings page.                                                                                                                         |
| `fxa_pref - two_step_authentication_view`                           | `flow.settings.two-step-authentication.view`                           | User viewed 2FA settings.                                                                                                                                            |
| Not Implemented                                                     | `flow.settings.two-step-authentication.recovery-codes.view`            | User viewed their 2FA recovery codes. These are only viewable one time only, after a user sets up 2FA, or after they generate new codes.                             |
| Not Implemented                                                     | `flow.settings.two-step-authentication.recovery-codes.print-option`    | User clicks to print their 2FA recovery codes.                                                                                                                       |
| Not Implemented                                                     | `flow.settings.two-step-authentication.recovery-codes.download-option` | User clicks to download their 2FA recovery codes.                                                                                                                    |
| Not Implemented                                                     | `flow.settings.two-step-authentication.recovery-codes.copy-option`     | User clicks to copy their 2FA recovery codes to the clipboard (this is fired only when they click the copy button, not if they copy using e.g. a keyboard shortcut). |
| Not Implemented                                                     | `flow.settings.change-password.view`                                   | User viewed the form to change their password.                                                                                                                       |
| `fxa_pref - password`                                               | `settings.change-password.success`                                     | User changed their password via settings.                                                                                                                            |
| `fxa_pref - newsletter` (see also user property `newsletter_state`) | `settings.communication-preferences.(optIn\|optOut).success`           | User changed their newsletter email preferences.                                                                                                                     |
| Not Implemented                                                     | `flow.settings.account_recovery.view`                                  | User viewed account recovery settings.                                                                                                                               |
| Not Implemented                                                     | `flow.settings.account_recovery.engage`                                | User clicked somewhere in account recovery settings.                                                                                                                 |
| Not Implemented                                                     | `flow.settings.account-recovery.confirm-password.view`                 | User viewed the password form prior to turning on account recovery. (user first has to verify their email address)                                                   |
| Not Implemented                                                     | `flow.settings.account-recovery.confirm-password.view`                 | User clicked the password form prior to turning on account recovery.                                                                                                 |
| Not Implemented                                                     | `flow.settings.account-recovery.confirm-password.submit`               | User submitted the password form prior to turning on account recovery.                                                                                               |
| Not Implemented                                                     | `flow.settings.account-recovery.confirm-password.success`              | User successfully submitted the password form prior to turning on account recovery.                                                                                  |
| Not Implemented                                                     | `flow.settings.account-recovery.recovery-key.view`                     | User viewed their recovery key. This is viewable one time only, after a user sets up account recovery, or after they generate a new key.                             |
| Not Implemented                                                     | `flow.settings.account-recovery.recovery-key.print-option`             | User clicks to print their recovery key.                                                                                                                             |
| Not Implemented                                                     | `flow.settings.account-recovery.recovery-key.download-option`          | User clicks to download their recovery key.                                                                                                                          |
| Not Implemented                                                     | `flow.settings.account-recovery.recovery-key.copy-option`              | User clicks to copy their recovery key to the clipboard (this is fired only when they click the copy button, not if they copy using e.g. a keyboard shortcut).       |
| Not Implemented                                                     | `flow.settings.account-recovery.refresh`                               | User generated a new recovery key.                                                                                                                                   |
| Not Implemented                                                     | `flow.settings.clients.view`                                           | User viewed the list of clients ("Devices & Apps") connected to their account. AKA the device manager.                                                               |
| Not Implemented                                                     | `flow.settings.clients.engage`                                         | User clicked somewhere the list of clients connected to their account.                                                                                               |
| Not Implemented                                                     | `flow.settings.clients.disconnect.view`                                | User viewed the dialog asking to confirm disconnection of a device.                                                                                                  |

# FxA Email Metrics

## Table of Contents

<!-- toc -->

## Introduction

Users must provide an email address when they sign up for a Firefox Account. Emails are sent to users to confirm authentication, alert them to new sign-ins, and to complete password resets. Users can also opt-in to marketing emails, however metrics for those are not covered in this article.

Events that we track relating to email:

1. When the email is sent.
2. If the email bounces.
3. If the email contains a verification/confirmation link, whether the user clicked on it.

Metrics relating to emails also contain the following properties:

1. The email service of the recipient
2. The `email_template` - the [template](https://github.com/mozilla/fxa/tree/main/packages/fxa-auth-server/lib/senders/templates) of the email that was sent (we currently only track this for sending events, not click events). This is more specific than the
3. `email_type`, which is broader grouping of many email templates into related categories, see chart below.

## Email Templates and Email Types

Only emails sent by the FxA auth server are represented in the table below. TBD on marketing emails.

| `email_template`                       | `email_type`       | Description & Notes                                                                                                                                                                                                                                                        |
| -------------------------------------- | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `verifySyncEmail`                      | `registration`     | Sent to users setting up a new sync account. Contains a verification link (user must click it for their account to become functional).                                                                                                                                     |
| `verifyEmail`                          | `registration`     | Sent to users setting up a new NON-sync account. Contains a verification link (user must click it for their account to become functional).                                                                                                                                 |
| `postVerifyEmail`                      | `registration`     | Sent after users confirm their email. Contains instructions for how to connect another device to sync.                                                                                                                                                                     |
| `verifyTrailheadEmail`                 | `registration`     | Updated version of `verifySyncEmail` for the trailhead promotion.                                                                                                                                                                                                          |
| `postVerifyTrailheadEmail`             | `registration`     | Updated version of `postVerifyEmail` for the trailhead promotion.                                                                                                                                                                                                          |
| `verificationReminderFirstEmail`       | `registration`     | If a users does not verify their account within 24 hours, they receive this email with an additional verification link.                                                                                                                                                    |
| `verificationReminderSecondEmail`      | `registration`     | If a users does not verify their account within 48 hours, they receive this email with an additional verification link.                                                                                                                                                    |
| `verifyLoginEmail`                     | `login`            | Sent to existing accounts when they try to login to sync. User must click the verification link before the logged-in device can begin syncing.                                                                                                                             |
| `newDeviceLoginEmail`                  | `login`            | Sent to existing accounts after they have logged into a device that FxA has not previously recognized.                                                                                                                                                                     |
| `verifyLoginCodeEmail`                 | `login`            | Sent to existing accounts when they try to login to sync, containing a code (rather than a link) the user must enter into the login form. Note that currently the use of confirmation codes is limited to some login contexts only - they are never used for registration. |
| `recoveryEmail`                        | `reset_password`   | After a user opts to reset their password (during login, because they clicked "forgot password"), they receive this email with a link to reset their password (without using a recovery key).                                                                              |
| `passwordResetEmail`                   | `reset_password`   | Sent to users after they reset their password (without using a recovery key).                                                                                                                                                                                              |
| `postAddAccountRecoveryEmail`          | `account_recovery` | Sent to users after they successfully add account recovery capabilities to their account (i.e. after generating recovery codes).                                                                                                                                           |
| `postRemoveAccountRecoveryEmail`       | `account_recovery` | Sent to users after they successfully REMOVE account recovery capabilities from their account.                                                                                                                                                                             |
| `passwordResetAccountRecoveryEmail`    | `account_recovery` | After a user resets their password using a recovery key, they receive this email telling them to generate a new recovery key.                                                                                                                                              |
| `passwordChangedEmail`                 | `change_password`  | Sent to users after they change their password via FxA settings (NOT during password reset; they must be logged in to do this).                                                                                                                                            |
| `verifyPrimaryEmail`                   | `verify`           | Sent to users when they request to change their primary email address via settings (is sent to their new email).                                                                                                                                                           |
| `postChangePrimaryEmail`               | `change_email`     | Sent to users after they successfully change their primary email address (is sent to their new email).                                                                                                                                                                     |
| `verifySecondaryEmail`                 | `secondary_email`  | Sent to users when they add a secondary email address via account settings. Contains a verification link (sent to the secondary email address).                                                                                                                            |
| `postVerifySecondaryEmail`             | `secondary_email`  | Sent to users after they successfully verified a secondary email address (sent to the secondary email address).                                                                                                                                                            |
| `postRemoveSecondaryEmail`             | `secondary_email`  | Sent to users after they successfully remove a secondary email address (sent to the secondary email address).                                                                                                                                                              |
| `postAddTwoStepAuthenticationEmail`    | `2fa`              | Sent to users after they successfully add 2 factor authentication to their account (TOTP)                                                                                                                                                                                  |
| `postRemoveTwoStepAuthenticationEmail` | `2fa`              | Sent to users after they successfully REMOVE 2 factor authentication from their account (TOTP)                                                                                                                                                                             |
| `postConsumeRecoveryCodeEmail`         | `2fa`              | Sent to users after they successfully use a recovery code to login to their account after not being able to use their second factor.                                                                                                                                       |
| `postNewRecoveryCodesEmail`            | `2fa`              | Sent to users after they successfully generate a new set of 2FA recovery codes.                                                                                                                                                                                            |
| `lowRecoveryCodesEmail`                | `2fa`              | Sent when a user is running low on 2FA recovery codes.                                                                                                                                                                                                                     |

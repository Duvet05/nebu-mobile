# Account deletion

The deletion screen refreshes `/users/me` before showing either confirmation.
The server-owned `requiresPasswordForDeletion` boolean controls the password
field; missing or null values default to `true` for older servers/cached users.
The app does not infer this requirement from the email or the last login button.

Both dialogs show the refreshed account email. `DELETE` is always required.
Accounts requiring a password submit it unchanged. OAuth-only accounts omit the
`password` property; they never send a fabricated password. Cancelling either
dialog sends no deletion request. A changed/missing session, failed profile
refresh or backend rejection must not delete the account or report success.

`DELETE /users/me` includes `expectedUserId`, bound to the account whose email
was confirmed. The server compares it with the authenticated session before
deletion; it never chooses a target from this input. This also covers a session
switch while the HTTP client reads its token. The server independently checks
its stored account type and password. The mobile boolean is not authorization.
After a successful response the app only logs out if that account is still
active; a newer session must not be closed by the old account's deletion.

Roll out the compatible backend change before validating this mobile candidate.
This is a normal backend and TestFlight release, not a direct database deletion.
Validate the signed build on a physical device using an explicitly authorized
test account before recording final review evidence. Unit/widget tests do not
establish that production has been updated or that any real account was deleted.

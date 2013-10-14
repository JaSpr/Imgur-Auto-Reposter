Imgur-Auto-Reposter
===================

Reposts (presumably old) images from Imgur back to user submitted

NOTE: Although I could not find any rules about bots on imgur (either in the terms of service OR the API), I am willing to bet this could get a user banned, and is definitely a bit shady.

Make sure to create a file in your $HOME directory named `.imgurrc.reposter` (or change the setting to any other file path)
You can rename this file, but you will need to change the constant in lib/imgur/base.rb

NOTE: my implementation has a different file name... RESET THE CONSTANT in lib/imgur/base.rb

`.imgurrc.reposter` File contents:

```
---
:client_id: YOUR_APP_CLIENT_ID
:client_secret: YOUR_APP_CLIENT_SECRET
```

For this to work, you will need to register an Imgur application (https://api.imgur.com/oauth2/addclient), and then authorize it using an Imgur account.  After doing so, you will record the access token and refresh token in the `.imgurrc.reposter` file, using the following lines:

```
:account_username: THE_IMGUR_USER_NAME
:access_token: YOUR_ACCESS_TOKEN
:refresh_token: YOUR_REFRESH_TOKEN
```

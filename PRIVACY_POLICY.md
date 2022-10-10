## firmus: Privacy policy

Welcome to the firmus home launcher app for Android!

This is an open source Android app developed by [ayham](https://ayham.xyz). The source
code is available on Codeberg under the MIT license; the app is also available
on Google Play.

As an avid Android user myself, I take privacy very seriously. I know how
irritating it is when apps collect your data without your knowledge.

I hereby state, to the best of my knowledge and belief, that I have not
programmed this app to collect any personally identifiable information. All
data (app preferences (like theme, etc.) and list of apps) created by you (the
user) is stored on your device only, and can be simply erased by clearing the
app's data or uninstalling it.

### Explanation of permissions requested in the app

The list of permissions required by the app can be found in the `AndroidManifest.xml` file:

```xml
<category android:name="android.intent.category.LAUNCHER"/>
<category android:name="android.intent.category.HOME" />
<category android:name="android.intent.category.DEFAULT" />
...
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
```

* `android.intent.category.LAUNCHER` - so Android considers the App as launcher
* `android.intent.category.HOME` - so Android displays the App on boot
* `android.intent.category.DEFAULT` - so Android implicitly assumes to launch the
* `android.permission.QUERY_ALL_PACKAGES` - so Android gives a list of
  installed applications. This is *NOT* sent anywhere.

If you find any security vulnerability that has been inadvertently caused by me,
or have any question regarding how the app protects your privacy, send me an
email or post a discussion on Codeberg.

Yours sincerely,
ayham,
me@ayham.xyz

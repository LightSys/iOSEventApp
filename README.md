# iOSEventApp

## Purpose

Provide attendees at events / conferences with information about the event, disseminated by QR code. 

## Installing the App

This code can be used with a personal apple developer account. In Xcode modify the team and bundle identifier, then install.

## Event Data

The current implementation has almost all of the data encoded in JSON format at the location of the url in the QR code. The data has another url linking to notifications for the event.

The data is stored in Core Data, so that it persists between runs of the app. The app does not refresh or regularly update data at the moment: to get updated data rescan the QR code (this option is in Settings).

## App Structure

### Sidebar

The sidebar and navigation controller are children of the `RootViewController`. This allows the sidebar to be displayed over the navigation controller.

### Navigation Controller

The navigation controller is used for its navigation bar. The only two view controllers that will be directly presented by the navigation controller are the `ScannerViewController` and `MainContainerViewController`. Going back to the `ScannerViewController` allows the user to scan a new QR code.

### Data Pages

The individual pages are children of the `MainContainerViewController`. There will only be one child at a time: when a new page is selected, it replaces the previous page as the sole child of `MainContainerViewController`.

## Attribution

The code in `QRScannerViewController` that scans QR codes came from https://www.hackingwithswift.com/example-code/media/how-to-scan-a-qr-code 


## To-do list
As the app is still in development and there are a lot of small items on this list, it makes sense to put these here for now, instead of using the issue tracker.

### Important

- [ ] Update as needed to ensure compatibility with the new web app
- [ ] Fix the core data crash (results occasionally from the "Refresh event data now" button in settings) **--Claimed**
- [ ] Thoroughly test error display in different (re)load scenarios
- [ ] Ask server if there are new notifications past a certain date / fetch new notifications after a certain date (would likely require server changes)
- [ ] About screen. It is hooked up but has no meaningful content.
- [ ] Use LightSys provisioning profile + development team.
- [ ] Check deployment target and allowed device types. 
- [ ] PR from finishing_touches

### Needs designer attention
- [ ] Background for logo
- [ ] Logo height
- [ ] Settings. All of it, particularly the refresh rate picker
- [ ] Welcome text
- [ ] Menu icon for settings

### Optional / Low Priority (These may not all be desired)
- [ ] Make sure there is always an activity indicator when refreshing data.
- [ ] Preserve spot on screens after data refresh
- [ ] Attempt to move notifications permissions to when the user first sees the notifications screen (Apple may not allow it)
- [ ] Revisit having phone and car icons in schedule (they are currently hidden from the user because they are superfluous)
- [ ] Cancel ongoing url session when going to QR scanner (to avoid trying to insert the wrong data into an event)
- [ ] Display day of the week in schedule (i.e. let the user know it is Tuesday in addition to the fourth of March)
- [ ] Convert times in schedule based off of time zones (the app has no concept of time zones right now)
- [ ] Determine if data should be persisted after the event ends (if the phone can't connect to the server, it keeps the data locally. Note that it is reasonable to want access to the event data for at least a couple of weeks afterward)
- [ ] Determine if the year in general should be used in the app
- [ ] Expand schedule item title only if the text is truncated (to avoid multiline titles when possible)
- [ ] Handle long notification title (consider this from a design perspective)
- [ ] Detail view for schedule items
- [ ] Detail view for notification items
- [ ] Use time zone when calculating event end
- [ ] Allow sort/filter of prayer partner groups by name
- [ ] Clearly display to the user in Settings if the user denied notification permissions
- [ ] Possibly include some disclaimer about how the app won't actually poll the server at regular intervals in the background
- [ ] Create an app widget (to give directions without being in the app; be cognizant of different map apps)
- [ ] Alternate event app text (in place of logo when it is missing, like in the android app)
- [ ] Swipe from edge of screen to open menu
- [ ] Improve managed object context usage (the data controller appears to violate Apple documentation's concurrency section by passing contexts between threads) **--Claimed**
- [ ] Make sure prayer partner groups have the same numbers as in the android app **--Claimed**
- [ ] Add some kind of order key to objects received in an array (not a dictionary) and update sorting to use that. **--Claimed**
- [ ] Start refresh timer when opening the app to go off when it would have gone off, if the timer did not fire when the app was opened.
- [ ] Fix white bar above sidebar menu (very noticeable in app switcher)

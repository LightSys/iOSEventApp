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

## Bugs

There are several known issues that have to do with data population. Some views are not sized correctly for the amount of text within them, and some of the headers are not populated with data. 

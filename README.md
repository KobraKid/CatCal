# CatCal
## How to get this project on your Mac
1. Click on the green **Clone or download** button, and copy the URL shown.
2. Open Xcode, and find **Source Control** on the Menu Bar. Choose clone, and paste the link from step 1. in the URL bar at the top of the new window.
3. Once the project is cloned, **close Xcode**. Open a new Terminal session, and `cd` into the CatCal folder, in the directory you chose to save the project clone. 
4. If you don't already have CocoaPods installed, run `sudo gem install cocoapods`. If you're not sure whether CocoaPods has already been installed, try `pod --version`. If you get an error, you will have to install CocoaPods.
5. With CocoaPods installed and while still in the CatCal folder, simply run `pod install`. This will install all the necessary pods.
6. Once the command has finished running, you can reopen Xcode. Run the project and it should build properly.

## How to use this app
When you first run the app, you will be asked to sign in to Google. I *highly* suggest you sign in using your **Northwestern Google account** so that you can access the test calendar that I have the app set to use. Otherwise, feel free to sign in to your person account and use your own calendar to test the app.

Once the project has been cloned, you are free to run the app, test it, play around and make changes to experiment with different parts of the code. See if you're able to change the size of each CalendarCell, or try adding a new button to the Navigation bar that deletes an event.

Another thing to note about the app (in its current state) is that when it first opens, the list of events is empty regardless of whether any events exist on a calendar or not. I encourage you to figure out why this is the case, and see if you can solve this problem. I haven't implemented a solution yet because I haven't been bothered by clicking 'Refresh' but obviously a fully polished app should be able to automatically fetch this list right away.

### Pods
This project uses CocoaPods to manage installed addons. These addons currently consist of:
- [SwiftyBeaver](https://github.com/SwiftyBeaver/SwiftyBeaver), which is used for convenient logging.
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON), easy to use JSON parsing software for Swift.
  - Note: SwiftyJSON is not currently implemented, so you could theoretically get away with removing it from the Podfile and not installing it, but I plan on incorporating it into the project once I get the Northwestern API implemented.

### Errors
Please let me know if you have any problems cloning this project, or if you come across any bugs in the code. I'll be happy to take a look.

## The Calendar
[Here](https://calendar.google.com/calendar/b/1?cid=dS5ub3J0aHdlc3Rlcm4uZWR1X3V1aDNzazM0aWw0MGhxMzMwZm05NWppYWljQGdyb3VwLmNhbGVuZGFyLmdvb2dsZS5jb20) is a link to the test Calendar that the app uses.

# TinyPrinter
[Tiny]Printer is an (Electric Imp powered) Internet-connected printer!

## Required Hardware:
For this project, you are going to need the following:
- [Electric Imp Card](http://www.adafruit.com/products/1129)
- [April Breakout Board](http://www.adafruit.com/products/1130)
- [Mini Thermal Receipt Printer Starter Pack](http://www.adafruit.com/products/600)

## Required Web Services:
For this project, we are going to use the following services
- [Electric Imp](https://ide.electricimp.com)
- [OAuth.io](https://oauth.io)
- [Twitter](https://dev.twitter.com/)

## Hardware Setup:
The hardware on this project is dirt simple:
- Follow the [Power](http://learn.adafruit.com/mini-thermal-receipt-printer/power) and [Microcontroller](http://learn.adafruit.com/mini-thermal-receipt-printer/microcontroller) steps in the [AdaFruit Guide](http://learn.adafruit.com/mini-thermal-receipt-printer).
  - Hook up the red wire from the DC power supply to the **Vin** pin on the April. 
  - Hook up the black wire from the DC power supply to one of the **GND** pins on the April.
  - Hook up the green wire from the printer to **PIN7** on the April Board.
  - Hook up the yellow wire from the printer to **PIN5** on the April Board.
  - Hook up the black wire from the printer to the other **GND** pin on the April.

## Software:
You should be able to copy and paste (*almost*) the source code from the repository to get started.
- Copy tinyprinter.agent.nut to the Agent window and:
  - Insert your OAuth.io public key
  - Insert your Twitter app's Consumer Token and Consumer Token Secret.

## How it works:
This project is meant to demonstrate how you can use OAuth.io to secure your projects. The device is in an "open" state during the first minute after a cold boot. During this period, someone can log into their Twitter account (by browsing to the Agent URL and clicking the 'Sign in with Twitter' button).

Once a user has logged in, the device is tied to their account, and no one else can log into the device. While logged into the device, the user can select a search term. 

Once a search term has been selected, the agent opens a connection to the Twitter Streaming API and prints any tweets that match the search criteria. 

The user's credentials and the current search term persist over device and agent restarts (including a cold boot). 

## //TODO:
- Ability to print Timeline, DM's, Interactions
- User should be able to select if they want the printer to have an open "question box" that anyone can submit text to to be printed. 

## Contact
[Matt Haines](github.com/beardedinventor)
[@beardedinventor](http://twitter.com/beardedinventor)

## License
This project is released under the MIT Licence. For more information see the LICENSE file.

# What is "Lord Crash A Lot"

"Lord Crash A Lot" is an App which tracks your Xcode crashes and sends the number of crashes + a unique identifier to a server.

We store the number of crashes and your identifier to build a ranking system. You can access the top 5 "Crash Lords" by visiting the following URL [Lord-Crash-A-Lot](http://lord-crash-a-lot.jantschnig.com/).

You can change the unique identifier to what ever you want. Just open the AppDelegate and change the code in the ``- (void)setupUniqueIdentifier;``. Per default we generate one for you.

# What we still need?

- Icon for the App as well as for the StatusBarItem.

# Contributors

- Cocoa Stuff:
Georg Kitz, [@gekitz](http://www.twitter.com/gekitz)

- Web Stuff:
Andreas Jantschnig, [@andi_jay](http://www.twitter.com/andi_jay)

# License
MIT
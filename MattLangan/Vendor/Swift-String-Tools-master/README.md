![](splash.png)
# Swift String Tools
A String extension that allows you to do some very awesome functions efforlessly. 

###Functions
Function Name | Description 
--------------|------------
```var length``` | Length of String in Swift
```var objclength ``` | Length of NSString, similar to ```.length``` in NSString
```func detectLanguage() -> String? ```| Detects the language of a String.
```func detectScript() -> String?``` | Detects the script of a String.
```func isRightToleft() -> Bool ```| Checks the text direction of a given String.
```var isEmail``` | Checks if the String is an Email.
```func isOnlyEmptySpacesAndNewLineCharacters() ->Bool ```| Checks that a String is only made of white spaces, and new line characters.
```func isTweetable() -> Bool ``` | Checks that a String is 'tweetable'; can be used in a tweet.
```func getLinks() -> [String] ```| Gets an array of Strings for all links found in a String.
```func getURLs() -> [NSURL] ```| Gets an array of URLs for all links found in a String.
```func getDates() -> [NSDate] ```| Gets an array of dates for all dates found in a String
```func getHashtags() -> [String] ```| Gets an array of strings (hashtags #acme) for all hashtags found in a String.
```func getMentions() -> [String] ```| Gets an array of strings (mentions @apple) for all mentions found in a String
```func containsDate() -> Bool ```| Checks if a String contains a Date in it.
```func containsLink() -> Bool ```| Checks if a String contains a link in it.
```func encodeToBase64Encoding() -> String ```| Encodes a String in Base64 encoding
```func decodeFromBase64Encoding() -> String ```| Decodes a Base64 encoded String


### License
String Tools is under MIT License. Check the license file for more information.


### Contact Info
follow me on twitter: [@jamal_2](https:///www.twitter.com/jamal_2)

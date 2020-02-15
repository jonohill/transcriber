# transcriber

An experimental command line application for transcribing audio files, written in Swift. Supports macOS Catalina (and above?) only.

## Usage

```
$ ./transcriber --help 
Usage:

    $ ./transcriber

Options:
    --list-locales [default: false] - Print the set of supported locales (then exit)
    --file [default: ] - Audio file to be transcribed
    --locale [default: en_NZ] - Locale of the speakers (use --list-locales for options)
```

## Examples

```
$ ./transcriber --file sample.mp3

Recognising audio. This will take about as long as the length of the clip...
This is a sample sentence
```

## Development

Assuming you have XCode installed on your Mac, `swift build` should do what you need.

## Caveats

- Requires macOS Catalina
- Apple's restrictions on speech recognition are not well-documented, but you might find you are rejected if you make too many requests.
- Clips longer than 1 minute will return a truncated transcript.
- I couldn't get offline recognition to work (all locales report that it is not supported).

If you can't get it to work, try these things:
- Check your internet connection.
- Ensure you have authorised Speech Recognition if macOS asks you.
- Ensure Siri is enabled in macOS Settings.
- Try a shorter audio file (usually anything longer than 1 minute is rejected or truncated).
- Wait and try again - Apple limits the number of server requests per hour.
- Use a macOS supported audio file format (aac, wav, mp3 etc).

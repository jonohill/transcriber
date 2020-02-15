import Foundation
import Commander
import Speech

let sysLocale = NSLocale.current

if #available(macOS 10.15, *) {
    command(
        Flag("list-locales", description: "Print the set of supported locales (then exit)"),
        Option<String?>("file", default: nil, description: "Audio file to be transcribed"),
        Option<String>("locale", default: sysLocale.identifier, description: "Locale of the speakers (use --list-locales for options)")
    ) { listLocales, file, locale in 
        if listLocales {
            var locales: [String] = []
            for locale in SFSpeechRecognizer.supportedLocales() {
                let id = locale.identifier
                let desc = sysLocale.localizedString(forIdentifier: id)!
                locales.append("\(id) - \(desc)")
            }
            locales.sort()
            for locale in locales {
                print(locale)
            }
            exit(0)
        }

        if file == nil {
            throw ArgumentError.missingValue(argument: "file")
        }

        let url = URL(fileURLWithPath: file!)

        let try_recognizer: SFSpeechRecognizer?
        if locale == sysLocale.identifier {
            try_recognizer = SFSpeechRecognizer()
        } else {
            try_recognizer = SFSpeechRecognizer(locale: Locale(identifier: locale))
        }
        
        if try_recognizer == nil || !try_recognizer!.isAvailable {
            fputs("Locale \"\(locale)\" is not supported for speech recognition. Try `--list-locales` and check your internet connection.", stderr)
        }
        let recognizer = try_recognizer!

        recognizer.defaultTaskHint = SFSpeechRecognitionTaskHint.dictation

        var recognizerCompleted = false
        var recogniserError: Error? = nil

        fputs("Recognising audio. This will take about as long as the length of the clip...\n", stderr)
        let request = SFSpeechURLRecognitionRequest(url: url)
        recognizer.recognitionTask(with: request) { (result, error) in
            guard let result = result else {
                recogniserError = error
                recognizerCompleted = true
                return
            }

            if result.isFinal {
                print(result.bestTranscription.formattedString)
                recognizerCompleted = true
            }
        }

        while !recognizerCompleted {
            RunLoop.current.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 10))
        }

        if recogniserError != nil {
            fputs("""
            Recognition failed (error: \(recogniserError!.localizedDescription))
            Tips:
            - Check your internet connection.
            - Ensure you have authorised Speech Recognition if macOS asks you.
            - Ensure Siri is enabled in macOS Settings.
            - Try a shorter audio file (usually anything longer than 1 minute is rejected or truncated).
            - Wait and try again - Apple limits the number of server requests per hour.
            - Use a macOS supported audio file format (aac, wav, mp3 etc).
            """, stderr)
            exit(1)
        } else {
            exit(0)
        }

    }.run()
} else {
    print("macOS 10.15 or newer is required")
    exit(0)
}

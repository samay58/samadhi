# Design refresh

Version 1.2, build 3, at source fingerprint `1a6352136861408c9fe019ca494905c631d489610d322a8d0ee6e0d19d2cc944`. Captured on the iPhone 17 Pro Simulator with iOS 27.0 and Xcode 27.2 during the gate that passed 205 package, 60 app-model, and 32 interface tests.

`contact-sheet.jpg` runs left to right, top to bottom: first screen, playlist sheet, reading partway, reading finished, song results, run controls, Hold to finish, open tempo wheel, paused, summary, recovery, and run controls at the largest text size.

What these frames prove: layout, type, the song-line map, and the speaker under its lens. Tests also prove that Pause and Finish hold their place at every text size.

What they do not prove: how real glass looks on a phone, since the Simulator only approximates it, frame rate on a phone, or pacing with a real playlist. The fixture is an invented playlist read one song at a time, and the real import reads three at a time. Nothing in this folder has been on a phone.

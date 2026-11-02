# Design refresh

Version 1.1, build 2, at commit `68a08ce`, source fingerprint `cb1d918cb1d804fc1bdbcad04d7519c5092191ff1ba7670a6197298eb2824166`. Captured on the iPhone 17 Pro Simulator with iOS 27.0 and Xcode 27.2 during the gate that passed 205 package, 51 app-model, and 39 serial interface tests.

`contact-sheet.jpg` runs left to right, top to bottom: first screen, reading partway, reading finished, song results, run controls, Hold to finish, tempo wheel, paused, summary, recovery, reading with Reduce Motion, and run controls at accessibility XXXL.

What these frames prove: layout, type, the song-line map, that Reduce Motion stops the drawing, and that the run screen fits at the largest text size. Interface tests also prove that Pause and Finish hold their place when they change state.

What they do not prove: frame rate on a phone, how real Liquid Glass looks on a phone, or pacing with a real playlist. The fixture is an invented playlist read one song at a time, and the real import reads three at a time. Nothing in this folder has been on a phone.

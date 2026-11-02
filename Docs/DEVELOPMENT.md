# Development

The Mac Mini is the main development machine. It has the disk for current Xcode, several Simulator runtimes, and heavy tools, and it stays on. A laptop can do the same work with one checkout, so nothing here depends on one machine. GitHub `main` is the source of truth. Push before changing machines, and pull when you arrive.

## The loop

Samadhi improves in three rings. Stay in the innermost ring that can answer the question, and move outward only when it cannot.

| Ring | Question it answers | Command | Time |
| --- | --- | --- | --- |
| Logic | Does the reducer, filter, or analyzer behave? | `swift test --package-path Packages/SamadhiKit` | Seconds |
| Look | Does it read right in every environment? | `./Scripts/sim.sh matrix <name> [args]` | About a minute |
| Motion | Does the interaction hold up frame by frame? | `./Scripts/sim.sh frames <test>` or `record <name> <seconds>` | Minutes |
| Gate | Is it ready for a phone? | `./Scripts/gate.sh` | About 15 minutes |
| Phone | Does it feel right on a body? | `./Scripts/phone.sh install`, then `pull` after moving | A walk |

### Logic

Write the failing reducer test first. The core is pure, so most behavior can be proved here without a Simulator. `swift test --filter "BoundaryLookAhead|Reach"` narrows to one area.

### Look

`./Scripts/sim.sh flags` lists the launch arguments that put the app into a known state. For example, this shows the partial import screen in all five environments on one contact sheet:

~~~sh
./Scripts/sim.sh matrix setup-partial -SAMADHI_FAST_MODE -SAMADHI_MUSIC_PARTIAL
~~~

The five are default, accessibility XXXL, Reduce Motion, Increased Contrast, and Reduced Transparency. Open the sheet and read it. An agent must inspect the image before claiming a visual result.

### Motion

UI tests in `Tests/SamadhiUITests/` drive states that take interaction to reach, and they attach frames. To export them:

~~~sh
./Scripts/sim.sh frames testTransportAndFinishAfterStateEvidence
~~~

For a press, a hold, or a transition, `./Scripts/sim.sh record finish-hold 6` records video and splits it into frames at 30 per second. The August overflow in Finish was only visible this way.

### Phone

The phone answers what nothing else can: cadence, sound, touch, and locked-screen behavior. Keep these sessions short and specific. [PHONE-CHECK.md](PHONE-CHECK.md) holds the ordered checks, and [DEVICE_RUNBOOK.md](DEVICE_RUNBOOK.md) holds the details.

~~~sh
./Scripts/phone.sh status     # Is it reachable, and is signing ready?
./Scripts/phone.sh install    # Exact profile, verified signature, in-place install
# Walk or run.
./Scripts/phone.sh pull       # Copies the run record here and summarizes it
~~~

The summary answers what a walk leaves behind: which build ran, what became of each cue, and why each song changed.

### Recording what was learned

Raw captures stay in `Evidence/Temp/`, which Git ignores. Commit a dated folder with a short README and at most five frames or one contact sheet, as described in [Evidence/README.md](../Evidence/README.md). Update [STATUS.md](STATUS.md) when a claim changes.

## Setting up a Mac

1. Install Xcode and XcodeGen. Keep one current Simulator runtime with an iPhone 17 Pro. The scripts create that Simulator if the runtime is present.
2. Run `sudo DevToolsSecurity -enable` once. Without it, the test host launches frozen and `xcodebuild test` hangs without an error, waiting for an authorization nobody can see.
3. Clone the repository and run `./Scripts/bootstrap.sh`.
4. Run `./Scripts/gate.sh`. A pass means this Mac can do everything short of the phone.
5. For phone work, install the exact provisioning profile and pair the phone. See [DEVICE_RUNBOOK.md](DEVICE_RUNBOOK.md). Never copy certificates, Derived Data, or Simulator contents between Macs.

The scripts follow `DEVELOPER_DIR`, then the selected Xcode from `xcode-select`. Do not run Simulator commands under two different Xcode versions at once. Doing so restarts the shared Simulator service and can kill a running test.

## Agent tools

`.mcp.json` registers Xcode's own agent service, so an agent can build, test, and render a SwiftUI preview without an open Xcode window. It needs Xcode 27.2 or later and a one-time setup with `sudo`:

~~~sh
sudo xcode-select -s /Applications/Xcode.app
sudo xcodebuild -runFirstLaunch
sudo xcrun mcp-server enable
xcrun mcp-server start
~~~

The first agent call raises a permission prompt on the Mac's screen. Choose Always Allow. Everything else in the loop works without this service.

Previews in `Packages/SamadhiKit/Sources/SamadhiDesign/SamadhiPreviews.swift` cover the screen states, so a rendered preview is the fastest visual check when no launch argument reaches the state.

## Keeping the machine lean

Build products from the scripts live in `.build/xcode/`, which Git ignores and is safe to delete. `Evidence/Temp/` is scratch space and is also safe to clear once a result is committed.

## Boundaries

- A Simulator pass never proves MusicKit, cadence, listening quality, haptics, or background behavior.
- Never uninstall the app from the phone. It holds the only copy of the selected collection and analysis cache.
- Do not claim a physical install until the signed build, application identifier, install result, and launch have been read back.

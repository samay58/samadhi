# Design benchmark notes

This pass uses four products as standards for focus, ergonomics, and native craft. It does not copy their visual language.

## Granola

Granola’s mobile product is intentionally narrower than its desktop product. The home structure separates upcoming meetings, existing notes, and chat; capture is designed around one-tap starts, Live Activities, and the Dynamic Island. The useful lesson for Samadhi is scope discipline: the phone surface should expose the action that matters now, and system surfaces should carry status when the app is not foregrounded.

Source: https://docs.granola.ai/help-center/ios/getting-started

## Avec

Avec puts one important email in focus at a time, then gives direct swipe and voice actions around that object. Its hierarchy is driven by attention and completion, not by a dashboard of equal cards. The useful lesson for Samadhi is to keep one centerpiece, place the next action close to it, and make secondary information recede without becoming low contrast.

Sources: https://www.avec.ai/ and https://apps.apple.com/app/id6742199038

## v0 for iOS

Vercel explicitly avoided feature parity with the web product and chose one mobile centerpiece. Native menus, alerts, sheets, keyboard behavior, and a floating Liquid Glass composer do most of the ergonomic work. The team also limits concurrent animation work rather than animating every mounted element. The useful lesson for Samadhi is to reserve glass for controls, use native interaction primitives, and let only one motion system lead at a time.

Source: https://vercel.com/blog/how-we-built-the-v0-ios-app

## Pool

Pool treats screenshots as the content rather than placing them inside heavy interface chrome. Its current release notes emphasize an immediate unified grid, instant content arrival, smoother scrolling, intent-aware actions, a custom icon set, and water-like navigation motion. The useful lesson for Samadhi is that atmosphere should remain content-bearing: the tempo orb, progress ring, and music identity should do real work rather than sit inside generic cards.

Source: https://apps.apple.com/app/id6752956163

## Rauno Freiberg craft filter

Rauno Freiberg’s public standard combines speed, beauty, consistency, care, timelessness, and soul. For this prototype that becomes a concrete review filter: every visual element must either communicate state, enable an action, improve legibility, or carry recognizable brand character. Decorative borders and repeated wordmarks fail that filter.

Source: https://raunofreiberg.me/

## Samadhi rules derived from the review

- One centerpiece per state. During a run it is the tempo orb; on ready it is the collection and Start action.
- No passive cards. Open typography uses an edge-free tonal well for contrast. Glass belongs to tappable controls.
- Every persistent ring is instrumentation. The outer white arc is song progress, not decoration.
- Brand character comes from one small original illustration, not repeated tracked text.
- Motion has a budget. The cover field moves before the run; the orb moves during the run; paused and recovery states freeze.
- Secondary copy remains readable. Reduced prominence comes from scale and spacing, not weak contrast.
- Controls remain at least 44 points, reachable, semantically labeled, and stable when VoiceOver focus enters.
- A state transition should feel like the same object changing jobs, not a new card replacing the last one.

# Brand

## Name

The product is Slipstream. A slipstream is the pocket of moving air behind a runner or rider that pulls you along with almost no effort, which is how the app should feel: you run in the music's slipstream. The word also holds "stream," and it names flow without naming meditation. The public tagline is "music in stride." "In step" is a lowercase run metric, not a second brand.

The app was first called Samadhi, and that stays the name of the repository, the code modules, the bundle identifier, and the folder on the phone that holds its data. Changing that folder or the identifier would cost the phone its only copy of the selected playlist and analysis. Older docs use Samadhi for the same product.

## Color

Two hues come from Phoenix Workbench, and each one means something.

- Lime `#D8F24C` means go and live. It fills the primary action, and it marks the music following the runner: the wheel's center cap, the progress arc, and the word Auto.
- Lilac means the runner took over. It marks Manual and the hold that ends a run. It is `#6E5C9E` on paper and on the hold's fill, and `#B8A9E8` on the dark ground. It is also the sphere in the icon and the mark, where it is identity and carries no state.
- Moss `#566400` stands in for lime on any thin line in light mode, because lime on paper has a contrast of about 1.1 to 1. Lime on paper is only ever a fill with dark text on it.
- The neutrals are Workbench paper `#F4F0E7` with ink `#15170F`, and near-black `#0B0D08` with ink `#F2F1E6`. Both carry a slight green bias so they agree with the lime.

There is no orange, apricot, clay, plum, or olive anywhere. Text and line pairings are held to 4.5 to 1 by `PaletteContrastTests`.

## Dark mode

Setup, recovery, and the summary follow the system appearance. The run screens are always dark, like Apple's Workout app, because lime on black reads at arm's length in sun and the glass has more to bend. Colors are named by role in `SamadhiColor`, so a new screen gets both appearances without extra work.

The field behind every screen is two soft radial lights over the ground, lime low on the left and lilac high on the right, and a still layer of faint noise. They are drawn together at high precision, so the noise lands before the colors are rounded to the display's 8 bits. That is true dithering, and it removes the banding dark gradients otherwise show.

## App icon

The icon is a polished lilac sphere with bold lines of air parting around it and swaying behind it, on a full field of lime. Lilac and lime together are the two brand colors, and the lime field is the loudest thing on a Home Screen. The lines are real flow past a sphere, so it is a literal slipstream, and the wake's left and right sway is the rhythm of a stride.

`Scripts/render-icon.py` draws all three versions from code, so a change is a number and a rerun, and no image model is involved. Light is ink on lime. Dark is lime on near-black. Tinted is a grayscale of the light version. Samay approved it on his phone on 2026-11-05. Every earlier direction is in `Evidence/Brand/`.

## In-app mark

`BrandMark` reduces the icon to one lilac sphere with four bold lines streaming behind it, drawn natively so it stays sharp at 38 points. The lines are lime in dark mode and ink in light mode. Nothing sits ahead of the sphere, because lines wrapped around it read as an eye.

## The playlist map

The signature of the interface is the map a playlist draws of itself. Each song read draws one contour line whose ripple comes from its measured tempo, and the progress line is a string that the same songs pluck. Keep it thin and in the field's own colors. It frames the playlist name and never crosses it.

## The speaker

The tempo wheel is a speaker driver seen head on, under a clear glass lens, with a low light under it. Thin ribs, one domed center cap, and no photo-real detail. It is drawn in the field's own ink so the field stays visible through it, and it pulses only at the music's current tempo. The cap turns lime only when the tempo has matched, so the one bright thing on the screen means something.

## Repository cover

`Brand/GitHub-Cover.png` is the mark, the name, and the tagline over a contour map in the dark palette. The contour tempos in it are illustrative.

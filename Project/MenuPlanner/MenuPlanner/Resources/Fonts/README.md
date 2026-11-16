# App fonts

Onest Medium (500) and SemiBold (600) are used by the `PP / Card`,
`PP / Display`, `PP / Title`, and `PP / Section` styles in Figma.
The other styles use the iOS system font (SF Pro).

The unmodified TTF files come from the official Onest 2.001 release:
https://github.com/simpals/onest/releases/tag/2.001

License: SIL Open Font License 1.1; see `Onest-OFL.txt`.

Xcode includes the fonts through the synchronized MenuPlanner folder.
`Configuration/Info.plist` registers their bundled filenames via `UIAppFonts`
in both Debug and Release. The PostScript names used in `AppFonts` are
`Onest-Medium` and `Onest-SemiBold`.

Use the styles with `.font(AppFonts.title)`, `.font(AppFonts.body)`, etc.
Their sizes scale with Dynamic Type. Figma line heights are layout properties
and are not applied by the font constants.

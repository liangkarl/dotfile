# Fonts

All of these fonts were downloaded from Nerd Fonts

## SauceCodePro

A great font that makes the text easier to recognize due to no extra curve,
underline. The width between each characters is great that you won't feel
pressed if the screen is filled with many text.

https://www.programmingfonts.org/#source-code-pro

## MesloLG

Similar with `SauceCodePro`, but `g` looks more modern and easier to recognize.
The line is thicker and the character is thinner than `SauceCodePro`'s, so it's
recommended to use `S` if you don't want the character become too crowded

https://www.programmingfonts.org/#meslo

### Symbol
- `L` means `Large`
- `M` means `Medium`
- `S` means `Slim` or `Small`
- `DZ` unknown

## SpaceMono

A wider font compared to the previous two, it has classical `g`, 'i', 'r',
and `l`. For the last three characters, it didn't add too much underline
making these characters look like underlined in a word.

https://www.programmingfonts.org/#space

## Split archives

Font ZIP archives are stored in parts of at most 49 MiB to fit GitHub's file
size limits. Run `make install` in this directory to reassemble and install
all of them. To extract an archive manually, for example:

```sh
./merge-archive.sh Meslo.zip
unzip Meslo.zip
```

To split another ZIP archive, run `./split-archive.sh archive.zip`. The script
keeps the original archive; verify the parts before removing it. Existing parts
must be moved or removed before splitting the same archive again.

The merge script checks that parts are consecutive and tests the reconstructed
ZIP before saving it. It refuses to overwrite an existing output; specify an
alternative output path with `./merge-archive.sh Meslo.zip /path/to/output.zip`.

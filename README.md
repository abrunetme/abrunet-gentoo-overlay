# My Gentoo Overlay

This is my personal Gentoo overlay containing adaptations of packages from the [Gentoo Portage Overlays](https://gpo.zugaina.org).

## Adding the Repository

To add this overlay, run the following command:

```sh
eselect repository add abrunet-gentoo-overlay git https://github.com/abrunetme/abrunet-gentoo-overlay.git
```

For more information on managing repositories with `eselect`, see the [eselect/repository](https://wiki.gentoo.org/wiki/Eselect/Repository).

## Usage

1. **Enable the repository** (optional, if not auto-enabled):
   ```sh
   eselect repository enable abrunet-gentoo-overlay
   ```
2. **Sync**:
   ```sh
   emaint sync -r abrunet-gentoo-overlay
   ```
3. **Install packages**:
   ```sh
   emerge <package-name>
   ```

## Customization

Feel free to modify or add packages as needed for your own setup.

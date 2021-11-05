# Barber

Barber is a macOS application to keep track of application updates easily. It lives in your menu bar, and uses homebrew to determine what's outdated and to update. See the [#future](#future) section for planned improvements.

# Contributing

Barber is a work-in-progress (including the name), so contributions are welcome. I use Github projects to keep track of issues and their statuses. I also use [Gitmoji](https://gitmoji.dev/) for commits, but it's not required to contribute.

# Future

My original plan for barber was a simple menu bar app to keep track of updates. However, I realized how nice a GUI for Homebrew would be - something that could actually resemble the ease-of-use of the Mac app store for the average user, but still be customizable for the power-user. To that end, I'd like to see barber become a more general GUI package manager frontend, using (for now) `brew` as a backend, maybe extending to more package managers (`mas`, `npm`, `gem`) in the future. I'd also like to see easy plugin support for new backends and new features.

# Inspirations

I was inspired by a multitude of sources - first and foremost, the original idea for this came from the brilliant [xBar](https://xbarapp.com/) (formerly bitbar) plugin, [`brew-updates`](https://xbarapp.com/docs/plugins/Dev/Homebrew/brew-updates.1h.sh.html). I was also inspired by the Manjaro package manager, `pamac`, which has both a CLI and a GUI, and supports a few different backends including the `pacman` repositories, the AUR, and the Snap/Flatpak stores.


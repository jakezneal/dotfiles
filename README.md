# dotfiles

## Download dotfiles
```sh
cd; curl -L https://github.com/jakezneal/dotfiles/tarball/master | tar -xzv --strip-components 1 --exclude=README.md
```

#### Set sensible macOS defaults
```sh
bash .macos.sh
```

#### Install [Homebrew](http://brew.sh) then use it to install [Git](http://git-scm.com), [Node](http://nodejs.org) and [Brew Cask](http://caskroom.io)
```sh
bash .brew.sh
```

#### Install apps with [Brew Cask](http://caskroom.io)
```sh
bash .cask.sh
```

#### Install global Node modules with [NPM](https://www.npmjs.org)
```sh
bash .npm.sh
```

#### Create standard set of directories
```sh
bash .mkdir.sh
```

#### Clone some GitHub repositories and install misc tools
```sh
bash .misc.sh
```

#### Finally, set some sensible defaults for the installed apps
```sh
bash .init.sh
```

#### Install Atom theme and packages with [APM](https://github.com/atom/apm)
```sh
bash .apm.sh
```

#### To-do
+ Alfred config
+ Further macOS preferences
+ Add additional folders to folder structure

# License
What license!? [WTFPL](http://www.wtfpl.net).

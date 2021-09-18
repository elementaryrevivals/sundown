[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://github.com/watsonprojects/sundown/blob/master/LICENSE)

<p align="center">
<img src="https://raw.githubusercontent.com/watsonprojects/sundown/master/data/com.github.watsonprojects.sundown.svg" alt="logo"> <br>
</p>

<div>
  <h1 align="center">Sundown</h1>
  <h3 align="center"><i>Brightness Adjustment App, written in Vala</i></h3>
</div>

<p align="center">
  <img src="https://raw.githubusercontent.com/watsonprojects/sundown/master/data/screenshot.png" alt="Screenshot"> <br>
</p>

Instead of adjusting the backlight, this app uses `xrandr` to change the brightness of the image displayed on your screen. This can be useful for displays without an adjustable backlight, displays with a too-bright minimum, or too-dark maximum backlight, or OLED displays. Setups with multipe displays (maximum 4 displays) can also be adjusted with different brightness levels.

<!-- ## Install from AppCenter
On elementaryOS simply install Sundown from AppCenter:
<p align="center">
  <a href="https://appcenter.elementary.io/com.github.watsonprojects.sundown">
    <img src="https://appcenter.elementary.io/badge.svg" alt="Get it on AppCenter">
  </a>
</p>

### or -->

## Build and Install manually

These dependencies must be present before building:

* gettext
* libgranite-dev
* libgtk-3-dev
* libgee-0.8-dev
* meson
* valac

<p>You can install these by executing the command:</p>

```
sudo apt install elementary-sdk meson ninja-build libgranite-dev libgee-0.8-dev
```

### Building from source

```
meson build --prefix=/usr
cd build
sudo ninja install
```

### Translation files
```
# after setting up meson build
cd build

# generates pot file
ninja com.github.watsonprojects.sundown-pot

# to regenerate and propagate changes
ninja com.github.watsonprojects.sundown-update-po
```
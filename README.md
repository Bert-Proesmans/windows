# Windows

> Currently running Windows 11

Repository with scripts to get productive ASAP on Windows.

## Goals

* Have an open low privileged windows local account
* Be able to do 99% of the everyday things without requiring admin privileges
* Have a strong password on the administrator local account
* Have latest software updates

## Clean desktop

The most often used applications are pinned to the taskbar (manually).
The icons toolbar is cleaned up (manually) to only show icons that facilitate easy control over my hardware.
The desktop has no content, most of the time, and should only display stuff I'm working on at the moment.

Other files are organized anyway;

* Doctors notes, taxes, identity documents, books => documents library, also backed up to the cloud
* Personal music collection => music library, also backed up to other system
* Sentimental images, desktop/phone wallpapers => images library, also backed up to cloud
* (Old) video projects => videos library, also backed up to other system

At every folder level I keep a simple inbox/archive structure. Almost all files are toplevel where I can quickly see and access them.
When a file/project becomes stale I move the file/folder into the archive folder. Requires minimal thinking.

| ![windows desktop window](/assets/desktop.png) | 
|:--:| 
| *My serene windows desktop. [Click for wallpaper source](https://twitter.com/inapple84/status/1472951312891650049)* |

| ![toplevel music library with recently used data](/assets/toplevel%20music%20library.png) | 
|:--:| 
| *The toplevel directory contents of my music library.* |

| ![archive folder music library with older data](/assets/archive%20folder%20music%20library.png) | 
|:--:| 
| *The archive folder directory contents of my music library. These archive folders also exist within project folders.* |

## Productive browsing experience

I daily drive firefox for browsing, and Progressive Web Apps (PWA's) for app-like experiences for Discord, Outlook Mail, Spotify and diagrams.net.

Firefox still has lots of knobs to tweak and attune to your liking. I've installed a bunch of add-ins and modified the window chrome (removed the horizontal tab bar).
Firefox is in permanent In-Private mode, which means it will remove all history and cookies automatically when the process closes. There are a few websites I keep whitelisted (excluded from automatic removal) for ease of access.

| ![firefox' new tab page](/assets/browser.png) | 
|:--:| 
| *The new tab page in my Firefox browser. I have not found positive netto effect by customizing (modding) the startpage.* |

See [Philosophy](#philosophy) for more explanation about software choices, their configuration, and intended use.

## Windows install

Manual steps.

1. Download Windows 11 IoT LTSC
1. Create installer with Rufus, add installer customizations
    1. Automatically create local admin account
1. Unplug network
1. Launch installer
1. Give entire SSD to install, let it rip
1. Get into the system
1. Set password for local admin account
1. Create user account for everyday use
    1. give it admin privileges (for now)
    1. don't set a password
    1. mark password as "never expire" !
1. Logon to new user
1. Relocate user libraries to other persisted disk
    1. (manually) open each library (documents, music, videos, images) and point them to the corresponding folders on the other disk
1. TODO !! Setup locally managed [mobile device management (MDM)](https://github.com/Bert-Proesmans/simple_mdm)
1. TO DEPRECATE !! Run scripts to configure computer (see .ps1 scripts)
    * The point is to have a single configuration file that is enforced by the local MDM server
1. Verify (and change) computer name
1. Verify (and change) logical drive letters
1. Restart if necessary
1. Plug in network
1. Perform windows activation
1. Proceed to install and configure software/software updates (see winget_install.ps1)
1. Remove Administrator group membership for everyday user account
1. Apply windows updates (if any)
1. Restart computer
1. DONE

## Contents

| Filename | Description |
| --- | --- |
| emergency.ps1 | Windows activation stuff, also edition switching activation, re-arming volume licensing etc
| set_acl.ps1 | The script updates the access control records of the library folders on another disk/partition. **Update the value of variable `$User` and the target paths.**
| set_groups.ps1 | The script adds the user to certain groups for higher privileges. For example, the group "Hyper-V Administrators" allows non-admin users to control hyper-V virtual machines. **Update the value of variable `$User` and the target groups.**
| set_system.ps1 | The script configures basic system behaviour. More info within the script file.
| set_features.ps1 | The script configures windows optional features. More info within the script file.
| windows_appstore_reset.ps | The script performs a cleanup and reset of the windows app store. Useful when your windows channel has no app store application or a broken application.
| winget_install.ps | Installs and updates winget so it's setup and ready as a storefront for the windows app store and the winget package index. The script needs to run with administrator privileges (recommended) to install winget and reset the winget index sources.
| software_install.ps1 | Install software through winget. The script needs to run as the everyday user, with administrator privileges (recommended). More info within script file.
| firefox\*.css | Files to fix Firefox' UI to accommodate my tabs setup.

# Philosophy

## Installed applications

### Twinkle Tray

My monitors are kept at reduced brightness all the time. I started doing this to keep the transmitted light balanced against the ambient lighting. At my desk I'm facing an outside window so my monitor never outshines the incoming atmospheric light. This has a downside that, depending on my activity (gaming, watching films, color sensitive work), the monitor output needs to be brighter.

I had probably changed the brightness manually a thousand times before I figured action HAD to be controllable from software, enter Twinkle Tray!

| ![Twinkle Tray look and feel demo](https://raw.githubusercontent.com/xanderfrangos/twinkle-tray/gh-pages/assets/img/tt-comparison.jpg) | 
|:--:| 
| *Twinkle Tray doesn't like to be screenshotted, so here is the look and feel demo from their code repository.* |

### F.Lux

F.Lux has been installed on my computers since (probably) 2010. All this time I have a permanent tint on my monitors that filter blue light. It's awesome software, literally set-and-forget forever!  
Research coming out since 2018 claims that blue light filters doesn't improve sleep. I'm used to the color shift now, and the automations help me as part of the ritual before going to bed, so I kept using the software.

### ZoomIt

A very late addition to my power toolset (approx since 2020)! I use it to quickly draw and type text on top of my desktop session before taking screenshots. The screenshots are either sent off as-is, or a bit post-processed and go into documentation files.  
As someone who takes professional documentation seriously, this little tool has saved me tens of hours per year!

| ![My desktop with ZoomIt annotations](/assets/zoomit.png) | 
|:--:| 
| *As I'm literally writing the above description, the time it took me to take the screenshot above was below 15 seconds!* |

### Windhawk

The newest tool under my belt since Windows 11's User eXperience (UX) went even more down the drain! Windhawk is an absolutely fantastic tool, made by a very cool developer, to tweak your windows' *anything*.  
My only gripe with it is that opening the main window, and managing plugins, requires administrator permissions. I've talked about this with the dev but that approach has not and is not gonna change in the short term. This is an issue for me because I'm daily driving a low privilege windows account, one without admin privileges and without password. But on the other hand Windhawk is a self-updating set-and-forget tool, so no complaints from me!

### Eartrumpet

I recommend it, very very much. Use it! You'll get used to managing all your audio devices easily and effortlessly and it's a million times better than the whatever the embarrassment is that microsoft puts into windows audio controls.  
This tool is at the same level, or even higher, of usability improvement as Twinkle Tray!

| ![Eartrumpet flyout showing my audio sinks](/assets/eartrumpet.png) | 
|:--:| 
| *Easily control individual output volumes and easily redirect application audio between output sinks? Check!* |

### Teracopy

My brains needs the confirmation that when I copied something from A to B, every bit has been copied correctly! By default, Windows does *not* verify file copies! Anno 2024 this is unacceptable behaviour!  
But thankfully, 3rd party to the rescue which bring a file copy manager that works intuitively and verifies your files are bit for bit OK! It even magically integrates with explorer (if you want it to.)

| ![Teracopy copy history manager](/assets/teracopy.png) | 
|:--:| 
| *Details of the copy information, provided by teracopy, after a succesful file-copy.* |

## Installed software extensions

### Firefox

* Bitwarden Password Manager
* uBlock Origin
* Tree Style Tab
* OneTab
* Consent-O-Matic
    * ~~I still don't care about cookies~~
* Modern for Hacker News

I have the following installed but disabled until I need them;

* eID Belgium
* Let's get color blind
* Canvas capture
* Table Capture
* cookies.txt
* Video DownloadHelper
* CSS Stacking Context inspector
* Ecosia - The search engine
    * I swapped back to google because the underlying engine of ecosia (mostly Bing) returned bad results very often

The following extensions aren't required anymore because they became Firefox native! (Yippeeeee 🎉);

* Firefox containers (built-in, see settings)
* SingleFile (built-in, see contextmenu > Take screenshot)
* [SOON] Tree Style Tab (SOON ™️, at this rate maybe in 2 years**)

** WHY IS IT SO HARD TO JUST IMPLEMENT ONE OF THE MOST POPULAR EXTENSIONS (FOR LITERAL YEARS) IN A NATIVE WAY?

#### Firefox sync

Login to restore extensions, bookmarks, and settings.

#### Firefox user chrome

To remove the topbar, where the browser tabs are located, we have to style the browser windows (the "chrome").
This method is marked as deprecated, but no alternative/better method is currently known.

1. Locate user profile folder
    - about:profiles -> open roaming folder
    - C:\Users\Bert\AppData\Roaming\Mozilla\Firefox\Profiles\*
1. Create folder 'chrome'
1. Copy file userChrome.css into 'chrome' folder
    - C:\Users\Bert\AppData\Roaming\Mozilla\Firefox\Profiles\*\chrome\userChrome.css
1. Enable legacy user modifications
    - about:config -> toolkit.legacyUserProfileCustomizations.stylesheets = true

#### TreeStyleTab

Go into settings and configure the extension like below;

* Style contents for left side
* Theme: Proton
* Disable animation effects
* Add firefox/treestyletab.css into Advanced > User style sheet

### Windhawk

* Better file sizes in Explorer details
* Middle click to close on taskbar
* Show all apps by default in start menu
* Taskbar labels for Windows 11
* Taskbar thumbnail reorder
* Taskbar tray system icons tweaks

## Approaches and configurations

### Windows

#### Hyper-V

Integrated platform for managing and running virtual machines. I do a bunch of development in and for linux so having a VM ready is nice!

See also; [Nix configuration](https://github.com/Bert-Proesmans/nix)

#### Windows containers

Quickly open up a "clean" windows installation for idempotency testing or isolating some quirky code and application behaviour.
Works amazing with custom shortcuts that facilitate data sharing between host and container(-vm).

See also; [Windows container shortcuts](https://github.com/Bert-Proesmans/WindowsSandboxShortcuts)

### Progressive Web Applications (PWA's)

* Discord
    * https://discord.com/
* Outlook live mail
    * https://outlook.live.com/mail/
* Spotify
    * https://open.spotify.com/

Best support is when the website publishes their own PWA manifest (basically an installation config file), but policies and manual "app creation" can be setup by using the above links.

### Windhawk - Better file sizes in explorer

* Don't show folder sizes
* Use MB/GB for larger sizes
* Use IEC terms (KiB instead of KB)

### Windhawk - taskbar tray system icons

* Hide sound icon
* Hide bell icon when there are no new notifications

### Windhawk - taskbar labels

Just a better approach to ungrouped taskbar windows than the default (half-assed) into Windows 11.

```json
{"taskbarItemWidth":120,"runningIndicatorStyle":"centerDynamic","progressIndicatorStyle":"sameAsRunningIndicatorStyle","fontSize":12,"leftAndRightPaddingSize":10,"spaceBetweenIconAndLabel":8,"labelForSingleItem":"%name%","labelForMultipleItems":"[%amount%] %name%","minimumTaskbarItemWidth":50,"maximumTaskbarItemWidth":176}
```

### Flux

Set-and-forget location and earliest wake-up time. Then you can tweak color temperature a bit.  
The icon can be displayed (or use the keyboard shortcuts) to quickly enable/disable the temperature shift.

* Disable when;
    * Using VLC
    * Fullscreen apps (? i toggle this on and off)
* Effects;
    * Use dark mode at sunset
* Options > Transition speed; Very fast
* Options > Tuning;
    * Use display data for better color accuracy
    * Use GPU for better quality with warm colors


| ![Flux temperature settings](/assets/flux%20settings.png) | 
|:--:| 
| *Personal color temperature settings within the F.Lux program.* |

### Zoomit

Disable all modules except for "Draw". To disable a module you set the shortcut to None, AKA click inside the shortcut field and press backspace.

Draw shortcut is keys are [CONTROL]+[2].

### Twinkle Tray

* Monitor settings;
    * Rename monitors; eg "main", "left", "up-right"
    * Reorder monitors, however you like
    * Normalize brightness, equalize lightlevels for locking (see below)
* Main flyout; Tick the chain to sync brightness levels between all monitors

### EarTrumpet

Nothing to configure, but EarTrumpet by default shows all enabled audio devices. You want to disable audio devices you do not use to remove them from the flyout window.

# Misc

## Noise suppression

* https://sourceforge.net/projects/equalizerapo/files/1.3/
* https://github.com/werman/noise-suppression-for-voice

These be my personal nixos configuration files, I didnt test it much so it might break in other systems. <br>
Btw you probably wanna remove the hardware-configuration.nix file before using it yerself <br>

specs:<br>
Editor: nixvim (neovim)<br>
Browser: firefox<br>
Terminal: Kitty<br>
WM: Hyprland<br>
Bar/Launcher/Clipboard/Notifications = Quickshell<br>

Notes:
it's a WIP, the quickshell configuration isn't integrated in my files yet, so you just gotta copy it to ~/.config. <br>
Alsoo some of the modules are kinda broken, specially the one for notifications, im still workin on it <br>

Useful Binds:
SUPER + T = Terminal <br>
SUPER + A = Launcher <br>
SUPER + V = Clipboard <br>
SUPER + B = Notification history <br>
SUPER + N = Screenshot (Region) <br>
SUPER + 1-0  = Change workspace <br>
SUPER + HJKL = Change focus <br>
Control + Esc = Toggle quickshell <br>

Capslock is disabled, holding it activates a layer that makes J and K mimic the left and right mouse buttons respectively. (You can just disable this in configuration.nix, it's the keyd thingie)<br>

Screenshots:
![image](SSes/ss00.webp)
![image](SSes/ss01.webp)
![image](SSes/ss02.webp)
![image](SSes/ss03.webp)
![image](SSes/ss04.webp)
![image](SSes/ss05.webp)

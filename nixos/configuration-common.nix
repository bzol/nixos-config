{ config, pkgs, ... }:

# Everything that is identical between my laptop and desktop is here.
{
  nix.settings.experimental-features = [ "nix-command flakes" ];
  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fi";
  };
  time.timeZone = "Europe/Helsinki";

  environment.systemPackages = with pkgs; [
    # git and firefox so we can easily install home-manager; it will handle the rest
    git
    firefox
  ];
  programs.vim.defaultEditor = true;
  programs.fish.enable = true;

  fonts.fonts = with pkgs; [
    noto-fonts
    liberation_ttf
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Enable sound.
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    windowManager.awesome.enable = true;
    displayManager.defaultSession = "none+awesome";
    desktopManager.xterm.enable = false;
    # disable automatic screen blanking and stuff, we'll do it manually instead
    serverFlagsSection = ''
      Option "BlankTime" "0"
      Option "StandbyTime" "0"
      Option "SuspendTime" "0"
      Option "OffTime" "0"
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bendez = {
    isNormalUser = true;
    home = "/home/bendez";
    description = "bendez";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "realtime"
      "audio"
      "jackaudio"
      "docker"
      "qemu"
      "libvirtd"
    ];
  };

  # yubikey setup
  # also requires ~/.gnupg/gpg.conf from https://github.com/drduh/config/blob/master/gpg.conf
  # and ~/.gnupg/scdaemon.conf with the line `disable-ccid`
  # for gpg-agent and yubico authenticator compatibility
  # (TODO: automate installing these with nix)
  programs.gnupg.agent.enable = true;
  programs.ssh.startAgent = false;
  services.pcscd.enable = true;

  programs.gnupg.agent = {
    pinentryFlavor = "qt";
    enableSSHSupport = true;
  };

  security.pam.yubico = {
    enable = true;
    debug = false;
    mode = "challenge-response";
  };
  security.pam.services.sudo.yubicoAuth = true;
  services.udev.extraRules = ''
    # Yubico YubiKey
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0200|0402|0403|0406|0407|0410", TAG+="uaccess"
    # Teensy rules for the Ergodox EZ
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"
  '';
}

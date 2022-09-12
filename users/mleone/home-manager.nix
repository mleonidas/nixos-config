{ config, lib, pkgs, ... }:

let sources = import ../../nix/sources.nix; in {
  xdg.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # Packages I always want installed. Most packages I install using
  # per-project flakes sourced with direnv and nix-shell, so this is
  # not a huge list.
  home.packages = [
    pkgs.bat
    pkgs.fd
    pkgs.firefox
    pkgs.fzf
    pkgs.feh
    pkgs.git-crypt
    pkgs.htop
    pkgs.jq
    pkgs.lsd
    pkgs.unzip
    pkgs.vivid
    pkgs.awscli2
    pkgs.ripgrep
    pkgs.rofi
    pkgs.file
    pkgs.starship
    pkgs.autojump
    pkgs.stow
    pkgs.tree
    pkgs.watch
    pkgs.aws-vault
    pkgs.zathura
    pkgs.tree-sitter
    pkgs.kubectl
    pkgs.kubectx
    pkgs._1password
    pkgs.go
    pkgs.gopls
    pkgs.zig-master

    pkgs.tlaplusToolbox
    pkgs.tetex
  ];

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
  };

  home.file.".gdbinit".source = ./gdbinit;
  home.file.".inputrc".source = ./inputrc;

  xdg.configFile."zsh/functions".text = builtins.readFile ./zsh/functions;
  xdg.configFile."i3/config".text = builtins.readFile ./i3;
  xdg.configFile.nvim = {
    source = ./nvim;
    recursive = true;
  };
  xdg.configFile."rofi/config.rasi".text = builtins.readFile ./rofi;
  xdg.configFile."devtty/config".text = builtins.readFile ./devtty;

  # tree-sitter parsers
  xdg.configFile."nvim/parser/proto.so".source = "${pkgs.tree-sitter-proto}/parser";
  xdg.configFile."nvim/queries/proto/folds.scm".source =
    "${sources.tree-sitter-proto}/queries/folds.scm";
  xdg.configFile."nvim/queries/proto/highlights.scm".source =
    "${sources.tree-sitter-proto}/queries/highlights.scm";
  xdg.configFile."nvim/queries/proto/textobjects.scm".source =
    ./textobjects.scm;

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.gpg.enable = true;

  programs.rofi  = {
    enable = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = ./theme.rafi;
  };

  programs.bash = {
    enable = true;
    shellOptions = [];
    historyControl = [ "ignoredups" "ignorespace" ];
    initExtra = builtins.readFile ./bashrc;

    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
    };
  };

  programs.direnv= {
    enable = true;

    config = {
      whitelist = {
        prefix= [
          "$HOME/code/go/src/github.com/hashicorp"
          "$HOME/code/go/src/github.com/mleonidas"
        ];

        exact = ["$HOME/.envrc"];
      };
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = lib.strings.concatStrings (lib.strings.intersperse "\n" [
      "source ${sources.theme-bobthefish}/functions/fish_prompt.fish"
      "source ${sources.theme-bobthefish}/functions/fish_right_prompt.fish"
      "source ${sources.theme-bobthefish}/functions/fish_title.fish"
      (builtins.readFile ./config.fish)
      "set -g SHELL ${pkgs.fish}/bin/fish"
    ]);

    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";

      # Two decades of using a Mac has made this such a strong memory
      # that I'm just going to keep it consistent.
      pbcopy = "xclip";
      pbpaste = "xclip -o";
    };

    plugins = map (n: {
      name = n;
      src  = sources.${n};
    }) [
      "fish-fzf"
      "fish-foreign-env"
      "theme-bobthefish"
    ];
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    autocd = true;
    enableCompletion = true;
    shellAliases = {
      pbcopy = "xclip";
      pbpaste = "xclip -o";
      ssh = "ssh -A";
      more = "less";
      vim = "nvim";
      grep = "grep --color";
      tmux = "tmux -2";
      gitpp = "git pull --prune --all";
      gitc = "git commit -m";
      gitp = "git push";
      gss = "git status -s";
      gita = "git add .";
      gitph = "git push origin HEAD";
      sha = "git log | head -1";
      dc = "docker-compose";
      k = "kubectl";
      ls = "lsd";
      l = "ls -lFh";
      la = "ls -lAFh";
      lr = "ls -tRFh";
      ll = "ls -l";
    };

    history = {
      expireDuplicatesFirst = true;
      save = 1000000;
      size = 10000000;
    };

    envExtra =  ''
      source ~/.flowcode/functions/activate
      '';

    initExtra = ''
      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=5'
      export LS_COLORS=$(vivid generate solarized-dark)
      export PATH=$PATH:$HOME/.bin
      source $HOME/.config/zsh/functions
      bindkey -e
      bindkey '^U' backward-kill-line
      bindkey '^Q' push-line-or-edit
      bindkey -s "^L" 'sesh^M'
      eval "$(starship init zsh)"
    '';
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions";}
        { name = "zsh-users/zsh-history-substring-search";}
        { name = "/zdharma-continuum/fast-syntax-highlighting";}
      ];

    };
  };

  programs.git = {
    enable = true;
    userName = "Michael Leone ";
    userEmail = "mike@powertools.dev";
    aliases = {
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
      lgr = "log --oneline --decorate --tags --parents --graph";
      br = "branch";
      co = "checkout";
      lgf = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''%C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
      ci = "commit";
      fl = "log -u";
      dl = "!git ll -1";
      gr = "grep -Ii";
      la = "!git config -l | grep alias | cut -c 7-";
      ir = "reset";
      r1 = "reset HEAD^";
      r2 = "reset HEAD^^";
      rh = "reset --hard";
      rh1 = "reset HEAD^ --hard";
      rh2 = "reset HEAD^^ --hard";
      wip = "commit -m {WIP}";

    };
    extraConfig = {
      branch.autosetuprebase = "always";
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      credential.helper = "store"; # want to make this more secure
      github.user = "mleonidas";
      push.default = "tracking";
      init.defaultBranch = "main";
    };
  };

  programs.go = {
    enable = true;
    goPath = "code/go";
    goPrivate = [ "github.com/powertooldev"];
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    shortcut = "f";
    secureSocket = false;
    keyMode = "vi";
    plugins = with pkgs.tmuxPlugins; [
      tmux-colors-solarized
      pain-control
      vim-tmux-navigator
      dracula
    ];
    extraConfig = ''
      bind-key / split-window -h -c '#{pane_current_path}' # Split panes vertically
      bind-key - split-window -v -c '#{pane_current_path}' # Split panes vertically
      set -g default-terminal "xterm-256color"
      set-option -ga terminal-overrides ",xterm-256color:Tc"
      '';
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERM = "xterm-256color";
      };
      scrolling = {
        multiplier = 1;
      };
      font = {
        size = 11.5;
        antialias = true;
        normal.family = "MesloLGMDZ Nerd Font Mono";
        normal.style = "Regular";
        bold.family = "MesloLGMDZ Nerd Font Mono";
        bold.style = "Bold";
        italic.family = "MesloLGMDZ Nerd Font Mono";
        italic.style = "Italic";
      };

      colors = {
        primary = {
          background = "0x002b36";
          foreground = "0x839496";
	};

	  # Normal colors
      normal = {
        black =   "0x073642";
	    red =     "0xdc322f";
	    green =   "0x859900";
	    yellow =  "0xb58900";
	    blue =    "0x268bd2";
	    magenta = "0xd33682";
	    cyan =    "0x2aa198";
	    white =   "0xeee8d5";
      };

      bright = {
        black =   "0x002b36";
	    red =     "0xcb4b16";
	    green =   "0x586e75";
	    yellow =  "0x657b83";
	    blue =    "0x839496";
	    magenta = "0x6c71c4";
	    cyan =    "0x93a1a1";
	    white =   "0xfdf6e3";
      };
      };
    };
  };

  programs.i3status = {
    enable = true;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
  };

  programs.autojump = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      format = "$kubernetes$aws$python$terraform$line_break$directory$git_branch$git_commit$git_state$git_status$cmd_duration$line_break$character";
      command_timeout = 1000;

      character = {
        error_symbol = "[✖](red) ";
      };

      gcloud = {
        format = "[$symbol$active]($style) ";
        style = "bold yellow";
      };
      aws = {
        format = "[$symbol$profile(\($region\))]($style) ";
        disabled = false;
        style = "#af8700";
        symbol = "🅰 ";
      };

      aws.region_aliases = {
        ap-southeast-2 = "au";
        us-east-1 = "va";
        us-east-2 = "oh";
        us-west-1 = "ca";
        us-west-2 = "or";
      };

      cmd_duration = {
        disabled = true;
        min_time = 500;
        format = "underwent [$duration](bold yellow)";
      };

      terraform = {
        format = "[$version$workspace]($style) ";
        disabled = false;
      };

      git_state = {
        format = "[\($state( $progress_current of $progress_total)\)]($style) ";
        disabled = true;
        style = "#1c1c1c";
        cherry_pick = "[🍒 PICKING](red)";
        progress_divider = " of ";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style))";
        modified = "*";
        style = "#d70000";
      };

      git_branch = {
        style = "#585858";
        format = "[$symbol$branch]($style)";
      };

      directory = {
        truncation_length = 8;
        format = "[$path]($style)[$lock_symbol]($lock_style) ";
        truncation_symbol = ".../";
        style = "blue";
      };

      python = {
        format = "[$symbol$pyenv_prefix$version(\\($virtualenv\\))]($style) ";
        style = "green";
        symbol = "";
      };

      username = {
        style_user = "dimmed blue";
        show_always = false;
      };

      kubernetes = {
        format = "[\\[$context[\\($namespace\\)](bold purple)\\]]($style) ";
        style = "cyan";
        disabled = false;
      };

      kubernetes.context_aliases = {
        ".*arn:aws:eks:(?P<region>\\\\w+-\\\\w+-\\\\d):(?P<account>\\\\d+):cluster/(?P<cluster_name>\\\\w+-\\\\w+).*" = "$region:$account:$cluster_name";
      };

      time = {
        disabled = true;
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "tty";

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
  };

  xresources.extraConfig = builtins.readFile ./Xresources;

  # Make cursor not tiny on HiDPI screens
  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
    x11.enable = true;
  };
}

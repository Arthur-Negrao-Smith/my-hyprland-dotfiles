import os
import sys
import subprocess as sbp
import logging
from datetime import datetime
from pathlib import Path
from enum import Enum

logging.getLogger().setLevel(logging.ERROR)
log: logging.Logger = logging.getLogger(__name__)
LOG_FILE: str = "log.txt"

# ==== CONFIGURATIONS ==== #
HOME: str = os.path.expanduser("~")
XDG_CONFIG_HOME: str = f"{HOME}/.config"

# zsh constants
ZSH_PATH: str = f"{HOME}/.zshrc"
ZSH_BIN: str = "/bin/zsh"

# nvim constants
NVIM_GIT: str = "https://github.com/Arthur-Negrao-Smith/My-nvim-config.git"

# script constants
SCRIPT_FILE: str = os.path.basename(__file__)
SCRIPT_PATH: str = __file__
DRY_RUN: bool = False
USED_STATE_FILE: str = ".configured"

# Assets
ASSETS_PATH: str = "assets"

# sddm constants
SDDM_CONFIG_PATH: str = "/etc/sddm.conf.d"
SDDM_THEMES_PATH: str = "/usr/share/sddm/themes"
SDDM_THEME_TAR_FILE: str = f"{ASSETS_PATH}/sugar-candy.tar.gz"

# hyprpaper constants
WALLPAPER_DIR_PATH: str = f"{HOME}/Pictures/Wallpapers"
DEFAULT_WALLPAPER_ASSET: str = f"{ASSETS_PATH}/default.jpg"
DEFAULT_WALLPAPER: str = f"{WALLPAPER_DIR_PATH}/default.jpg"

# Assets needed
NEEDED_ASSETS: tuple[str, ...] = (
    SDDM_THEME_TAR_FILE,
    DEFAULT_WALLPAPER_ASSET,
)


CONFIG_DIRS: tuple[str, ...] = (
    "hypr",
    "kitty",
    "rofi",
    "waybar",
    "wlogout",
    "zsh",
)

# pacman packages to install
PACMAN_PACKAGES: tuple[str, ...] = (
    "rofi",
    "ripgrep",
    "firefox",
    "flatpak",
    "kitty",
    "nautilus",
    "stow",
    "zsh",
    "nvim",
    "hypridle",
    "sddm",
    "yazi",
    "tar",
    "qt5-graphicaleffects",
    "qt5-quickcontrols2",
    "qt5-svg",
    "jq",
    "sensors",
    "unzip",
    "zip",
    "git",
    "wl-clipboard",
    "brightnessctl",
    "btop",
    "waybar",
    "curl",
    "ttf-cascadia-code-nerd",
    "ttf-0xproto-nerd",
    "hyprshot",
    "xdg-desktop-portal-hyprland",
    "hyprland",
)

# yay packages to install
YAY_PACKAGES: tuple[str, ...] = ("wlogout",)

# flatpaks to install
FLATPAKS: tuple[str, ...] = (
    "com.github.tchx84.Flatseal",
    "com.discordapp.Discord",
    "org.kde.okular",
    "org.pulseaudio.pavucontrol",
    "com.valvesoftware.Steam",
    "com.visualstudio.code",
)


# ==== COLORS ==== #
class Colors:
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    BLUE = "\033[94m"
    RED = "\033[91m"
    GREY = "\033[38"
    RESET = "\033[0m"


# ==== EXIT CODES ==== #
class ExitCodes(Enum):
    SUCCESS = 1
    ALREADY_USED = 2
    INVALID_ARGUMENTS = 3
    NO_PERMISSIONS = 4


# ==== AUX FUNCTIONS ==== #
def script_exit(code: ExitCodes) -> None:
    """
    Exit process with custom codes
    """
    exit(code.value)


def custom_print(msg: str, color: str | None = None, end: str = "\n") -> None:
    """
    Function to colorize the output of print
    """
    if color is None:
        print(f"{Colors.YELLOW}{msg}{Colors.RESET}", end=end)
    else:
        print(f"{color}{msg}{Colors.RESET}", end=end)


def show_command(args: tuple, dry_run: bool) -> None:
    """
    Function to show the bash commands

    Args:
        dry_run (bool): True if 'DRY-RUN' is activated, else show 'RUN'
    """
    command: str = ""
    if dry_run:
        command += "DRY-RUN: "
    else:
        command += f"RUN: "

    command += f"{args[0]} "
    for arg in args[1:]:
        command += f"{arg} "

    log.debug(command)


def run_cmd(
    *args, dry_run: bool = True, shell: bool = False, **kwargs
) -> sbp.CompletedProcess | None:
    """
    Function to run bash commands

    Args:
        args (tuple[str, ...]): All commands to run
        dry_run (bool): True if don't run the command, else runs normally
        shell (bool): True if must use a real shell. Otherwise, use a standard subprocess.
        **kwargs: Extra arguments passed to sbp.run (like input, text, etc.)
    """
    show_command(args, dry_run=dry_run)

    if not dry_run:
        return sbp.run(args, shell=shell, **kwargs)


# ==== FUNCTIONS ==== #
def show_help() -> None:
    """
    Show the script usage
    """
    print(f"""

Usage: {SCRIPT_FILE} [OPTIONS]

Options:
  --run             Run the script in real mode (all changes are made)
  --dry-run         Run the script in simulation mode (no changes made)
  -d, --debug       Active logs and save in the file "{LOG_FILE}"
  -h, --help        Show this help message and exit

Returns:
  {ExitCodes.SUCCESS.value}                 If the script was a success
  {ExitCodes.ALREADY_USED.value}                 If the script has been used previously
  {ExitCodes.INVALID_ARGUMENTS.value}                 If the arguments are invalid
""")


def script_already_used() -> bool:
    file_path: Path = Path(USED_STATE_FILE)

    return file_path.is_file()


def assets_are_available() -> bool:
    """
    Function to verify all assets
    """
    log.info(">>> Verifing the assets available")

    for asset in NEEDED_ASSETS:
        asset_file: Path = Path(asset)
        if not asset_file.is_file():
            log.warning(f"The asset '{asset}' aren't available")
            return False

    return True


def check_assets_availability() -> None:
    if not assets_are_available():
        response: str = (
            input(
                f"The assets aren't available in '{ASSETS_PATH}'. "
                + "Continue configuration without assets? [y/n] "
            )
            .strip()[0]
            .lower()
        )

        if response != "y":
            log.warning(">>> Aborting the configuration script...")
            custom_print("\n>>> No modifications were made")
            script_exit(ExitCodes.SUCCESS)
        else:
            log.warning(">>> Continuing configuration without assets")


def create_config_dirs(dry_run: bool = True):
    """
    Function to create dirs in '~/config'

    Args:
        dry_run (bool): True if don't run the command, else runs normally
    """
    log.info(">>> Creating configuration directories...")

    for dir in CONFIG_DIRS:
        if not dry_run:
            Path(f"{XDG_CONFIG_HOME}/{dir}").mkdir(exist_ok=True)


def update_system(dry_run: bool = True):
    """
    Function to update the system packages

    Args:
        dry_run (bool): True if don't run the command, else runs normally
    """
    log.info(">>> Updating system packages...")
    run_cmd("sudo", "pacman", "-Syu", "--noconfirm", dry_run=dry_run)
    run_cmd("yay", "-Syu", "--noconfirm", dry_run=dry_run)


def install_packages(dry_run: bool = True):
    """
    Function to install packages with pacman and yay

    Args:
        dry_run (bool): True if don't run the command, else runs normally
    """
    log.info(">>> Installing packages from Packman...")
    run_cmd(
        "sudo",
        "pacman",
        "-S",
        "--needed",
        "--noconfirm",
        *PACMAN_PACKAGES,
        dry_run=dry_run,
    )

    log.info(">>> Installing packages from Yay...")
    run_cmd(
        "yay",
        "-S",
        "--needed",
        "--noconfirm",
        *YAY_PACKAGES,
        dry_run=dry_run,
    )

    log.debug("Updating the pacman again")
    update_system(dry_run=dry_run)


def configure_nvim(dry_run: bool = True) -> None:
    log.info(">>> Configuring the nvim...")

    nvim_path = f"{XDG_CONFIG_HOME}/nvim"

    backup_if_exists(nvim_path, dry_run)

    log.info(">>> Cloning the nvim configs...")
    run_cmd(
        "git",
        "clone",
        NVIM_GIT,
    )


def install_flatpaks(dry_run: bool = True) -> None:
    log.info(">>> Installing flatpaks...")
    run_cmd("flatpak", "install", "-y", *FLATPAKS)


def backup_if_exists(target: str, dry_run: bool) -> None:
    """
    Function to create backup to file if it exist

    Args:
        target (str): Path to file
        dry_run (bool): True if don't run the command, else runs normally
    """
    if os.path.exists(target) and not os.path.islink(target):
        log.warning(f"{target} already exists. Creating backup as {target}.bak")

        if not dry_run:
            target_path: Path = Path(target)
            target_path.rename(f"{target}.bak")


def backup_existing_configs(dry_run: bool = True) -> None:
    """
    Function to create backup of original configs files

    Args:
        dry_run (bool): True if don't run the command, else runs normally
    """
    log.info(">>> Checking for conflicts before using stow...")

    for dir in CONFIG_DIRS:
        if dir == "zsh":
            target: str = f"{HOME}/.zshrc"
        else:
            target: str = f"{XDG_CONFIG_HOME}/{dir}"

        backup_if_exists(target, dry_run)


def stow_configs(dry_run: bool = True) -> None:
    """
    Function to create symbolical links

    Args:
        dry_run (bool): True if don't run the command, else runs normally
    """
    log.info(">>> Creating symbolic links with stow...")

    for dir in CONFIG_DIRS:
        run_cmd("stow", dir, dry_run=dry_run)

    run_cmd("stow", "zsh", dry_run=dry_run)
    run_cmd("stow", "nvim", dry_run=dry_run)


def configure_zsh(dry_run: bool = True) -> None:
    """
    Function to configure all zsh plugins
    """
    log.info(">>> Configuring the zsh...")

    log.debug("Configuring the oh-my-zsh")
    run_cmd(
        "sh",
        "-c",
        '"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"',
        dry_run=dry_run,
    )

    log.debug("Configuring the powerlevel10k")
    run_cmd(
        "git",
        "clone",
        "--depth=1",
        "https://github.com/romkatv/powerlevel10k.git",
        '"${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"',
        dry_run=dry_run,
    )


def change_shell_to_zsh(dry_run: bool = True) -> None:
    """
    Function to change the current shell to zsh

    Args:
        dry_run (bool): True if don't run the command, else runs normally
    """
    try:
        log.info(">>> Changing the root shell...")
        run_cmd("sudo", "chsh", "-s", ZSH_BIN, dry_run=dry_run)

        log.info(">>> Changing the current shell...")
        run_cmd("chsh", "-s", ZSH_BIN, dry_run=dry_run)

        log.debug("Source command to load the new configs")
        run_cmd("source", ZSH_PATH, dry_run=dry_run, shell=True)
    except Exception as e:
        log.error(
            f"Error to change the shell: {e}. Try run `chsh -s /bin/zsh` manually."
        )


def configure_sddm(dry_run: bool = True):
    try:
        log.info("Configuring the sddm to login in system...")

        log.debug(
            f"Creating directorys: '{SDDM_CONFIG_PATH}' and '{SDDM_THEMES_PATH}'..."
        )
        if not dry_run:
            Path(SDDM_CONFIG_PATH).mkdir(exist_ok=True)
            Path(SDDM_THEMES_PATH).mkdir(exist_ok=True)

        sddm_file: Path = Path(SDDM_THEME_TAR_FILE)
        if sddm_file.is_file():
            log.debug(f"Writing in file: {SDDM_CONFIG_PATH}/theme.conf")
            config_content: str = "[Theme]\nCurrent=sugar-candy\n"
            run_cmd(
                "sudo",
                "tee",
                f"{SDDM_CONFIG_PATH}/theme.conf",
                dry_run=dry_run,
                input=config_content,
                text=True,
                stdout=sbp.DEVNULL,
            )

            log.debug(
                f"Extracting files from '{SDDM_THEME_TAR_FILE}' to '{SDDM_THEMES_PATH}'..."
            )
            run_cmd(
                "sudo",
                "tar",
                "-xzvf",
                SDDM_THEME_TAR_FILE,
                "-C",
                SDDM_THEMES_PATH,
                dry_run=dry_run,
            )
        else:
            log.warning(
                f"The file '{SDDM_THEME_TAR_FILE}' aren't in dotfiles. No themes will be added to sddm"
            )

        log.debug("Initializing the sddm service")
        run_cmd("systemctl", "enable", "sddm.service", dry_run=dry_run)
    except Exception as e:
        log.error(f"Error to configure the SDDM: {e}.")


def configure_hyprpaper(dry_run: bool = True) -> None:
    log.info(f">>> Creating wallpaper directory {WALLPAPER_DIR_PATH}")

    if not dry_run:
        wallpaper_path = Path(WALLPAPER_DIR_PATH)
        wallpaper_path.mkdir(exist_ok=True)


def save_used_state(dry_run: bool = True):
    """
    Function to create a file to avoid run the script again
    """
    log.info(">>> Add saving a state to don't use this script again")

    run_cmd("touch", USED_STATE_FILE, dry_run=dry_run)


def main(dry_run: bool = True):
    start: datetime = datetime.now()
    log.debug(f"The script starts at: {start}")

    if script_already_used():
        log.error(f"The script has been used previously")
        script_exit(ExitCodes.ALREADY_USED)

    check_assets_availability()

    create_config_dirs(dry_run)

    update_system(dry_run)
    install_packages(dry_run)

    install_flatpaks(dry_run)

    configure_nvim(dry_run)

    backup_existing_configs(dry_run)
    stow_configs(dry_run)

    configure_zsh(dry_run)
    change_shell_to_zsh(dry_run)

    configure_sddm(dry_run)

    configure_hyprpaper(dry_run)

    save_used_state(dry_run)

    finish: datetime = datetime.now()

    log.info(f"""Script Finished:
    Started at {start}
    Finished at {finish}
    Total time: {finish-start}""")
    log.info(f">>> Installation completed successfully! <<<")

    custom_print(
        "\n>>> Type 'start-hyprland' to initilize the Hyprland. (reboot is recomended)"
    )
    script_exit(ExitCodes.SUCCESS)


def parse_args(args: list) -> None:
    """
    Function to parse args and run main function
    """
    if ("-h" in args) or ("--help" in args):
        show_help()
        script_exit(ExitCodes.SUCCESS)

    # test number of arguments
    if len(args) != 2 and len(args) != 3:
        print(args)
        custom_print(
            "Bad usage: Exactly one or two arguments are required.", color=Colors.RED
        )
        show_help()
        script_exit(ExitCodes.INVALID_ARGUMENTS)

    debug_on = False
    dry_run: bool | None = None

    # check the arguments
    for arg in args[1:]:
        if arg == "--dry-run":
            if dry_run is None:
                custom_print("""
######################################################
>>> Dry-run mode enabled. No changes will be made. <<<
######################################################
""")
                dry_run = True

        elif arg == "--run":
            if dry_run is None:
                custom_print(f"""
###################################################
>>> Run mode enabled. All changes will be made. <<<
###################################################
""")
                dry_run = False

        elif (arg == "-d") or (arg == "--debug"):
            debug_on = True

        else:
            custom_print(f"Unknown option: {args[1]}", Colors.RED)
            show_help()
            script_exit(ExitCodes.INVALID_ARGUMENTS)

    if debug_on:
        log_level = logging.DEBUG
    else:
        log_level = logging.INFO

    root: logging.Logger = logging.getLogger()
    # remove previous handlers
    for h in root.handlers[:]:
        root.removeHandler(h)

    # file handler to save the LOG_FILE
    fh: logging.FileHandler = logging.FileHandler(LOG_FILE)
    formatter: logging.Formatter = logging.Formatter(
        "[%(asctime)s] [%(levelname)7s] - %(message)s", datefmt="%Y-%m-%d %H:%M:%S"
    )
    fh.setFormatter(formatter)
    fh.setLevel(log_level)

    # To show stderr
    sh: logging.StreamHandler = logging.StreamHandler()
    sh.setFormatter(formatter)
    sh.setLevel(log_level)

    root.addHandler(fh)
    root.addHandler(sh)
    root.setLevel(log_level)

    if dry_run is None:
        custom_print('The flags "--dry-run" or "--run" are required', color=Colors.RED)
        show_help()
        script_exit(ExitCodes.INVALID_ARGUMENTS)

    elif dry_run:
        log.warning(">>> Dry-run mode enabled. <<<")

    else:
        log.warning(">>> Run mode enabled. <<<")

    main(dry_run=dry_run)  # type: ignore


# ==== RUN ==== #
parse_args(sys.argv)

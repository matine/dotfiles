menu() {
    chirp --title "Menu"

    options=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12")

    chirp --prompt "Please select an option"
    
    while true; do
        chirp --option "1:   Install all the things in order"
        chirp --option "2:   Setup shell (zsh)"
        chirp --option "3:   Setup GIT"
        chirp --option "4:   Install Homebrew"
        chirp --option "5:   Install Homebrew packages"
        chirp --option "6:   Install NPM packages"
        chirp --option "7:   Configure VSCode"
        chirp --option "8:   Configure MacOS"
        chirp --option "9:   Configure Karabiner"
        chirp --option "10:  Configure Wezterm"
        chirp --option "11:  Edit dotfiles files"
        chirp --option "12:  Exit this menu"
        
        read -p "$PS3" choice

        case $choice in
            1)
                chirp --info "Installing all the things in order"
                sh $DOTFILES/scripts/shell.sh
                sh $DOTFILES/scripts/git.sh
                sh $DOTFILES/scripts/homebrew.sh
                sh $DOTFILES/scripts/homebrew-packages.sh
                sh $DOTFILES/scripts/npm-packages.sh
                sh $DOTFILES/scripts/vscode.sh
                sh $DOTFILES/scripts/macos.sh
                sh $DOTFILES/scripts/karabiner.sh
                sh $DOTFILES/scripts/wezterm.sh
                ;;
            2)
                chirp --info "Running the Shell script"
                sh $DOTFILES/scripts/shell.sh || chirp --error "Failed to run the Shell script"
                ;;
            3)
                chirp --info "Running the GIT script"
                sh $DOTFILES/scripts/git.sh || chirp --error "Failed to run the GIT script"
                ;;
            4)
                chirp --info "Running the Homebrew script"
                sh $DOTFILES/scripts/homebrew.sh || chirp --error "Failed to run the Homebrew installation script"
                ;;
            5)
                chirp --info "Running the Homebrew packages script"
                sh $DOTFILES/scripts/homebrew-packages.sh || chirp --error "Failed to run the Homebrew packages script"
                ;;
            6)
                chirp --info "Running the NPM packages script"
                sh $DOTFILES/scripts/npm-packages.sh || chirp --error "Failed to run the (P)NPM packages script"
                ;;
            7)
                chirp --info "Running the VSCode script"
                sh $DOTFILES/scripts/vscode.sh || chirp --error "Failed to run the VSCode configuration script"
                ;;
            8)
                chirp --info "Running the MacOS script"
                sh $DOTFILES/scripts/macos.sh || chirp --error "Failed to run the MacOS configuration script"
                ;;
            9)
                chirp --info "Running the Karabiner script"
                sh $DOTFILES/scripts/karabiner.sh || chirp --error "Failed to run the Karabiner configuration script"
                ;;
            10)
                chirp --info "Running the Wezterm script"
                sh $DOTFILES/scripts/wezterm.sh || chirp --error "Failed to run the Wezterm configuration script"
                ;;
            11)
                chirp --info "Opening dotfiles in VSCode"
                cd $DOTFILES && $EDITOR || chirp --error "Failed to open dotfiles in VSCode"
                ;;
            12)
                chirp --info "Exiting menu" || chirp --error "Failed to exit menu"
                break
                ;;
            *)
                chirp --warn "Invalid option $choice"
                ;;
        esac
    done
}

# Invoke the menu function
menu

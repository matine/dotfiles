menu() {
    chirp --title "Menu"

    options=("1" "2" "3" "4" "5" "6" "7" "8" "9")

    chirp --prompt "Please select an option"
    
    while true; do
        chirp --option "1:   Install all the things in order"
        chirp --option "2:   Symlink all the things"
        chirp --option "3:   Install Homebrew"
        chirp --option "4:   Install Homebrew packages"
        chirp --option "5:   Set default applications to open files"
        chirp --option "6:   Install (P)NPM packages"
        chirp --option "7:   Configure MacOS"
        chirp --option "8:   Edit dotfiles files"
        chirp --option "9:   Exit this menu"
        
        read -p "$PS3" choice

        case $choice in
            1)
                chirp --info "Installing all the things in order"
                sh $DOTFILES/scripts/install.sh || chirp --error "Failed to run the Install script"
                ;;
            2)
                chirp --info "Symlinking all the things"
                sh $DOTFILES/scripts/symlinks.sh || chirp --error "Failed to run the Symlinks script"
                ;;
            3)
                chirp --info "Running the Homebrew script"
                sh $DOTFILES/scripts/homebrew.sh || chirp --error "Failed to run the Homebrew installation script"
                ;;
            4)
                chirp --info "Running the Homebrew packages script"
                sh $DOTFILES/scripts/homebrew-packages.sh || chirp --error "Failed to run the Homebrew packages script"
                ;;
            5)
                chirp --info "Running the Duti script"
                sh $DOTFILES/scripts/duti.sh || chirp --error "Failed to run the Duti script"
                ;;
            6)
                chirp --info "Running the (P)NPM packages script"
                sh $DOTFILES/scripts/npm-packages.sh || chirp --error "Failed to run the (P)NPM packages script"
                ;;
            7)
                chirp --info "Running the MacOS script"
                sh $DOTFILES/scripts/macos.sh || chirp --error "Failed to run the MacOS configuration script"
                ;;
            8)
                chirp --info "Opening dotfiles in VSCode"
                $EDITOR $DOTFILES || chirp --error "Failed to open dotfiles in VSCode"
                ;;
            9)
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

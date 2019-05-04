# git-password-finder

I found this article:  
https://www.zdnet.com/google-amp/article/a-hacker-is-wiping-git-repositories-and-asking-for-a-ransom/  
I know, a lot of time ago I saved username and password in .git/config files locally.  
To find and fix such repos I wrote this tool.

## How to

1. Install Haskell Platform ( https://haskell.org )
2. Clone this repo `git clone https://github.com/DKurilo/git-password-finder.git`
3. Build it with `stack build`
4. Run it with `stack exec -- git-password-finder +RTS -N4 -RTS ~`. You can change `N4` to amount of CPU cores you can use for this tool and `~` to directory where you want to check repos.


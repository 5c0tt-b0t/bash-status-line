# displays only the last 25 characters of pwd

bsl_set_new_pwd() {
    # How many characters of the $PWD should be kept
    local pwdmaxlen=25
    # Indicate that there has been dir truncation
    local trunc_symbol=".."
    local dir=${PWD##*/}
    pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))
    NEW_PWD=${PWD/#$HOME/\~}
    local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))
    if [ ${pwdoffset} -gt "0" ]
        then
            NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
            NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
    fi
}

# the name of the git branch in the current directory

bsl_set_git_branch() {
    unset GIT_BRANCH
    local branch=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1 /'`;
    if test $branch
        then
            GIT_BRANCH="${EMG}git: ${NONE}$branch"
    fi
}

# revision of the svn repo in the current directory

bsl_set_svn_rev() {
    unset SVN_REV
    local rev=`svn info 2> /dev/null | grep "Revision" | sed 's/Revision: \(.*\)/r\1 /'`;
    if test $rev
        then
            SVN_REV="${EMG}svn:${NONE}$rev"
    fi
}

# the name of the activated virtual env

bsl_set_app_env_base() {
    unset APP_ENV_BASE
    local venv=`basename "$APP_ENV"`
    if test $venv
        then
            APP_ENV_BASE="${EMG}env:${NONE}$venv "
    fi
}

bsl_set_ruby_version() {
    unset CURRENT_RVM_RUBY_VERSION
    CURRENT_RVM_RUBY_VERSION="${EMG}rvm: ${NONE}$(~/.rvm/bin/rvm-prompt)"
}

bsl_set_status_line() {
    local lines=`tput lines`
    tput sc
    non_scroll_line=$(($lines - 1))
    scroll_region="0 $(($lines - 2))"
    tput csr $scroll_region

    # Clear out the status line
    tput cup $non_scroll_line 0
    printf "%${COLUMNS}s"
    tput rc

    # Reprint the status line
    tput cup $non_scroll_line 0
    echo -en "${EMB}[${NONE}${NEW_PWD}${EMB}] ${GIT_BRANCH}${SVN_REV}${CURRENT_RVM_RUBY_VERSION} ${APP_ENV_BASE}"
    tput rc
}

bsl_update_status_line() {
    bsl_set_new_pwd
    bsl_set_git_branch
    bsl_set_svn_rev
    bsl_set_ruby_version
    bsl_set_app_env_base
    bsl_set_status_line
}
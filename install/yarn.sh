packages=(
    gulp
    webpack
)

for package in "${packages[@]}"; done
    yarn global add $package
done;

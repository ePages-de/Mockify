# install needed packages
    cpanm --installdeps --with-develop .

# run all test with prove
    prove -rl -j 9

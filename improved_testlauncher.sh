#!/bin/bash
rm containers/app.yml
command=$1
config='app'
opt=$3

# Docker doesn't like uppercase characters, spaces or special characters, catch it now before we build everything out and then find out
re='[A-Z/ !@#$%^&*()+~`=]'
if [[ $config =~ $re ]];
  then
    echo
    echo "ERROR: Config name must not contain upper case characters, spaces or special characters. Correct config name and rerun $0."
    echo
    exit 1
fi

cd "$(dirname "$0")"

docker_min_version='1.6.0'
docker_rec_version='1.6.0'

config_file=containers/"$config".yml
cidbootstrap=cids/"$config"_bootstrap.cid
local_discourse=local_discourse
image=discourse/discourse:1.0.17
docker_path=`which docker.io || which docker`


# 
# 
# 
# Testing run_ruby_file
run_ruby_script() {
  ruby_file=$1
  arguments=$2
  config_full_path="/var/discourse/$config_file"
  ln -sf /var/discourse/$config_file /var/discourse/ruby_scripts/config.yml   # symlink config into docker data volume
  echo `$docker_path run $user_args --rm -i -a stdout -a stdin -v /var/discourse/ruby_scripts:/ruby_scripts $image ruby /ruby_scripts/$ruby_file $arguments`
}

#
#
# testing simple_setup
#
config_variables=(
  DISCOURSE_HOSTNAME
  DISCOURSE_DEVELOPER_EMAILS
  DISCOURSE_SMTP_ADDRESS
  DISCOURSE_SMTP_PORT
  DISCOURSE_SMTP_USER_NAME
  DISCOURSE_SMTP_PASSWORD
)
config_variables_desc=(
  'Domain name'
  "Initial admin and developer email(s)"
  '(email provider) SMTP Address'
  '(email provider) SMTP Port'
  '(email provider) SMTP Username'
  '(email provider) SMTP Password'
)
# Get the config variables
echo "To configure discourse we need a few things from you:"
echo
echo "- The domain name this Discourse instance will respond to, example: discourse.example.org"
echo "- The emails that will be made admin and developer on initial signup, example: 'user1@example.com,user2@example.com'"
echo "- Your email provider configuration. For help, go to https://github.com/discourse/discourse/blob/master/docs/INSTALL-email.md"
echo
for index in ${!config_variables[*]}; do # The indexes of the array
  read -p "${config_variables_desc[$index]}: " ${config_variables[$index]}
  simple_setup_hash+="${config_variables[$index]}, ${!config_variables[$index]},"
done
echo
echo "Bootstrapping app"
echo "This will take between 2 and 8 minutes to complete"

# Copy over the config if it doesn't exist
if [ ! -e $config_file ]; then
  cp 'samples/standalone.yml' containers/"$config".yml
fi

# Install the docker image

# Still NEED TO PUT CODE HERE!


# Run the simple_installer
config_full_path="/var/discourse/$config_file"
run_ruby_script 'simple_setup.rb' "$simple_setup_hash"`

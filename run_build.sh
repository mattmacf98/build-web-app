#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")"; pwd -P)"
cd "$SCRIPTPATH"

echo "making web_app"
ssh -i "~/.ssh/keys/remotebuild.pem" -t ec2-user@"$1" "mkdir web_app"

echo "copying web_app resources"
scp -i "~/.ssh/keys/remotebuild.pem" -r ../web_app/src ec2-user@"$1":/home/ec2-user/web_app/src
scp -i "~/.ssh/keys/remotebuild.pem" -r ../web_app/Cargo.toml ec2-user@"$1":/home/ec2-user/web_app/Cargo.toml
scp -i "~/.ssh/keys/remotebuild.pem" -r ../web_app/config.yml ec2-user@"$1":/home/ec2-user/web_app/config.yml
scp -i "~/.ssh/keys/remotebuild.pem" -r ../web_app/Dockerfile ec2-user@"$1":/home/ec2-user/web_app/Dockerfile

echo "downloading rust"
ssh -i "~/.ssh/keys/remotebuild.pem" -t ec2-user@"$1" << EOF
  curl https://sh.rustup.rs -sSf | bash -s -- -y
  until [ -f ./output.txt ]
  do
      sleep 2
  done
  echo "File Found"
EOF
echo "Rust has been initialized"

echo "logging into Docker"
ssh -i "~/.ssh/keys/remotebuild.pem" -t ec2-user@"$1" << EOF
  echo $3 | docker login --username $2 --password-stdin
EOF

echo "building Rust Docker image"
ssh -i "~/.ssh/keys/remotebuild.pem" -t ec2-user@"$1" << EOF
  cd web_app
  docker build . -t rust_app
  docker tag rust_app:latest mattmacf98/to_do_actix:latest
  docker push mattmacf98/to_do_actix:latest
EOF
echo "web app Docker image built"

echo "copying React app"
rm -rf ../front_end/node_modules/
rm -rf ../front_end/dist/
rm -rf ../front_end/build/
scp -i "~/.ssh/keys/remotebuild.pem" -r ../front_end/ ec2-user@"$1":/home/ec2-user/front_end

echo "installing node on build server"
ssh -i "~/.ssh/keys/remotebuild.pem" -t ec2-user@"$1" << EOF
  curl -o- https:/raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
  . ~/.nvm/nvm.sh
  nvm install --lts
EOF

echo "building front_end on server"
ssh -i "~/.ssh/keys/remotebuild.pem" -t ec2-user@"$1" << EOF
  cd front_end
  docker build . -t front_end
  docker tag front_end:latest mattmacf98/to_do_react:latest
  docker push mattmacf98/to_do_react:latest
EOF
echo "front end docker image built"


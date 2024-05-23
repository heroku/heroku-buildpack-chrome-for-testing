STACK=$1
BASE_IMAGE="heroku/${STACK/-/:}-build"
docker build --progress=plain --build-arg="STACK=$STACK" --build-arg="BASE_IMAGE=$BASE_IMAGE" -t heroku-buildpack-chrome-for-testing .
docker run heroku-buildpack-chrome-for-testing

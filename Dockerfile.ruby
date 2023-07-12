FROM cimg/ruby:3.1

#RUN useradd -m circleci
USER circleci

RUN sudo apt-get update && sudo apt-get install -y vim

RUN gem install linkeddata

WORKDIR /data/testdata
